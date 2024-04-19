## code to prepare `individual` dataset goes here
## Setup ----
library(dplyr)
source(here::here("R", "geolocate.R"))

## Combine individual tables ----
## Create paths to inputs
raw_data_path <- here::here("data-raw",
                            "wood-survey-data-master")
individual_paths <- paths <- fs::dir_ls(
  fs::path(raw_data_path, "individual")
  )

individual <- purrr::map(.x = individual_paths,
                         ~ readr::read_csv(.x, 
                                           col_types = readr::cols(.default = "c"),   # character type columns
                                           show_col_types = FALSE)) %>% 
  purrr::list_rbind() %>% 
  readr::type_convert()     # convert to proper types (will guess appropriate type based on first 1000 rows)

# save this as an 'intermediate' raw dataset - just the raw data in one big file
individual %>% 
  readr::write_csv(
    file = fs::path(raw_data_path, "vst_individuals.csv")
  )

## Combine NEON data tables ----
# read in additional tables
maptag <- readr::read_csv(
  fs::path(raw_data_path, "vst_mappingandtagging.csv")
) %>% 
  select(-eventID)
perplot <- readr::read_csv(
  fs::path(raw_data_path, "vst_perplotperyear.csv"),
  show_col_types = FALSE
) %>% 
  select(-eventID) 

# Left join tables to individual
individual %<>%   
  left_join(maptag, by = "individualID",
            suffix = c("", "_map")) %>%      
  left_join(perplot, by = "plotID",
            suffix = c("", "_ppl")) %>% 
assertr::assert(         
  assertr::not_na, stemDistance, stemAzimuth, pointID,   
  decimalLatitude, decimalLongitude
)

# Geolocate individuals ----
individual <- individual %>% 
  mutate(
    stemLat = get_stem_location(
      decimalLongitude, decimalLatitude,
      stemAzimuth, stemDistance
    )$lat,
    stemLong = get_stem_location(
      decimalLongitude, decimalLatitude,
      stemAzimuth, stemDistance
    )$lon,
  ) %>% 
  janitor::clean_names()   # this will put the column names into 'snake case' - no capitals, words separated by underscores

# Save analytical dataset ----
fs::dir_create("data")
individual %>% 
  readr::write_csv(
    here::here("data", "individual.csv")
  )

usethis::use_data(individual, overwrite = TRUE)
