#################################
### Prepare data for SAC tool ###
#################################

# Load libraries
library(dplyr)
library(tidyr)
library(r4ss)

# Get inputs from 2017 assessment that will get carried over to this assessment
model_2017_path <- file.path(
  getwd(),
  "model",
  "2017_yelloweye_model_updated_ss3_exe"
)
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
    catch = TOTAL_CATCH
  )

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

write.csv(
  all_catch,
  file = file.path(getwd(), "Data", "for_SS", "all_catch_SAC.csv"),
  row.names = FALSE
)

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
ORFS_index <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "ORFS_index_forSS.csv"
)) |>
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
  "IPHC_model_based_index_forSS3_UNSCALED.csv"
))
IPHC_ORWA_index <- IPHC_ORWA |>
  mutate(Label = "IPHC_ORWA")
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
    TRI_index,
    NWFSC_ORWA_index,
    IPHC_ORWA_index
  )
)

write.csv(
  all_indices,
  file = file.path(getwd(), "Data", "for_SS", "all_indices_SAC.csv"),
  row.names = FALSE
)

###########################
### Length compositions ###
###########################

colnames_l <- c("Year", "Month", "Fleet", "Sex", "Nsamps", seq(10, 74, by = 2))

# Load in length comps for commercial fisheries
raw_length_comps_PacFIN_WCGOP <- read.csv(here::here("Data", "processed", "length_age_comps", 'Commercial_length_comps_PacFIN_WCGOP_forSS.csv')) |>
  select(-part)
raw_length_comps_PacFIN <- read.csv(here::here("Data", "processed", "length_age_comps", 'Commercial_length_comps_PacFIN_forSS.csv')) |>
  select(-partition)
raw_length_comps_WCGOP <- read.csv(here::here("Data", "processed", "length_age_comps", 'Commercial_length_comps_WCGOP_forSS.csv')) |>
  select(-partition)

#format to SAC data names
names(raw_length_comps_PacFIN_WCGOP) <- names(raw_length_comps_PacFIN) <- names(raw_length_comps_WCGOP) <- colnames_l

# format old data 
inputs$dat$lencomp <- inputs$dat$lencomp |>
  select(-part)
names(inputs$dat$lencomp) <- colnames_l

# CA TWL (from PacFIN) - fleet 1
CA_TWL_PacFIN_WCGOP_lengths <- inputs$dat$lencomp |>
  filter(Fleet == 1, Year <= 2015) |> 
  bind_rows(raw_length_comps_PacFIN_WCGOP |> filter(Fleet == 1, Year > 2015))

# CA NONTWL (from PacFIN) up until 2002 - fleet 2
# Provided by Juliette and Morgan
# using 2017 data for 1979 - 2002, no new data
# NB: Sample size from 2017 does not match our updated computation for unexplained reason. We use the 2017 data.
CA_NONTWL_PacFIN_lengths <- inputs$dat$lencomp |>
  filter(Fleet == 2, Year <= 2002)
  
# CA NONTWL (from WCGOP) - fleet 2
# Provided by Juliette and Morgan
# using 2017 data for 2004-2015 and 2025 data update for 2016-2023
# NB: the sample size used in 2017 does not match our values, whereas we have the 
# exact same number of trips and fish samples. We use the 2017 data.
CA_NONTWL_WCGOP_lengths <-inputs$dat$lencomp |>
  filter(Fleet == 2, Year > 2002) |>
  bind_rows(raw_length_comps_WCGOP |> filter(Fleet == 2, Year > 2015))

# CA Rec - fleet 3
CA_REC_lengths_old <- inputs$dat$lencomp |>
  filter(Fleet == 3)
CA_REC_lengths_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "ca_rec_lengths.csv"
)) |>
  select(-partition) |>
  filter(year >= 2017)
colnames(CA_REC_lengths_new) <- colnames_l

# Calculate Nsamps using linear equation y = 4.6 + 0.732x
x <- CA_REC_lengths_new$Nsamps
CA_REC_lengths_new$Nsamps <- 4.6 + 0.732*x
# put them together
CA_REC_lengths <- rbind(CA_REC_lengths_old, CA_REC_lengths_new)

