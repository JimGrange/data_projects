# https://towardsdatascience.com/plotting-a-map-of-london-crime-data-using-r-8dcefef1c397
# https://maximilianrohde.com/posts/2021-01-06-gganimatemap/
# https://gganimate.com/articles/gganimate.html
# https://www.youtube.com/watch?v=a--t9eppDqI

library(tidyverse)
library(here)
library(ggmap)
library(mapproj)
library(gganimate)

# load in the data --------------------------------------------------------
setwd(here("data"))

# empty containers to store all data
crime_data_raw <- NULL
search_data_raw <- NULL

# get a list of all data folders & remove leading ./
folder_names <- list.dirs('.', recursive = FALSE)
folder_names <- gsub(
  pattern = ('./'), 
  replacement = '', 
  x = folder_names, 
  fixed = TRUE
)

# loop over each
for(i in 1:length(folder_names)){
  
  # change working directory
  setwd(here(paste("data/", folder_names[i], 
                   sep = "")))
  
  # get the crime data files
  crime <- list.files() %>% 
    str_subset(pattern = "street") %>% 
    read_csv(col_types = cols())
  
  # get the stop & search data
  search <- list.files() %>% 
    str_subset(pattern = "search") %>% 
    read_csv(col_types = cols())
  
  # store crime data
  if(!is.null(crime_data_raw)){
    crime_data_raw <- rbind(crime_data_raw, crime)
  } else {
    crime_data_raw <- crime
  }
  
  # store stop & search data
  if(!is.null(search_data_raw)){
    search_data_raw <- rbind(search_data_raw, search)
  } else {
    search_data_raw <- search
  }
  
}
setwd(here())

crime_data <- crime_data_raw %>% 
  select(month = Month, 
         longitude = Longitude, 
         latitude = Latitude, 
         crime = `Crime type`) %>% 
  mutate(year = str_extract(month, pattern = "[^-]+")) %>% 
  mutate(crime = fct_lump(crime, n = 5)) %>% 
  fct_recode(crime, theft = "Other theft")






# get nantwich map --------------------------------------------------------

nantwich_map <- get_map(location = c(-2.524, 53.067), 
                        zoom = 14, 
                        maptype = "roadmap")

considered_crime <- crime_data %>%
  filter(crime == "Drugs")

# anim <- ggmap(nantwich_map) + 
#   geom_point(data = considered_crime, 
#              aes(x = longitude, 
#                  y = latitude), 
#              size = 5, 
#              colour = "red", 
#              alpha = 0.2) + 
#   labs(title = considered_crime$year) + 
#   transition_states(considered_crime$year, 
#                     transition_length = 2, 
#                     state_length = 1) + 
#   shadow_mark(color = "black")
# 
# 
# animate(anim, 
#         nframes = 300, 
#         fps = 20)

ggmap(nantwich_map) + 
  stat_density2d(aes(x = longitude, 
                     y = latitude), 
                 alpha = 0.4, 
                 bins = 10, 
                 data = crime_data, 
                 geom = "polygon") + 
  facet_wrap(crime, ncol = 2)
