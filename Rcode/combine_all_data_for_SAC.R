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
  filter(year < 2016) |>
  select(year, catch) |>
  rename(Year = year)

# PACFIN data that starts in 2017
CA_2016_2024_TWL <- yelloweye_recent_comm_catch |>
  filter(ST_FLEET == "CA_TWL") |>
  select(YEAR, TOTAL_CATCH) |>
  mutate(TOTAL_CATCH = round(TOTAL_CATCH, 3)) |>
  rename(
    Year = YEAR,
    catch = TOTAL_CATCH)

CA_TWL <- CA_1889_2015_TWL |>
  bind_rows(CA_2016_2024_TWL) |>
  arrange(Year) |>
  rename(CA_TWL = catch)

# CA NONTWL - fleet 2
# Use CA TWL from 1889-2015 from previous assessment
CA_1889_2015_NONTWL <- inputs$dat$catch |>
  filter(fleet == 2) |>
  filter(year < 2016) |>
  select(year, catch) |>
  rename(Year = year)
  
# PACFIN data
# No catch data for 2016, 2018, 2019, 2020, or 2024
CA_2016_2024_NONTWL <- yelloweye_recent_comm_catch |>
  filter(ST_FLEET == "CA_NONTWL") |>
  select(YEAR, TOTAL_CATCH) |>
  mutate(TOTAL_CATCH = round(TOTAL_CATCH, 3)) |>
  rename(
    Year = YEAR,
    catch = TOTAL_CATCH
  )

CA_NONTWL <- CA_1889_2015_NONTWL |>
  bind_rows(CA_2016_2024_NONTWL) |>
  arrange(Year) |>
  rename(CA_NONTWL = catch)

# CA Rec - fleet 3
CA_hist_catch_REC <- inputs$dat$catch |>
  filter(fleet == 3 & year < 2016) |>
  filter(!between(year, 1880, 1927)) |>
  select(year, catch) |>
  rename(Year = year)

# RecFIN data for 2016 - 2024
CA_recent_catch_REC <- read.csv(file.path(
  getwd(), 
  "Data", 
  "raw", 
  "nonconfidential", 
  "CTE001-California-1990---2024.csv"
  )) |>
  select(RECFIN_YEAR, SUM_TOTAL_MORTALITY_MT) |>
  group_by(RECFIN_YEAR) |>
  summarize(catch = sum(SUM_TOTAL_MORTALITY_MT)) |>
  rename(Year = RECFIN_YEAR) |>
  filter(Year >= 2016) |>
  mutate(catch = round(catch, 3))

CA_REC <- CA_hist_catch_REC |>
  bind_rows(CA_recent_catch_REC) |>
  arrange(Year) |>
  rename(CA_REC = catch)

# ORWA TWL - fleet 4
# All OR data provided from Ali with updated historical catch reconstruction
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
  rename(
    Year = YEAR,
    catch = TOTAL
  )

# WA historical catch with unchanged reconstruction provided from Fabio
WA_TWL <- WA_TWL <- read.csv(file.path(
  getwd(), 
  "Data", 
  "raw", 
  "nonconfidential", 
  "WA_hist_catch_twl.csv"
  )) |>
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
  mutate(TOTAL_CATCH = round(TOTAL_CATCH, 3)) |>
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

WA_NONTWL <- read.csv(file.path(
  getwd(), 
  "Data", 
  "raw", 
  "nonconfidential", 
  "WA_hist_catch_nontwl.csv"
  )) |>
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
  mutate(TOTAL_CATCH = round(TOTAL_CATCH, 3)) |>
  rename(
    Year = YEAR,
    catch = TOTAL_CATCH
  )

ORWA_NONTWL <- ORWA_NONTWL_until_2015 |>
  bind_rows(ORWA_NONTWL_2016_2024) |>
  arrange(Year) |>
  rename(ORWA_NONTWL = catch)

# OR Rec - fleet 6
OR_REC_to_1978 <- inputs$dat$catch |>
  filter(fleet == 6) |>
  filter(year <= 1978) |>
  select(year, catch) |>
  rename(Year = year)

