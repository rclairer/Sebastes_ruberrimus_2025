# rm(list=ls())
library(dplyr)
library(tidyr)
library(ggplot2)
library(r4ss)
library(readr)
library(nwfscSurvey)
library(pacfintools)

###############################################
#########    2017 BASE MODEL #######################
##############################################

model_2017_base_path <- file.path(getwd(), "model", "2017_yelloweye_model_base")

##############################################
############   UPDATED SS3 EXE   #############
##############################################

model_2017_updatedexe_path <- file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")

###########################################################################
############   UPDATED SS3 EXE but nsexes same as base 2017   #############
###########################################################################

copy_SS_inputs(
  dir.old = model_2017_updatedexe_path, 
  dir.new = file.path(getwd(), "model", "2017_updated_ss3_exe_nsexes1_20250409"),
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

inputs <- SS_read(dir = file.path(getwd(), "model", "2017_updated_ss3_exe_nsexes1_20250409"))
inputs$dat$Nsexes <- 1  

SS_write(inputs, dir = file.path(getwd(), "model", "2017_updated_ss3_exe_nsexes1_20250409"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "2017_updated_ss3_exe_nsexes1_20250409"))

run(dir = file.path(getwd(), "model", "2017_updated_ss3_exe_nsexes1_20250409"), show_in_console = TRUE, extras = "-nohess")

replist <- SS_output(dir = file.path(getwd(), "model", "2017_updated_ss3_exe_nsexes1_20250409"))
SS_plots(replist)


#compare base, updataed ss3 exe, nsexes = -1 and updated ss3 exe
#models <- list.dirs(file.path(getwd(), "model"), recursive = FALSE)
#models <- models[c(4,3,5)] #CHECK THIS EVERY TIME
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_base")),
                   paste0(file.path(getwd(), "model", "2017_updated_ss3_exe_nsexes1_20250409")),
                   paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", 
                                      "1_base_updatedss3exe_updatednsexes"),
                  legendlabels = c("2017 base", "2017 updated SS3 exe (Nsexes = 1)", "2017 updated SS3 exe (Nsexes = -1)"),
                  print = TRUE
)



###########################################################################
#### UPDATED SS3 EXE, UPDATED HISTORICAL CATCH (< YEAR 2017) ONLY #########
###########################################################################

copy_SS_inputs(
  dir.old = model_2017_updatedexe_path, 
  dir.new = file.path(getwd(), "model", "updated_historical_catch_20250414"),
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

inputs <- SS_read(dir = file.path(getwd(), "model", "updated_historical_catch_20250414"))

#inputs$dat$endyr <- 2016

colnames_c <- c("year", "seas", "fleet", "catch", "catch_se")

# Load recent commercial catch data for CA, OR, and WA
yelloweye_recent_comm_catch <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "yelloweye_commercial_catch_2016_2024_25Mar2025.csv"
)) |>
  filter(YEAR < 2025)

# CA TWL - fleet 1
# Use CA TWL from 1889-2015 from previous assessment
CA_1889_2015_TWL <- inputs$dat$catch |>
  filter(fleet == 1) |>
  filter(year < 2016)

# PACFIN data with discards that starts in 2016
# Data from Sam Schiano
CA_2016_2024_TWL <- yelloweye_recent_comm_catch |>
  filter(ST_FLEET == "CA_TWL") |>
  mutate(fleet = 1) |>
  select(YEAR, SEAS, fleet, TOTAL_CATCH, CATCH_SE) |>
  mutate(TOTAL_CATCH = round(TOTAL_CATCH, 3))
colnames(CA_2016_2024_TWL) <- colnames_c

CA_TWL <- CA_1889_2015_TWL |>
  bind_rows(CA_2016_2024_TWL) |>
  arrange(year)

# CA NONTWL - fleet 2
# Use CA TWL from 1889-2015 from previous assessment
CA_1889_2015_NONTWL <- inputs$dat$catch |>
  filter(fleet == 2) |>
  filter(year < 2016)

# PACFIN data with discards
# From Sam Schiano
# No catch data for 2016, 2018, 2019, 2020, or 2024
CA_2016_2024_NONTWL <- yelloweye_recent_comm_catch |>
  filter(ST_FLEET == "CA_NONTWL") |>
  mutate(fleet = 2) |>
  select(YEAR, SEAS, fleet, TOTAL_CATCH, CATCH_SE) |>
  mutate(TOTAL_CATCH = round(TOTAL_CATCH, 3))
colnames(CA_2016_2024_NONTWL) <- colnames_c

CA_NONTWL <- CA_1889_2015_NONTWL |>
  bind_rows(CA_2016_2024_NONTWL) |>
  arrange(year)

# CA REC - fleet 3
# CA historical catch the same as the previous assessment
CA_hist_catch_REC <- inputs$dat$catch |>
  filter(fleet == 3 & year < 2016) |>
  filter(!between(year, 1880, 1927))

# RecFIN data for 2016 - 2024
# Data from Madison and Elizabeth
CA_recent_catch_REC <- read.csv(file.path(
  getwd(),
  "Data",
  "raw",
  "nonconfidential",
  "CTE001-California-1990---2024.csv"
)) |>
  select(RECFIN_YEAR, SUM_TOTAL_MORTALITY_MT) |>
  group_by(RECFIN_YEAR) |>
  summarize(
    seas = 1,
    fleet = 3,
    catch = sum(SUM_TOTAL_MORTALITY_MT),
    catch_se = 0.01
  ) |>
  rename(year = RECFIN_YEAR) |>
  filter(year >= 2016) |>
  mutate(catch = round(catch, 3))

CA_REC <- CA_hist_catch_REC |>
  bind_rows(CA_recent_catch_REC) |>
  arrange(year)

# ORWA TWL - fleet 4
# All OR data provided from Ali Whitman with updated historical catch reconstruction
OR_comm_all <- read.csv(file.path(
  getwd(),
  "Data",
  "raw",
  "nonconfidential",
  "ORCommLandings_457_2024.csv"
))

OR_TWL <- OR_comm_all |>
  select(YEAR, FLEET, TOTAL) |>
  filter(
    FLEET == "TRW",
    YEAR < 2016
  ) |>
  select(-FLEET) |>
  rename(year = YEAR) |>
  mutate(
    seas = 1,
    fleet = 4,
    catch = TOTAL,
    catch_se = 0.01
  ) |>
  select(-TOTAL)

# WA historical catch with unchanged reconstruction provided from Fabio which Theresa
# gave to the last assessment
WA_TWL <- read.csv(file.path(
  getwd(),
  "Data",
  "raw",
  "nonconfidential",
  "WA_hist_catch_twl.csv"
)) |>
  select(Year, Catches..mtons.) |>
  filter(Year < 2016) |>
  mutate(
    seas = 1,
    fleet = 4,
    catch_se = 0.01
  ) |>
  rename(
    year = Year,
    catch = Catches..mtons.
  ) |>
  select(year, seas, fleet, catch, catch_se)

# Combine historical catch prior to 2016
ORWA_TWL_until_2015 <- OR_TWL |>
  bind_rows(WA_TWL) |>
  group_by(year) |>
  summarize(
    seas = 1,
    fleet = 4,
    catch = sum(catch),
    catch_se = 0.01
  )

# Recent OR and WA historical catch from PacFIN
# Provided by Sam Schiano
ORWA_TWL_2016_2024 <- yelloweye_recent_comm_catch |>
  filter(ST_FLEET == "ORWA_TWL") |>
  mutate(fleet = 4) |>
  select(YEAR, SEAS, fleet, TOTAL_CATCH, CATCH_SE) |>
  mutate(TOTAL_CATCH = round(TOTAL_CATCH, 3))
colnames(ORWA_TWL_2016_2024) <- colnames_c

# add back in start line because starting from scratch it isn't there
start_line <- data.frame(
  year = -999,
  seas = 1,
  fleet = 4,
  catch = 0,
  catch_se = 0.01
)

ORWA_TWL <- start_line |>
  bind_rows(ORWA_TWL_until_2015) |>
  bind_rows(ORWA_TWL_2016_2024) |>
  arrange(year)

# ORWA NONTWL - fleet 5
# All OR data provided from Ali with updated historical catch reconstruction
OR_NONTWL <- OR_comm_all |>
  select(YEAR, FLEET, TOTAL) |>
  filter(
    FLEET == "NTRW",
    YEAR < 2016
  ) |>
  select(-FLEET) |>
  rename(year = YEAR) |>
  mutate(
    seas = 1,
    fleet = 5,
    catch = TOTAL,
    catch_se = 0.01
  ) |>
  select(-TOTAL)

# WA historical catch with unchanged reconstruction provided from Fabio
WA_NONTWL <- read.csv(file.path(
  getwd(),
  "Data",
  "raw",
  "nonconfidential",
  "WA_hist_catch_nontwl.csv"
)) |>
  select(Year, Catches..mtons.) |>
  filter(Year < 2016) |>
  mutate(
    seas = 1,
    fleet = 5,
    catch_se = 0.01
  ) |>
  rename(
    year = Year,
    catch = Catches..mtons.
  ) |>
  select(year, seas, fleet, catch, catch_se)

# Combine historical catch prior to 2016
ORWA_NONTWL_until_2015 <- OR_NONTWL |>
  bind_rows(WA_NONTWL) |>
  group_by(year) |>
  summarize(
    seas = 1,
    fleet = 5,
    catch = sum(catch),
    catch_se = 0.01
  )

# Recent OR and WA historical catch from PacFIN
ORWA_NONTWL_2016_2024 <- yelloweye_recent_comm_catch |>
  filter(ST_FLEET == "ORWA_NONTWL") |>
  mutate(fleet = 5) |>
  select(YEAR, SEAS, fleet, TOTAL_CATCH, CATCH_SE) |>
  mutate(TOTAL_CATCH = round(TOTAL_CATCH, 3))
colnames(ORWA_NONTWL_2016_2024) <- colnames_c

# add back in start line because starting from scratch it isn't there
start_line <- data.frame(
  year = -999,
  seas = 1,
  fleet = 5,
  catch = 0,
  catch_se = 0.01
)

