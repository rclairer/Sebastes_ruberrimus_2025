#### Diagnostics ####

install.packages("remotes")
remotes::install_github("pfmc-assessments/nwfscDiag")
library(nwfscDiag)

directory <- here::here("model")
base_model_name <- "2025_update_forecast"


#### Profiles ####

profile_info <- get_settings_profile(
  parameters =  c("NatM_uniform_Fem_GP_1", "SR_BH_steep", "SR_LN(R0)"),
  low =  c(0.04, 0.25, -2),
  high = c(0.04, 1.0, 2),
  step_size = c(0.0005, 0.05, 0.25),
  param_space = c('multiplier', 'real', 'relative')
  )


# DON"T DO PROFILE IN PARALLEL
model_settings <- get_settings(
  settings = list(
    base_name = base_model_name,
    run = c("profile"),
    profile_details = profile_info )
)

run_diagnostics(mydir = directory, model_settings = model_settings)


#### Jitter ####

ncores <- parallelly::availableCores(omit = 1)
future::plan(future::multisession, workers = ncores)

# YOU CAN USE THIS IN PARALLEL
model_settings <- get_settings(
  settings = list(
    base_name = base_model_name,
    run = c("jitter", "retro"),

    # Jitter Settings
    extras = "-nohess",
    Njitter = 100,
    jitter_fraction = 0.1,
    jitter_init_values_src = NULL,
    
    # Retrospective Settings
    newsubdir = "retro",
    retro_yrs = -1:-5,
    
    # Plot target lines
    btarg = NULL,
    minbthresh = NULL)
)

run_diagnostics(mydir = directory, model_settings = model_settings)

future::plan(future::sequential)


#### MCMC ####
path <- here::here("model", "2025_update_forecast")

un_mcmc_diagnostics(
  dir_wd = path,
  model = "ss3",
  extension = ".exe",
  iter = 200,
  chains = 2,
  interactive = FALSE,
  verbose = FALSE
)