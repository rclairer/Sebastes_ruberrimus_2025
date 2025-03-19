library(dplyr)
library(r4ss)

###############################################
#########    BASE MODEL #######################
##############################################

model_2017_base_path <- file.path(getwd(), "model", "2017_yelloweye_model_base")

##############################################
############   UPDATED SS3 EXE   #############
##############################################

model_2017_updatedexe_path <- file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")


###################################################
# UPDATED SS3 EXE AND BIAS ADJUSTMENT FOR ONE SEX #
###################################################

model_2017_updatedexe_biasadj_path <- file.path(getwd(), "model", "2017_add_bias_adjustment")
#how do we run this model??????????????????? 
#I'm assuming this is old exe, hopefully - to replace "base model" in comparisons

##############################################
#### UPDATED SS3 EXE, UPDATED CATCH #########
#############################################

copy_SS_inputs(
  dir.old = model_2017_updatedexe_path, #why won't this work with the biasadj model
  dir.new = file.path(getwd(), "model", "2025_updated_catch_20250317"),
  create.dir = FALSE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

inputs_catch <- SS_read(dir = file.path(getwd(), "model", "2025_updated_catch_20250317"))
inputs_catch$dat$endyr <- 2024

colnames_c <- c("year", "seas", "fleet", "catch", "catch_se")
yelloweye_recent_comm_catch <- read.csv(file.path(getwd(), "Data", "processed", "yelloweye_commercial_catch_2016_2024.csv"))

# CA TWL - fleet 1
CA_hist_catch <- read.csv(file.path(getwd(), "Data", "processed", "CA_all_fleets_historical_catches.csv"))
CA_hist_catch_TWL <- CA_hist_catch |>
  filter(fleet == 1) |>
  rename(year = Year) |>
  mutate(
    seas = 1,
    catch_se = 0.01
  ) |>
  select(year, seas, fleet, catch, catch_se)

CA_1981_2015_TWL <- inputs_catch$dat$catch |>
  filter(fleet == 1) |>
  filter(year > 1980 & year < 2016)

CA_2016_2024_TWL <- yelloweye_recent_comm_catch |>
  filter(ST_FLEET == "CA_TWL") |>
  mutate(fleet = 1) |>
  select(YEAR, SEAS, fleet, TOTAL_CATCH, CATCH_SE)
colnames(CA_2016_2024_TWL) <- colnames_c

CA_TWL <- CA_hist_catch_TWL |>
  bind_rows(CA_1981_2015_TWL) |>
  bind_rows(CA_2016_2024_TWL) |>
  arrange(year)

# CA NONTWL - fleet 2
CA_hist_catch_NONTWL <- CA_hist_catch |>
  filter(fleet == 2) |>
  rename(year = Year) |>
  mutate(
    seas = 1,
    catch_se = 0.01
  ) |>
  select(year, seas, fleet, catch, catch_se)

CA_1981_2015_NONTWL <- inputs_catch$dat$catch |>
  filter(fleet == 2) |>
  filter(year > 1980 & year < 2016)

CA_2016_2024_NONTWL <- yelloweye_recent_comm_catch |>
  filter(ST_FLEET == "CA_NONTWL") |>
  mutate(fleet = 1) |>
  select(YEAR, SEAS, fleet, TOTAL_CATCH, CATCH_SE)
colnames(CA_2016_2024_NONTWL) <- colnames_c

CA_NONTWL <- CA_hist_catch_NONTWL |>
  bind_rows(CA_1981_2015_NONTWL) |>
  bind_rows(CA_2016_2024_NONTWL) |>
  arrange(year)

# CA REC - fleet 3
CA_hist_catch_REC <- CA_hist_catch |>
  filter(fleet == 3) |>
  rename(year = Year) |>
  mutate(
    seas = 1,
    catch_se = 0.01
  ) |>
  select(year, seas, fleet, catch, catch_se)

CA_2004_REC <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "CTE510-2004CRFSYelloweye.csv")) |>
  select(Year, Wgt.Ab1) |>
  filter(Wgt.Ab1 != "-") |>
  group_by(Year) |>
  summarize(
    seas = 1,
    fleet = 3,
    catch = sum(as.numeric(Wgt.Ab1)) / 1000,
    catch_se = 0.01
  ) |>
  rename(year = Year)

