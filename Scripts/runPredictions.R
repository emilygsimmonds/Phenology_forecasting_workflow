# =============================================================================
# This script takes the prediction data set and generates predictions using the
# 'predictPhenology.R' script
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

# import data

predictionData <- read.csv("./Data/predictionData.csv")


################################################################################
# run prediction #
################################################################################

predictions <- predictPhenology(predYears = unique(predictionData$year),
                 paramFilename = "./Data/modelRun.rds",
                 predData = predictionData,
                 nDraws = 100)



