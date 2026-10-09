# script that sets all inputs needed for the workflow - allows testing

traitData <- read.csv('./Data/lm2_traits_with_metadata.csv')

months <- 5:8

years <- sort(unique(traitData$year))[-170] # remove 2025