CA_1981_2004_REC <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "MRFSS_catch_est_yelloweye_CA.csv")) |>
  select(YEAR_, WGT_AB1) |>
  group_by(YEAR_) |>
  summarize(
    seas = 1,
    fleet = 3,
    catch = sum(WGT_AB1) / 1000,
    catch_se = 0.01
  ) |>
  rename(year = YEAR_) |>
  bind_rows(CA_2004_REC) |>
  filter(!is.na(catch))

CA_missing_1981_2004_rec <- inputs_catch$dat$catch |>
  filter(fleet == 3 & year > 1980 & year < 2005) |>
  filter(!year %in% CA_1981_2004_REC$year)

CA_1981_2004_REC <- CA_1981_2004_REC |>
  bind_rows(CA_missing_1981_2004_rec) |>
  arrange(year)

CA_recent_catch_REC <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "CTE001-California-1990---2024.csv")) |>
  select(RECFIN_YEAR, SUM_TOTAL_MORTALITY_MT) |>
  group_by(RECFIN_YEAR) |>
  summarize(
    seas = 1,
    fleet = 3,
    catch = sum(SUM_TOTAL_MORTALITY_MT),
    catch_se = 0.01
  ) |>
  rename(year = RECFIN_YEAR)

CA_REC <- CA_hist_catch_REC |>
  bind_rows(CA_1981_2004_REC) |>
  bind_rows(CA_recent_catch_REC) |>
  arrange(year) |>
  mutate(catch = round(catch, 2))

# ORWA TWL - fleet 4
# OR historical catch reconstruction has been updated
OR_comm_all <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "ORCommLandings_457_2024.csv"))

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

WA_TWL <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "WA_hist_catch_twl.csv")) |>
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

ORWA_TWL_until_2015 <- OR_TWL |>
  bind_rows(WA_TWL) |>
  group_by(year) |>
  summarize(
    seas = 1,
    fleet = 4,
    catch = sum(catch),
    catch_se = 0.01
  )

ORWA_TWL_2016_2024 <- yelloweye_recent_comm_catch |>
  filter(ST_FLEET == "ORWA_TWL") |>
  mutate(fleet = 4) |>
  select(YEAR, SEAS, fleet, TOTAL_CATCH, CATCH_SE)
colnames(ORWA_TWL_2016_2024) <- colnames_c

ORWA_TWL <- ORWA_TWL_until_2015 |>
  bind_rows(ORWA_TWL_2016_2024) |>
  arrange(year)

# ORWA NONTWL - fleet 5
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

WA_NONTWL <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "WA_hist_catch_nontwl.csv")) |>
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

ORWA_NONTWL_until_2015 <- OR_NONTWL |>
  bind_rows(WA_NONTWL) |>
  group_by(year) |>
  summarize(
    seas = 1,
    fleet = 5,
    catch = sum(catch),
    catch_se = 0.01
  )

ORWA_NONTWL_2016_2024 <- yelloweye_recent_comm_catch |>
  filter(ST_FLEET == "ORWA_NONTWL") |>
  mutate(fleet = 5) |>
  select(YEAR, SEAS, fleet, TOTAL_CATCH, CATCH_SE)
colnames(ORWA_NONTWL_2016_2024) <- colnames_c

ORWA_NONTWL <- ORWA_NONTWL_until_2015 |>
  bind_rows(ORWA_NONTWL_2016_2024) |>
  arrange(year)