# ORWA TWL (PacFIN and WCGOP combined) - fleet 4
# Provided by Juliette and Morgan
# using 2017 data for 1995-2015 (2016 was included in 2017 but we update it with new data) 
# and 2025 data update for 2016-2024
ORWA_TWL_PacFIN_WCGOP_lengths <- inputs$dat$lencomp |>
  filter(Fleet == 4, Year <= 2015) |>
  bind_rows(raw_length_comps_PacFIN_WCGOP |> filter(Fleet == 4, Year > 2015))

# ORWA NONTWL (PacFIN and WCGOP combined) - fleet 5
# Provided by Juliette and Morgan
# using 2017 data for 1980-2015 and 2025 data update for 2016-2024
ORWA_NONTWL_PacFIN_WCGOP_lengths <- inputs$dat$lencomp |>
  filter(Fleet == 5, Year <= 2015) |>
  bind_rows(raw_length_comps_PacFIN_WCGOP |> filter(Fleet == 5, Year > 2015))

# OR REC (MRFSS and ORBS combined, plus data associated with WDFW ages (1979-2002) 
# and ODFW (2009-2016) ages, not included in RecFIN) - fleet 6
# Provided by Morgan and Abby
# Previous data until 2016
OR_REC_lengths_old <- inputs$dat$lencomp |>
  filter(Fleet == 6)
OR_REC_lengths_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "or_rec_lengths.csv"
)) |>
  filter(year >= 2017) |>
  select(-partition)
colnames(OR_REC_lengths_new) <- colnames_l
# Calculate Nsamps using linear equation y = 0.341 + 1.1x
x <- OR_REC_lengths_new$Nsamps
OR_REC_lengths_new$Nsamps <- 0.341 + 1.1*x
OR_REC_lengths <- rbind(OR_REC_lengths_old, OR_REC_lengths_new)

# WA REC (data from WDFW) - fleet 7
WA_REC_lengths_old <- inputs$dat$lencomp |>
  filter(Fleet == 7)
WA_REC_lengths_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "wa_rec_lengths.csv"
)) |>
  filter(year >= 2017) |>
  select(-partition)
colnames(WA_REC_lengths_new) <- colnames_l
x <- WA_REC_lengths_new$Nsamps
WA_REC_lengths_new$Nsamps <- 2.02 + 0.17*x
WA_REC_lengths <- rbind(WA_REC_lengths_old, WA_REC_lengths_new)

# CA observer - fleet 8
# Provided by Morgan and Abby
CA_observer_lengths_old <- inputs$dat$lencomp |>
  filter(Fleet == 8)
CA_observer_lengths_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "ca_obs_lengths.csv"
)) |>
  filter(year >= 2017) |>
  select(-partition)
colnames(CA_observer_lengths_new) <- colnames_l
x <- CA_observer_lengths_new$Nsamps
CA_observer_lengths_new$Nsamps <- 1.48 + 0.73*x
CA_observer_lengths <- rbind(CA_observer_lengths_old, CA_observer_lengths_new)

# OR observer - fleet 9
# Provided by Morgan and Abby
OR_observer_lengths_old <- inputs$dat$lencomp |>
  filter(Fleet == 9)
OR_observer_lengths_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "or_obs_lengths.csv"
)) |>
  filter(year >= 2017) |>
  select(-partition)
colnames(OR_observer_lengths_new) <- colnames_l
# Calculate Nsamps using linear equation y = 5.76 + 0.415x
x <- OR_observer_lengths_new$Nsamps
OR_observer_lengths_new$Nsamps <- 5.76 + 0.415*x
OR_observer_lengths <- rbind(OR_observer_lengths_old, OR_observer_lengths_new)

# Triennial survey - fleet 10
TRI_lengths <- inputs$dat$lencom |>
  filter(Fleet == 10) 

# NWFSC survey - fleet 11
NWFSC_lengths_old <- inputs$dat$lencom |>
  filter(Fleet == 11) 
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
  filter(Fleet == 12)
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
    CA_TWL_PacFIN_WCGOP_lengths,
    CA_NONTWL_PacFIN_lengths,
    CA_NONTWL_WCGOP_lengths,
    CA_REC_lengths,
    ORWA_TWL_PacFIN_WCGOP_lengths,
    ORWA_NONTWL_PacFIN_WCGOP_lengths,
    OR_REC_lengths,
    WA_REC_lengths,
    CA_observer_lengths,
    OR_observer_lengths,
    TRI_lengths,
    NWFSC_lengths,
    IPHC_lengths
  )
)

