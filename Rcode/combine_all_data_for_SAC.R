#################################
### Prepare data for SAC tool ###
#################################

# Load libraries
library(dplyr)
library(tidyr)
library(r4ss)

# Get inputs from 2017 assessment that will get carried over to this assessment
model_2017_path <- file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")
inputs <- SS_read(dir = model_2017_path, ss_new = TRUE)

#############
### Catch ###
#############

# colnames for catch is Year and then each fleet with a name which
# needs to match names of indices if they overlap
yelloweye_recent_comm_catch <- read.csv(file.path(getwd(), "Data", "processed", "yelloweye_commercial_catch_2016_2024.csv"))

# CA TWL - fleet 1

CA_hist_catch <- read.csv(file.path(getwd(), "Data", "processed", "CA_all_fleets_historical_catches.csv"))
CA_hist_catch_TWL <- CA_hist_catch |>
  filter(fleet == 1) |>
  select(Year, catch)

CA_1981_2015_TWL <- inputs$dat$catch |>
  filter(fleet == 1) |>
  filter(year > 1980 & year < 2016) |>
  select(year, catch) |>
  rename(Year = year)

CA_2016_2024_TWL <- yelloweye_recent_comm_catch |>
  filter(ST_FLEET == "CA_TWL") |>
  select(YEAR, TOTAL_CATCH) |>
  rename(
    Year = YEAR,
    catch = TOTAL_CATCH
  )

CA_TWL <- CA_hist_catch_TWL |>
  bind_rows(CA_1981_2015_TWL) |>
  bind_rows(CA_2016_2024_TWL) |>
  arrange(Year) |>
  rename(CA_TWL = catch)

# CA NONTWL - fleet 2
CA_hist_catch_NONTWL <- CA_hist_catch |>
  filter(fleet == 2) |>
  select(Year, catch)

CA_1981_2015_NONTWL <- inputs$dat$catch |>
  filter(fleet == 2) |>
  filter(year > 1980 & year < 2016) |>
  select(year, catch) |>
  rename(Year = year)

CA_2016_2024_NONTWL <- yelloweye_recent_comm_catch |>
  filter(ST_FLEET == "CA_NONTWL") |>
  select(YEAR, TOTAL_CATCH) |>
  rename(
    Year = YEAR,
    catch = TOTAL_CATCH
  )

CA_NONTWL <- CA_hist_catch_NONTWL |>
  bind_rows(CA_1981_2015_NONTWL) |>
  bind_rows(CA_2016_2024_NONTWL) |>
  arrange(Year) |>
  rename(CA_NONTWL = catch)

# CA Rec - fleet 3
CA_hist_catch_REC <- CA_hist_catch |>
  filter(fleet == 3) |>
  select(Year, catch)

# Provided by Julia Coates at CDFW
CA_2004_REC <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "CTE510-2004CRFSYelloweye.csv")) |>
  select(Year, Wgt.Ab1) |>
  filter(Wgt.Ab1 != "-") |>
  group_by(Year) |>
  summarize(catch = sum(as.numeric(Wgt.Ab1)) / 1000)

# Provided by Julia Coates at CDFW
CA_1981_2004_REC <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "MRFSS_catch_est_yelloweye_CA.csv")) |>
  select(YEAR_, WGT_AB1) |>
  group_by(YEAR_) |>
  summarize(catch = sum(WGT_AB1) / 1000) |>
  rename(Year = YEAR_) |>
  bind_rows(CA_2004_REC) |>
  filter(!is.na(catch))

CA_missing_1981_2004_rec <- inputs$dat$catch |>
  filter(fleet == 3 & year > 1980 & year < 2005) |>
  rename(Year = year) |>
  filter(!Year %in% CA_1981_2004_REC$Year) |>
  select(Year, catch)

CA_1981_2004_REC <- CA_1981_2004_REC |>
  bind_rows(CA_missing_1981_2004_rec) |>
  arrange(Year)

