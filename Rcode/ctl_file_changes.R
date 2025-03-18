################################
### SS3 Control File Updates ###
################################

# Load libraries
library(dplyr)
library(tidyr)
library(r4ss)

# Get inputs from 2017 assessment that will get carried over to this assessment
# You can also change this to another model
model_2017_path <- file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")
ctl <- r4ss::SS_readctl(file = file.path(model_2017_path, "control.ss_new"))

ctl$MG_parms["Wtlen_1_Fem_GP_1",]$INIT <- 7.183309e-06
ctl$MG_parms["Wtlen_1_Fem_GP_1",]$PRIOR <- 7.183309e-06
ctl$MG_parms["Wtlen_2_Fem_GP_1",]$INIT <- 3.244801
ctl$MG_parms["Wtlen_2_Fem_GP_1",]$PRIOR <-3.244801

# Fill outfile with directory and file name of the file written
r4ss::SS_writectl(ctl, outfile = "", overwrite = TRUE)