ORWA_NONTWL <- start_line |>
  bind_rows(ORWA_NONTWL_until_2015) |>
  bind_rows(ORWA_NONTWL_2016_2024) |>
  arrange(year)

# OR REC - fleet 6
# OR Rec data up to 2024 provided from Ali Whitman
# From Ali: Previous assessments used some in-house data to produce recreational
# catch  estimates from 1973 – 1978. The data are similar (same sampling program)
# to  those used in the new sport reconstruction, which as you said, starts in 1979.
# I have no updates for those numbers but hope to eventually incorporate those
# data into our new reconstruction. I would suggest just rolling those years
# (1973 – 1978) over from the previous assessment.  I’m not opposed to removing
# them if you guys feel otherwise, but I think they’re fine as is.

OR_REC_to_1978 <- inputs$dat$catch |>
  filter(fleet == 6) |>
  filter(year <= 1978)

OR_REC <- read.csv(file.path(
  getwd(),
  "Data",
  "raw",
  "nonconfidential",
  "ORRecLandings_457_2024.csv"
)) |>
  select(Year, Total_MT) |>
  mutate(
    seas = 1,
    fleet = 6,
    catch = Total_MT,
    catch_se = 0.01
  ) |>
  rename(year = Year) |>
  select(-Total_MT) |>
  mutate(catch = round(catch, 2)) |>
  bind_rows(OR_REC_to_1978) |>
  arrange(year)

# WA REC - fleet 7
# Data provided by Fabio and RecFin, data compiled by Elizabeth
# WA Rec data from RecFIN - See Rcode > removals > WA_rec_catch.r file for how this was compiled
# Discards are included unlike they were in the 2017 assessment and I think we should use those
# but it's not that much different from the previous assessment so also good with using this assessment
WA_hist_catch_REC <- inputs$dat$catch |>
  filter(fleet == 7 & year < 2016) |>
  filter(!between(year, 1880, 1974))

WA_REC <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "WA_historical_to_recent_rec_catch.csv"
)) |>
  mutate(
    seas = 1,
    fleet = 7,
    catch_se = 0.01
  ) |>
  select(year, seas, fleet, catch, catch_se) |>
  filter(year >= 2016) |>
  mutate(catch = round(catch, 2)) |>
  bind_rows(WA_hist_catch_REC) |>
  arrange(year)

# Combine all catch data
all_catch <- do.call(
  "rbind",
  list(
    CA_TWL,
    CA_NONTWL,
    CA_REC,
    ORWA_TWL,
    ORWA_NONTWL,
    OR_REC,
    WA_REC
  )
)

inputs$dat$catch <- all_catch

SS_write(inputs, dir = file.path(getwd(), "model", "updated_historical_catch_20250414"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "updated_historical_catch_20250414"))

run(dir = file.path(getwd(), "model", "updated_historical_catch_20250414"), show_in_console = TRUE, extras = "-nohess")

replist <- SS_output(dir = file.path(getwd(), "model", "updated_historical_catch_20250414"))
SS_plots(replist)

#compare updataed ss3 exe and updated historical catch
#models <- list.dirs(file.path(getwd(), "model"), recursive = FALSE)
#models <- models[c(5,12)] #CHECK THIS EVERY TIME
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "updated_historical_catch_20250414")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", 
                                      "2_updatedss3exe_updatedhistoricalcatch"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", "updated historical catch"),
                  print = TRUE
)

#################################################################################
#### UPDATED SS3 EXE, UPDATED HISTORICAL (< YEAR 2017) AND EXTENDED CATCH #######
#################################################################################

copy_SS_inputs(
  dir.old = file.path(getwd(), "model", "updated_historical_catch_20250414"), 
  dir.new = file.path(getwd(), "model", "updated_historical_and_extended_catch_20250414"),
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)


inputs <- SS_read(dir = file.path(getwd(), "model", "updated_historical_and_extended_catch_20250414"))

inputs$dat$endyr <- 2024

inputs$dat$catch <- all_catch

SS_write(inputs, dir = file.path(getwd(), "model", "updated_historical_and_extended_catch_20250414"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "updated_historical_and_extended_catch_20250414"))

run(dir = file.path(getwd(), "model", "updated_historical_and_extended_catch_20250414"), show_in_console = TRUE, extras = "-nohess")

replist <- SS_output(dir = file.path(getwd(), "model", "updated_historical_and_extended_catch_20250414"))
SS_plots(replist)

#compare updataed ss3 exe, updated historical catch, and updated historical catch + extended catch
#models <- list.dirs(file.path(getwd(), "model"), recursive = FALSE)
#models <- models[c(5,12,11)] #CHECK THIS EVERY TIME
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "updated_historical_catch_20250414")),
            paste0(file.path(getwd(), "model", "updated_historical_and_extended_catch_20250414")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", 
                                      "3_add_extendedcatch"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", "updated historical catch", "updated historical and extended catch"),
                  print = TRUE
)

#################################################################################
#### UPDATED SS3 EXE, UPDATED HISTORICAL (< YEAR 2017) AND EXTENDED CATCH #######
####           AND UPDATED HISTORICAL INDICES                             #######
#################################################################################

copy_SS_inputs(
  dir.old = file.path(getwd(), "model", "updated_historical_and_extended_catch_20250414"), 
  dir.new = file.path(getwd(), "model", "updated_historical_indices_20250414"),
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

inputs <- SS_read(dir = file.path(getwd(), "model", "updated_historical_indices_20250414"))

inputs$dat$endyr <- 2016

colnames_i <- c("year", "month", "index", "obs", "se_log")

# CA Rec MRFSS dockside CPUE - fleet 3
# I think we just bring over from 2017 assessment, because max year is 1999
CA_REC_MRFSS_index <- inputs$dat$CPUE |>
  filter(index == 3)

# OR Rec MRFSS - fleet 6
# Just bring over from 2017 assessment
OR_REC_MRFSS_index <- inputs$dat$CPUE |>
  filter(index == 6, year < 2000)

# OR ORBS - fleet 6
# From Ali Whitman
# This now includes years 2004 and 2017 - 2024
ORBS_index <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "ORBS_index_forSS.csv"
)) |>
  mutate(fleet = 6) #UPDATE THIS IN COMBINE_ALL_DATA files
colnames(ORBS_index) <- colnames_i

# WA Rec CPUE - fleet 7
# Just bring over from the 2017 assessment, because max year is 2001
WA_REC_CPUE_index <- inputs$dat$CPUE |>
  filter(index == 7)

# CA onboard CPFV CPUE - fleet 8
# Just bring over from the 2017 assessment, because max year is 1998
CA_CPFV_CPUE_index <- inputs$dat$CPUE |>
  filter(index == 8)

# Oregon onboard Recreational Charter observer CPUE (ORFS) - fleet 9
# From Ali: I don’t typically recommend using both ORFS and ORBS in a model together, 
# as they sample the same fishery and in rare cases, the same boats. This is 
# exacerbated in this assessment because the ORBS index uses released fish only 
# (as opposed to retained fish, which is how ORBS is typically set up).  Second, 
# while I updated both ORBS and ORFS for yelloweye this cycle (thinking I could 
# improve upon the previous ORFS model), the diagnostics continue to be poor for 
# the ORFS index. The TORs won’t let us remove one or the other without. We need to 
# just note all this for the future and move ahead with the updated versions of ORBS and ORFS in the model.

# We can do a sensitivity with just ORBS and just ORFS

# For some reason 2003 is missing from the updated index. This also now includes
# years 2015, 2017, 2022, 2023, and 2024
# Using everything Ali gave because it's pretty different from the ORFS index
# in the 2017 assessment
ORFS_index <- read.csv(file.path(getwd(), "Data", "processed", "ORFS_index_forSS.csv")) |>
  mutate(
    fleet = 9,
    obs = round(obs, digits = 6),
    logse = round(logse, digits = 6)
  )
colnames(ORFS_index) <- colnames_i

# Triennial survey - fleet 10
tri_index <- inputs$dat$CPUE |>
  filter(index == 10)

# NWFSC ORWA (sdmTMB) - fleet 11
# Full update done by Claire
NWFSC_ORWA <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "wcgbts_indices",
  "updated_indices_ORWA_CA_split",
  "yelloweye_split_42_point_offanisotropy/yelloweye_rockfish/wcgbts",
  "delta_lognormal",
  "index",
  "est_by_area.csv"
))
NWFSC_ORWA_index <- NWFSC_ORWA |>
  filter(area == "Coastwide") |>
  select(year, est, se) |>
  mutate(
    Month = 7,
    Fleet = 11
  ) |>
  select(year, Month, Fleet, est, se)
colnames(NWFSC_ORWA_index) <- colnames_i

# IPHC ORWA - fleet 12
#IPHC_ORWA_index <- inputs$dat$CPUE |>
#  filter(index == 12)
# Full update done in sdmTMB by Matheus
IPHC_ORWA <- read.csv(file.path(
getwd(),
  "Data",
  "processed",
  "IPHC_index",
  "IPHC_model_based_index_forSS3_UNSCALED.csv" ##UPDATE THIS IN COMBINE_ALL_DATA files
))
IPHC_ORWA_index <- select(IPHC_ORWA, -Assessment) #UPDATE THIS IN COMBINE_ALL_DATA FILES
colnames(IPHC_ORWA_index) <- colnames_i

all_indices <- do.call(
  "rbind",
  list(
    CA_REC_MRFSS_index,
    OR_REC_MRFSS_index,
    ORBS_index,
    WA_REC_CPUE_index,
    CA_CPFV_CPUE_index,
    ORFS_index,
    tri_index,
    NWFSC_ORWA_index,
    IPHC_ORWA_index
  )
)

inputs$dat$CPUE <- all_indices

SS_write(inputs, dir = file.path(getwd(), "model", "updated_historical_indices_20250414"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "updated_historical_indices_20250414"))

run(dir = file.path(getwd(), "model", "updated_historical_indices_20250414"), show_in_console = TRUE, extras = "-nohess")

replist <- SS_output(dir = file.path(getwd(), "model", "updated_historical_indices_20250414"))
SS_plots(replist)

