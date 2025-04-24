################################
### SS3 Control File Updates ###
################################

# Load libraries
library(dplyr)
library(tidyr)
library(r4ss)
library(here)

# Get inputs from 2025 assessment that ran with updated data
dir_fitbias <- here::here("model", "2025_update_data_fitbias")


##### Update CTL file for 2025 assessment ##### ----------------------------------------
update_ctl_model_path <- here::here("model", "2025_update_data_ctl")

copy_SS_inputs(
  dir.old = dir_fitbias,
  dir.new = update_ctl_model_path,
  create.dir = FALSE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

inputs <- SS_read(dir = update_ctl_model_path)
ctl <- inputs$ctl

# Update block end year 
ctl$Block_Design[[2]][2] <- 2024
ctl$Block_Design[[3]][2] <- 2024
ctl$Block_Design[[4]][2] <- 2024

# Need to update the Prior SD for M for Hamel method
ctl$MG_parms["NatM_p_1_Fem_GP_1", ]$PR_SD <- 0.31

# Update weight-length relationship
ctl$MG_parms["Wtlen_1_Fem_GP_1", ]$INIT <- 7.183309e-06
ctl$MG_parms["Wtlen_1_Fem_GP_1", ]$PRIOR <- 7.183309e-06
ctl$MG_parms["Wtlen_2_Fem_GP_1", ]$INIT <- 3.244801
ctl$MG_parms["Wtlen_2_Fem_GP_1", ]$PRIOR <- 3.244801

# Question: Switch do rec_dev to option 3? It's currently option 1 but I think
# most people are using option 2 or 3
# Answer: We can stick with option 1 for the base model but we can also try it
# out with option 2 or 3
# ctl$do_recdev <- 2
# ctl$do_recdev <- 3

# Change last year of main rec_dev, for the last assessment this was 2015 so I
# would assume this would be 2023 for this year?
ctl$MainRdevYrLast <- 2023

# Remove 4 params that have priors but are not estimated by changing prior type to 0
ctl$MG_parms["NatM_p_1_Fem_GP_1", ]$PR_type <- 0
ctl$MG_parms["Eggs_alpha_Fem_GP_1", ]$PR_type <- 0
ctl$MG_parms["Eggs_beta_Fem_GP_1", ]$PR_type <- 0
ctl$SR_parms["SR_BH_steep", ]$PR_type <- 0

# Change size selex types for these two fleets to 0 because they appear to be ignored
# by the model anyways
ctl$size_selex_types["4_ORWA_TWL",]$Special <- 0
ctl$size_selex_types["5_ORWA_NONTWL",]$Special <- 0

# Change the growth age for L1 from 1 to 0 because at 1 it produces a funny growth curve
# as Vlada showed us
ctl$Growth_Age_for_L1 <- 0

# Fill outfile with directory and file name of the file written
r4ss::SS_writectl(
  ctl,
  outfile = file.path(update_ctl_model_path, "yelloweye_control.ss"),
  overwrite = TRUE
)


r4ss::get_ss3_exe(dir = update_ctl_model_path)

# You have to run this model in full (not using -nohess) because you need the covar file
# to fit the bias
#r4ss::run(dir = model_2025_path)
replist_update_ctl <- r4ss::SS_output(dir = update_ctl_model_path)
r4ss::SS_plots(replist_update_ctl)

##### After initial model is run tasks ##### -----------------------------------
##### Fit rec bias ramp ##### --------------------------------------------------
# Need to run model first but after we do, we can change the recruitment bias
# adjustment
# Import output of model run as replist
dir_ctl_fitbias <- here::here("model", "2025_update_ctl_fitbias")

copy_SS_inputs(
  dir.old = update_ctl_model_path,
  dir.new = dir_ctl_fitbias,
  create.dir = FALSE,
  overwrite = TRUE,
  copy_exe = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

# must run oldctl model once before doing this
r4ss::SS_fitbiasramp(
  replist_update_ctl, #use replist from previous run
  plot = FALSE,
  print = FALSE,
  oldctl = file.path(update_ctl_model_path, "yelloweye_control.ss"),
  newctl = file.path(dir_ctl_fitbias, "yelloweye_control.ss"),
  startvalues = NULL,
  method = "BFGS",
  altmethod = "nlminb"
)

r4ss::get_ss3_exe(dir = dir_ctl_fitbias)
# r4ss::run(dir = dir_ctl_fitbias)
replist_ctl_fitbias <- r4ss::SS_output(dir = dir_ctl_fitbias)
r4ss::SS_plots(replist_ctl_fitbias)


##### Tune composition data ##### ----------------------------------------------
tunecomps_dir <- here::here("model/2025_update_ctl_tune_comps")

copy_SS_inputs(
  dir.old = here::here("model/2025_update_ctl_fitbias"),
  dir.new = tunecomps_dir,
  copy_exe = TRUE,
  overwrite = TRUE
)

other_files <- c("Report.sso", "CompReport.sso", "warning.sso")
lapply(other_files, function(files){
  file.copy(
    from = here::here("model/2025_update_ctl_fitbias", files),
    to = here::here(tunecomps_dir, files),
    overwrite = TRUE
  )
})

r4ss::tune_comps(
  replist, # use replist from previous run
  niters_tuning = 2, 
  option = "Francis",
  dir = tunecomps_dir,
  show_in_console = TRUE,
  extras = "-nohess",
  exe = "ss3"
)


# Run model after this with hessian to use for fit bias
r4ss::run(dir = tunecomps_dir)

replist_tunecomps <- r4ss::SS_output(dir = tunecomps_dir)
r4ss::SS_plots(replist_tunecomps)