OR_REC <- read.csv(file.path(
  getwd(), 
  "Data", 
  "raw", 
  "nonconfidential", 
  "ORRecLandings_457_2024.csv"
  )) |>
  select(Year, Total_MT) |>
  mutate(catch = round(Total_MT, 2)) |>
  select(-Total_MT) |>
  bind_rows(OR_REC_to_1978) |>
  arrange(Year) |>
  rename(OR_REC = catch)

# WA Rec - fleet 7
WA_hist_catch_REC <- inputs$dat$catch |>
  filter(fleet == 7 & year < 2016) |>
  filter(!between(year, 1880, 1974)) |>
  select(year, catch)

WA_REC <- read.csv(file.path(
  getwd(), 
  "Data", 
  "processed", 
  "WA_historical_to_recent_rec_catch.csv"
  )) |>
  select(year, catch) |>
  filter(year >= 2016) |>
  mutate(catch = round(catch, 2)) |>
  bind_rows(WA_hist_catch_REC) |>
  rename(
    Year = year,
    WA_REC = catch
  ) |>
  arrange(Year)

# Combine all catch data
all_catch <- CA_TWL |>
  left_join(CA_NONTWL, by = "Year") |>
  left_join(CA_REC, by = "Year") |>
  left_join(ORWA_TWL, by = "Year") |>
  left_join(ORWA_NONTWL, by = "Year") |>
  left_join(OR_REC, by = "Year") |>
  left_join(WA_REC, by = "Year") |>
  filter(Year > 0)
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
# Just bring over from 2017 assessment
OR_REC_MRFSS_index <- inputs$dat$CPUE |>
  filter(index == 6, year < 2000) |>
  mutate(Label = "OR_REC")
colnames(OR_REC_MRFSS_index) <- colnames_i

# OR ORBS - fleet 6 (OR_REC)
ORBS_index <- read.csv(file.path(
  getwd(), 
  "Data", 
  "processed", 
  "ORBS_index_forSS.csv"
  )) |>
  mutate(
    fleet = 6,
    Label = "OR_REC"
  ) 
colnames(ORBS_index) <- colnames_i

# WA Rec CPUE - fleet 7
# Just bring over from the 2017 assessment, because max year is 2001
WA_REC_CPUE_index <- inputs$dat$CPUE |>
  filter(index == 7) |>
  mutate(Label = "WA_REC")
colnames(WA_REC_CPUE_index) <- colnames_i

# CA onboard CPFV CPUE - fleet 8
# Just bring over from the 2017 assessment, because max year is 1998
CA_CPFV_CPUE_index <- inputs$dat$CPUE |>
  filter(index == 8) |>
  mutate(Label = "CA_CPFV_CPUE")
colnames(CA_CPFV_CPUE_index) <- colnames_i

# Experimental ORFS to test a sensitivity with
# From Ali Whitman
# For some reason 2003 is missing from the updated index. This also now includes
# years 2015, 2017, 2022, 2023, and 2024
ORFS_index <- read.csv(file.path(getwd(), "Data", "processed", "ORFS_index_forSS.csv")) |>
  mutate(
    fleet = 9,
    obs = round(obs, digits = 6),
    logse = round(logse, digits = 6),
    Label = "OR_RECOB/ORFS"
  )
colnames(ORFS_index) <- colnames_i

# TRI ORWA - fleet 10
TRI_index <- inputs$dat$CPUE |>
  filter(index == 10) |>
  mutate(Label = "Triennial")
colnames(TRI_index) <- colnames_i

# NWFSC ORWA - fleet 11
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
    Fleet = 11,
    Label = "NWFSC_ORWA"
  ) |>
  select(year, Month, Fleet, est, se, Label)
colnames(NWFSC_ORWA_index) <- colnames_i

# IPHC ORWA - fleet 12
# this might be updated with a sdmTMB model based
IPHC_ORWA <- read.csv(file.path(
  getwd(), 
  "Data", 
  "processed", 
  "IPHC_index",
  "IPHC_model_based_index_forSS3.csv"
  ))
