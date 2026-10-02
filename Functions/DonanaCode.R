# code from Donana case study

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