# OR REC - fleet 6
OR_REC <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "ORRecLandings_457_2024.csv")) |>
  select(Year, Total_MT) |>
  mutate(
    seas = 1,
    fleet = 6,
    catch = Total_MT,
    catch_se = 0.01
  ) |>
  rename(year = Year) |>
  select(-Total_MT)

# WA REC - fleet 7
# Discards are included unlike they were in the 2017 assessment
WA_REC <- read.csv(file.path(getwd(), "Data", "processed", "WA_historical_to_recent_rec_catch.csv")) |>
  mutate(
    seas = 1,
    fleet = 7,
    catch_se = 0.01
  ) |>
  select(year, seas, fleet, catch, catch_se)

# Combine all catch data
all_catch <- do.call("rbind", list(
  CA_TWL,
  CA_NONTWL,
  CA_REC,
  ORWA_TWL,
  ORWA_NONTWL,
  OR_REC,
  WA_REC
))

inputs_catch$dat$catch <- all_catch

SS_write(inputs_catch, dir = file.path(getwd(), "model", "2025_updated_catch_20250317"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "2025_updated_catch_20250317"))

run(dir = file.path(getwd(), "model", "2025_updated_catch_20250317"), show_in_console = TRUE)

replist <- SS_output(dir = file.path(getwd(), "model", "2025_updated_catch_20250317"))
SS_plots(replist)

###################################################
# UPDATED SS3, UPDATED CATCH, UPDATED WCGBTS INDEX#
###################################################

