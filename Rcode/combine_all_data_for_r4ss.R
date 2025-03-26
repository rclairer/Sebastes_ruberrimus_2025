####################################################
### Prepare data for r4ss to format SS3 dat file ###
####################################################

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

# Discard mortality not included for WA recreational fishery so need to figure out
##############
### End Yr ###
##############
inputs$dat$endyr <- 2024

#############
### Catch ###
#############
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
CA_1889_2015_TWL <- inputs_catch$dat$catch |>
  filter(fleet == 1) |>
  filter(year < 2016)

# PACFIN data that starts in 2017
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
CA_1889_2015_NONTWL <- inputs_catch$dat$catch |>
  filter(fleet == 2) |>
  filter(year < 2016)

# PACFIN data
# No catch data for 2016, 2018, 2019, 2020, or 2024
CA_2016_2024_NONTWL <- yelloweye_recent_comm_catch |>
  filter(ST_FLEET == "CA_NONTWL") |>
  mutate(fleet = 2) |>
  select(YEAR, SEAS, fleet, TOTAL_CATCH, CATCH_SE) |>
  mutate(TOTAL_CATCH = round(TOTAL_CATCH, 3))
colnames(CA_2016_2024_NONTWL) <- colnames_c

years_no_data <- data.frame(
  year = c(2018, 2019, 2020, 2024),
  seas = c(1, 1, 1, 1),
  fleet = c(2, 2, 2, 2),
  catch = c(0, 0, 0, 0),
  catch_se = c(0.01, 0.01, 0.01, 0.01)
)

CA_NONTWL <- CA_1889_2015_NONTWL |>
  bind_rows(CA_2016_2024_NONTWL) |>
  bind_rows(years_no_data) |>
  arrange(year)

# CA REC - fleet 3
# CA historical catch the same as the previous assessment
CA_hist_catch_REC <- inputs_catch$dat$catch |>
  filter(fleet == 3 & year < 2016) |>
  filter(!between(year, 1880, 1927))

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
  rename(year = YEAR) |>
  mutate(
    seas = 1,
    fleet = 4,
    catch = TOTAL,
    catch_se = 0.01
  ) |>
  select(-TOTAL)

# WA historical catch with unchanged reconstruction provided from Fabio
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
ORWA_TWL_2016_2024 <- yelloweye_recent_comm_catch |>
  filter(ST_FLEET == "ORWA_TWL") |>
  mutate(fleet = 4) |>
  select(YEAR, SEAS, fleet, TOTAL_CATCH, CATCH_SE)
colnames(ORWA_TWL_2016_2024) <- colnames_c

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
  arrange(year) |>
  mutate(catch = round(catch, 2))

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
  select(YEAR, SEAS, fleet, TOTAL_CATCH, CATCH_SE)
colnames(ORWA_NONTWL_2016_2024) <- colnames_c

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
  arrange(year) |>
  mutate(catch = round(catch, 2))

# OR REC - fleet 6
# OR Rec data up to 2024 provided from Ali Whitman
# From Ali: Previous assessments used some in-house data to produce recreational
# catch  estimates from 1973 – 1978. The data are similar (same sampling program)
# to  those used in the new sport reconstruction, which as you said, starts in 1979.
# I have no updates for those numbers but hope to eventually incorporate those
# data into our new reconstruction. I would suggest just rolling those years
# (1973 – 1978) over from the previous assessment.  I’m not opposed to removing
# them if you guys feel otherwise, but I think they’re fine as is.

OR_REC_to_1978 <- inputs_catch$dat$catch |>
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
# WA Rec data from RecFIN - See Rcode > removals > WA_rec_catch.r file for how this was compiled
# Discards are included unlike they were in the 2017 assessment and I think we should use those
# but it's not that much different from the previous asssessment so also good with using this assessment
WA_hist_catch_REC <- inputs_catch$dat$catch |>
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

inputs_catch$dat$catch <- all_catch


###############
### Indices ###
###############
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
  mutate(fleet = 6)
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
OR_onboard_rec_index <- inputs$dat$CPUE |>
  filter(index == 9)

