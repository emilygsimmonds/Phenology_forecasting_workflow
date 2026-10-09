# =============================================================================
# This script takes as inputs: 
# - the output of the phenology model (phenoModel)
# - a prediction dataset for different years to the dataset used for the model (predictionData)
# - the number of draws to take from the posterior (nDraws). 
# It subsamples the model posterior results and then generates a prediction for 
# each supplied location and time. The output is currently a raw array of 
# predictions but can be refined to match required format. Predictions 
# generated using the 'predictionCode.R' script
# -----------------------------------------------------------------------------
#
# Author: Emily G. Simmonds, 02.10.26
# =============================================================================


################################################################################
# Set up #
################################################################################

# load packages

library(tidyverse)

# load scripts

source('./Functions/predictPhenology.R')


################################################################################
# run prediction #
################################################################################

predictions <- predictPhenology(predYears = unique(predictionData$year),
                                phenoModel = phenoModel,
                                predData = predictionData,
                                nDraws = nDraws)