copy_SS_inputs(
  dir.old = model_2017_updatedexe_path,
  dir.new = file.path(getwd(), "model", "2025_updated_catch_WCGBTSindex_20250317"),
  create.dir = FALSE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

# Use ss_new files from the catches run
inputs_catch_wcgbts <- SS_read(dir = file.path(getwd(), "model", "2025_updated_catch_20250317"), ss_new = TRUE)

colnames_i <- c("year", "month", "index", "obs", "se_log")

NWFSC_ORWA <- read.csv(file.path(getwd(), "Data", "processed", "wcgbts_indices", "updated_indices_ORWA_CA_split", "yelloweye_split_42_point_offanisotropy/yelloweye_rockfish/wcgbts", "delta_lognormal", "index", "est_by_area.csv"))
NWFSC_ORWA_index <- NWFSC_ORWA |>
  filter(area == "Coastwide") |>
  select(year, est, se) |>
  mutate(
    Month = 7,
    Fleet = 11
  ) |>
  select(year, Month, Fleet, est, se)
colnames(NWFSC_ORWA_index) <- colnames_i

inputs_catch_wcgbts$dat$indices <- inputs_catch_wcgbts$dat$CPUE |>
  filter(index != 11) |>
  bind_rows(NWFSC_ORWA_index) |>
  arrange(index, year)

SS_write(inputs_catch_wcgbts, dir = file.path(getwd(), "model", "2025_updated_catch_WCGBTSindex_20250317"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "2025_updated_catch_WCGBTSindex_20250317"))

run(dir = file.path(getwd(), "model", "2025_updated_catch_WCGBTSindex_20250317"), show_in_console = TRUE)

replist <- SS_output(dir = file.path(getwd(), "model", "2025_updated_catch_WCGBTSindex_20250317"))
SS_plots(replist)


###################################################
# UPDATED SS3, UPDATED CATCH, UPDATED ALL INDICES#
###################################################

copy_SS_inputs(
  dir.old = model_2017_updatedexe_path,
  dir.new = file.path(getwd(), "model", "2025_updated_catch_indices_20250317"),
  create.dir = FALSE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

# Use ss_new files from the catches run
inputs_catch_indices <- SS_read(dir = file.path(getwd(), "model", "2025_updated_catch_20250317"), ss_new = TRUE)

colnames_i <- c("year", "month", "index", "obs", "se_log")

# CA Rec MRFSS dockside CPUE - fleet 3
# I think we just bring over from 2017 assessment, because max year is 1999
CA_REC_MRFSS_index <- inputs_catch_indices$dat$CPUE |>
  filter(index == 3)

# OR Rec MRFSS - fleet 6
# Just bring over from 2017 assessment
OR_REC_MRFSS_index <- inputs_catch_indices$dat$CPUE |>
  filter(index == 6, year < 2000)

# OR ORBS - fleet 6
ORBS_index <- read.csv(file.path(getwd(), "Data", "processed", "ORBS_index_forSS.csv")) |>
  mutate(fleet = 6)
colnames(ORBS_index) <- colnames_i

# WA Rec CPUE - fleet 7
# Just bring over from the 2017 assessment, because max year is 2001
WA_REC_CPUE_index <- inputs_catch_indices$dat$CPUE |>
  filter(index == 7)

# CA onboard CPFV CPUE - fleet 8
# Just bring over from the 2017 assessment, because max year is 1998
CA_CPFV_CPUE_index <- inputs_catch_indices$dat$CPUE |>
  filter(index == 8)

# Oregon onboard Recreational Charter observer CPUE (ORFS) - fleet 9
# From Ali Whitman
ORFS_index <- read.csv(file.path(getwd(), "Data", "processed", "ORFS_index_forSS.csv")) |>
  mutate(
    fleet = 9,
    obs = round(obs, digits = 6),
    logse = round(logse, digits = 6)
  )
colnames(ORFS_index) <- colnames_i

# Triennial survey - fleet 10
tri_index <- inputs_catch_indices$dat$CPUE |>
  filter(index == 10)

# NWFSC ORWA - fleet 11
NWFSC_ORWA <- read.csv(file.path(getwd(), "Data", "processed", "wcgbts_indices", "updated_indices_ORWA_CA_split", "yelloweye_split_42_point_offanisotropy/yelloweye_rockfish/wcgbts", "delta_lognormal", "index", "est_by_area.csv"))
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
IPHC_ORWA <- read.csv(file.path(getwd(), "Data", "processed", "IPHC_model_based_index_forSS3.csv"))
IPHC_ORWA_index <- IPHC_ORWA
colnames(IPHC_ORWA_index) <- colnames_i

all_indices <- do.call("rbind", list(
  CA_REC_MRFSS_index,
  OR_REC_MRFSS_index,
  ORBS_index,
  WA_REC_CPUE_index,
  CA_CPFV_CPUE_index,
  ORFS_index,
  tri_index,
  NWFSC_ORWA_index,
  IPHC_ORWA_index
))

inputs_catch_indices$dat$indices <- all_indices

SS_write(inputs_catch_indices, dir = file.path(getwd(), "model", "2025_updated_catch_indices_20250317"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "2025_updated_catch_indices_20250317"))

run(dir = file.path(getwd(), "model", "2025_updated_catch_indices_20250317"), show_in_console = TRUE)

replist <- SS_output(dir = file.path(getwd(), "model", "2025_updated_catch_indices_20250317"))
SS_plots(replist)

#####################################################
############## MODEL COMPARISON  ###################
####################################################
#how do I change model names in plots????????

# Get branch that SSsummarize fix is on for now until it is merged into main
#devtools::install_github("r4ss/r4ss", ref = "fix_SSsummarize")
# library(r4ss)
models <- list.dirs(file.path(getwd(), "model"), recursive = FALSE)
#first, base, updated ss3 exe, and bias adj CHANGE THE ORDER OF THIS IS BIAS ADJ USES OLD EXE
models <- models[c(2,3)]
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "term1_final_model_comparisons", "base_updatedss3exe"),
                  print = TRUE
)

models <- list.dirs(file.path(getwd(), "model"), recursive = FALSE)
#first, base, updated ss3 exe, and bias adj
models <- models[c(2,3,5,6)]
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "term1_final_model_comparisons", "base_updatedss3exe_updatedcatch_updatedindices"),
                  print = TRUE
)