write.csv(
  all_lengths,
  file = file.path(getwd(), "Data", "for_SS", "all_lengths_SAC.csv"),
  row.names = FALSE
)


########################
### Age compositions ###
########################

colnames_a <- c(
  "Year",
  "Month",
  "Fleet",
  "Sex",
  "Ageing_error",
  "Lbin_low",
  "Lbin_hi",
  "Nsamps",
  0:65
)

# Load in age comps for commercial fisheries
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

# No age data from CA TWL fleet

# CA NONTWL CAAL and MAAL - fleet 2 and -2
# No new data
CA_NONTWL_ages <- inputs$dat$agecom |>
  filter(fleet %in% c(-2, 2)) |>
  filter(year < 2005) |>
  select(-part)
colnames(CA_NONTWL_ages) <- colnames_a

# CA NONTWL WCGOP - fleet -2 and 2
CA_NONTWL_ages_wcgop <- inputs$dat$agecom |>
  filter(fleet %in% c(-2, 2)) |>
  select(-part) |>
  filter(year == 2005)
colnames(CA_NONTWL_ages_wcgop) <- colnames_a

# CA REC CAAL and MAAL (aged by WDFW, 1983 and 1996 only) - fleet -3 and 3
CA_REC_wdfw_ages <- inputs$dat$agecom |>
  filter(fleet %in% c(-3, 3)) |>
  filter(year == 1983 | year == 1996) |>
  select(-part)
colnames(CA_REC_wdfw_ages) <- colnames_a

# CA REC CAAL and MAAL (data from Don Pearson 1979 - 1984, aged by Betty) - fleet -3 and 3
# *divide all Nsamp and Ages by 2* - everything was doubled by accident in last assessment
# Use this first section to grab the old data with out any changes!
CA_REC_don_pearson_caal <- inputs$dat$agecomp |>
  filter(fleet == 3) |>
  filter(year >= 1979 & year <= 1984) |>
  filter(ageerr == 2) |>
  select(-part)
colnames(CA_REC_don_pearson_caal) <- colnames_a
# For the Update, add this next section to correct for the doubling mistake
CA_REC_don_pearson_caal[,8:74] <- CA_REC_don_pearson_caal[,8:74]/2


# *need to rebuild from CAAL* - Nsamp column was duplicated (and is wrong), so it shifted all of the ages forward by 1 and dropped the last age column
# Use this first section to grab the old data with out any changes! 
CA_REC_don_pearson_maal_old <- inputs$dat$agecomp |>
  filter(fleet == -3) |>
  filter(year >= 1979 & year <= 1984) |>
  filter(ageerr == 2) |>
  select(-part)
colnames(CA_REC_don_pearson_maal_old) <- colnames_a
# For the Update, add this next section to fix old mistake
# Take CAAL and group it so it matches MAAL structure, re-add the correct columns
### STOPPED HERE
### Figure out how to look for columns that have numbers to summarize across
CA_REC_don_pearson_maal <- CA_REC_don_pearson_caal |>
  group_by(Year) |>  # Retain key columns
  summarise(across(matches("^\\d+$"), \(x) sum(x, na.rm = TRUE)), # Sum numeric columns
            Nsamps = sum(Nsamps, na.rm = TRUE), .groups = "drop") # Sum input_n
CA_REC_don_pearson_maal <- cbind(CA_REC_don_pearson_maal_old[,1:7],CA_REC_don_pearson_maal[,68],CA_REC_don_pearson_maal[,2:67])
CA_REC_don_pearson <- rbind(CA_REC_don_pearson_caal, CA_REC_don_pearson_maal)

# CA REC CAAL and MAAL from John - fleet -3 and 3
# *divide all Nsamp and Ages by 2* - No new data, all data we got matched perfectly with 2017 assessment data, so just use old data.
# Use this first section to grab the old data with out any changes! 
CA_REC_caal <- inputs$dat$agecomp |>
  filter(fleet == 3) |>
  filter(year >= 2009 & year <= 2016) |>
  select(-part)