CA_recent_catch_REC <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "CTE001-California-1990---2024.csv")) |>
  select(RECFIN_YEAR, SUM_TOTAL_MORTALITY_MT) |>
  group_by(RECFIN_YEAR) |>
  summarize(catch = sum(SUM_TOTAL_MORTALITY_MT)) |>
  rename(Year = RECFIN_YEAR)

CA_REC <- CA_hist_catch_REC |>
  bind_rows(CA_1981_2004_REC) |>
  bind_rows(CA_recent_catch_REC) |>
  arrange(Year) |>
  mutate(catch = round(catch, 2)) |>
  rename(CA_REC = catch)

# ORWA TWL - fleet 4

OR_comm_all <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "ORCommLandings_457_2024.csv"))

OR_TWL <- OR_comm_all |>
  select(YEAR, FLEET, TOTAL) |>
  filter(
    FLEET == "TRW",
    YEAR < 2016
  ) |>
  select(-FLEET) |>
  rename(
    Year = YEAR,
    catch = TOTAL
  )

WA_TWL <- WA_TWL <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "WA_hist_catch_twl.csv")) |>
  select(Year, Catches..mtons.) |>
  filter(Year < 2016) |>
  rename(catch = Catches..mtons.)

ORWA_TWL_until_2015 <- OR_TWL |>
  bind_rows(WA_TWL) |>
  group_by(Year) |>
  summarize(catch = sum(catch))

ORWA_TWL_2016_2024 <- yelloweye_recent_comm_catch |>
  filter(ST_FLEET == "ORWA_TWL") |>
  select(YEAR, TOTAL_CATCH) |>
  rename(
    Year = YEAR,
    catch = TOTAL_CATCH
  )

ORWA_TWL <- ORWA_TWL_until_2015 |>
  bind_rows(ORWA_TWL_2016_2024) |>
  arrange(Year) |>
  rename(ORWA_TWL = catch)

# ORWA NONTWL - fleet 5

OR_NONTWL <- OR_comm_all |>
  select(YEAR, FLEET, TOTAL) |>
  filter(
    FLEET == "NTRW",
    YEAR < 2016
  ) |>
  rename(
    Year = YEAR,
    catch = TOTAL
  )

WA_NONTWL <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "WA_hist_catch_nontwl.csv")) |>
  select(Year, Catches..mtons.) |>
  filter(Year < 2016) |>
  rename(catch = Catches..mtons.) |>
  select(Year, catch)

ORWA_NONTWL_until_2015 <- OR_NONTWL |>
  bind_rows(WA_NONTWL) |>
  group_by(Year) |>
  summarize(catch = sum(catch))

ORWA_NONTWL_2016_2024 <- yelloweye_recent_comm_catch |>
  filter(ST_FLEET == "ORWA_NONTWL") |>
  select(YEAR, TOTAL_CATCH) |>
  rename(
    Year = YEAR,
    catch = TOTAL_CATCH
  )

ORWA_NONTWL <- ORWA_NONTWL_until_2015 |>
  bind_rows(ORWA_NONTWL_2016_2024) |>
  arrange(Year) |>
  rename(ORWA_NONTWL = catch)

# OR Rec - fleet 6
OR_REC <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "ORRecLandings_457_2024.csv")) |>
  select(Year, Total_MT) |>
  rename(OR_REC = Total_MT)

# WA Rec - fleet 7
WA_REC <- read.csv(file.path(getwd(), "Data", "processed", "WA_historical_to_recent_rec_catch.csv")) |>
  select(year, catch) |>
  rename(
    Year = year,
    WA_REC = catch
  )

# Combine all catch data
all_catch <- CA_TWL |>
  left_join(CA_NONTWL, by = "Year") |>
  left_join(CA_REC, by = "Year") |>
  left_join(ORWA_TWL, by = "Year") |>
  left_join(ORWA_NONTWL, by = "Year") |>
  left_join(OR_REC, by = "Year") |>
  left_join(WA_REC, by = "Year")
all_catch[is.na(all_catch)] <- 0

write.csv(all_catch, file = file.path(getwd(), "Data", "for_SS", "all_catch_SAC.csv"), row.names = FALSE)

###############
### Indices ###
###############