#compare updataed ss3 exe, updated historical catch, and updated historical catch + extended catch
#models <- list.dirs(file.path(getwd(), "model"), recursive = FALSE)
#models <- models[c(5,12,11)] #CHECK THIS EVERY TIME
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "updated_historical_catch_20250414")),
            paste0(file.path(getwd(), "model", "updated_historical_and_extended_catch_20250414")),
            paste0(file.path(getwd(), "model", "updated_historical_indices_20250414")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", 
                                      "4_add_updatedhistoricalindices"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", "updated historical catch", "+ extended catch", "+ updated historical indices"),
                  print = TRUE
)

#################################################################################
#### UPDATED SS3 EXE, UPDATED HISTORICAL (< YEAR 2017) AND EXTENDED CATCH #######
####    UPDATED HISTORICAL INDICES AND EXTENDED INDICES                   #######
#################################################################################

copy_SS_inputs(
  dir.old = file.path(getwd(), "model", "updated_historical_indices_20250414"), 
  dir.new = file.path(getwd(), "model", "updated_historical_and_extended_indices_20250414"),
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)


inputs <- SS_read(dir = file.path(getwd(), "model", "updated_historical_and_extended_indices_20250414"))

inputs$dat$endyr <- 2024

inputs$dat$catch <- all_catch

inputs$dat$CPUE <- all_indices

SS_write(inputs, dir = file.path(getwd(), "model", "updated_historical_and_extended_indices_20250414"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "updated_historical_and_extended_indices_20250414"))

run(dir = file.path(getwd(), "model", "updated_historical_and_extended_indices_20250414"), show_in_console = TRUE, extras = "-nohess")

replist <- SS_output(dir = file.path(getwd(), "model", "updated_historical_and_extended_indices_20250414"))
SS_plots(replist)

#compare updataed ss3 exe, updated historical catch, and updated historical catch + extended catch
#models <- list.dirs(file.path(getwd(), "model"), recursive = FALSE)
#models <- models[c(5,12,11)] #CHECK THIS EVERY TIME
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "updated_historical_and_extended_catch_20250414")),
            paste0(file.path(getwd(), "model", "updated_historical_indices_20250414")),
            paste0(file.path(getwd(), "model", "updated_historical_and_extended_indices_20250414")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", 
                                      "5_add_extendedindices"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", 
                                   "updated historical and extended catch", 
                                   "+ updated historical indices", 
                                   "+ extended indices"),
                  print = TRUE
)


#################################################################################
#### UPDATED SS3 EXE, UPDATED HISTORICAL (< YEAR 2017) AND EXTENDED CATCH #######
####  UPDATED HISTORICAL AND EXTENDED INDICES + COMMERCIAL LENCOMP          #######
#################################################################################

# copy model starters and data file from prev run
copy_SS_inputs(
  dir.old = file.path(getwd(), "model", "updated_historical_and_extended_indices_20250414"), 
  dir.new = file.path(getwd(), "model", "updated_catch_indices_comlencomp_20250414"),
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)


inputs <- SS_read(dir = file.path(getwd(), "model", "updated_catch_indices_comlencomp_20250414"))

# read our new length comp (3 files: PacFIN, WCGOP and PacFIN+WCGOP combined
file_path = "Data/processed/length_age_comps/"
raw_length_comps_PacFIN_WCGOP <- read.csv(paste0(file_path,'Commercial_length_comps_PacFIN_WCGOP_forSS.csv'))
raw_length_comps_PacFIN <- read.csv(paste0(file_path,'Commercial_length_comps_PacFIN_forSS.csv'))
raw_length_comps_WCGOP <- read.csv(paste0(file_path,'Commercial_length_comps_WCGOP_forSS.csv'))

#format to SS data names
names(raw_length_comps_PacFIN_WCGOP) <- names(raw_length_comps_PacFIN) <- names(raw_length_comps_WCGOP) <- names(inputs$dat$lencomp)

# reminder of commercial fleet no. CA.TWL=1,CA.NONTWL=2,ORWA.TWL=4,ORWA.NONTWL=5

# CA_TWL, PacFIN AND WCGOP
## using 2017 data for 1978-2015 + 2025 data update for 2016-2024
##NB: previous assessment had CA_TWL from PacFIN only, now PacFIN and WCGOP are combined (because there are samples from both in years 2019-2022).
CA_TWL_PacFIN_WCGOP_length <- inputs$dat$lencomp %>% filter(fleet==1,year<=2015) %>% 
  bind_rows(raw_length_comps_PacFIN_WCGOP %>% filter(fleet==1,year>2015))

# CA_NONTWL, PacFIN
## using 2017 data for 1979 - 2002, no new data
##NB: Sample size from 2017 does not match our updated computation for unexplained reason. We use the 2017 data.
CA_NONTWL_PacFIN_length <- inputs$dat$lencomp %>% filter(fleet==2,year<=2002) 


# CA_NONTWL, WCGOP
## using 2017 data for 2004-2015 and 2025 data update for 2016-2023
#NB: the sample size used in 2017 does not match our values, whereas we have the exact same number of trips and fish samples. We use the 2017 data.
CA_NONTWL_WCGOP_length <-inputs$dat$lencomp %>% filter(fleet==2,year>2002) %>% 
  bind_rows(raw_length_comps_WCGOP %>% filter(fleet==2,year>2015))

# ORWA_TWL, PacFIN and WCGOP combined
## using 2017 data for 1995-2015 (2016 was included in 2017 but we update it with new data) 
## and 2025 data update for 2016-2024
ORWA_TWL_PacFIN_WCGOP_length <- inputs$dat$lencomp %>% filter(fleet==4,year<=2015) %>% 
  bind_rows(raw_length_comps_PacFIN_WCGOP %>% filter(fleet==4,year>2015))

# ORWA_NONTWL, PacFIN and WCGOP combined
## using 2017 data for 1980-2015 and 2025 data update for 2016-2024
ORWA_NONTWL_PacFIN_WCGOP_length <- inputs$dat$lencomp %>% filter(fleet==5,year<=2015) %>% 
  bind_rows(raw_length_comps_PacFIN_WCGOP %>% filter(fleet==5,year>2015))

# replace all previous commercial length comp with the updated data
# there are some remaining length comps from rec: fleet 3,6,7,8,9,10,11,12
inputs$dat$lencomp <- inputs$dat$lencomp %>% 
  filter(!fleet %in%c(1,2,4,5)) %>% #remove commercial fleet
  bind_rows(CA_TWL_PacFIN_WCGOP_length, #add our updated commercial fleet
      CA_NONTWL_PacFIN_length,
      CA_NONTWL_WCGOP_length, 
      ORWA_TWL_PacFIN_WCGOP_length,
      ORWA_NONTWL_PacFIN_WCGOP_length)

# overwrite data file
SS_write(inputs, dir = file.path(getwd(), "model", "updated_catch_indices_comlencomp_20250414"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "updated_catch_indices_comlencomp_20250414"))

run(dir = file.path(getwd(), "model", "updated_catch_indices_comlencomp_20250414"), 
    show_in_console = TRUE, extras = "-nohess")

replist <- SS_output(dir = file.path(getwd(), "model", "updated_catch_indices_comlencomp_20250414"))
SS_plots(replist)

#compare updataed ss3 exe, updated historical catch, and updated historical catch + extended catch
#models <- list.dirs(file.path(getwd(), "model"), recursive = FALSE)
#models <- models[c(5,12,11)] #CHECK THIS EVERY TIME
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "updated_historical_and_extended_catch_20250414")),
            paste0(file.path(getwd(), "model", "updated_historical_and_extended_indices_20250414")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_comlencomp_20250414")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", 
                                      "6_add_commlencomp"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", 
                                   "updated historical and extended catch", 
                                   "+ updated historical and extended indices", 
                                   "+ extended commecial length comps"),
                  print = TRUE
)



#################################################################################
#### UPDATED SS3 EXE, UPDATED HISTORICAL (< YEAR 2017) AND EXTENDED CATCH #######
####           AND UPDATED INDICES + COMMERCIAL LENCOMP + REC LENCOMP     #######
#################################################################################

