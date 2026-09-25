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
  
# Part 3: Generate standardised outputs
  
  # Flatten the 3-D prediction array to a long data frame
  predictionsFlat <- array2DF(predictions)
  colnames(predictionsFlat) <- c("uncertainty_component", "site_id", "datetime", "prediction")
  
  halimium_predictions$datetime <- factor(halimium_predictions$datetime)
  levels(halimium_predictions$datetime) <- paste0(seq(year_before_pred + 1, year_before_pred + n.years.pred),
                                                  "-05-20 18:00:00")  # fixed survey date within each year
  halimium_predictions$datetime <- as.character(halimium_predictions$datetime)
  
  # Attach metadata columns required by the standard forecast format
  halimium_predictions$project_id         <- "donana_forecast_V1"
  halimium_predictions$model_id           <- "demo_Nmix"
  halimium_predictions$forecast_type      <- "temporal"
  halimium_predictions$reference_datetime <- paste0(year_before_pred, "-05-20 18:00:00")
  halimium_predictions$duration           <- "P1Y"   # ISO 8601: 1-year forecast horizon
  halimium_predictions$species            <- "Halimium halimifolium"
  halimium_predictions$family             <- "sample"  # each row is a single posterior draw
  # Variable name flags this as the autoregressive baseline with no covariate
  halimium_predictions$variable           <- "abundance_rpois"
  
  # Reorder columns to match the standard submission schema
  halimium_predictions <- halimium_predictions[, c("project_id", "model_id", "forecast_type",
                                                   "datetime", "reference_datetime", "duration",
                                                   "site_id", "species", "family",
                                                   "uncertainty_component", "variable", "prediction")]
  
  
  
  
}










