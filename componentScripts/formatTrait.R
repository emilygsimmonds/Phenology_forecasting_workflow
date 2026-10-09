# =============================================================================
# This component takesa trait data file and reformats it to be used with 
# climate data such as Chelsa.

# Inputs = 
# - file of traitData, including date, longitude, latitude
# - a vector of the months of interest as numbers (months)
# - a vector of the years of interest as numbers and full year XXXX (years)

# Reformatting = 
# subsets data to focal years and months
# renames longitude and latitude to match input for Chelsa
# checks date columns

# Output = 
# trait data file will all columns
# shorter Chelsa input file with just date, lon, lat
# -----------------------------------------------------------------------------
#
# Author: Emily G. Simmonds added 2026-10-09
# =============================================================================


################################################################################
# Set up #
################################################################################

# might need to be made into a function e.g. plantTraitFormat <- function(traitData, months, years)
# load any necessary packages ####

library(tidyverse)
library(terra)

# trait data

# first step - rename the trait data latitude and longitude columns
markerLat <- grep("latitude", tolower(colnames(traitData)))
markerLon <- grep("longitude", tolower(colnames(traitData)))
colnames(traitData)[c(markerLon, markerLat)] <- c("lon", "lat")

# second step - round the lat and lon to 2 decimal places
traitData <- traitData %>%
  mutate(lon = round(lon, 2),
         lat = round(lat, 2))

# third step - subset to just the months and years of interest
formattedTraits <- filter(traitData, month >= min(months) & month <= max(months),
                         year >= min(years) & year <= max(years))

# forth step - output the finished whole dataframe
write.csv(formattedTraits, "formattedTraits.csv", row.names = FALSE)

# final step - output Chelsa Extractor inputs
chelsaExInputs <- formattedTraits[,c("year", "lon", "lat")]
write.csv(chelsaExInputs, "chelsaExInputs.csv", row.names = FALSE)