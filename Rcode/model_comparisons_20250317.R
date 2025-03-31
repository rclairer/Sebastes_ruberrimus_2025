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

###########################################################################
############   UPDATED SS3 EXE but nsexes same as base 2017   #############
###########################################################################

#model_2017_updatedexe_nsexes1

copy_SS_inputs(
  dir.old = model_2017_updatedexe_path, 
  dir.new = file.path(getwd(), "model", "2017_updated_ss3_exe_nsexes1_20250320"),
  create.dir = FALSE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

inputs_nsexes <- SS_read(dir = file.path(getwd(), "model", "2017_updated_ss3_exe_nsexes1_20250320"))
inputs_nsexes$dat$Nsexes <- 1  

SS_write(inputs_nsexes, dir = file.path(getwd(), "model", "2017_updated_ss3_exe_nsexes1_20250320"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "2017_updated_ss3_exe_nsexes1_20250320"))

run(dir = file.path(getwd(), "model", "2017_updated_ss3_exe_nsexes1_20250320"), show_in_console = TRUE)

replist <- SS_output(dir = file.path(getwd(), "model", "2017_updated_ss3_exe_nsexes1_20250320"))
SS_plots(replist)


#####################################################################
#### UPDATED SS3 EXE, UPDATED CATCH (keep < 2017 the same) #########
#####################################################################

copy_SS_inputs(
  dir.old = model_2017_updatedexe_path, 
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
  dir.new = file.path(getwd(), "model", "2025_updated_catch_indices_20250320"),
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

inputs_catch_indices$dat$CPUE <- all_indices

SS_write(inputs_catch_indices, dir = file.path(getwd(), "model", "2025_updated_catch_indices_20250320"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "2025_updated_catch_indices_20250320"))

run(dir = file.path(getwd(), "model", "2025_updated_catch_indices_20250320"), show_in_console = TRUE)

replist <- SS_output(dir = file.path(getwd(), "model", "2025_updated_catch_indices_20250320"))
SS_plots(replist)

##############################################################
# UPDATED SS3, UPDATED CATCH, UPDATED ALL INDICES, some comps#
##############################################################
copy_SS_inputs(
  dir.old = model_2017_updatedexe_path,
  dir.new = file.path(getwd(), "model", "2025_updated_catch_indices_somecomps_20250320"),
  create.dir = FALSE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

# Use ss_new files from the catches run
inputs_catch_indices_somecomps <- SS_read(dir = file.path(getwd(), "model", "2025_updated_catch_indices_20250320"), ss_new = TRUE)


#just update Juliette's

###########################
### Length compositions ###
###########################

colnames_l <- colnames(inputs$dat$lencom)

# CA TWL (from PacFIN) - fleet 1

# CA NONTWL (from PacFIN) - fleet 2

# CA NONTWL (from WCGOP) - fleet 2

# CA REC - fleet 3
CA_REC_lengths <- read.csv(file.path(getwd(), "Data", "processed", "recfin_bio_data", "recfin_ca_lengths.csv"))
colnames(CA_REC_lengths) <- colnames_l

# ORWA TWL (PacFIN and WCGOP combined) - fleet 4

# ORWA NONTWL (PacFIN and WCGOP combined) - fleet 5

# OR REC (MRFSS and ORBS combined, plus data associated with WDFW ages (1979-2002) and ODFW (2009-2016) ages, not included in RecFIN) - fleet 6

# WA REC (data from WDFW) - fleet 7
CA_REC_lengths <- read.csv(file.path(getwd(), "Data", "processed", "recfin_bio_data", "recfin_wa_lengths.csv"))
colnames(CA_REC_lengths) <- colnames_l

# CA observer - fleet 8

# OR observer - fleet 9

# Nsamp method used for all survey length comps is the old Stewart Hamel method from the 2017 assessment where
# Nsamp = n_trips + 0.0707 * n_fish when n_fish/n_tows < 55 and
# Nsamp = 4.89 * n_trips when n_fish/n_tows >= 55
# Triennial survey - fleet 10
tri_lengths <- read.csv(file.path(
  getwd(), "Data", "processed", "NWFSC.Combo_and_Tri_length_comps",
  "Tri_length_cm_unsexed_raw_10_74_yelloweye rockfish_groundfish_triennial_shelf_survey.csv"
)) |>
  colnames(tri_lengths) <- colnames_l

# NWFSC survey - fleet 11
nwfsc_lengths <- read.csv(file.path(
  getwd(), "Data", "processed", "NWFSC.Combo_and_Tri_length_comps",
  "NWFSC.Combo_length_cm_unsexed_raw_10_74_yelloweye rockfish_groundfish_slope_and_shelf_combination_survey.csv"
)) |>
  colnames(nwfsc_lengths) <- colnames_l

# IPHC ORWA - fleet 12
# IPHC bio data notes:
# Total_Biodata_Comb includes all Yelloweye biodata collected from IPHC FISS 2A from 2022-2023 and stlkeys for association with the IPHC effort database, and some location information pulled from the IPHC effort database
# Experimental gear catch and catch where species could not be rectified against onboard tag documentation were removed.
# 2A was not fished in 2020 and 2024.  Oregon stations were not fished in 2023.
# Oregon rockfish were not tagged in 2021 and fish cannot be reconciled with IPHC effort data.
# IPHC has not provided onboard tag information for Oregon stations in 2019. 2019 landings currently cannot be reconciled with IPHC effort data.

iphc_lengths <- read.csv(file.path(
  getwd(),
  "Data", "processed", "IPHC_bio_data", "iphc_length_comps.csv"
))


all_lengths <- do.call("rbind", list(
  tri_lengths,
  nwfsc_lengths,
  iphc_lengths
))

inputs_catch_indices_somecomps$dat$lencomp <- all_lengths

########################
### Age compositions ###
########################

colnames_a <- colnames(inputs$dat$agecom)

# CA NONTWL CAAL - fleet 2

# CA NONTWL MAAL - fleet -2

# CA NONTWL WCGOP - fleet -2 and 2
ca_nontwl_wcgop <- inputs$dat$agecom |>
  filter(fleet %in% c(-2, 2)) |>
  filter(year == 2005)
colnames(ca_nontwl_wcgop) <- colnames_a

# CA REC CAAL and MAAL (aged by WDFW, 1983 and 1996 only) - fleet -3 and 3
ca_rec_wdfw <- inputs$dat$agecom |>
  filter(fleet %in% c(-3, 3))
ca_rec_wdfw <- ca_rec_wdfw[1:4, ]
colnames(ca_rec_wdfw) <- colnames_a

# CA REC CAAL (data from Don Pearson 1979 - 1984, aged by Betty) - fleet -3 and 3
ca_rec_don_pearson <- inputs$dat$agecom |>
  filter(fleet %in% c(-3, 3))
ca_rec_don_pearson <- ca_rec_don_pearson[-c(1:4), ] |>
  filter(year < 1985)
colnames(ca_rec_don_pearson) <- colnames_a

# CA REC CAAL (data from CDFW John Budrick, aged by Betty) - fleet 3

# CA REC MAAL (data from John Budrick, aged by Betty) - fleet -3

# ORWA TWL CAAL (PacFIN and WCGOP combined) - fleet 4

# ORWA TWL MAAL (PacFIN and WCGOP combined) - fleet -4

# ORWA NONTWL CAAL (PacFIN and WCGOP combined) - fleet 5

# ORWA NONTWL MAAL (PacFIN and WCGOP combined) - fleet -5

# OR REC CAAL - fleet 6

# OR REC MAAL - fleet -6

# WA REC CAAL - fleet 7

# WA REC MAAL - fleet -7

# Nsamp method used for all survey maal is the old Stewart Hamel method from the 2017 assessment where
# Nsamp = n_trips + 0.0707 * n_fish when n_fish/n_tows < 55 and
# Nsamp = 4.89 * n_trips when n_fish/n_tows >= 55
# NWFSC survey CAAL and MAAL - fleet -11 and 11
nwfsc_caal <- read.csv(file.path(
  getwd(), "Data", "processed", "NWFSC.Combo_CAAL",
  "processed_one_sex_caal.csv"
))
colnames(nwfsc_caal) <- colnames_a

nwfsc_maal <- read.csv(file.path(
  getwd(), "Data", "processed", "NWFSC.Combo_age_comps",
  "NWFSC.Combo_age_unsexed_raw_0_65_yelloweye rockfish_groundfish_slope_and_shelf_combination_survey.csv"
)) |>
  mutate(
    ageerr = 2,
    fleet = -11
  )

colnames(nwfsc_maal) <- colnames_a

nwfsc_ages <- rbind(nwfsc_caal, nwfsc_maal)

# IPHC survey CAAL and MAAL - fleet -12 and 12
iphc_caal <- read.csv(file.path(
  getwd(),
  "Data", "processed", "IPHC_bio_data", "iphc_caal.csv"
))
iphc_maal <- read.csv(file.path(
  getwd(),
  "Data", "processed", "IPHC_bio_data", "iphc_marginal_ages.csv"
))
iphc_ages <- rbind(iphc_caal, iphc_maal)

# Combine all ages together
all_ages <- do.call("rbind", list(
  ca_nontwl_wcgop,
  ca_rec_wdfw,
  ca_rec_don_pearson,
  nwfsc_ages,
  iphc_ages
))

inputs_catch_indices_somecomps$dat$agecomp <- all_ages

SS_write(inputs_catch_indices, dir = file.path(getwd(), "model", "2025_updated_catch_indices_somecomps_20250320"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "2025_updated_catch_indices_somecomps_20250320"))

run(dir = file.path(getwd(), "model", "2025_updated_catch_indices_somecomps_20250320"), show_in_console = TRUE)

replist <- SS_output(dir = file.path(getwd(), "model", "2025_updated_catch_indices_somecomps_20250320"))
SS_plots(replist)



#####################################################
############## MODEL COMPARISON  ###################
####################################################
#how do I change model names in plots????????

# Get branch that SSsummarize fix is on for now until it is merged into main
#devtools::install_github("r4ss/r4ss", ref = "fix_SSsummarize")
# library(r4ss)

#not using
models <- list.dirs(file.path(getwd(), "model"), recursive = FALSE)
#first, base, updated ss3 exe
models <- models[c(3,4)] #CHECK THIS EVERY TIME
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "term1_final_model_comparisons", "base_updatedss3exe"),
                  legendlabels = c("2017 base", "2017 updated SS3 exe"),
                  print = TRUE
)


models <- list.dirs(file.path(getwd(), "model"), recursive = FALSE)
#first, base, updated ss3 exe with nsexes = 1 and then with nsexes = -1
models <- models[c(3,2,4)] #CHECK THIS EVERY TIME
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "term1_final_model_comparisons", "base_updatedss3exe_nsexes"),
                  legendlabels = c("2017 base", "2017 updated SS3 exe (Nsexes = 1)", "2017 updated SS3 exe (Nsexes = -1)"),
                  print = TRUE
)

#not using
models <- list.dirs(file.path(getwd(), "model"), recursive = FALSE)
models <- models[c(2,3,5,6)] #CHECK THIS EVERY TIME
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "term1_final_model_comparisons", "base_updatedss3exe_updatedcatch_updatedindices"),
                  legendlabels = c("2017 base", "2017 updated SS3 exe", "2025 updated catch", "2025 updated catch & indices"),
                  print = TRUE
)

models <- list.dirs(file.path(getwd(), "model"), recursive = FALSE)
models <- models[c(4,6,8)] #CHECK THIS EVERY TIME
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "term1_final_model_comparisons", "updatedss3exe_updatedcatch_updatedindices"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", "2025 updated catch", "2025 updated catch & indices"),
                  print = TRUE
)

#working updated catch
models <- list.dirs(file.path(getwd(), "model"), recursive = FALSE)
models <- models[c(4,5)] #CHECK THIS EVERY TIME
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
                  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "term1_final_model_comparisons", "updatedss3exe_updatedcatch"),
                  legendlabels = c("2017 updated SS3 exe (Nsexes = -1)", "2025 updated catch"),
                  print = TRUE
)


