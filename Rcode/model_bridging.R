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
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", "base_updatedss3exe_updatednsexes"),
                  legendlabels = c("2017 base", "2017 updated SS3 exe (Nsexes = 1)", "2017 updated SS3 exe (Nsexes = -1)"),
                  print = TRUE
)



###########################################################################
#### UPDATED SS3 EXE, UPDATED HISTORICAL CATCH (< YEAR 2017) ONLY #########
###########################################################################

copy_SS_inputs(
  dir.old = model_2017_updatedexe_path, 
  dir.new = file.path(getwd(), "model", "2025_updated_historical_catch_20250409"),
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

inputs <- SS_read(dir = file.path(getwd(), "model", "2025_updated_historical_catch_20250409"))

#inputs_catch$dat$endyr <- 2016

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

SS_write(inputs, dir = file.path(getwd(), "model", "2025_updated_historical_catch_20250409"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "2025_updated_historical_catch_20250409"))

run(dir = file.path(getwd(), "model", "2025_updated_historical_catch_20250409"), show_in_console = TRUE, extras = "-nohess")

replist <- SS_output(dir = file.path(getwd(), "model", "2025_updated_historical_catch_20250409"))
SS_plots(replist)

#compare updataed ss3 exe and updated historical catch
#models <- list.dirs(file.path(getwd(), "model"), recursive = FALSE)
#models <- models[c(5,12)] #CHECK THIS EVERY TIME
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "2025_updated_historical_catch_20250409")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", "updatedss3exe_updatedhistoricalcatch"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", "2025 updated historical catch"),
                  print = TRUE
)

#################################################################################
#### UPDATED SS3 EXE, UPDATED HISTORICAL (< YEAR 2017) AND EXTENDED CATCH #######
#################################################################################

copy_SS_inputs(
  dir.old = file.path(getwd(), "model", "2025_updated_historical_catch_20250409"), 
  dir.new = file.path(getwd(), "model", "2025_updated_historical_and_extended_catch_20250409"),
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)


inputs <- SS_read(dir = file.path(getwd(), "model", "2025_updated_historical_and_extended_catch_20250409"))

inputs$dat$endyr <- 2024

SS_write(inputs, dir = file.path(getwd(), "model", "2025_updated_historical_and_extended_catch_20250409"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "2025_updated_historical_and_extended_catch_20250409"))

run(dir = file.path(getwd(), "model", "2025_updated_historical_and_extended_catch_20250409"), show_in_console = TRUE, extras = "-nohess")

replist <- SS_output(dir = file.path(getwd(), "model", "2025_updated_historical_and_extended_catch_20250409"))
SS_plots(replist)

#compare updataed ss3 exe, updated historical catch, and updated historical catch + extended catch
#models <- list.dirs(file.path(getwd(), "model"), recursive = FALSE)
#models <- models[c(5,12,11)] #CHECK THIS EVERY TIME
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "2025_updated_historical_catch_20250409")),
            paste0(file.path(getwd(), "model", "2025_updated_historical_and_extended_catch_20250409")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", "updatedss3exe_updatedhistoricalcatch_extendedcatch"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", "2025 updated historical catch", "2025 updated historical and extended catch"),
                  print = TRUE
)

#################################################################################
#### UPDATED SS3 EXE, UPDATED HISTORICAL (< YEAR 2017) AND EXTENDED CATCH #######
####           AND UPDATED INDICES                                        #######
#################################################################################

copy_SS_inputs(
  dir.old = file.path(getwd(), "model", "2025_updated_historical_and_extended_catch_20250409"), 
  dir.new = file.path(getwd(), "model", "2025_updated_catch_and_indices_20250409"),
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)


inputs <- SS_read(dir = file.path(getwd(), "model", "2025_updated_catch_and_indices_20250409"))

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
# Full update done in STAN by Matheus
IPHC_ORWA <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "IPHC_index",
  "IPHC_model_based_index_forSS3_UNSCALED.csv" ##UPDATE THIS IN COMBINE_ALL_DATA files
))
IPHC_ORWA_index <- IPHC_ORWA
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

SS_write(inputs, dir = file.path(getwd(), "model", "2025_updated_catch_and_indices_20250409"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "2025_updated_catch_and_indices_20250409"))

run(dir = file.path(getwd(), "model", "2025_updated_catch_and_indices_20250409"), show_in_console = TRUE, extras = "-nohess")

replist <- SS_output(dir = file.path(getwd(), "model", "2025_updated_catch_and_indices_20250409"))
SS_plots(replist)