IPHC_ORWA_index <- IPHC_ORWA |>
  mutate(Label = "IPHC_ORWA")
colnames(IPHC_ORWA_index) <- colnames_i

all_indices <- do.call("rbind", list(
  CA_REC_MRFSS_index,
  OR_REC_MRFSS_index,
  ORBS_index,
  WA_REC_CPUE_index,
  CA_CPFV_CPUE_index,
  ORFS_index,
  TRI_index,
  NWFSC_ORWA_index,
  IPHC_ORWA_index
))

write.csv(all_indices, file = file.path(getwd(), "Data", "for_SS", "all_indices_SAC.csv"), row.names = FALSE)

###########################
### Length compositions ###
###########################

colnames_l <- c("Year", "Month", "Fleet", "Sex", "Nsamps", seq(10, 74, by = 2))

# CA TWL (from PacFIN) - fleet 1
CA_TWL_lengths <- inputs$dat$lencomp |>
  filter(fleet == 1) |>
  select(-part)
# CA_TWL_lengths_new <-
# CA_TWL_lengths <- rbind(CA_TWL_lengths_old, CA_TWL_lengths_new)
colnames(CA_TWL_lengths) <- colnames_l
  
# CA NONTWL (from PacFIN) - fleet 2
CA_NONTWL_lengths <- inputs$dat$lencomp |>
  filter(fleet == 2) |>
  filter(year <= 2002) |>
  select(-part)
# CA_NONTWL_lengths_new <- 
# CA_NONTWL_lengths <- rbind(CA_NONTWL_lengths_old, CA_NONTWL_lengths_new)
colnames(CA_NONTWL_lengths) <- colnames_l

# CA NONTWL (from WCGOP) - fleet 2
CA_NONTWL_lengths_wcgop <- inputs$dat$lencomp |>
  filter(fleet == 2) |>
  filter(year > 2002) |>
  select(-part)
# CA_NONTWL_lengths_wcgop_new <- 
# CA_NONTWL_lengths_wcgop <- rbind(CA_NONTWL_lengths_wcgop_old, CA_NONTWL_lengths_wcgop_new)
colnames(CA_NONTWL_lengths_wcgop) <- colnames_l

# CA Rec - fleet 3
CA_REC_lengths_old <- inputs$dat$lencomp |>
  filter(fleet == 3) |>
  select(-part)
colnames(CA_REC_lengths_old) <- colnames_l
CA_REC_lengths_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "ca_rec_lengths.csv"
)) |>
  select(-X, -partition) |>
  filter(year > 2016)
colnames(CA_REC_lengths_new) <- colnames_l

CA_REC_lengths <- rbind(CA_REC_lengths_old, CA_REC_lengths_new)

# ORWA TWL (PacFIN and WCGOP combined) - fleet 4
ORWA_TWL_lengths <- inputs$dat$lencomp |>
  filter(fleet == 4) |>
  select(-part)
# ORWA_TWL_lengths_new <- 
# ORWA_TWL_lengths <- rbind(ORWA_TWL_lengths_old, ORWA_TWL_lengths_new)
colnames(ORWA_TWL_lengths) <- colnames_l

# ORWA NONTWL (PacFIN and WCGOP combined) - fleet 5
ORWA_NONTWL_lengths <- inputs$dat$lencomp |>
  filter(fleet == 5) |>
  select(-part)
# ORWA_NONTWL_lengths_new <- 
# ORWA_NONTWL_lengths <- rbind(ORWA_NONTWL_lengths_old, ORWA_NONTWL_lengths_new)
colnames(ORWA_NONTWL_lengths) <- colnames_l

# OR REC (MRFSS and ORBS combined, plus data associated with WDFW ages (1979-2002) and ODFW (2009-2016) ages, not included in RecFIN) - fleet 6
OR_REC_lengths_old <- inputs$dat$lencomp |>
  filter(fleet == 6) |>
  select(-part)
