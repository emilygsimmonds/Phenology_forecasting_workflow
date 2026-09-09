# =============================================================================
# This script holds the nimble code for a linear mixed effects model of 
# flowering phenology as a function of temperature, latitude, and elevation. 
#
# The model includes a random effect of year. 
# -----------------------------------------------------------------------------
#
# Author: Emily G. Simmonds, 07.09.26
# =============================================================================


################################################################################
# Set up #

# load packages

library(nimble)
library(nimbleEcology)

################################################################################

## define the model
code <- nimbleCode({
  
  # set up priors for the covariate effects
  
  beta0 ~ dnorm(0, sd = 10000) # intercept
  betaTemperature ~ dnorm(0, sd = 10000) # effect of temperature on flowering
  betaSpace ~ dnorm(0, sd = 1000) # effect of latitude
  betaElevation ~ dnorm(0, sd = 1000) # effect of elevation
  # should think abotu including species and phylogeny
  sigma_year ~ dunif(0, 1000) # sd of random effect of year
  sigma ~ dunif(0, 1000) # sd of residual error
  
  for (i in 1:N) { # N = sample size
    
    # year effect
    yearEffect[i] ~ dnorm(0, sd = sigma_year)
    
    # linear predictor
    mu[i] <- beta0 + betaTemperature * temperature[i] + 
                     betaSpace * latitude[i] +
                     betaElevation * elevation[i] +
                     yearEffect[i]
    
    # random part
    Y[i] ~ dnorm(mu[i], sd = sigma)
    
  }
})