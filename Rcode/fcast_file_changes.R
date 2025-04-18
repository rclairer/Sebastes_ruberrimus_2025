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

fitbias <- here::here("model", "2025_update_ctl_fitbias")
update_forecast <- here::here("model", "2025_update_forecast")

copy_SS_inputs(
  dir.old = fitbias,
  dir.new = update_forecast,
  create.dir = FALSE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  copy_exe = TRUE,
  verbose = TRUE
)

inputs <- SS_read(dir = update_forecast)
fcast <- inputs$fore

# Update benchmark years, convert to negative value representing years before the ending year of the model
fcast$Bmark_years <- c(0, 0, 0, 0, 0, 0, 1916, 0, 1916, 0)

# Update flimit fraction
fcast$Flimitfraction <- -1

# update buffer values
fcast$Flimitfraction_m <- PEPtools::get_buffer(2025:2036, sigma = 0.5, pstar = 0.45)

# These may not need to change; either way this is something to do with the rebuilder stuff
# fcast$Ydecl <- 0
# fcast$Yinit <- 0

# change "stddev of log(realized catch/target catch) in forecast" to 0
fcast$stddev_of_log_catch_ratio <- 0

# update fixed forecast catches at the bottom for assumed catches in 2025 and 2026 
# (values will likely be provided by Groundfish Management Team)
# fcast$ForeCatch <- data.frame(
#   year = rep(2025:2026, each = 3),
#   seas = 1,
#   fleet = rep(1:12, 2),
#   catch_or_F = c(???) 
# )

inputs$fore <- fcast
SS_write(inputs, dir = update_forecast, overwrite = TRUE)

replist <- SS_output(dir = update_forecast)
SS_plots(replist)