# copy model starters and data file from prev run
copy_SS_inputs(
  dir.old = file.path(getwd(), "model", "updated_catch_indices_comlencomp_20250414"), 
  dir.new = file.path(getwd(), "model", "updated_catch_indices_comlencomp_reclencomp_20250414"),
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

inputs <- SS_read(dir = file.path(getwd(), "model", "updated_catch_indices_comlencomp_reclencomp_20250414"))
file_path = "Data/processed/rec_comps/"

# CA_REC, RecFin and Don's data, 1979-2024
  # Remember, we filtered out 2020 data because there was only 1 length available.
  # There was a perfect match for data, so no updates for old data. 
  # Just add the new stuff on top, with fixed Nsamps

  # Use this first section to grab the old data with out any changes!
ca_rec_len <- inputs$dat$lencomp  |>
  filter(fleet == 3) 
  # For the Update, add this next section to add data from 2017-2024
new_ca_rec_len <- read_csv(paste0(file_path,'ca_rec_lengths.csv')) 
names(new_ca_rec_len) <- names(ca_rec_len) # Replace col names so they match everything else
new_ca_rec_len <- new_ca_rec_len |>
  filter(year >= 2017) # only grab newest years
  # Calculate Nsamps using linear equation y = 4.6 + 0.732x
x <- new_ca_rec_len$Nsamp
y <-  4.6 + 0.732*x
new_ca_rec_len$Nsamp <- y
  # put them together
ca_rec_len <- rbind(ca_rec_len,new_ca_rec_len) 

# OR_REC, MRFFS and ORBS combined, 1979-2024
  # There was a *close* match for data, so no updates for old data. 
  # Might be worth investigating these data sources for the future assessment.
  # Just add the new stuff on top, with fixed Nsamps

  # Use this first section to grab the old data with out any changes!
or_rec_len <- inputs$dat$lencomp  |>
  filter(fleet == 6)
  # For the Update, add this next section to add data from 2017-2024
new_or_rec_len <- read_csv(paste0(file_path,'or_rec_lengths.csv'))
names(new_or_rec_len) <- names(or_rec_len) # Replace col names so they match everything else
new_or_rec_len <- new_or_rec_len |>
  filter(year >= 2017) # only grab newest years
  # Calculate Nsamps using linear equation y = 0.341 + 1.1x
x <- new_or_rec_len$Nsamp
y <-  0.341 + 1.1*x
new_or_rec_len$Nsamp <- y
  # put them together
or_rec_len <- rbind(or_rec_len,new_or_rec_len) 

# WA_REC, 1981, 1987, 1996-2024
  # There was a *close* match for data, no updates for old data. 
  # Might be worth investigating these data sources for the future assessment.
  # Just add the new stuff on top, with fixed Nsamps

  # Use this first section to grab the old data with out any changes!
wa_rec_len <- inputs$dat$lencomp  |>
  filter(fleet == 7)
  # For the Update, add this next section to add data from 2017-2024
new_wa_rec_len <- read_csv(paste0(file_path,'wa_rec_lengths.csv'))
names(new_wa_rec_len) <- names(wa_rec_len) # Replace col names so they match everything else
new_wa_rec_len <- new_wa_rec_len |>
  filter(year >= 2017) # only grab newest years, no data for 2016
  # Calculate Nsamps using linear equation y = 2.02 + 0.17x
x <- new_wa_rec_len$Nsamp
y <-  2.02 + 0.17*x
new_wa_rec_len$Nsamp <- y
  # put them together
wa_rec_len <- rbind(wa_rec_len,new_wa_rec_len) 

# CA_OBS, 1987-2024
  # There was a *close* match for data, no updates for old data. 
  # Might be worth investigating these data sources for the future assessment.
  # Just add the new stuff on top, with fixed Nsamps

  # Use this first section to grab the old data with out any changes!
ca_obs_len <- inputs$dat$lencomp  |>
  filter(fleet == 8)
  # For the Update, add this next section to add data from 2017-2024
new_ca_obs_len <- read_csv(paste0(file_path,'ca_obs_lengths.csv'))
names(new_ca_obs_len) <- names(ca_obs_len) # Replace col names so they match everything else
new_ca_obs_len <- new_ca_obs_len |>
  filter(year >= 2017) # only grab newest years
  # Calculate Nsamps using linear equation y = 1.48 + 0.73x
x <- new_ca_obs_len$Nsamp
y <-  1.48 + 0.73*x
new_ca_obs_len$Nsamp <- y
  # put them together
ca_obs_len <- rbind(ca_obs_len,new_ca_obs_len) 

# OR_OBS, 2003-2024
  # There was a perfect match for length data. 
  # However, the Nsamps in the 2017 assessment are whole numbers.
  # For some reason they were rounded. Vlada found the raw Nsamp numbers. So for the update, we will replace them.
  # Also fix the Nsamps using linear equation

  # Use this first section to grab the old data with out any changes!
or_obs_len <- inputs$dat$lencomp  |>
  filter(fleet == 9)
  # Fix Nsamps so they aren't rounded numbers using Vlada's data
or_obs_len$Nsamp <- c(2.276,13.898,15.312,30.348,30.176,29.142,18.416,14.76,15.14,41.42,26.658,34.626,18.002,19.864)
  # For the Update, use only the new data, so that it has both updated years and updated Nsamps 
new_or_obs_len <- read_csv(paste0(file_path,'or_obs_lengths.csv'))
names(new_or_obs_len) <- names(or_obs_len) # Replace col names so they match everything else
new_or_obs_len <- new_or_obs_len |>
  filter(year >= 2017) # only grab newest years
  # Calculate Nsamps using linear equation y = 5.76 + 0.415x
x <- new_or_obs_len$Nsamp
y <-  5.76 + 0.415*x
new_or_obs_len$Nsamp <- y
  # put them together
or_obs_len <- rbind(or_obs_len,new_or_obs_len) 

# replace all previous rec length comp with the updated data
# there are some remaining length comps from the survey: fleet 10,11,12
inputs$dat$lencomp <- inputs$dat$lencomp %>% 
  filter(!fleet %in%c(3,6,7,8,9)) %>% #remove rec fleets
  bind_rows(ca_rec_len, #add our updated rec fleets
            or_rec_len,
            wa_rec_len, 
            ca_obs_len,
            or_obs_len) %>%
  arrange(fleet,year) # reorder the data so it matches the old datafile structure

# overwrite data file
SS_write(inputs, dir = file.path(getwd(), "model", "updated_catch_indices_comlencomp_reclencomp_20250414"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "updated_catch_indices_comlencomp_reclencomp_20250414"))

run(dir = file.path(getwd(), "model", "updated_catch_indices_comlencomp_reclencomp_20250414"), 
    show_in_console = TRUE, extras = "-nohess")

replist <- SS_output(dir = file.path(getwd(), "model", "updated_catch_indices_comlencomp_reclencomp_20250414"))
SS_plots(replist)

#compare updataed ss3 exe, updated historical catch, and updated historical catch + extended catch
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "updated_historical_and_extended_catch_20250414")),
            paste0(file.path(getwd(), "model", "updated_historical_and_extended_indices_20250414")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_comlencomp_20250414")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_comlencomp_reclencomp_20250414")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", 
                                      "7_add_reclencomp"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", 
                                   "updated historical and extended catch", 
                                   "+ updated historical and extended indices",
                                   "+ extended commecial length comps", 
                                   "+ extended recreational length comps"),
                  print = TRUE
)


#################################################################################
####   UPDATED SS3 EXE, UPDATED HISTORICAL (< YEAR 2017) AND EXTENDED CATCH  ####
#### UPDATED HISTORICAL AND EXTENDED INDICES + COMMERCIAL LENCOMP + REC LENCOMP #
####                  + SURVEY LENCOMP                                       #### 
#################################################################################

# copy model starters and data file from prev run
copy_SS_inputs(
  dir.old = file.path(getwd(), "model", "updated_catch_indices_comlencomp_reclencomp_20250414"), 
  dir.new = file.path(getwd(), "model", "updated_catch_indices_comlencomp_reclencomp_surveylencomp_20250414"),
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

inputs <- SS_read(dir = file.path(getwd(), "model", "updated_catch_indices_comlencomp_reclencomp_surveylencomp_20250414"))

  # Nsamp method used for all survey length comps is the old Stewart Hamel method from the 2017 assessment where
  # Nsamp = n_trips + 0.0707 * n_fish when n_fish/n_tows < 55 and
  # Nsamp = 4.89 * n_trips when n_fish/n_tows >= 55

# Triennial survey - fleet 10
TRI_lengths <- inputs$dat$lencom |>
  filter(fleet == 10)

# NWFSC survey - fleet 11
NWFSC_lengths_old <- inputs$dat$lencom |>
  filter(fleet == 11)
NWFSC_lengths_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "NWFSC.Combo_and_Tri_length_comps",
  "NWFSC.Combo_length_cm_unsexed_raw_10_74_yelloweye rockfish_groundfish_slope_and_shelf_combination_survey.csv"
)) |>
  filter(year > 2016)
colnames(NWFSC_lengths_new) <- colnames(NWFSC_lengths_old)
NWFSC_lengths <- rbind(NWFSC_lengths_old, NWFSC_lengths_new)

# IPHC ORWA - fleet 12
  # IPHC bio data notes:
  # Total_Biodata_Comb includes all Yelloweye biodata collected from IPHC FISS 2A 
  # from 2022-2023 and stlkeys for association with the IPHC effort database, and 
  # some location information pulled from the IPHC effort database
  # Experimental gear catch and catch where species could not be rectified against 
  # onboard tag documentation were removed.
  # 2A was not fished in 2020 and 2024.  Oregon stations were not fished in 2023.
  # Oregon rockfish were not tagged in 2021 and fish cannot be reconciled with IPHC 
  # effort data.
  # IPHC has not provided onboard tag information for Oregon stations in 2019. 2019 
  # landings currently cannot be reconciled with IPHC effort data.
  # From the 2017 assessment, it looks like Jason and Vlada used only lengths that also
  # had ages EXCEPT for 2016 where they used all the lengths, we will keep their data for this
  # year because there were not many samples for this year and only using lengths
  # that have ages for 2016 truncates the age data
IPHC_lengths_old <- inputs$dat$lencom |>
  filter(fleet == 12)
IPHC_lengths_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "IPHC_bio_data",
  "iphc_length_comps.csv"
)) |>
  filter(year > 2016)
colnames(IPHC_lengths_new) <- colnames(IPHC_lengths_old)
IPHC_lengths <- rbind(IPHC_lengths_old, IPHC_lengths_new)

# replace all previous survey length comp with the updated data
inputs$dat$lencomp <- inputs$dat$lencomp %>% 
  filter(!fleet %in%c(10,11,12)) %>% #remove rec fleets
  bind_rows(TRI_lengths, #add our updated rec fleets
            NWFSC_lengths,
            IPHC_lengths) %>%
  arrange(fleet,year) # reorder the data so it matches the old datafile structure

all_lencomp <- inputs$dat$lencomp

# overwrite data file
SS_write(inputs, dir = file.path(getwd(), "model", "updated_catch_indices_comlencomp_reclencomp_surveylencomp_20250414"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "updated_catch_indices_comlencomp_reclencomp_surveylencomp_20250414"))

run(dir = file.path(getwd(), "model", "updated_catch_indices_comlencomp_reclencomp_surveylencomp_20250414"), 
    show_in_console = TRUE, extras = "-nohess")

replist <- SS_output(dir = file.path(getwd(), "model", "updated_catch_indices_comlencomp_reclencomp_surveylencomp_20250414"))
SS_plots(replist)

#compare updataed ss3 exe, updated historical catch, and updated historical catch + extended catch
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "updated_historical_and_extended_catch_20250414")),
            paste0(file.path(getwd(), "model", "updated_historical_and_extended_indices_20250414")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_comlencomp_reclencomp_20250414")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_comlencomp_reclencomp_surveylencomp_20250414")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", 
                                      "8_add_surveylencomp"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", 
                                   "updated historical and extended catch",
                                   "+ updated historical and extended indices",
                                   "+ extended comm and rec length comps",
                                   "+ extended survey length comps"),
                  print = TRUE
)


#################################################################################
####   UPDATED SS3 EXE, UPDATED HISTORICAL (< YEAR 2017) AND EXTENDED CATCH  ####
#### UPDATED HISTORICAL AND EXTENDED INDICES + COMMERCIAL LENCOMP + REC LENCOMP #
####  + SURVEY LENCOMP + UPDATED HISTORICAL COMMERCIAL AGECOMP (YEAR<2016)   #### 
#################################################################################

