###############################
## SS3 Forecast File Updates ##
###############################
remotes::install_github("pfmc-assessments/PEPtools")

# Load libraries
library(dplyr)
library(tidyr)
library(r4ss)
library(here)
library(PEPtools)

fitbias <- here::here("model", "2025_update_all_fitbias")
update_forecast <- here::here("model", "2025_update_forecast")

copy_SS_inputs(
  dir.old = fitbias,
  dir.new = update_forecast,
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = FALSE,
  verbose = TRUE
)

inputs <- SS_read(dir = update_forecast)
fcast <- inputs$fore

# Update benchmark years, convert to negative value representing years before the ending year of the model
fcast$Bmark_years <- c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

# Update flimit fraction
fcast$Flimitfraction <- -1

# update buffer values
fcast$Flimitfraction_m <- PEPtools::get_buffer(2025:2036, sigma = 0.5, pstar = 0.45)

# comment out  "FirstYear for caps and allocations" because we have no caps or allocations
# ??? Should this be 2027
fcast$FirstYear_for_caps_and_allocations <- 2027

fcast$Ydecl <- 0
fcast$Yinit <- 0

# change "stddev of log(realized catch/target catch) in forecast" to 0
fcast$stddev_of_log_catch_ratio <- 0

# update fixed forcast catches at the bottom for assumed catches in 2025 and 2026 
# (values will likely be provided by GMT)
# Who is GMT?
# fcast$ForeCatch <- data.frame(
#   year = rep(2025:2026, each = 3),
#   seas = 1,
#   fleet = rep(1:12, 2),
#   catch_or_F = c(???) 
# )

inputs$fore <- fcast
SS_write(inputs, dir = update_forecast)

get_ss3_exe(dir = update_forecast)

replist <- SS_output(dir = update_forecast)
SS_plots(replist)