colnames(CA_REC_caal) <- colnames_a
# For the Update, add this next section to correct for the doubling mistake
CA_REC_caal[,8:74] <- CA_REC_caal[,8:74]/2

# *need to rebuild from CAAL* - Nsamp column is totally wrong, All the age data looks correct, but how they added the Nsamps together is off. Do the same thing as above and just rebuild from CAAL. Confirmed that the data matched the MAAL that I calculated using nwfsc code.
# Also, Vlada says that Nsamp column for MAAL data DOES NOT MATTER...but for an update, lets at least make it consistent with everything else in that Nsamp = "total samples".
# It is a lot easier to look for mistakes in the data if the Nsamps = total samples, and is consistent throughout the datafile.
# Use this first section to grab the old data with out any changes! 
CA_REC_maal_old <- inputs$dat$agecomp |>
  filter(fleet == -3) |>
  filter(year >= 2009 & year <= 2016) |>
  select(-part)
colnames(CA_REC_maal_old) <- colnames_a
# For the Update, add this next section to fix old mistake
# Take CAAL and group it so it matches MAAL structure, re-add the correct columns
CA_REC_maal <- CA_REC_caal %>%
  group_by(Year) %>%  # Retain key columns
  summarise(across(matches("^\\d+$"), \(x) sum(x, na.rm = TRUE)), # Sum numeric columns
            Nsamps = sum(Nsamps, na.rm = TRUE), .groups = "drop") # Sum input_n
CA_REC_maal <- cbind(CA_REC_maal_old[,1:7],CA_REC_maal[,68],CA_REC_maal[,2:67])
CA_REC_ages <- rbind(CA_REC_caal, CA_REC_maal)

# ORWA TWL CAAL and MAAL (PacFIN and WCGOP combined) - fleet 4 and -4
# Provided by Juliette and Morgan
# use 2017 data for 2001-2015 (2016 was included in 2017 but we are updating it with new data),
# and bring new data for 2016-2024
ORWA_TWL_ages_caal <- raw_age_caal_PacFIN_WCGOP %>% filter(fleet==4)
ORWA_TWL_ages_maal <-raw_age_comps_PacFIN_WCGOP %>% filter(fleet==-4)
ORWA_TWL_ages <- rbind(ORWA_TWL_ages_caal, ORWA_TWL_ages_maal) |>
  select(-part)
colnames(ORWA_TWL_ages) <- colnames_a

# ORWA NONTWL CAAL and MAAL (PacFIN and WCGOP combined) - fleet 5 and -5
# Provided by Juliette and Morgan
# using 2017 data for 2001-2015, and 2025 data update for 2016-2024
ORWA_NONTWL_ages_caal <- raw_age_caal_PacFIN_WCGOP %>% filter(fleet==5)
ORWA_NONTWL_ages_maal <- raw_age_comps_PacFIN_WCGOP %>% filter(fleet==-5)
ORWA_NONTWL_ages <- rbind(ORWA_NONTWL_ages_caal, ORWA_NONTWL_ages_maal) |>
  select(-part)
colnames(ORWA_NONTWL_ages) <- colnames_a

# OR REC CAAL and MAAL - fleet -6 and 6
# Morgan and Abby need to provide an updated data set
# *doubling issue here too* - Also fixing Ageing Error column and adding updated Ages
# The extra ages in 2015 were filtered out because they were sex == U, but since that doesnt matter any more, Ali suggests we include them
# Use this first section to grab the old data with out any changes! 
# Bring in old data from 1979-2016
OR_REC_caal_old <- inputs$dat$agecomp |>
  filter(fleet == 6) |>
  select(-part)
# Next, fix doubling problem, without adding any new data
# Use for a model run where we fix issues before adding new data
OR_REC_caal_old[,8:74] <- OR_REC_caal_old[,8:74]/2
# Next problem is to fix the age column.Below is the correct age location and years according to Ali
# 1979 - 2000 = WDFW
# 2001 = WDFW(40) /unknown (assumed NWFSC) (10)
# 2002 =WDFW (n = 73)
# 2009 - 2016 = NWFSC
OR_REC_caal_old[144:160,5] <- 1 # changing 2001 and 2002 = WDFW
OR_REC_caal_old[161:193,5] <- 2 # changing 2009-2016 = NWFSC
colnames(OR_REC_caal_old) <- colnames_a