# copy model starters and data file from prev run
copy_SS_inputs(
  dir.old = file.path(getwd(), "model", "updated_catch_indices_comlencomp_reclencomp_surveylencomp_20250414"), 
  dir.new = file.path(getwd(), "model", "updated_catch_indices_lencompall_upcomagecomp_20250414"),
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

inputs <- SS_read(dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upcomagecomp_20250414"))

#because we are changing historical data we first to a run without extending to 2024
inputs$dat$endyr <- 2016

# load our updated data 
file_path = "Data/processed/length_age_comps/"
## length comps, maal and caal from PacFIN AND WCGOP combined
raw_age_caal_PacFIN_WCGOP <- read.csv(paste0(file_path,'Commercial_caal_PacFIN_WCGOP_forSS.csv'))
raw_age_comps_PacFIN_WCGOP <- read.csv(paste0(file_path,'Commercial_age_comps_PacFIN_WCGOP_forSS.csv'))

## length comps, maal and caal from PacFIN only
raw_age_caal_PacFIN <- read.csv(paste0(file_path,'Commercial_caal_PacFIN_forSS.csv'))
raw_age_comps_PacFIN <- read.csv(paste0(file_path,'Commercial_age_comps_PacFIN_forSS.csv'))

## length comps, maal and caal from PacFIN AND WCGOP combined
raw_age_caal_WCGOP <- read.csv(paste0(file_path,'Commercial_caal_WCGOP_forSS.csv'))
raw_age_comps_WCGOP <- read.csv(paste0(file_path,'Commercial_age_comps_WCGOP_forSS.csv'))

# arrange naming
names(raw_age_caal_PacFIN_WCGOP) <- names(raw_age_caal_PacFIN) <- names(raw_age_caal_WCGOP) <- names(inputs$dat$agecomp)
names(raw_age_comps_PacFIN_WCGOP) <- names(raw_age_comps_PacFIN) <- names(raw_age_comps_WCGOP) <- names(inputs$dat$agecomp)

# add updated caal and maal from commercial fleets 
# NB: because of doubling issues in 2017 file we are using our update data for all fleets

# reminder of commercial fleet no. CA.TWL=1,CA.NONTWL=2,ORWA.TWL=4,ORWA.NONTWL=5

# no age data from CA_TWL

# CA_NONTWL, CAAL and MAAL, data from CDFW, Traci file
## 1978-1988 - no new data 
CA_NONTWL_TraciCDFW_caal <- raw_age_caal_PacFIN %>% filter(fleet==2)
CA_NONTWL_TraciCDFW_maal <- raw_age_comps_PacFIN %>% filter(fleet==-2)

# CA_NONTWL, CAAL, WCGOP
## 2005 - no new data
CA_NONTWL_WCGOP_caal <- raw_age_caal_WCGOP %>% filter(fleet==2,year==2005)
CA_NONTWL_WCGOP_maal <- raw_age_comps_WCGOP %>% filter(fleet==-2,year==2005) 

# ORWA_TWL, CAAL, PacFIN and WCGOP combined
## use 2017 data for 2001-2015 (2016 was included in 2017 but we are updating it with new data),
## and bring new data for 2016-2024
ORWA_TWL_PacFIN_WCGOP_caal <- raw_age_caal_PacFIN_WCGOP %>% filter(fleet==4)
ORWA_TWL_PacFIN_WCGOP_maal <-raw_age_comps_PacFIN_WCGOP %>% filter(fleet==-4)

# ORWA_NONTWL, CAAL, PacFIN and WCGOP combined
## using 2017 data for 2001-2015, and 2025 data update for 2016-2024
ORWA_NONTWL_PacFIN_WCGOP_caal <- raw_age_caal_PacFIN_WCGOP %>% filter(fleet==5)
ORWA_NONTWL_PacFIN_WCGOP_maal <- raw_age_comps_PacFIN_WCGOP %>% filter(fleet==-5)

# replace all previous survey length comp with the updated data
inputs$dat$agecomp <- inputs$dat$agecomp %>% 
  filter(!fleet %in%c(1,2,4,5,-1,-2,-4,-5)) %>% #remove commercial fleets
  bind_rows( #add our updated commercial fleets
            CA_NONTWL_TraciCDFW_caal,CA_NONTWL_TraciCDFW_maal,
             CA_NONTWL_WCGOP_caal,CA_NONTWL_WCGOP_maal,
             ORWA_TWL_PacFIN_WCGOP_caal,ORWA_TWL_PacFIN_WCGOP_maal,
             ORWA_NONTWL_PacFIN_WCGOP_caal,ORWA_NONTWL_PacFIN_WCGOP_maal) %>%
  arrange(fleet,year) # reorder the data so it matches the old datafile structure

comm_agecomp <- inputs$dat$agecomp

# overwrite data file
SS_write(inputs, dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upcomagecomp_20250414"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upcomagecomp_20250414"))

run(dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upcomagecomp_20250414"), 
    show_in_console = TRUE, extras = "-nohess")

replist <- SS_output(dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upcomagecomp_20250414"))
SS_plots(replist)

#compare updataed ss3 exe, updated historical catch, and updated historical catch + extended catch
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "updated_historical_and_extended_catch_20250414")),
            paste0(file.path(getwd(), "model", "updated_historical_and_extended_indices_20250414")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_comlencomp_reclencomp_surveylencomp_20250414")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_lencompall_upcomagecomp_20250414")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", 
                                      "9_add_historicalcomagecomp"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", 
                                   "updated historical and extended catch", 
                                   "+ updated historical and extended indices",
                                   "+ extended length comps",
                                   "+ updated historical comm age comps"),
                  print = TRUE
)

#################################################################################
####   UPDATED SS3 EXE, UPDATED HISTORICAL (< YEAR 2017) AND EXTENDED CATCH  ####
#### AND UPDATED INDICES + COMMERCIAL LENCOMP + REC LENCOMP + SURVEY LENCOMP ####
####       COMMERCIAL AGECOMP UPDATED AND EXTENDED (END YEAR=2024)        #######
#################################################################################

# copy model starters and data file from prev run
copy_SS_inputs(
  dir.old = file.path(getwd(), "model", "updated_catch_indices_lencompall_upcomagecomp_20250414"), 
  dir.new = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_20250414"),
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

inputs <- SS_read(dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_20250414"))

#now we are extending to 2024
inputs$dat$endyr <- 2024

inputs$dat$catch <- all_catch

inputs$dat$CPUE <- all_indices

inputs$dat$lencomp <- all_lencomp

inputs$dat$agecomp <- comm_agecomp

# overwrite data file
SS_write(inputs, dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_20250414"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_20250414"))

run(dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_20250414"), 
    show_in_console = TRUE, extras = "-nohess")

replist <- SS_output(dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_20250414"))
SS_plots(replist)

#compare updataed ss3 exe, updated historical catch, and updated historical catch + extended catch
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "updated_historical_and_extended_catch_20250414")),
            paste0(file.path(getwd(), "model", "updated_historical_and_extended_indices_20250414")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_comlencomp_reclencomp_surveylencomp_20250414")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_lencompall_upcomagecomp_20250414")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_20250414")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", 
                                      "10_add_upextcomagecomp"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)",
                                   "updated historical and extended catch", 
                                   "+ updated historical and extended indices",
                                   "+ extended length comps",
                                   "+ updated historical comm age comps",
                                   "+ extended comm age comps"),
                  print = TRUE
)


#################################################################################
####   UPDATED SS3 EXE, UPDATED HISTORICAL (< YEAR 2017) AND EXTENDED CATCH  ####
#### AND UPDATED INDICES + COMMERCIAL LENCOMP + REC LENCOMP + SURVEY LENCOMP ####
####       + COMMERCIAL AGECOMP UPDATED AND EXTENDED (END YEAR=2024)         ####
####                   + REC AGECOMP UPDATED (YEAR<2016)                     ####
#################################################################################

