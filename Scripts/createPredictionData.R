# =============================================================================
# This script imports the trait data and climate data for future predictions
# and combines those files into a single prediction dataframe. 
# -----------------------------------------------------------------------------
#
# Author: Emily G. Simmonds added 2026-09-25
# =============================================================================


################################################################################
# Set up #
################################################################################

# source functions ####


# load packages ####

library(tidyverse)

# import data ####

# trait data

combinedData <- read.csv("./Data/combinedData.csv") %>%
  filter(elevation > 0) # remove any NAs in elevation

predictionYears <- (max(combinedData$year) + 1) : 2025


# climate data

climateDataFuture <- readRDS("./Data/climateDataFuture.rds")

# remove entry at index 201 as it is totally empty
climateDataFuture <- climateDataFuture[-201]
combinedData <- combinedData[-201,]

################################################################################
# Combine #
################################################################################


listTraitData <- split(combinedData, row(combinedData))

# for now - just predict for a single year

# outer loop over years
  
predictionData <- map2(.x = listTraitData, .y = climateDataFuture, ~{
  
  .y2 <- filter(.y, year == 2024)
  
  # extra check that there is sufficient data - should be 246 entries will accept > 240
  if(length(.y[,1]) > 240){
  
  if(length(sum(dim(.y2)) > 0)){
    # do some checks
    check1 <- .y2[1,]$lon == .x$lon
    check2 <- .y2[1,]$lat == .x$lat
    
    if(sum(c(check1, check2)) == 2){ # if all checks passed, then progress
      predictionData <- .x %>% select(species, 
                                    doy, 
                                    lat, 
                                    lon, 
                                    elevation) %>%
        mutate(temperature = mean(.y2$value),
               year = mean(.y2$year))
      return(predictionData)}
    
  }else{return(NULL)}}else{return(NULL)}
  
}) %>% compact() %>% bind_rows() # compact removes NULL



# now save out the combined data

write.csv(predictionData, "./Data/predictionData.csv", row.names = FALSE)