colnames(OR_REC_lengths_old) <- colnames_l
OR_REC_lengths_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "or_rec_lengths.csv"
)) |>
  filter(year > 2016) |>
  select(-X, -partition)
colnames(OR_REC_lengths_new) <- colnames_l

OR_REC_lengths <- rbind(OR_REC_lengths_old, OR_REC_lengths_new)

# WA REC (data from WDFW) - fleet 7
WA_REC_lengths_old <- inputs$dat$lencomp |>
  filter(fleet == 7) |>
  select(-part)
colnames(WA_REC_lengths_old) <- colnames_l
WA_REC_lengths_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "wa_rec_lengths.csv"
)) |>
  filter(year > 2016) |>
  select(-X, -partition)
colnames(WA_REC_lengths_new) <- colnames_l

WA_REC_lengths <- rbind(WA_REC_lengths_old, WA_REC_lengths_new)

# CA observer - fleet 8
CA_observer_lengths_old <- inputs$dat$lencomp |>
  filter(fleet == 8) |>
  select(-part)
colnames(CA_observer_lengths_old) <- colnames_l
CA_observer_lengths_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "ca_obs_lengths.csv"
)) |>
  filter(year > 2016) |>
  select(-X, -partition)
colnames(CA_observer_lengths_new) <- colnames_l

CA_observer_lengths <- rbind(CA_observer_lengths_old, CA_observer_lengths_new)

# OR observer - fleet 9
OR_observer_lengths_old <- inputs$dat$lencomp |>
  filter(fleet == 9) |>
  select(-part)
colnames(OR_observer_lengths_old) <- colnames_l
OR_observer_lengths_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "or_obs_lengths.csv"
)) |>
  filter(year > 2016) |>
  select(-X, -partition)
colnames(OR_observer_lengths_new) <- colnames_l

OR_observer_lengths <- rbind(OR_observer_lengths_old, OR_observer_lengths_new)

# Triennial survey - fleet 10
TRI_lengths <- inputs$dat$lencom |>
  filter(fleet == 10) |>
  select(-part)
colnames(TRI_lengths) <- colnames_l

# NWFSC survey - fleet 11
NWFSC_lengths_old <- inputs$dat$lencom |>
  filter(fleet == 11) |>
  select(-part)
colnames(NWFSC_lengths_old) <- colnames_l
NWFSC_lengths_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "NWFSC.Combo_and_Tri_length_comps",
  "NWFSC.Combo_length_cm_unsexed_raw_10_74_yelloweye rockfish_groundfish_slope_and_shelf_combination_survey.csv"
)) |>
  filter(year > 2016) |>
  select(-partition)
colnames(NWFSC_lengths_new) <- colnames_l
NWFSC_lengths <- rbind(NWFSC_lengths_old, NWFSC_lengths_new)

# IPHC ORWA - fleet 12
IPHC_lengths_old <- inputs$dat$lencom |>
  filter(fleet == 12) |>
  select(-part)
colnames(IPHC_lengths_old) <- colnames_l
IPHC_lengths_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "IPHC_bio_data",
  "iphc_length_comps.csv"
)) |>
  filter(year > 2016) |>
  select(-part)
colnames(IPHC_lengths_new) <- colnames_l
IPHC_lengths <- rbind(IPHC_lengths_old, IPHC_lengths_new)

# All lengths
all_lengths <- do.call(
  "rbind",
  list(
    CA_TWL_lengths,
    CA_NONTWL_lengths,
    CA_NONTWL_lengths_wcgop,
    CA_REC_lengths,
    ORWA_TWL_lengths,
    ORWA_NONTWL_lengths,
    OR_REC_lengths,
    WA_REC_lengths,
    CA_observer_lengths,
    OR_observer_lengths,
    TRI_lengths,
    NWFSC_lengths,
    IPHC_lengths
  )
)

write.csv(all_lengths, file = file.path(getwd(), "Data", "for_SS", "all_lengths_SAC.csv"), row.names = FALSE)