# copy model starters and data file from prev run
copy_SS_inputs(
  dir.old = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_20250414"), 
  dir.new = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_uprecagecomp_20250414"),
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

inputs <- SS_read(dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_uprecagecomp_20250414"))
file_path = "Data/processed/rec_comps/"

#because we are changing historical data we first to a run without extending to 2024
inputs$dat$endyr <- 2016

# CA_REC CAAL 1983-1996, aged by WDFW
  # *no change* pull in old data and use in all model runs
  # Future assessments: find the Traci file and make sure the ages and lengths are correct.
ca_rec_caal_1983_1996 <- inputs$dat$agecomp |>
  filter(fleet == 3) |>
  filter(year == 1983 | year == 1996) |>
  filter(ageerr == 1)

# CA_REC MAAL Ghost 1983-1996, aged by WDFW
  # *no change* pull in old data and use in all model runs
ca_rec_maal_1983_1996 <- inputs$dat$agecomp |>
  filter(fleet == -3) |>
  filter(year == 1983 | year == 1996) |>
  filter(ageerr == 1)

# CA_REC CAAL Don Pearson Data 1979-1984, aged by Betty
  # *divide all Nsamp and Ages by 2* - everything was doubled by accident in last assessment
  # Use this first section to grab the old data with out any changes! 
ca_rec_caal_Don <- inputs$dat$agecomp |>
  filter(fleet == 3) |>
  filter(year >= 1979 & year <= 1984) |>
  filter(ageerr == 2)
  # For the Update, add this next section to correct for the doubling mistake
ca_rec_caal_Don[,9:75] <- ca_rec_caal_Don[,9:75]/2

# CA_REC CAAL John Budrick Data 2009-2016, aged by Betty
  # *divide all Nsamp and Ages by 2* - No new data, all data we got matched perfectly with 2017 assessment data, so just use old data.
  # Use this first section to grab the old data with out any changes! 
ca_rec_caal_John <- inputs$dat$agecomp |>
  filter(fleet == 3) |>
  filter(year >= 2009 & year <= 2016)
  # For the Update, add this next section to correct for the doubling mistake
ca_rec_caal_John[,9:75] <- ca_rec_caal_John[,9:75]/2

# CA_REC MAAL Ghost, Don's data
  # *need to rebuild from CAAL* - Nsamp column was duplicated (and is wrong), so it shifted all of the ages forward by 1 and dropped the last age column
  # Use this first section to grab the old data with out any changes! 
old_ca_rec_maal_Don <- inputs$dat$agecomp |>
  filter(fleet == -3) |>
  filter(year >= 1979 & year <= 1984) |>
  filter(ageerr == 2)
  # For the Update, add this next section to fix old mistake
  # Take CAAL and group it so it matches MAAL structure, re-add the correct columns
ca_rec_maal_Don <- ca_rec_caal_Don %>%
  group_by(year) %>%  # Retain key columns
  summarise(across(starts_with("a"), \(x) sum(x, na.rm = TRUE)),  # Sum age columns
            Nsamp = sum(Nsamp, na.rm = TRUE), .groups = "drop")  # Sum input_n
ca_rec_maal_Don <- cbind(old_ca_rec_maal_Don[,1:8],ca_rec_maal_Don[,69],ca_rec_maal_Don[,3:68])

# CA_REC MAAL Ghost, John's data
  # *need to rebuild from CAAL* - Nsamp column is totally wrong, All the age data looks correct, but how they added the Nsamps together is off. Do the same thing as above and just rebuild from CAAL. Confirmed that the data matched the MAAL that I calculated using nwfsc code.
  # Also, Vlada says that Nsamp column for MAAL data DOES NOT MATTER...but for an update, lets at least make it consistent with everything else in that Nsamp = "total samples".
  # It is a lot easier to look for mistakes in the data if the Nsamps = total samples, and is consistent throughout the datafile.
  # Use this first section to grab the old data with out any changes! 
old_ca_rec_maal_John <- inputs$dat$agecomp |>
  filter(fleet == -3) |>
  filter(year >= 2009 & year <= 2016)
  # For the Update, add this next section to fix old mistake
  # Take CAAL and group it so it matches MAAL structure, re-add the correct columns
ca_rec_maal_John <- ca_rec_caal_John %>%
  group_by(year) %>%  # Retain key columns
  summarise(across(starts_with("a"), \(x) sum(x, na.rm = TRUE)),  # Sum age columns
            Nsamp = sum(Nsamp, na.rm = TRUE), .groups = "drop")  # Sum input_n
ca_rec_maal_John <- cbind(old_ca_rec_maal_John[,1:8],ca_rec_maal_John[,69],ca_rec_maal_John[,3:68])

# OR_REC CAAL
  # *doubling issue here too* - Also fixing Ageing Error column and adding updated Ages
  # The extra ages in 2015 were filtered out because they were sex == U, but since that doesnt matter any more, Ali suggests we include them
  # Use this first section to grab the old data with out any changes! 
  # Bring in old data from 1979-2016
or_rec_caal <- inputs$dat$agecomp |>
  filter(fleet == 6) |>
  filter(year >= 1979)
  # Next, fix doubling problem, without adding any new data
  # Use for a model run where we fix issues before adding new data
or_rec_caal[,9:75] <- or_rec_caal[,9:75]/2
  # Next problem is to fix the age column.Below is the correct age location and years according to Ali
  # 1979 - 2000 = WDFW
  # 2001 = WDFW(40) /unknown (assumed NWFSC) (10)
  # 2002 =WDFW (n = 73)
  # 2009 - 2016 = NWFSC
or_rec_caal[144:160,6] <- 1 # changing 2001 and 2002 = WDFW
or_rec_caal[161:193,6] <- 2 # changing 2009-2016 = NWFSC
  # Last, Bring in new 2009-2016 data - some ages from 2015 were added
new_or_rec_caal <- read_csv(paste0(file_path,'or_rec_caal.csv'))
names(new_or_rec_caal) <- names(or_rec_caal)
or_rec_caal <- rbind(or_rec_caal|>filter(year<=2002),new_or_rec_caal|>filter(year>=2009))

# OR_REC MAAL ghost
  # *why are Nsamps not whole numbers?* - It doesn't matter...but it is a lot easier to double check the data if Nsamps are "total samples", so rebuild using up to date CAAL data
  # Use this first section to grab the old data with out any changes!
  # load old MAAL so we can use the first 8 columns and double check the data
old_or_rec_maal <- inputs$dat$agecomp |>
  filter(fleet == -6)
  # For the Update, add this next section to fix Nsamps
  # Take CAAL and group it so it matches MAAL structure, re-add the correct columns
or_rec_maal <- or_rec_caal %>%
  group_by(year) %>%  # Retain key columns
  summarise(across(starts_with("a"), \(x) sum(x, na.rm = TRUE)),  # Sum age columns
            Nsamp = sum(Nsamp, na.rm = TRUE), .groups = "drop")  # Sum input_n
or_rec_maal <- cbind(old_or_rec_maal[,1:8],or_rec_maal[,69],or_rec_maal[,3:68])

# WA_REC CAAL
  # *Doubling problem, however, Fabio (state rep) provided new data for the entire time series and recommends we use all new data* - some of the old ages have been updated.
  # Use this first section to grab the old data with out any changes!
old_wa_rec_caal <- inputs$dat$agecomp |>
  filter(fleet == 7)
  # Use this section to fix the doubling problem for OLD data
old_wa_rec_caal[,9:75] <- old_wa_rec_caal[,9:75]/2
  # For the Update, add this next section to use the updated ages (Fabio), ignore all old data
  # load new processed data from most recent RecFin pull
wa_rec_caal <- read_csv(paste0(file_path,'wa_rec_caal.csv'))
names(wa_rec_caal) <- names(old_wa_rec_caal) # Replace col names from another MAAL dataset so they match everything else

# WA_REC MAAL
  # *Just use new data* - some of the old ages have been updated.
  # Use this first section to grab the old data with out any changes!
old_wa_rec_maal <- inputs$dat$agecomp |>
  filter(fleet == -7)
  # For the Update, add this next section to use the updated ages (Fabio), ignore all old data
  # load new processed data from most recent RecFin pull
wa_rec_maal <- read_csv(paste0(file_path,'wa_rec_maal.csv'))
names(wa_rec_maal) <- names(old_wa_rec_maal) # Replace col names from another MAAL dataset so they match everything else


# replace all previous CAAL and MAAL rec age comp with the updated data
inputs$dat$agecomp <- inputs$dat$agecomp %>% 
  filter(!fleet %in%c(3,6,7,-3,-6,-7)) %>% #remove all rec fleets
  bind_rows(ca_rec_caal_1983_1996,
            ca_rec_maal_1983_1996,
            ca_rec_caal_Don,
            ca_rec_maal_Don,
            ca_rec_caal_John,
            ca_rec_maal_John,
            or_rec_caal,
            or_rec_maal,
            wa_rec_caal,
            wa_rec_maal) %>%
  arrange(fleet,year) # reorder the data so it matches the old datafile structure

comm_rec_agecomp <- inputs$dat$agecomp

# overwrite data file
SS_write(inputs, dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_uprecagecomp_20250414"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_uprecagecomp_20250414"))

run(dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_uprecagecomp_20250414"), 
    show_in_console = TRUE, extras = "-nohess")

replist <- SS_output(dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_uprecagecomp_20250414"))
SS_plots(replist)

#compare updataed ss3 exe, updated historical catch, and updated historical catch + extended catch
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "updated_historical_and_extended_catch_20250414")),
            paste0(file.path(getwd(), "model", "updated_historical_and_extended_indices_20250414")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_comlencomp_reclencomp_surveylencomp_20250414")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_20250414")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_uprecagecomp_20250414")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", 
                                      "11_add_uprecagecomp"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", 
                                   "updated historical and extended catch", 
                                   "+ updated historical and extended indices",
                                   "+ extended length comps",
                                   "+ updated historical and extended comm age comps",
                                   "+ updated historical rec age comps"),
                  print = TRUE)


#################################################################################
####   UPDATED SS3 EXE, UPDATED HISTORICAL (< YEAR 2017) AND EXTENDED CATCH  ####
#### AND UPDATED INDICES + COMMERCIAL LENCOMP + REC LENCOMP + SURVEY LENCOMP ####
####       + COMMERCIAL AGECOMP UPDATED AND EXTENDED (END YEAR=2024)         ####
####         + REC AGECOMP UPDATED AND EXTENDED (END YEAR=2024)              ####
#################################################################################

# copy model starters and data file from prev run
copy_SS_inputs(
  dir.old = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_uprecagecomp_20250414"), 
  dir.new = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_20250414"),
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

inputs <- SS_read(dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_20250414"))

#extend to 2024
inputs$dat$endyr <- 2024

inputs$dat$catch <- all_catch

inputs$dat$CPUE <- all_indices

inputs$dat$lencomp <- all_lencomp

inputs$dat$agecomp <- comm_rec_agecomp

# overwrite data file
SS_write(inputs, dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_20250414"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_20250414"))

run(dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_20250414"), 
    show_in_console = TRUE, extras = "-nohess")

replist <- SS_output(dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_20250414"))
SS_plots(replist)

#compare updataed ss3 exe, updated historical catch, and updated historical catch + extended catch
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "updated_historical_and_extended_catch_20250414")),
            paste0(file.path(getwd(), "model", "updated_historical_and_extended_indices_20250414")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_comlencomp_reclencomp_surveylencomp_20250414")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_20250414")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_uprecagecomp_20250414")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_20250414")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", 
                                      "12_add_upextrecagecomp"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", 
                                   "updated historical and extended catch", 
                                   "+ updated historical and extended indices",
                                   "+ extended length comps",
                                   "+ updated historical and extended comm age comps",
                                   "+ updated historical rec age comps",
                                   "+ extended rec age comps"),
                  print = TRUE)

#################################################################################
####   UPDATED SS3 EXE, UPDATED HISTORICAL (< YEAR 2017) AND EXTENDED CATCH  ####
#### AND UPDATED INDICES + COMMERCIAL LENCOMP + REC LENCOMP + SURVEY LENCOMP ####
####       + COMMERCIAL AGECOMP UPDATED AND EXTENDED (END YEAR=2024)         ####
####         + REC AGECOMP UPDATED AND EXTENDED (END YEAR=2024)              ####
####                      + SURVEY AGECOMPS                                  ####
#################################################################################

