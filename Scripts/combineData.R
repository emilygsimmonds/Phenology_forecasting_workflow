# =============================================================================
# This script imports the trait data and climate data. 
# It then reduces both to complete entries (removes missing data) and combines
# to a single working file. 
# -----------------------------------------------------------------------------
#
# Author: Emily G. Simmonds added 2026-09-09
# =============================================================================


################################################################################
# Set up #
################################################################################

# source functions ####

source('./Functions/get_chelsa.R')


# load packages ####

library(tidyverse)
library(terra)

# import data ####

# trait data

traitData <- read.csv('./Data/lm2_traits_with_metadata.csv')
colnames(traitData) <- 
  c(colnames(traitData[,1:7]), "lat", "lon",
    colnames(traitData[,10:22]))

traitData <- traitData %>%
  mutate(lon = round(lon, 2),
         lat = round(lat, 2))

# climate data

climateData <- readRDS("./Data/climateData.rds")
climateDataFuture <- readRDS("./Data/climateDataFuture.rds")

################################################################################
# Reduce trait data and combine #
################################################################################

# keep only the initial variables needed: species, year, doy, decimalLatitude,
# decimalLongitude, elevation

# also remove any trait records with no climate data - will do this as a map
# function

# make trait data a list same length as climate

# make the dataframe a list of rows
# will filter to only include months 5 - 8
traitData2 <- filter(traitData, month >= 5 & month <= 8) # removes 42 and NAs
listTraitData <- split(traitData2, row(traitData2))


combinedData <- map2(.x = listTraitData, .y = climateData, ~{
  
  if(length(sum(dim(.y)) > 0)){
    # do some checks
    check1 <- .y[1,]$lon == .x$lon
    check2 <- .y[1,]$lat == .x$lat
    check3 <- .y[1,]$year == .x$year
    
    if(sum(c(check1, check2, check3)) == 3){ # if all checks passed, then progress
      combinedData <- .x %>% select(species, 
                                    year, 
                                    doy, 
                                    lat, 
                                    lon, 
                                    elevation) %>%
      mutate(temperature = mean(.y$value))
      return(combinedData)}
    
  }else{return(NULL)}
  
}) %>% compact() %>% bind_rows()


# now save out the combined data

write.csv(combinedData, "./Data/combinedData.csv", row.names = FALSE)