# Index labels need to be the same as the Catch names if they are the same "fleet"
# so indices 3-7 will have the same labels as the Catch names

colnames_i <- c("Year", "Month", "Fleet", "Index", "CV", "Label")

# CA Rec MRFSS dockside CPUE - fleet 3
# I think we just bring over from 2017 assessment, because max year is 1999
CA_REC_MRFSS_index <- inputs$dat$CPUE |>
  filter(index == 3) |>
  mutate(Label = "CA_REC")
colnames(CA_REC_MRFSS_index) <- colnames_i

# OR Rec MRFSS - fleet 6 (OR_REC)
# I think we just bring over from 2017 assessment
OR_REC_MRFSS_index <- inputs$dat$CPUE |>
  filter(index == 6, year < 2000) |>
  mutate(Label = "OR_REC")
colnames(OR_REC_MRFSS_index) <- colnames_i

# OR ORBS - fleet 6 (OR_REC)
ORBS_index <- read.csv(file.path(getwd(), "Data", "processed", "ORBS_index_forSS.csv")) |>
  mutate(
    fleet = 6,
    Label = "OR_REC"
  ) |>
  colnames(ORBS_index) <- colnames_i

# WA Rec CPUE - fleet 7
# I think we just bring over from the 2017 assessment, because max year is 2001
WA_REC_CPUE_index <- inputs$dat$CPUE |>
  filter(index == 7) |>
  mutate(Label = "WA_REC")
colnames(WA_REC_CPUE_index) <- colnames_i

# CA onboard CPFV CPUE - fleet 8
# I think we just bring over from the 2017 assessment, because max year is 1998
CA_CPFV_CPUE_index <- inputs$dat$CPUE |>
  filter(index == 8) |>
  mutate(Label = "CA_CPFV_CPUE")
colnames(CA_CPFV_CPUE_index) <- colnames_i

# Oregon onboard Recreational Charter observer CPUE - fleet 9
# this is ORFS, right?
# FROM ALI, hopefully 03/05/2025

# TRI ORWA - fleet 10
tri_index <- inputs$dat$CPUE |>
  filter(index == 10) |>
  mutate(Label = "Triennial")
colnames(tri_index) <- colnames_i

# NWFSC ORWA - fleet 11
NWFSC_ORWA <- read.csv(file.path(getwd(), "Data", "processed", "wcgbts_indices", "updated_indices_ORWA_CA_split", "yelloweye_split_42_point_offanisotropy/yelloweye_rockfish/wcgbts", "delta_lognormal", "index", "est_by_area.csv"))
NWFSC_ORWA_index <- NWFSC_ORWA |>
  filter(area == "Coastwide") |>
  select(year, est, se) |>
  mutate(
    Month = 7,
    Fleet = 11,
    Label = "NWFSC_ORWA"
  ) |>
  select(year, Month, Fleet, est, se, Label)
colnames(NWFSC_ORWA_index) <- colnames_i

# IPHC ORWA - fleet 12
# this might be updated with a sdmTMB model based
IPHC_ORWA <- read.csv(file.path(getwd(), "Data", "processed", "IPHC_model_based_index_forSS3.csv"))
IPHC_ORWA_index <- IPHC_ORWA |>
  mutate(Label = "IPHC_ORWA")
colnames(IPHC_ORWA_index) <- colnames_i

all_indices <- do.call("rbind", list(
  CA_REC_MRFSS_index,
  OR_REC_MRFSS_index,
  WA_REC_CPUE_index,
  CA_CPFV_CPUE_index,
  tri_index,
  NWFSC_ORWA_index,
  IPHC_ORWA_index
))

write.csv(all_indices, file = file.path(getwd(), "Data", "for_SS", "all_indices_SAC.csv"), row.names = FALSE)

###########################
### Length compositions ###
###########################

colnames_l <- c("Year", "Month", "Fleet", "Sex", "Nsamps", seq(10, 74, by = 2))

# CA TWL (from PacFIN) - fleet 1

# CA NONTWL (from PacFIN) - fleet 2

# CA NONTWL (from WCGOP) - fleet 2

