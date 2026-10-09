# =============================================================================
# This script takes two inputs, formatted trait data (formattedTrait) and 
# the climate data (climateData)
# from chelsa. It then combines them by taking the mean temperature for each 
# spatial location. 

# The output is a datafile with all trait data and a temperature variable. 
# -----------------------------------------------------------------------------
#
# Author: Emily G. Simmonds added 2026-09-09
# =============================================================================


################################################################################
# Set up #
################################################################################

# load packages ####

library(tidyverse)
library(terra)

################################################################################
# Reduce trait data and combine #
################################################################################

# first step: remove any trait records with no climate data 

listTraitData <- split(formattedTrait, row(formattedTrait))


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