# Experimental ORFS to test a sensitivity with
# From Ali Whitman
# For some reason 2003 is missing from the updated index. This also now includes
# years 2015, 2017, 2022, 2023, and 2024
# ORFS_index <- read.csv(file.path(getwd(), "Data", "processed", "ORFS_index_forSS.csv")) |>
#   mutate(
#     fleet = ?,
#     obs = round(obs, digits = 6),
#     logse = round(logse, digits = 6)
#   )
# colnames(ORFS_index) <- colnames_i

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
  "IPHC_model_based_index_forSS3.csv"
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
    OR_onboard_rec_index,
    # ORFS_index,
    tri_index,
    NWFSC_ORWA_index,
    IPHC_ORWA_index
  )
)

inputs$dat$CPUE <- all_indices

###########################
### Length compositions ###
###########################

colnames_l <- colnames(inputs$dat$lencom)

# CA TWL (from PacFIN) - fleet 1

# CA NONTWL (from PacFIN) - fleet 2

# CA NONTWL (from WCGOP) - fleet 2

# CA REC - fleet 3
CA_REC_lengths <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "recfin_bio_data",
  "recfin_ca_lengths.csv"
))
colnames(CA_REC_lengths) <- colnames_l

# ORWA TWL (PacFIN and WCGOP combined) - fleet 4

# ORWA NONTWL (PacFIN and WCGOP combined) - fleet 5

# OR REC (MRFSS and ORBS combined, plus data associated with WDFW ages (1979-2002) and ODFW (2009-2016) ages, not included in RecFIN) - fleet 6
OR_REC_lengths <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "or_rec_lengths.csv"
))
colnames(OR_REC_lengths) <- colnames_l

# WA REC (data from WDFW) - fleet 7
WA_REC_lengths <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "recfin_wa_lengths.csv"
))
colnames(WA_REC_lengths) <- colnames_l

# CA observer - fleet 8

# OR observer - fleet 9

# Nsamp method used for all survey length comps is the old Stewart Hamel method from the 2017 assessment where
# Nsamp = n_trips + 0.0707 * n_fish when n_fish/n_tows < 55 and
# Nsamp = 4.89 * n_trips when n_fish/n_tows >= 55
# Triennial survey - fleet 10
TRI_lengths <- inputs$dat$lencom |>
  filter(fleet == 10)

# NWFSC survey - fleet 11
NWFSC_lengths_old <- inputs$dat$lencom |>
  filter(fleet == 11) |>
  select(year < 2016)
NWFSC_lengths_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "NWFSC.Combo_and_Tri_length_comps",
  "NWFSC.Combo_length_cm_unsexed_raw_10_74_yelloweye rockfish_groundfish_slope_and_shelf_combination_survey.csv"
)) |>
  filter(Year >= 2016)
colnames(NWFSC_lengths_new) <- colnames_l
NWFSC_lengths <- rbind(NWFSC_lengths_old, NWFSC_lengths_new)

# IPHC ORWA - fleet 12
# IPHC bio data notes:
# Total_Biodata_Comb includes all Yelloweye biodata collected from IPHC FISS 2A from 2022-2023 and stlkeys for association with the IPHC effort database, and some location information pulled from the IPHC effort database
# Experimental gear catch and catch where species could not be rectified against onboard tag documentation were removed.
# 2A was not fished in 2020 and 2024.  Oregon stations were not fished in 2023.
# Oregon rockfish were not tagged in 2021 and fish cannot be reconciled with IPHC effort data.
# IPHC has not provided onboard tag information for Oregon stations in 2019. 2019 landings currently cannot be reconciled with IPHC effort data.

IPHC_lengths_old <- inputs$dat$lencom |>
  filter(fleet == 11)

# Use previous assessment year 2016 or use new data?
IPHC_lengths_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "IPHC_bio_data",
  "iphc_length_comps.csv"
)) |>
  filter(Year > 2016)
colnames(IPHC_lengths) <- colnames_l
IPHC_lengths <- rbind(IPHC_lengths_old, IPHC_lengths_new)

# Put all lengths together
all_lengths <- do.call(
  "rbind",
  list(
    CA_REC_lengths,
    OR_REC_lengths,
    WA_REC_lengths,
    TRI_lengths,
    NWFSC_lengths,
    IPHC_lengths
  )
)

inputs$dat$lencomp <- all_lengths

########################
### Age compositions ###
########################

colnames_a <- colnames(inputs$dat$agecom)

# CA NONTWL CAAL - fleet 2

# CA NONTWL MAAL - fleet -2

# CA NONTWL WCGOP - fleet -2 and 2
CA_NONTWL_wcgop <- inputs$dat$agecom |>
  filter(fleet %in% c(-2, 2)) |>
  filter(year == 2005)
