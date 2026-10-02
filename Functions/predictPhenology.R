# =============================================================================
# This script holds the function 'predictPhenology.R' it takes posterior samples
# from a nimble model combined with location, elevation, and predicted temperature
# and predicts future phenology dates for the focal plants. 
#
# There are three parts:
#   1. Prepare data for predictions (subsample the poster samples of parameters)
#   2. Generate forecasts (forward simulation using all parameters)
#   3. Generate standardised outputs (following standard practice/guidelines)
#
# Arguments:
#   predYears - years to be predicted
#   paramFilename - filename and path for posterior samples of parameters
#   predData - datafile needed for prediction
#   nDraws - number of samples to take
#
# -----------------------------------------------------------------------------
#
# Author: Emily G. Simmonds, 11.09.26
# =============================================================================


################################################################################
# Set up #
################################################################################

# load packages 
library(tidyverse)

predictPhenology <- function(predYears,
                             paramFilename,
                             predData,
                             nDraws){

################################################################################
# Part 1: Prepare data for predictions 
  
  # load the posterior samples
  sampledParameters <- readRDS(paramFilename) 
  
  # ideally re-format into one single long list of samples
  sampledParametersTogether <- bind_rows(as.data.frame(sampledParameters[[1]]),
                                         as.data.frame(sampledParameters[[2]]))
  
  # Draw 1000 random samples from the pooled posterior to propagate
  # parameter uncertainty through the forecasts
  subsampledParameters <- apply(sampledParametersTogether, 2, sample, 
                                size = nDraws,
                                replace = FALSE) 
  # this is done for each column, which is a different parameter
  
# Part 2: Generate forecasts
  
  # need to save into an array [draws, year, location]
  predictions <- array(NA, c(nDraws, length(predYears), length(predData[,1])))
  yearEffect <- rep(NA, length(predYears))
  
  # then create a loop to generate the predictions
  
  for(i in 1:nDraws){
  
    # first pull year effects for these new years assuming same distribution
    for (j in 1:length(predYears)) {
    
    # year effect
    set.seed(j)
    yearEffect[j] <- rnorm(1, 0, sd = subsampledParameters[i, "sigmaYear"])
    
    # then loop over the data
    for (k in 1:length(predData[,1])) { 
    
    # linear predictor
    mu <- subsampledParameters[i, "beta0"] + 
      (subsampledParameters[i, "betaTemperature"] * predData$temperature[k]) + 
      (subsampledParameters[i, "betaSpace"] * predData$lat[k]) +
      (subsampledParameters[i, "betaElevation"] * predData$elevation[k]) +
      yearEffect[j]
    
    # random part
    predictions[i,j,k] <- rnorm(1, mu, sd = subsampledParameters[i, "sigma"])
    
    }}}
  
return(predictions)
  
  
}