# copy model starters and data file from prev run
copy_SS_inputs(
  dir.old = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_20250414"), 
  dir.new = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_surveyagecomp_20250414"),
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

inputs <- SS_read(dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_surveyagecomp_20250414"))

# Nsamp method used for all survey maal is the old Stewart Hamel method from the 2017 assessment where
# Nsamp = n_trips + 0.0707 * n_fish when n_fish/n_tows < 55 and
# Nsamp = 4.89 * n_trips when n_fish/n_tows >= 55

# NWFSC survey CAAL and MAAL - fleet -11 and 11
  # QUESTION: The age comps were a little different between the old assessment and the new assessment, are we
  # going to use updated ages? for all years?
  # For this run, use all new data, but figure out why Nsamps are whole numbers
NWFSC_caal_old <- inputs$dat$agecom |>
   filter(fleet == 11)
NWFSC_caal_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "NWFSC.Combo_CAAL",
  "processed_one_sex_caal.csv"
)) |>
  select(year, month, fleet, sex, partition, ageerr, Lbin_lo, Lbin_hi, Nsamp, everything())
# |>
#   filter(year > 2016)
colnames(NWFSC_caal_new) <- colnames(NWFSC_caal_old)
NWFSC_caal <- NWFSC_caal_new
# NWFSC_caal <- rbind(NWFSC_caal_old, NWFSC_caal_new)

NWFSC_maal_old <- inputs$dat$agecom |>
   filter(fleet == -11)
NWFSC_maal_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "NWFSC.Combo_age_comps",
  "NWFSC.Combo_age_unsexed_raw_0_65_yelloweye rockfish_groundfish_slope_and_shelf_combination_survey.csv"
)) |>
  mutate(
    ageerr = 2,
    fleet = -11
  ) |>
  select(year, month, fleet, sex, partition, ageerr, Lbin_lo, Lbin_hi, Nsamp, everything())
# |>
#   filter(year > 2016) 
colnames(NWFSC_maal_new) <- colnames(NWFSC_maal_old)
NWFSC_maal <- NWFSC_maal_new
# NWFSC_maal <- rbind(NWFSC_maal_old, NWFSC_maal_new)

NWFSC_ages <- rbind(NWFSC_caal, NWFSC_maal)

# IPHC survey CAAL and MAAL - fleet -12 and 12
# Data provided by Fabio, bio comps processed by Elizabeth
IPHC_caal_old <- inputs$dat$agecom |>
  filter(fleet == 12) #|>
  #filter(year <= 2016)
IPHC_caal_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "IPHC_bio_data",
  "iphc_caal.csv"
)) #|>
  #filter(year > 2016)
colnames(IPHC_caal_new) <- colnames(IPHC_caal_old)
IPHC_caal <- rbind(IPHC_caal_old, IPHC_caal_new)

IPHC_maal_old <- inputs$dat$agecom |>
  filter(fleet == -12) #|>
  #filter(year <= 2016)
IPHC_maal_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "IPHC_bio_data",
  "iphc_marginal_ages.csv"
)) #|>
  #filter(year > 2016)
colnames(IPHC_maal_new) <- colnames(IPHC_maal_old)
IPHC_maal <- rbind(IPHC_maal_old, IPHC_maal_new)

IPHC_ages <- rbind(IPHC_caal, IPHC_maal)

##########################
#need to add something like this

############################
# replace all previous CAAL and MAAL rec age comp with the updated data
inputs$dat$agecomp <- inputs$dat$agecomp %>% 
  filter(!fleet %in%c(11,12,-11,-12)) %>% #remove all rec fleets
  bind_rows(NWFSC_ages,
            IPHC_ages) %>%
  arrange(fleet,year) # reorder the data so it matches the old datafile structure

all_agecomp <- inputs$dat$agecomp

##################
#need to add something like this

######################################

# overwrite data file
SS_write(inputs, dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_surveyagecomp_20250414"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_surveyagecomp_20250414"))

run(dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_surveyagecomp_20250414"), 
    show_in_console = TRUE, extras = "-nohess")

replist <- SS_output(dir = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_surveyagecomp_20250414"))
SS_plots(replist)

#compare updataed ss3 exe, updated historical catch, and updated historical catch + extended catch
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "updated_historical_and_extended_catch_20250414")),
            paste0(file.path(getwd(), "model", "updated_historical_and_extended_indices_20250414")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_comlencomp_reclencomp_surveylencomp_20250414")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_20250414")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_20250414")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_surveyagecomp_20250414")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", 
                                      "13_add_surveyagecomp"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", 
                                   "updated historical and extended catch", 
                                   "+ updated historical and extended indices",
                                   "+ extended length comps",
                                   "+ updated historical and extended comm age comps",
                                   "+ updated historical and extended rec age comps",
                                   "+ extended survey age comps"),
                  print = TRUE)


###################################################################
#######                  TUNE COMPS                       #########
###################################################################

# copy model starters and data file from prev run
copy_SS_inputs(
  dir.old = file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_surveyagecomp_20250414"), 
  dir.new = file.path(getwd(), "model", "updated_alldata_tunecomps_20250416"),
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

#inputs <- SS_read(dir = file.path(getwd(), "model", "updated_alldata_tunecomps_20250416"))

get_ss3_exe(dir = file.path(getwd(), "model", "updated_alldata_tunecomps_20250416"))

run(dir = file.path(getwd(), "model", "updated_alldata_tunecomps_20250416"), 
    show_in_console = TRUE, extras = "-nohess")

replist <- SS_output(dir = file.path(getwd(), "model", "updated_alldata_tunecomps_20250416"))


##### Tune composition data ##### ----------------------------------------------
tunecomps_dir <- here::here("model/updated_alldata_tunecomps_20250416")

r4ss::tune_comps(
  replist, # use replist from previous run
  write = TRUE,
  niters_tuning = 2, 
  option = "Francis",
  dir = tunecomps_dir,
  show_in_console = TRUE,
  #extras = "-nohess", #run with hessian so we can run fitbias next
  exe = "ss3"
)

replist_tunecomps <- SS_output(dir = file.path(getwd(), "model", "updated_alldata_tunecomps_20250416"))

SS_plots(replist_tunecomps)

#compare updataed ss3 exe, updated historical catch, and updated historical catch + extended catch
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_surveyagecomp_20250414")),
            paste0(file.path(getwd(), "model", "updated_alldata_tunecomps_20250416")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", 
                                      "14_alldata_tunecomps"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", 
                                   "2025 updated all data",
                                   "+ tuned comps"),
                  print = TRUE)


###################################################################
#######       FIT RECRUITMENT BIAS RAMP                   #########
###################################################################

# change the recruitment bias adjustment

fitbias_dir <- here::here("model/updated_alldata_tunecomps_fitbias_20250416")

copy_SS_inputs(
  dir.old = tunecomps_dir,
  dir.new = fitbias_dir,
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

fitbias_plots <- here::here("model/updated_alldata_tunecomps_fitbias_20250416/plots")
#add this folder manually

r4ss::SS_fitbiasramp(
  replist_tunecomps, #use replist from previous run
  plot = FALSE,
  print = TRUE,
  plotdir = fitbias_plots,
  shownew = TRUE, #try this
  oldctl = file.path(tunecomps_dir, "yelloweye_control.ss"),
  newctl = file.path(fitbias_dir, "yelloweye_control.ss"),#this incorporates the suggested changes from the last run. I suppose it could be run twice to be even better. So then we will run it again below.
  startvalues = NULL,
  method = "BFGS",
  altmethod = "nlminb"
)

# Run model after fitbias
r4ss::get_ss3_exe(dir = fitbias_dir)

run(dir = fitbias_dir, show_in_console = TRUE)

replist_fitbias <- r4ss::SS_output(dir = fitbias_dir)

SS_plots(replist_fitbias)

#compare updataed ss3 exe, updated historical catch, and updated historical catch + extended catch
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_surveyagecomp_20250414")),
            paste0(file.path(getwd(), "model", "updated_alldata_tunecomps_20250416")),
            paste0(file.path(getwd(), "model", "updated_alldata_tunecomps_fitbias_20250416")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", 
                                      "15_alldata_tunecomps_fitbias"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", 
                                   "2025 updated all data",
                                   "+ tuned comps",
                                   "+ recruitment dev bias adj"),
                  print = TRUE)


###################################################################
#######       FIT RECRUITMENT BIAS RAMP SECOND TIME       #########
###################################################################

# change the recruitment bias adjustment AGAIN

fitbias_2_dir <- here::here("model/updated_alldata_tunecomps_fitbias_2_20250416")

copy_SS_inputs(
  dir.old = fitbias_dir,
  dir.new = fitbias_2_dir,
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

fitbias_2_plots <- here::here("model/updated_alldata_tunecomps_fitbias_2_20250416/plots")
#add this folder manually

r4ss::SS_fitbiasramp(
  replist_fitbias, #use replist from previous run
  plot = FALSE,
  print = TRUE,
  plotdir = fitbias_2_plots,
  shownew = TRUE, #try this
  oldctl = file.path(fitbias_dir, "yelloweye_control.ss"),
  newctl = file.path(fitbias_2_dir, "yelloweye_control.ss"),#this incorporates the suggested changes from the last run. I suppose it could be run twice to be even better. So then we will run it again below.
  startvalues = NULL,
  method = "BFGS",
  altmethod = "nlminb"
)

# Run model after fitbias
r4ss::get_ss3_exe(dir = fitbias_2_dir)

run(dir = fitbias_2_dir, show_in_console = TRUE)

replist_fitbias_2 <- r4ss::SS_output(dir = fitbias_2_dir)

SS_plots(replist_fitbias_2)

#compare updataed ss3 exe, updated historical catch, and updated historical catch + extended catch
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_surveyagecomp_20250414")),
            paste0(file.path(getwd(), "model", "updated_alldata_tunecomps_20250416")),
            paste0(file.path(getwd(), "model", "updated_alldata_tunecomps_fitbias_20250416")),
            paste0(file.path(getwd(), "model", "updated_alldata_tunecomps_fitbias_2_20250416")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", 
                                      "15_alldata_tunecomps_fitbias"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", 
                                   "2025 updated all data",
                                   "+ tuned comps",
                                   "+ recruitment dev bias adj",
                                   "+ recruitment dev bias adj x 2"),
                  print = TRUE)