colnames(CA_NONTWL_wcgop) <- colnames_a

# CA REC CAAL and MAAL (aged by WDFW, 1983 and 1996 only) - fleet -3 and 3
CA_REC_wdfw <- inputs$dat$agecom |>
  filter(fleet %in% c(-3, 3))
CA_REC_wdfw <- ca_rec_wdfw[1:4, ]
colnames(CA_REC_wdfw) <- colnames_a

# CA REC CAAL and MAAL (data from Don Pearson 1979 - 1984, aged by Betty) - fleet -3 and 3
CA_REC_don_pearson <- inputs$dat$agecom |>
  filter(fleet %in% c(-3, 3))
CA_REC_don_pearson <- ca_rec_don_pearson[-c(1:4), ] |>
  filter(year < 1985)
colnames(CA_REC_don_pearson) <- colnames_a

# CA REC CAAL and MAAL (data from CDFW Julia Coates) - fleet -3 and 3
CA_REC_caal <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "ca_rec_caal.csv"
))
CA_REC_maal <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "ca_rec_caal.csv"
))

CA_REC_ages <- rbind(CA_REC_caal, CA_REC_maal)
colnames(CA_REC_ages) <- colnames_a

# ORWA TWL CAAL (PacFIN and WCGOP combined) - fleet 4

# ORWA TWL MAAL (PacFIN and WCGOP combined) - fleet -4

# ORWA NONTWL CAAL (PacFIN and WCGOP combined) - fleet 5

# ORWA NONTWL MAAL (PacFIN and WCGOP combined) - fleet -5

# OR REC CAAL and MAAL - fleet -6 and 6
OR_REC_caal <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "or_rec_caal.csv"
))
OR_REC_maal <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "or_rec_maal.csv"
))

OR_REC_ages <- rbind(OR_REC_caal, OR_REC_maal)
colnames(OR_REC_ages) <- colnames_a

# WA REC CAAL and MAAL - fleet -7 and 7
WA_REC_caal <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "wa_rec_caal.csv"
))
WA_REC_maal <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "wa_rec_maal.csv"
))

WA_REC_ages <- rbind(WA_REC_caal, WA_REC_maal)
colnames(WA_REC_ages) <- colnames_a

# Nsamp method used for all survey maal is the old Stewart Hamel method from the 2017 assessment where
# Nsamp = n_trips + 0.0707 * n_fish when n_fish/n_tows < 55 and
# Nsamp = 4.89 * n_trips when n_fish/n_tows >= 55
# NWFSC survey CAAL and MAAL - fleet -11 and 11
NWFSC_caal_old <- inputs$dat$agecom |>
  filter(fleet == 11)
NWFSC_caal_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "NWFSC.Combo_CAAL",
  "processed_one_sex_caal.csv"
))
colnames(NWFSC_caal) <- colnames_a
NWFSC_caal <- rbind(NWFSC_caal_old, NWFSC_caal_new)

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
  )
colnames(NWFSC_maal) <- colnames_a
NWFSC_maal <- rbind(NWFSC_maal_old, NWFSC_maal_new)

NWFSC_ages <- rbind(NWFSC_caal, NWFSC_maal)

# IPHC survey CAAL and MAAL - fleet -12 and 12
IPHC_caal_old <- inputs$dat$agecom |>
  filter(fleet == 12) |>
  filter(year <= 2015)
IPHC_caal_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "IPHC_bio_data",
  "iphc_caal.csv"
)) |>
  filter(year > 2015)
IPHC_caal <- rbind(IPHC_caal_old, IPHC_caal_new)

IPHC_maal_old <- inputs$dat$agecom |>
  filter(fleet == -12) |>
  filter(year <= 2015)
IPHC_maal_old <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "IPHC_bio_data",
  "iphc_marginal_ages.csv"
)) |>
  filter(year > 2015)
IPHC_maal <- rbind(IPHC_maal_old, IPHC_maal_new)

IPCH_ages <- rbind(IPHC_caal, IPHC_maal)

# Combine all ages together
all_ages <- do.call(
  "rbind",
  list(
    CA_NONTWL_wcgop,
    CA_REC_wdfw,
    CA_REC_don_pearson,
    CA_REC_ages,
    OR_REC_ages,
    WA_REC_ages,
    NWFSC_ages,
    IPHC_ages
  )
)

inputs$dat$agecomp <- all_ages

r4ss::SS_write(inputs, dir = "", overwrite = TRUE)
