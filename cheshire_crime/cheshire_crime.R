# https://towardsdatascience.com/plotting-a-map-of-london-crime-data-using-r-8dcefef1c397

library(tidyverse)
library(here)



# load in the data --------------------------------------------------------
setwd(here("data"))

# empty containers to store all data
crime_data <- NULL
search_data <- NULL

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
  if(!is.null(crime_data)){
    crime_data <- rbind(crime_data, crime)
  } else {
    crime_data <- crime
  }
  
  # store stop & search data
  if(!is.null(search_data)){
    search_data <- rbind(search_data, search)
  } else {
    search_data <- search
  }
  
}
setwd(here())


