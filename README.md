# Phenology_forecasting_workflow
Test repository for code related to phenology forecasting for PREDICT project 
(OSCARS)

This workflow consists of five components as described below.

Component 1: Temporary component which will be replaced with **TidyTRY**: 
in code used here this component takes three *inputs*, a file of
trait data, a vector of months of interest (numeric), and a vector of years to 
take data for. The component reformats the
trait data to specify input files for component 2 and to be used in later modelling.
Key steps are changing names of the latitude and longitude columns and reducing
the dataset to the months and years of interest. *Outputs* are a trait data file
that can be an input for component 3, a dataframe of date, latitude, and longitude,
which will act as the input for component 2. Requires only 1 *script* 'formatTrait.R'.

Component 2: Temporary component to be replaced by **Chelsa Extractor**: 
this component takes two *inputs* a dataframe
of year, lon, lat, and a vector of the months to take data for (numeric). The
component pulls the appropriate temperature data from these locations and dates 
from Chelsa. It then *outputs* the resulting climate data. Requires 2 *scripts* 
'get_chelsa.R' and 'pullChelsaData.R'.

Component 3: Temporary component to be replaced by **Traits and Environmental 
Data Cubes**: this component takes two *inputs*,
the trait data from component 1 and the climate data from component 2. This 
component combines them by taking the mean temperature for each spatial location.
The *output* is a datafile with all trait data and a temperature variable.
Requires 1 *script* 'combineTraitClimate.R'.

Component 4: **Model phenology**: this component takes several *inputs*, first,
the output of component 3 as the input data, then model parameters of nchains,
niter, nburnin, nchains, nthin. The component runs a nimble mixed effects 
model including effects of Year (random), elevation (fixed), temperature (fixed),
and latitude (fixed). The *output* is a datafile of all samples from the chains
for the intercept, slope, and standard deviation of the random effect of year,
and residual standard deviation. Requires 2 *scripts* 'modelCode.R' and 
'runPhenologyModel.R'.

Component 5: **Forecast Phenology**: this component takes as *inputs* the 
output of the model in component 4, a prediction dataset created by components 1-3
but for different years to the dataset used for the model, and a number of draws
to take from the posterior. It subsamples the model posterior results and then
generates a prediction for each supplied location and time. The *output* is 
currently a raw array of predictions but can be refined to match required 
format. Requires 2 *scripts* 'predictionCode.R' and 'runPhenologyPrediction.R'.

