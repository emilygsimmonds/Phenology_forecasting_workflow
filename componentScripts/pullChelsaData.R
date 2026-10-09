# =============================================================================
# This script takes input of a file of year, latitudes, and longitudes (chelsaExInputs), 
# and a vector
# of focal months (months) and any prediction years (predYears)
# and uses that to define the time and space
# extent to pull the chelsa data for. Then uses the get_chelsa function to pull 
# climate data. 

# 
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

################################################################################
# Pull climate data from Chelsa #
################################################################################

# first check if prediction years have been specified

if(!is.null(predYears)){ # if it is specified - re create data to have those years
  chelsaExInputs <- map(as.list(predYears), ~{
    chelsaExInputs <- chelsaExInputs %>%
      mutate(year = .x) 
  }) %>% 
    bind_rows()
}

# split input data into list
listchelsaExInputs <- split(chelsaExInputs, row(chelsaExInputs))

# then run the extraction using map
climateData <- map(listchelsaExInputs, ~{
  get_chelsa(coords = as.data.frame(.x[,c("lon",
                                          "lat")]),
             vars = "tasmin",
             source = c("present"),
             start = as.Date(paste0(.x$year,"-01-01")), # using date for each species
             end = as.Date(paste0(.x$year + 1,"-01-01")),
             months = c(months), # taking for specified months
             to_celsius = TRUE,
             output_dir = NULL,
             id_col = NULL,
             verbose = TRUE)
  
})

# save out
saveRDS(climateData, "./Data/climateData.rds")  