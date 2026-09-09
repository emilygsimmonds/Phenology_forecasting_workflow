# =============================================================================
# This script imports the trait data and uses that to define the time and space
# extent to pull the chelsa data for. Then uses the get_chelsa function to pull 
# climate data. 
# -----------------------------------------------------------------------------
#
# Author: Emily G. Simmonds added 2026-08-05
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


################################################################################
# Time and space extents #
################################################################################

# take the min and maximum years and min and max long and lat

temporalExtent <- range(traitData$year)
spatialExtent <- c(range(traitData$Latitude),
                   range(traitData$Longitude))


################################################################################
# Pull climate data #
################################################################################

# pull data for each point rather than as a RASTER. Can do this with map.
# ideally want to pull data only for the year in which the event happened
# this will help save computation time. 

# to choose which months of the year to take data for, need to look at 
# distribution of timings. 
summary(traitData)

# seem to cover a huge range from 2nd to 12th month but most around month 7-8.
length(which(traitData$month < 5)) # 7
length(which(traitData$month > 8)) # 35

# will filter to only include months 5 - 8
traitData2 <- filter(traitData, month >= 5 & month <= 8) # removes 42 and NAs

# make the dataframe a list of rows
listTraitData <- split(traitData2, row(traitData2))


##### NOTE! actually only need the data in the year of the event and likely only
# in the months preceding the event for now. 

climateData <- map(listTraitData, ~{
  get_chelsa(coords = as.data.frame(.x[,c("lon",
                                          "lat")]),
             vars = "tasmin",
             source = c("present"),
             start = as.Date(paste0(.x$year,"-01-01")), # using custom dates for now
             end = as.Date(paste0(.x$year + 1,"-01-01")),
             #start = as.Date(paste0(temporalExtent[1],"-01-01")),
             #end = as.Date(paste0(temporalExtent[1]+1,"-01-01")),
             months = c(5:8), # taking months 5-8 for all
             to_celsius = TRUE,
             output_dir = NULL,
             id_col = NULL,
             verbose = TRUE)
  
})

# save out
saveRDS(climateData, "./Data/climateData.rds")  