#compare updataed ss3 exe, updated historical catch, and updated historical catch + extended catch
#models <- list.dirs(file.path(getwd(), "model"), recursive = FALSE)
#models <- models[c(5,12,11)] #CHECK THIS EVERY TIME
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "2025_updated_historical_catch_20250409")),
            paste0(file.path(getwd(), "model", "2025_updated_historical_and_extended_catch_20250409")),
            paste0(file.path(getwd(), "model", "2025_updated_catch_and_indices_20250409")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", "updatedss3exe_updatedhistoricalcatch_extendedcatch_indices"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", "2025 updated historical catch", "2025 updated historical and extended catch", "2025 updated catch and indices"),
                  print = TRUE
)


#################################################################################
#### UPDATED SS3 EXE, UPDATED HISTORICAL (< YEAR 2017) AND EXTENDED CATCH #######
####           AND UPDATED INDICES + COMMERCIAL LENCOMP                   #######
#################################################################################

# copy model starters and data file from prev run
copy_SS_inputs(
  dir.old = file.path(getwd(), "model", "2025_updated_catch_and_indices_20250409"), 
  dir.new = file.path(getwd(), "model", "2025_updated_catch_and_indices_comlencomp_20250410"),
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)


inputs <- SS_read(dir = file.path(getwd(), "model", "2025_updated_catch_and_indices_20250409"))

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
SS_write(inputs, dir = file.path(getwd(), "model", "2025_updated_catch_and_indices_comlencomp_20250410"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "2025_updated_catch_and_indices_comlencomp_20250410"))

run(dir = file.path(getwd(), "model", "2025_updated_catch_and_indices_comlencomp_20250410"), 
    show_in_console = TRUE, extras = "-nohess")

replist <- SS_output(dir = file.path(getwd(), "model", "2025_updated_catch_and_indices_comlencomp_20250410"))
SS_plots(replist)

#compare updataed ss3 exe, updated historical catch, and updated historical catch + extended catch
#models <- list.dirs(file.path(getwd(), "model"), recursive = FALSE)
#models <- models[c(5,12,11)] #CHECK THIS EVERY TIME
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "2025_updated_historical_and_extended_catch_20250409")),
            paste0(file.path(getwd(), "model", "2025_updated_catch_and_indices_20250409")),
            paste0(file.path(getwd(), "model", "2025_updated_catch_and_indices_comlencomp_20250410")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", "updatedss3exe_updatedhistoricalcatch_extendedcatch_indices_commlencomp"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", "2025 updated historical and extended catch", "2025 updated extended catch and indices","+ commecial length comps"),
                  print = TRUE
)


#################################################################################
#### UPDATED SS3 EXE, UPDATED HISTORICAL (< YEAR 2017) AND EXTENDED CATCH #######
####           AND UPDATED INDICES + COMMERCIAL LENCOMP + REC LENCOMP     #######
#################################################################################

# copy model starters and data file from prev run
copy_SS_inputs(
  dir.old = file.path(getwd(), "model", "2025_updated_catch_and_indices_comlencomp_20250410"), 
  dir.new = file.path(getwd(), "model", "2025_updated_catch_indices_comlencomp_reclencomp_20250410"),
  create.dir = TRUE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

inputs <- SS_read(dir = file.path(getwd(), "model", "2025_updated_catch_and_indices_comlencomp_20250410"))
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
SS_write(inputs, dir = file.path(getwd(), "model", "2025_updated_catch_indices_comlencomp_reclencomp_20250410"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "2025_updated_catch_indices_comlencomp_reclencomp_20250410"))

run(dir = file.path(getwd(), "model", "2025_updated_catch_indices_comlencomp_reclencomp_20250410"), 
    show_in_console = TRUE, extras = "-nohess")

replist <- SS_output(dir = file.path(getwd(), "model", "2025_updated_catch_indices_comlencomp_reclencomp_20250410"))
SS_plots(replist)

#compare updataed ss3 exe, updated historical catch, and updated historical catch + extended catch
models <- c(paste0(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")),
            paste0(file.path(getwd(), "model", "2025_updated_historical_and_extended_catch_20250409")),
            paste0(file.path(getwd(), "model", "2025_updated_catch_and_indices_20250409")),
            paste0(file.path(getwd(), "model", "2025_updated_catch_and_indices_comlencomp_20250410")),
            paste0(file.path(getwd(), "model", "2025_updated_catch_indices_comlencomp_reclencomp_20250410")))
models
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "model_bridging_data_comparisons", "updatedss3exe_updatedhistoricalcatch_extendedcatch_indices_commlencomp_reclencomp"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", "2025 updated historical and extended catch", "2025 updated extended catch and indices","+ commecial length comps","+ recreational length comps"),
                  print = TRUE
)