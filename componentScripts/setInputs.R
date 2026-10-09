# script that sets all inputs needed for the workflow - allows testing

# component 1

traitData <- read.csv('./Data/lm2_traits_with_metadata.csv')

months <- 5:8

years <- sort(unique(traitData$year))[-170] # remove 2025

# component 2

chelsaExInputs <- read.csv("chelsaExInputs.csv")

predYears <- NULL

# component 3

formattedTraits <- read.csv("formattedTraits.csv")

climateData <- readRDS('climateData.rds')

# component 4

combinedData <- read.csv("combinedData.csv")

niter <- 100000
nburnin <- niter*0.4
nchains <- 2
nthin <-  10

# component 5 

predictionData <- read.csv("predictionData.csv")
nDraws = 1000
phenoModel <- readRDS("modelRun.rds")


