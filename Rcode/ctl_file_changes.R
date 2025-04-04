################################
### SS3 Control File Updates ###
################################

# Load libraries
library(dplyr)
library(tidyr)
library(r4ss)

# Get inputs from 2017 assessment that will get carried over to this assessment
# You can also change this to another model
model_2025_path <- file.path(getwd(), "model", "2025_update_all_data")
inputs <- r4ss::SS_read(model_2025_path)
ctl <- inputs$ctl

# Update block end year (selectivity and biology (if used) time blocks)
ctl$Block_Design[[2]][2] <- 2024
ctl$Block_Design[[3]][2] <- 2024
ctl$Block_Design[[4]][2] <- 2024

# Do we need to update the prior on M?
# ctl$MG_parms["NatM_p_1_Fem_GP_1",]$PRIOR <- ?

# Update weight-length relationship
ctl$MG_parms["Wtlen_1_Fem_GP_1",]$INIT <- 7.183309e-06
ctl$MG_parms["Wtlen_1_Fem_GP_1",]$PRIOR <- 7.183309e-06
ctl$MG_parms["Wtlen_2_Fem_GP_1",]$INIT <- 3.244801
ctl$MG_parms["Wtlen_2_Fem_GP_1",]$PRIOR <-3.244801

# Question: Switch do rec_dev to option 3? It's currently option 1 but I think 
# most people use option 3

# Change last year of main rec_dev, for the last assessment this was 2015 so I
# would assume this would be 2023 for this year?
ctl$MainRdevYrLast <- 2023

# Selectivity Params if needed - do we need to do this?

# Fill outfile with directory and file name of the file written
r4ss::SS_writectl(ctl, outfile = file.path(model_2025_path, "yelloweye_control.ss"), overwrite = TRUE)

r4ss::get_ss3_exe(dir = model_2025_path)

#r4ss::run(dir = model_2025_path)
replist_update_ctl <- r4ss::SS_output(dir = model_2025_path)
#r4ss::SS_plots(replist)

##### After initial model is run tasks ##### -----------------------------------
# Need to run model first but after we do, we can change the recruitment bias 
# adjustment
# Import output of model run as replist
dir_fitbias <- file.path(getwd(), "model", "2025_update_all_data_fitbias")
  
copy_SS_inputs(
  dir.old = model_2025_path,
  dir.new = dir_fitbias,
  create.dir = FALSE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

# must run oldctl model once before doing this
r4ss::SS_fitbiasramp(replist,
                     plot = FALSE, 
                     print = FALSE,
                     oldctl = file.path(model_2025_path, "yelloweye_control.ss"),
                     newctl = file.path(dir_fitbias, "yelloweye_control.ss"),
                     startvalues = NULL,
                     method = "BFGS",
                     altmethod = "nlminb")

r4ss::get_ss3_exe(dir = dir_fitbias)
# r4ss::run(dir = dir_fitbias)
replist <- r4ss::SS_output(dir = dir_fitbias)

# tune comps
dir_tunecomps <- file.path(getwd(), "model", "2025_update_all_data_fitbias_tunecomps")

copy_SS_inputs(
  dir.old = dir_fitbias,
  dir.new = dir_tunecomps,
  create.dir = FALSE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

r4ss::get_ss3_exe(dir = dir_tunecomps)

r4ss::tune_comps(replist,
                 option = "Francis",
                 write = TRUE,
                 dir = dir,
                 exe = "ss3")