###################################################################
#######               CTL FILE CHANGES                   #########
###################################################################

#check if the control file updated from the previous run with the rec dev bias adj

# Get inputs from 2025 assessment that ran with updated data
updated_alldata_tunecomps_fitbias_dir <- here::here("model", "updated_alldata_tunecomps_fitbias_2_20250416")

##### Update CTL file for 2025 assessment ##### ----------------------------------------
updated_ctlfile_dir <- here::here("model", "updated_alldata_tunecomps_fitbias_ctl_20250416")

copy_SS_inputs(
  dir.old = updated_alldata_tunecomps_fitbias_dir,
  dir.new = updated_ctlfile_dir,
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

inputs <- SS_read(dir = updated_ctlfile_dir)
#ctl <- inputs$ctl

# Update block end year (selectivity and biology (if used) time blocks)
# Update block end year (selectivity and biology (if used) time blocks)
inputs$ctl$Block_Design[[2]][2] <- 2024
inputs$ctl$Block_Design[[3]][2] <- 2024
inputs$ctl$Block_Design[[4]][2] <- 2024

# Need to update the Prior SD for M for Hamel method
inputs$ctl$MG_parms["NatM_p_1_Fem_GP_1", ]$PR_SD <- 0.31

# Update weight-length relationship
inputs$ctl$MG_parms["Wtlen_1_Fem_GP_1", ]$INIT <- 7.183309e-06 #update with standard_filtering = FALSE
inputs$ctl$MG_parms["Wtlen_1_Fem_GP_1", ]$PRIOR <- 7.183309e-06 #update with standard_filtering = FALSE
inputs$ctl$MG_parms["Wtlen_2_Fem_GP_1", ]$INIT <- 3.244801 #update with standard_filtering = FALSE
inputs$ctl$MG_parms["Wtlen_2_Fem_GP_1", ]$PRIOR <- 3.244801 #update with standard_filtering = FALSE

# Question: Switch do rec_dev to option 3? It's currently option 1 but I think
# most people are using option 2 or 3
# Answer: We can stick with option 1 for the base model but we can also try it
# out with option 2 or 3
# ctl$do_recdev <- 2
# ctl$do_recdev <- 3

# Change last year of main rec_dev, for the last assessment this was 2015 so I
# would assume this would be 2023 for this year?
inputs$ctl$MainRdevYrLast <- 2023 #Aaron Berger recommended changing this to ~2019, because recruitment isn't that informed close to the end year

# Change selparm bounds that are being hit
# Size_DblN_peak_10_TRI_ORWA(10)
#ctl$size_selex_parms[49, ]$HI <- 87

# Remove 4 params that have priors but are not estimated by changing prior type to 0
inputs$ctl$MG_parms["NatM_p_1_Fem_GP_1", ]$PR_type <- 0
inputs$ctl$MG_parms["Eggs_alpha_Fem_GP_1", ]$PR_type <- 0
inputs$ctl$MG_parms["Eggs_beta_Fem_GP_1", ]$PR_type <- 0
inputs$ctl$SR_parms["SR_BH_steep", ]$PR_type <- 0

# Change size selex types for these two fleets to 0 because they appear to be ignored
# by the model anyways
inputs$ctl$size_selex_types["4_ORWA_TWL",]$Special <- 0
inputs$ctl$size_selex_types["5_ORWA_NONTWL",]$Special <- 0

# Change the growth age for L1 from 1 to 0 because at 1 it produces a funny growth curve
# as Vlada showed us
inputs$ctl$Growth_Age_for_L1 <- 0


ctl <- inputs$ctl
# Fill outfile with directory and file name of the file written
r4ss::SS_writectl(
  ctl,
  outfile = file.path(updated_ctlfile_dir, "yelloweye_control.ss"),
  overwrite = TRUE
)

# Changed convergence criterion to 1.3e-04 from 1e-04 because needed covar file
# start <- inputs$start
# start$converge_criterion <- 1.3e-04
# r4ss::SS_writestarter(start, outfile = file.path(update_ctl_model_path, "starter.ss"), overwrite = TRUE)

r4ss::get_ss3_exe(dir = updated_ctlfile_dir)

# You have to run this model in full (not using -nohess) because you need the covar file
# to fit the bias
r4ss::run(dir = updated_ctlfile_dir, show_in_console = TRUE)

replist_updated_ctlfile <- r4ss::SS_output(dir = updated_ctlfile_dir)

r4ss::SS_plots(replist_updated_ctlfile)

#compare updataed ss3 exe, updated historical catch, and updated historical catch + extended catch
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_surveyagecomp_20250414")),
            paste0(file.path(getwd(), "model", "updated_alldata_tunecomps_20250416")),
            paste0(file.path(getwd(), "model", "updated_alldata_tunecomps_fitbias_2_20250416")),
            paste0(file.path(getwd(), "model", "updated_alldata_tunecomps_fitbias_ctl_20250416")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", 
                                      "16_alldata_tunecomps_fitbias_upctl"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", 
                                   "2025 updated all data",
                                   "+ tuned comps",
                                   "+ recruitment dev bias adj x 2",
                                   "+ updated ctl file"),
                  print = TRUE)

###################################################################
#######                  TUNE COMPS AGAIN                 #########
###################################################################

# copy model starters and data file from prev run
copy_SS_inputs(
  dir.old = file.path(getwd(), "model", "updated_alldata_tunecomps_fitbias_ctl_20250416"), 
  dir.new = file.path(getwd(), "model", "updated_alldata_tunecomps_fitbias_ctl_tunecomps_20250416"),
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

#inputs <- SS_read(dir = file.path(getwd(), "model", "updated_alldata_tunecomps_20250416"))

get_ss3_exe(dir = file.path(getwd(), "model", "updated_alldata_tunecomps_fitbias_ctl_tunecomps_20250416"))

run(dir = file.path(getwd(), "model", "updated_alldata_tunecomps_fitbias_ctl_tunecomps_20250416"), 
    show_in_console = TRUE, extras = "-nohess")

replist <- SS_output(dir = file.path(getwd(), "model", "updated_alldata_tunecomps_fitbias_ctl_tunecomps_20250416"))


##### Tune composition data ##### ----------------------------------------------
tunecomps_dir <- here::here("model/updated_alldata_tunecomps_fitbias_ctl_tunecomps_20250416")

r4ss::tune_comps(
  replist, # use replist from previous run
  write = TRUE,
  niters_tuning = 2, 
  option = "Francis",
  dir = tunecomps_dir,
  show_in_console = TRUE,
  #extras = "-nohess", #run with hessian so we can run fitbias next
  exe = "ss3"
)

replist_tunecomps <- SS_output(dir = file.path(getwd(), "model", "updated_alldata_tunecomps_fitbias_ctl_tunecomps_20250416"))

SS_plots(replist_tunecomps)

#compare updataed ss3 exe, updated historical catch, and updated historical catch + extended catch
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_surveyagecomp_20250414")),
            paste0(file.path(getwd(), "model", "updated_alldata_tunecomps_20250416")),
            paste0(file.path(getwd(), "model", "updated_alldata_tunecomps_fitbias_2_20250416")),
            paste0(file.path(getwd(), "model", "updated_alldata_tunecomps_fitbias_ctl_20250416")),
            paste0(file.path(getwd(), "model", "updated_alldata_tunecomps_fitbias_ctl_tunecomops_20250416")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", 
                                      "14_alldata_tunecomps"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", 
                                   "2025 updated all data",
                                   "+ tuned comps",
                                   "+ recruitment dev bias adj x 2",
                                   "+ updated ctl file",
                                   "+ tuned comps again"),
                  print = TRUE)



###################################################################
#######               STARTER FILE CHANGES                 #########
###################################################################
updated_ctlfile_dir <- here::here("model", "updated_alldata_tunecomps_fitbias_ctl_20250416")

updated_startfile_dir <- here::here("model", "updated_alldata_tunecomps_fitbias_ctl_start_20250416")


copy_SS_inputs(
  dir.old = updated_ctlfile_dir,
  dir.new = updated_startfile_dir,
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

inputs <- SS_read(dir = updated_startfile_dir)
#start <- inputs$start

inputs$start$prior_like <- 1 #changing from 0 to 1

#no other changes necessary for now

start <- inputs$start
#start <- SS_readstarter(file.path(updated_startfile_dir, "starter.ss"), verbose = TRUE)
# Fill outfile with directory and file name of the file written
r4ss::SS_writestarter(
  start,
  dir = updated_startfile_dir,
  file = "starter.ss",
#  outfile = file.path(updated_startfile_dir, "starter.ss"),
  overwrite = TRUE
)

r4ss::get_ss3_exe(dir = updated_startfile_dir)

# You have to run this model in full (not using -nohess) because you need the covar file
# to fit the bias
r4ss::run(dir = updated_startfile_dir, show_in_console = TRUE)

replist_updated_startfile <- r4ss::SS_output(dir = updated_startfile_dir)

r4ss::SS_plots(replist_updated_startfile)

#compare updataed ss3 exe, updated historical catch, and updated historical catch + extended catch
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "updated_catch_indices_lencompall_upextcomagecomp_upextrecagecomp_surveyagecomp_20250414")),
            paste0(file.path(getwd(), "model", "updated_alldata_tunecomps_20250416")),
            paste0(file.path(getwd(), "model", "updated_alldata_tunecomps_fitbias_20250416")),
            paste0(file.path(getwd(), "model", "updated_alldata_tunecomps_fitbias_ctl_20250416")),
            paste0(file.path(getwd(), "model", "updated_alldata_tunecomps_fitbias_ctl_start_20250416")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", 
                                      "17_alldata_tunecomps_fitbias_upctl_upstart"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", 
                                   "2025 updated all data",
                                   "+ tuned comps",
                                   "+ recruitment dev bias adj",
                                   "+ updated ctl file",
                                   "+ updated start file"),
                  print = TRUE)

###################################################################
#######               FORECAST FILE CHANGES               #########
###################################################################

