################################
### SS3 Control File Updates ###
################################

# Load libraries
library(dplyr)
library(tidyr)
library(r4ss)
library(here)

# Get inputs from 2025 assessment that ran with updated data
update_data_model_path <- here::here("model", "2025_update_all_data")


##### Update CTL file for 2025 assessment ##### ----------------------------------------
update_ctl_model_path <- here::here("model", "2025_update_data_ctl")

copy_SS_inputs(
  dir.old = update_data_model_path ,
  dir.new = update_ctl_model_path,
  create.dir = FALSE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

inputs <-SS_read(dir = update_ctl_model_path)
ctl <- inputs$ctl

# Update block end year (selectivity and biology (if used) time blocks)
ctl$Block_Design[[2]][2] <- 2024
ctl$Block_Design[[3]][2] <- 2024
ctl$Block_Design[[4]][2] <- 2024

# Need to update the Prior SD for M for Hamel method
ctl$MG_parms["NatM_p_1_Fem_GP_1",]$PR_SD <- 0.31

# Update weight-length relationship
ctl$MG_parms["Wtlen_1_Fem_GP_1",]$INIT <- 7.183309e-06
ctl$MG_parms["Wtlen_1_Fem_GP_1",]$PRIOR <- 7.183309e-06
ctl$MG_parms["Wtlen_2_Fem_GP_1",]$INIT <- 3.244801
ctl$MG_parms["Wtlen_2_Fem_GP_1",]$PRIOR <-3.244801

# Question: Switch do rec_dev to option 3? It's currently option 1 but I think 
# most people are using option 2 or 3
# Answer: We can stick with option 1 for the base model but we can also try it 
# out with option 2 or 3
# ctl$do_recdev <- 2
# ctl$do_recdev <- 3

# Change last year of main rec_dev, for the last assessment this was 2015 so I
# would assume this would be 2023 for this year?
ctl$MainRdevYrLast <- 2023

# Change QParams that are hitting bounds
# Q_extraSD_8_CACPFV(8) 
ctl$Q_parms[8,]$LO <- -1
# Q_extraSD_12_IPHC_ORWA(12)
ctl$Q_parms[16,]$HI <- 7
ctl$Q_parms[16,]$LO <- -1

# Selectivity Params if needed - do we need to do this?
# Change selparm bounds that are being hit
# Size_DblN_peak_10_TRI_ORWA(10)
ctl$size_selex_parms[49,]$HI <- 95

# Fill outfile with directory and file name of the file written
r4ss::SS_writectl(ctl, outfile = file.path(update_ctl_model_path, "yelloweye_control.ss"), overwrite = TRUE)

r4ss::get_ss3_exe(dir = update_ctl_model_path)

#r4ss::run(dir = model_2025_path)
replist_update_ctl <- r4ss::SS_output(dir = update_ctl_model_path)
#r4ss::SS_plots(replist_update_ctl)

##### After initial model is run tasks ##### -----------------------------------

##### Fit rec bias ramp ##### --------------------------------------------------
# Need to run model first but after we do, we can change the recruitment bias 
# adjustment
# Import output of model run as replist
dir_fitbias <- here::here("model", "2025_update_all_fitbias")
  
copy_SS_inputs(
  dir.old = update_ctl_model_path,
  dir.new = dir_fitbias,
  create.dir = FALSE,
  overwrite = TRUE,
  use_ss_new = FALSE,
  verbose = TRUE
)

# must run oldctl model once before doing this
r4ss::SS_fitbiasramp(replist_update_ctl, #use replist from previous run
                     plot = FALSE, 
                     print = FALSE,
                     oldctl = file.path(update_ctl_model_path, "yelloweye_control.ss"),
                     newctl = file.path(dir_fitbias, "yelloweye_control.ss"),
                     startvalues = NULL,
                     method = "BFGS",
                     altmethod = "nlminb")

r4ss::get_ss3_exe(dir = dir_fitbias)
# r4ss::run(dir = dir_fitbias)
replist_fitbias <- r4ss::SS_output(dir = dir_fitbias)

##### Tune composition data ##### ----------------------------------------------
dir_tunecomps <- here::here("model", "2025_update_all_fitbias_tunecomps")

copy_SS_inputs(
  dir.old = dir_fitbias,
  dir.new = dir_tunecomps,
  create.dir = FALSE,
  overwrite = TRUE,
  use_ss_new = FALSE,
  verbose = TRUE
)

r4ss::get_ss3_exe(dir = dir_tunecomps)

r4ss::tune_comps(replist_fitbias, # use replist from previous run
                 option = "Francis",
                 write = TRUE,
                 dir = dir,
                 exe = "ss3")

replist_tunecomps <- r4ss::SS_output(dir = dir_tunecomps)