# CA Rec - fleet 3

# ORWA TWL (PacFIN and WCGOP combined) - fleet 4

# ORWA NONTWL (PacFIN and WCGOP combined) - fleet 5

# OR REC (MRFSS and ORBS combined, plus data associated with WDFW ages (1979-2002) and ODFW (2009-2016) ages, not included in RecFIN) - fleet 6

# WA REC (data from WDFW) - fleet 7

# CA observer - fleet 8

# OR observer - fleet 9

# Triennial survey - fleet 10
tri_lengths <- read.csv(file.path(
  getwd(), "Data", "processed", "NWFSC.Combo_and_Tri_length_comps",
  "Tri_length_cm_unsexed_raw_10_74_yelloweye rockfish_groundfish_triennial_shelf_survey.csv"
)) |>
  select(-partition)
colnames(tri_lengths) <- colnames_l

# NWFSC survey - fleet 11
nwfsc_lengths <- read.csv(file.path(
  getwd(), "Data", "processed", "NWFSC.Combo_and_Tri_length_comps",
  "NWFSC.Combo_length_cm_unsexed_raw_10_74_yelloweye rockfish_groundfish_slope_and_shelf_combination_survey.csv"
)) |>
  select(-partition)
colnames(nwfsc_lengths) <- colnames_l

# IPHC ORWA - fleet 12

all_lengths <- do.call("rbind", list(nwfsc_lengths))

write.csv(all_lengths, file = file.path(getwd(), "Data", "for_SS", "all_lengths_SAC.csv"), row.names = FALSE)


########################
### Age compositions ###
########################

colnames_a <- c("Year", "Month", "Fleet", "Sex", "Ageing_error", "Lbin_low", "Lbin_hi", "Nsamps", 0:65)

# CA NONTWL CAAL - fleet 2

# CA NONTWL MAAL - fleet -2

# CA NONTWL WCGOP - fleet -2 and 2
ca_nontwl_wcgop <- inputs$dat$agecom |>
  filter(fleet %in% c(-2, 2)) |>
  select(-part) |>
  filter(year == 2005)
colnames(ca_nontwl_wcgop) <- colnames_a

# CA REC CAAL and MAAL (aged by WDFW, 1983 and 1996 only) - fleet -3 and 3
ca_rec_wdfw <- inputs$dat$agecom |>
  filter(fleet %in% c(-3, 3)) |>
  select(-part)
ca_rec_wdfw <- ca_rec_wdfw[1:4, ]
colnames(ca_rec_wdfw) <- colnames_a

# CA REC CAAL (data from Don Pearson 1979 - 1984, aged by Betty) - fleet -3 and 3
ca_rec_don_pearson <- inputs$dat$agecom |>
  filter(fleet %in% c(-3, 3)) |>
  select(-part)
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

# NWFSC survey CAAL and MAAL - fleet -11 and 11
nwfsc_caal <- read.csv(file.path(
  getwd(), "Data", "processed", "NWFSC.Combo_CAAL",
  "processed_one_sex_caal.csv"
)) |>
  select(-partition)
colnames(nwfsc_caal) <- colnames_a

nwfsc_maal <- read.csv(file.path(
  getwd(), "Data", "processed", "NWFSC.Combo_age_comps",
  "NWFSC.Combo_age_unsexed_raw_0_65_yelloweye rockfish_groundfish_slope_and_shelf_combination_survey.csv"
)) |>
  select(-partition) |>
  mutate(
    ageerr = 2,
    fleet = -11
  )
colnames(nwfsc_maal) <- colnames_a

nwfsc_ages <- rbind(nwfsc_caal, nwfsc_maal)

# IPHC survey CAAL and MAAL - fleet -12 and 12

# Combine all ages together
all_ages <- do.call("rbind", list(
  ca_nontwl_wcgop,
  ca_rec_wdfw,
  ca_rec_don_pearson,
  nwfsc_ages
))

write.csv(all_ages, file = file.path(getwd(), "Data", "for_SS", "all_ages_SAC.csv"), row.names = FALSE)
