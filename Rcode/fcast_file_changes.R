################################
### SS3 Forecast File Updates ###
################################

# Load libraries
library(dplyr)
library(tidyr)
library(r4ss)
library(here)

inputs <-SS_read(dir = update_ctl_model_path)

fcast <- inputs$fore


# Update flimit fraction
fcast$Flimitfraction <- -1

# update buffer values
remotes::install_github("pfmc-assessments/PEPtools")
PEPtools::get_buffer(years = 2025:2036, sigma =  0.5, pstar = 0.45)

fcast$stddev_of_log_catch_ratio <- 0