########################
### Age compositions ###
########################

colnames_a <- c("Year", "Month", "Fleet", "Sex", "Ageing_error", "Lbin_low", "Lbin_hi", "Nsamps", 0:65)

# CA TWL CAAL and MAAL - fleet 1 and -1
CA_TWL_ages <- inputs$dat$agecom |>
  filter(fleet %in% c(-1, 1)) |>
  select(-part)
# CA_TWL_ages_new <- 
# CA_TWL_ages <- rbind(CA_TWL_ages_old, CA_TWL_ages_new)
colnames(CA_TWL_ages) <- colnames_a

# CA NONTWL CAAL and MAAL - fleet 2 and -2
CA_NONTWL_ages <- inputs$dat$agecom |>
  filter(fleet %in% c(-2, 2)) |>
  filter(year < 2005) |>
  select(-part)
# CA_NONTWL_ages_new <- 
# CA_NONTWL_ages <- rbind(CA_NONTWL_ages_old, CA_NONTWL_ages_new)
colnames(CA_NONTWL_ages) <- colnames_a

# CA NONTWL WCGOP - fleet -2 and 2
CA_NONTWL_ages_wcgop <- inputs$dat$agecom |>
  filter(fleet %in% c(-2, 2)) |>
  select(-part) |>
  filter(year == 2005)
colnames(CA_NONTWL_ages_wcgop) <- colnames_a

# CA REC CAAL and MAAL (aged by WDFW, 1983 and 1996 only) - fleet -3 and 3
CA_REC_wdfw <- inputs$dat$agecom |>
  filter(fleet %in% c(-3, 3)) |>
  select(-part)
CA_REC_wdfw <- CA_REC_wdfw[1:4, ]
colnames(CA_REC_wdfw) <- colnames_a

# CA REC CAAL and MAAL (data from Don Pearson 1979 - 1984, aged by Betty) - fleet -3 and 3
CA_REC_don_pearson <- inputs$dat$agecom |>
  filter(fleet %in% c(-3, 3)) |>
  select(-part)
CA_REC_don_pearson <- CA_REC_don_pearson[-c(1:4), ] |>
  filter(year < 1985)
colnames(CA_REC_don_pearson) <- colnames_a

# CA REC CAAL and MAAL (data from CDFW John Budrick, aged by Betty) - fleet 3, -3
CA_REC_caal <- inputs$dat$agecomp |>
  filter(fleet == 3) |>
  filter(year >=2009) |>
  select(-part)
CA_REC_maal <- inputs$dat$agecomp |>
  filter(fleet == -3) |>
  filter(year >= 2009) |>
  select(-part)
CA_REC_ages <- rbind(CA_REC_caal, CA_REC_maal)
colnames(CA_REC_ages) <- colnames_a

# ORWA TWL CAAL and MAAL (PacFIN and WCGOP combined) - fleet 4, -4
ORWA_TWL_ages <- inputs$dat$agecom |>
  filter(fleet %in% c(-4, 4)) |>
  select(-part)
# ORWA_TWL_ages_new <- 
# ORWA_TWL_ages <- rbind(ORWA_TWL_ages_old, ORWA_TWL_ages_new)
colnames(ORWA_TWL_ages) <- colnames_a

# ORWA NONTWL CAAL and MAAL (PacFIN and WCGOP combined) - fleet 5, -5
ORWA_NONTWL_ages <- inputs$dat$agecom |>
  filter(fleet %in% c(-5, 5)) |>
  select(-part)
# ORWA_NONTWL_ages_new <- 
# ORWA_NONTWL_ages <- rbind(ORWA_NONTWL_ages_old, ORWA_NONTWL_ages_new)
colnames(ORWA_NONTWL_ages) <- colnames_a

# OR REC CAAL and MAAL - fleet 6, -6
OR_REC_caal_old <- inputs$dat$agecom |>
  filter(fleet == 6) |>
  select(-part)
