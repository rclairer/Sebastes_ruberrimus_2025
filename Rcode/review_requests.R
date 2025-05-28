rm(list=ls())
library(dplyr)
library(tidyr)
library(ggplot2)
#remotes::install_github("r4ss/r4ss")
library(r4ss)
library(readr)
library(nwfscSurvey)
library(here)
#remotes::install_github("pfmc-assessments/pacfintools")
library(pacfintools)
exe_loc <- here::here('model/ss3.exe')

#############################################################################

# Read in base model
#base_mod_dir <- here::here("model/2025_base_model")
base_mod <- SS_read(here::here("model", "2025_base_model"))
SS_write(base_mod, here::here("model", "2025_base_model_requests"), overwrite = TRUE)
base_mod_requests_dir <- here::here("model/2025_base_model_requests")

r4ss::get_ss3_exe(dir = base_mod_requests_dir)
r4ss::run(dir = here::here("model", "2025_base_model_requests"), show_in_console = TRUE)
#SS_plots(replist = SS_output(here::here("model", "2025_base_model_requests")),dir = 2025_base_model_requests_dir)

replist_base_mod_requests <- r4ss::SS_output(dir = file.path(getwd(), "model", "2025_base_model_requests"))

#run(dir = base_mod_dir, show_in_console = TRUE)

#replist_base_mod <- r4ss::SS_output(dir = file.path(getwd(), "model", "2025_base_model"))

#replist_base_mod <- r4ss::SS_output(dir = base_mod_dir, covar = TRUE)

second_fitbias_dir <- here::here("model/second_fit_bias_adj_ramp")

copy_SS_inputs(
  dir.old = base_mod_requests_dir,
  dir.new = second_fitbias_dir,
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

#fitbias_plots <- here::here("model/updated_alldata_tunecomps_fitbias_20250416/plots")
#add this folder manually

r4ss::SS_fitbiasramp(
  replist_base_mod_requests, #use replist from previous run
  plot = FALSE,
  #print = TRUE,
  #plotdir = fitbias_plots,
  #shownew = TRUE,
  oldctl = file.path(base_mod_requests_dir, "yelloweye_control.ss"),
  newctl = file.path(second_fitbias_dir, "yelloweye_control.ss"),#this incorporates the suggested changes from the last run
  startvalues = NULL,
  method = "BFGS",
  altmethod = "nlminb"
)

# Run model after fitbias
r4ss::get_ss3_exe(dir = second_fitbias_dir)

run(dir = second_fitbias_dir, show_in_console = TRUE)

replist_second_fitbias <- r4ss::SS_output(dir = second_fitbias_dir)

SS_plots(replist_second_fitbias)

#compare updataed ss3 exe, updated historical catch, and updated historical catch + extended catch
models <- c(paste0(file.path(getwd(), "model", "2025_base_model_requests")),
            paste0(file.path(getwd(), "model", "second_fit_bias_adj_ramp")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", 
                                      "21_second_fitbias"),
                  legendlabels = c("2025 base model", 
                                   "second fitbias"),
                  print = TRUE)