OR_REC_caal_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "or_rec_caal.csv"
)) |>
  filter(year >= 2009) |>
  select(-partition)
colnames(OR_REC_caal_new) <- colnames_a
OR_REC_caal <- rbind(OR_REC_caal_old |> filter(Year <= 2002), OR_REC_caal_new)

# *why are Nsamps not whole numbers?* - It doesn't matter...but it is a lot easier to double check the data if Nsamps are "total samples", so rebuild using up to date CAAL data
# Use this first section to grab the old data with out any changes!
# load old MAAL so we can use the first 8 columns and double check the data
OR_REC_maal_old <- inputs$dat$agecom |>
  filter(fleet == -6) |>
  select(-part)
colnames(OR_REC_maal_old) <- colnames_a
# For the Update, add this next section to fix Nsamps
# Take CAAL and group it so it matches MAAL structure, re-add the correct columns

# For the Update, add this next section to fix Nsamps
# Take CAAL and group it so it matches MAAL structure, re-add the correct columns
OR_REC_maal <- OR_REC_caal %>%
  group_by(Year) %>%  # Retain key columns
  summarise(across(matches("^\\d+$"), \(x) sum(x, na.rm = TRUE)), # Sum numeric columns
            Nsamps = sum(Nsamps, na.rm = TRUE), .groups = "drop")  # Sum input_n
OR_REC_maal <- cbind(OR_REC_maal_old[,1:7],OR_REC_maal[,68],OR_REC_maal[,2:67])
OR_REC_ages <- rbind(OR_REC_caal, OR_REC_maal)

# WA REC CAAL and MAAL - fleet -7 and 7
# Provided by Morgan and Abby
# Fabio said to use new ages because they have been reanalyzed
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
NWFSC_caal_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "NWFSC.Combo_CAAL",
  "processed_one_sex_caal.csv"
)) |>
  select(
    year,
    month,
    fleet,
    sex,
    ageerr,
    Lbin_lo,
    Lbin_hi,
    Nsamp,
    everything()
  ) |>
  select(-partition)
colnames(NWFSC_caal_new) <- colnames_a
NWFSC_caal <- NWFSC_caal_new

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
  select(
    year,
    month,
    fleet,
    sex,
    ageerr,
    Lbin_lo,
    Lbin_hi,
    Nsamp,
    everything()
  ) |>
  select(-partition)
colnames(NWFSC_maal_new) <- colnames_a
NWFSC_maal <- NWFSC_maal_new
NWFSC_ages <- rbind(NWFSC_caal, NWFSC_maal)

# IPHC survey CAAL and MAAL - fleet -12 and 12
IPHC_caal_old <- inputs$dat$agecom |>
  filter(fleet == 12) |>
  filter(year <= 2016) |>
  select(-part)
colnames(IPHC_caal_old) <- colnames_a
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
all_ages <- do.call(
  "rbind",
  list(
    CA_NONTWL_ages,
    CA_NONTWL_ages_wcgop,
    CA_REC_wdfw_ages,
    CA_REC_don_pearson,
    CA_REC_ages,
    ORWA_TWL_ages,
    ORWA_NONTWL_ages,
    OR_REC_ages,
    WA_REC_ages,
    NWFSC_ages,
    IPHC_ages
  )
)

write.csv(
  all_ages,
  file = file.path(getwd(), "Data", "for_SS", "all_ages_SAC.csv"),
  row.names = FALSE
)

#L50 selex: 35.6,33.5,32.3,36.9,38.8,30.9,36.9,32,26,2.3,35.1,46
#Lpeak selex: 49,45,45,55,53,39,47,45,35,81,57,57
# yelloweye_fixed_params
# M = 0.0439034
# k = 0700988
# Linf = 63.4537
# t0 = 8.56493
# CV at length (young) = 0.189443
# CV at length (old) = 0.0547183
# L at 50% maturity = 42.0705
# L at 95% maturity = 49.39108
# Wtlen a = 0.000007183309
# Wtlen b = 3.244801
# Egg a = 0.0000000721847 
# Egg b = 4.043
# h = 0.718