colnames(OR_REC_caal_old) <- colnames_a
OR_REC_caal_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "or_rec_caal.csv"
)) |>
  filter(year > 2016) |>
  select(-partition)
colnames(OR_REC_caal_new) <- colnames_a
OR_REC_caal <- rbind(OR_REC_caal_old, OR_REC_caal_new)

OR_REC_maal_old <- inputs$dat$agecom |>
  filter(fleet == -6) |>
  select(-part)
colnames(OR_REC_maal_old) <- colnames_a
OR_REC_maal_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "or_rec_maal.csv"
))|>
  filter(year > 2016) |>
  select(-X, -partition)
colnames(OR_REC_maal_new) <- colnames_a
OR_REC_maal <- rbind(OR_REC_maal_old, OR_REC_maal_new)

OR_REC_ages <- rbind(OR_REC_caal, OR_REC_maal)

# WA REC CAAL and MAAL - fleet 7 and -7
WA_REC_caal <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "wa_rec_caal.csv"
)) |>
  select(-partition)
colnames(WA_REC_caal) <- colnames_a

WA_REC_maal <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "wa_rec_maal.csv"
)) |>
  select(-partition)
colnames(WA_REC_maal) <- colnames_a

WA_REC_ages <- rbind(WA_REC_caal, WA_REC_maal)

# NWFSC survey CAAL and MAAL - fleet -11 and 11
# NWFSC_caal_old <- inputs$dat$agecom |>
#   filter(fleet == 11)
NWFSC_caal_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "NWFSC.Combo_CAAL",
  "processed_one_sex_caal.csv"
)) |>
  select(-partition)
# |>
#   filter(year > 2016)
colnames(NWFSC_caal_new) <- colnames_a
NWFSC_caal <- NWFSC_caal_new
# NWFSC_caal <- rbind(NWFSC_caal_old, NWFSC_caal_new)

# NWFSC_maal_old <- inputs$dat$agecom |>
#   filter(fleet == -11)
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
  select(-partition)
# |>
#   filter(year > 2016)
colnames(NWFSC_maal_new) <- colnames_a
NWFSC_maal <- NWFSC_maal_new
# NWFSC_maal <- rbind(NWFSC_maal_old, NWFSC_maal_new)

NWFSC_ages <- rbind(NWFSC_caal, NWFSC_maal)

# IPHC survey CAAL and MAAL - fleet -12 and 12
IPHC_caal_old <- inputs$dat$agecom |>
  filter(fleet == 12) |>
  filter(year <= 2016) |>
  select(-part)
colnames(IPHC_caal_old) <- colnames_a
IPHC_caal_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "IPHC_bio_data",
  "iphc_caal.csv"
)) |>
  filter(year > 2016) |>
  select(-part)
colnames(IPHC_caal_new) <- colnames_a
IPHC_caal <- rbind(IPHC_caal_old, IPHC_caal_new)

IPHC_maal_old <- inputs$dat$agecom |>
  filter(fleet == -12) |>
  filter(year <= 2016) |>
  select(-part)
colnames(IPHC_maal_old) <- colnames_a
IPHC_maal_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "IPHC_bio_data",
  "iphc_marginal_ages.csv"
)) |>
  filter(year > 2016) |>
  select(-part)
colnames(IPHC_maal_new) <- colnames_a
IPHC_maal <- rbind(IPHC_maal_old, IPHC_maal_new)

IPHC_ages <- rbind(IPHC_caal, IPHC_maal)

# Combine all ages together
all_ages <- do.call("rbind", list(
  CA_TWL_ages,
  CA_NONTWL_ages,
  CA_NONTWL_ages_wcgop,
  CA_REC_wdfw,
  CA_REC_don_pearson,
  CA_REC_ages,
  ORWA_TWL_ages,
  ORWA_NONTWL_ages,
  OR_REC_ages,
  WA_REC_ages,
  NWFSC_ages,
  IPHC_ages
))

write.csv(all_ages, file = file.path(getwd(), "Data", "for_SS", "all_ages_SAC.csv"), row.names = FALSE)
