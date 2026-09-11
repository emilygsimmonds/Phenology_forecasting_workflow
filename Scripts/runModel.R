# =============================================================================
# This script takes the nimble code in 'modelCode.R' and the data output from
# 'combineData.R', compiles the model and runs an MCMC sampler to get posterior
# estimates of all unknown parameters. 
# -----------------------------------------------------------------------------
#
# Author: Emily G. Simmonds, 07.09.26
# =============================================================================


################################################################################
# Set up #
################################################################################

# load packages

library(nimble)
library(nimbleEcology)
library(tidyverse)
library(MCMCvis)

# load scripts

source('./Scripts/modelCode.R')

# import data

combinedData <- read.csv("./Data/combinedData.csv")

# remove NAs

combinedData <- filter(combinedData, elevation > 0)


################################################################################
# Model set up #
################################################################################

# first set up the running parameters
niter <- 500000 # number of iterations
nburnin <- niter*0.4 # amount of burn in
nchains <- 2 # number of chains
nthin <- 1 # a thinning parameter if needed
seed <- 1:nchains # set a seed for each chain

# create an extra dataframe with unique years and a given index
yearIndex <- data.frame(yearIndex = 1:length(unique(combinedData$year)),
                        year = unique(combinedData$year))

# join the datasets
combinedData2 <- combinedData %>%
  left_join(yearIndex, by = join_by(year))

constants <- list(N = length(combinedData2$doy), # sample size
                  nYear = length(yearIndex$year), # number of years
                  yearMarker = combinedData2$yearIndex) # index of years relevative to nYear

set.seed(2026)

# set inits based on the priors for each parameter
inits <- list(beta0 = rnorm(1, 0, sd = 10000), # intercept
              betaTemperature = rnorm(1, 0, sd = 10000), # effect of temperature on flowering
              betaSpace = rnorm(1, 0, sd = 1000), # effect of latitude
              betaElevation = rnorm(1, 0, sd = 1000), # effect of elevation
              # should think about including species and phylogeny
              sigmaYear = runif(1, 0, 1000), # sd of random effect of year
              sigma = runif(1, 0, 1000)) # sd of residual error

parametersToMonitor = c("beta0",
                        "betaTemperature", 
                        "betaSpace",
                        "betaElevation",
                        "sigmaYear",
                        "sigma")

dataInput = list(Y = combinedData2$doy,
                 temperature = combinedData2$temperature,
                 latitude = combinedData2$lat,
                 elevation = combinedData2$elevation)


################################################################################
# Compile and run the model #
################################################################################

# First build the model in R

rModel <- nimbleModel(code = code, 
                      data = dataInput, 
                      constants = constants, 
                      inits = inits)

# then compile in C
cModel <- compileNimble(rModel) 

# then configure the sampler
conf <- configureMCMC(rModel, 
                      monitors = parametersToMonitor) 

# build MCMC in R
rMCMC <- buildMCMC(conf) 

# compile MCMC in C
cMCMC <- compileNimble(rMCMC, 
                       project = rModel) 

# run the model
modelRun <- runMCMC(cMCMC, 
                    niter = niter, 
                    nburnin = nburnin, 
                    thin = nthin, 
                    nchains = nchains, 
                    setSeed = seed)

# save the output
saveRDS(modelRun, "./Data/modelRun.rds")



