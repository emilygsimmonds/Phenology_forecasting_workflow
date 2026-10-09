# Phenology_forecasting_workflow
Test repository for code related to phenology forecasting for PREDICT project 
(OSCARS)

This workflow consists of five components as described below.

Component 1: **Prepare Trait Data**: this component takes three *inputs*, a file of
trait data, a vector of months of interest (numeric), and a vector of years to 
take data for. The component reformats the
trait data to specify input files for component 2 and to be used in later modelling.
Key steps are changing names of the latitude and longitude columns and reducing
the dataset to the months and years of interest. *Outputs* are a trait data file
that can be an input for component 3, a dataframe of date, latitude, and longitude,
which will act as the input for component 2.

Component 2: **Pull Chelsa Data**: this component takes two *inputs* a dataframe
of year, lon, lat, and a vector of the months to take data for (numeric). The
component pulls the appropriate temperature data from these locations and dates 
from Chelsa. It then *outputs* the resulting climate data. 

Component 3: **Combine Trait and Climate Data**: this component takes two *inputs*,
the trait data from component 1 and the climate data from component 2. This 
component combines them by taking the mean temperature for each spatial location.
The *output* is a datafile with all trait data and a temperature variable.

Component 4: **Model phenology**: this component takes several *inputs*, first,
the output of component 3 as the input data, then model parameters of nchains,
niter, nburnin, nchains, nthin. The component runs a nimble mixed effects 
model including effects of Year (random), elevation (fixed), temperature (fixed),
and latitude (fixed). The *output* is a datafile of all samples from the chains
for the intercept, slope, and standard deviation of the random effect of year,
and residual standard deviation. 

Component 5: **Forecast Future Phenology**: this component takes as *inputs* the 
output of the model in component 4, a prediction dataset created by components 1-3
but for different years to the dataset used for the model, and a number of draws
to take from the posterior. It subsamples the model posterior results and then
generates a prediction for each supplied location and time. The *output* is 
currently a raw array of predictions but can be refined to match required 
format. 

