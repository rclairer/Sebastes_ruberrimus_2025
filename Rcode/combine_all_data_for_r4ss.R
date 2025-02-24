####################################################
### Prepare data for r4ss to format SS3 dat file ###
####################################################

# Load libraries
library(dplyr)
library(tidyr)
library(r4ss)

# Get inputs from 2017 assessment that will get carried over to this assessment
inputs <- SS_read(dir = file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe"))

file.copy(
  file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe", "yelloweye_data.ss"),
  file.path(getwd(), "data", "for_SS", "yelloweye_data_2025.ss")
)

##############
### End Yr ###
##############
inputs$dat$endyr <- 2024

#############
### Catch ###
#############
colnames_c <- c("year", "seas", "fleet", "catch", "catch_se")

# CA TWL - fleet 1
ca_hist_catch <- read.csv(file.path(getwd(), "Data", "processed", "CA_all_fleets_historical_catches.csv"))
ca_hist_catch_TWL <- ca_hist_catch |>
  filter(fleet == 1) |>
  mutate(
    year = year,
    seas = 1,
    fleet = fleet,
    catch = catch,
    catch_se = 0.01
  )
# |> bind_rows(ca_recent_catch_TWL)


# CA NONTWL - fleet 2
ca_hist_catch_NONTWL <- ca_hist_catch |>
  filter(fleet == 2) |>
  mutate(
    year = year,
    seas = 1,
    fleet = fleet,
    catch = catch,
    catch_se = 0.01
  )
# |> bind_rows(ca_recent_catch_NONTWL)

# CA Rec - fleet 3
ca_hist_catch_RECL <- ca_hist_catch |>
  filter(fleet == 3) |>
  mutate(
    year = year,
    seas = 1,
    fleet = fleet,
    catch = catch,
    catch_se = 0.01
  )
# |> bind_rows(ca_recent_catch_REC)

# ORWA TWL - fleet 4
OR_hist_catch_to_2000 <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "OR_YEYE_combined historical landings.csv"))
OR_hist_TWL <- OR_hist_catch_to_2000 |>
  select(year, comm_TWL) |>
  filter(!is.na(comm_TWL)) |>
  mutate(
    seas = 1,
    fleet = 4,
    catch = comm_TWL,
    catch_se = 0.01
  )
# |> bind_rows(ORWA_recent_TWL)
OR_hist_catch_to_2000 <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "OR_YEYE_combined historical landings.csv"))
OR_hist_TWL <- OR_hist_catch_to_2000 |>
  select(year, comm_TWL) |>
  filter(!is.na(comm_TWL)) |>
  mutate(
    seas = 1,
    fleet = 4,
    catch = comm_TWL,
    catch_se = 0.01
  )
# |> bind_rows(ORWA_recent_TWL)

# ORWA NONTWL - fleet 5
OR_hist_NONTWL <- OR_hist_catch_to_2000 |>
  select(year, comm_NTWL) |>
  mutate(
    seas = 1,
    fleet = 5,
    catch = comm_NTWL,
    catch_se = 0.01
  )
# |> bind_rows(ORWA_recent_NONTWL)
OR_hist_NONTWL <- OR_hist_catch_to_2000 |>
  select(year, comm_NTWL) |>
  mutate(
    seas = 1,
    fleet = 5,
    catch = comm_NTWL,
    catch_se = 0.01
  )
# |> bind_rows(ORWA_recent_NONTWL)

# OR Rec - fleet 6
OR_his_rec <- OR_hist_catch_to_2000 |>
  select(year, rec) |>
  filter(!is.na(rec)) |>
  mutate(
    seas = 1,
    fleet = 6,
    catch = rec,
    catch_se = 0.01
  )
# |> bind_rows(OR_recent_rec)
OR_his_rec <- OR_hist_catch_to_2000 |>
  select(year, rec) |>
  filter(!is.na(rec)) |>
  mutate(
    seas = 1,
    fleet = 6,
    catch = rec,
    catch_se = 0.01
  )
# |> bind_rows(OR_recent_rec)

# WA Rec - fleet 7
wa_rec_catch <- read.csv(file.path(getwd(), "Data", "processed", "WA_historical_to_recent_rec_catch.csv")) |>
  mutate(
    seas = 1,
    fleet = 7,
    catch_se = 0.01
  ) |>
  select(year, seas, fleet, catch, catch_se)

all_catch <- do.call("rbind", list(c(wa_rec_catch, )))

inputs$dat$catch <- all_catch

###############
### Indices ###
###############
colnames_i <- c("year", "seas", "index", "obs", "se_log")

# CA Rec MRFSS dockside CPUE - fleet 3
# I think we just bring over from 2017 assessment, because max year is 1999
CA_REC_MRFSS_index <- inputs$dat$CPUE |>
  filter(index == 3)

# OR Rec MRFSS - fleet 6
# I think we just bring over from 2017 assessment
OR_REC_MRFSS_index <- inputs$dat$CPUE |>
  filter(index == 6, year < 2000)

# OR ORBS - fleet 6
# FROM ALI, hopefully 03/05/2025

# WA Rec CPUE - fleet 7
# I think we just bring over from the 2017 assessment, because max year is 2001
WA_REC_CPUE_index <- inputs$dat$CPUE |>
  filter(index == 7)

# CA onboard CPFV CPUE - fleet 8
# I think we just bring over from the 2017 assessment, because max year is 1998
CA_CPFV_CPUE_index <- inputs$dat$CPUE |>
  filter(index == 8)

# Oregon onboard Recreational Charter observer CPUE - fleet 9
# this is ORFS, right?
# FROM ALI, hopefully 03/05/2025

# TRI ORWA - fleet 10
tri_index <- inputs$dat$CPUE |>
  filter(index == 10)

# NWFSC ORWA - fleet 11
NWFSC_ORWA <- read.csv(file.path(getwd(), "Data", "processed", "wcgbts_indices", "updated_indices_ORWA_CA_split", "yelloweye_split_42_point/yelloweye_rockfish/wcgbts", "delta_lognormal", "index", "est_by_area.csv"))
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
colnames(IPHC_ORWA_index) <- colnames_i # se or se_log?

all_indices <- do.call("rbind", list(c(CA_REC_MRFSS_index, OR_REC_MRFSS_index, WA_REC_CPUE_index, CA_CPFV_CPUE_index, tri_index, NWFSC_ORWA_index, IPHC_ORWA_index)))

inputs$dat$indices <- all_indices

###########################
### Length compositions ###
###########################

colnames_1 <- colnames(inputs$dat$lencom)

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
tri_lengths <- inputs$dat$lencom |>
  filter(fleet == 10)

# NWFSC survey - fleet 11
nwfsc_lengths <- read.csv(file.path(
  getwd(), "Data", "processed", "NWFSC.Combo_and_Tri_length_comps",
  "NWFSC.Combo_length_cm_unsexed_raw_10_74_yelloweye rockfish_groundfish_slope_and_shelf_combination_survey.csv"
)) |>
  colnames(nwfsc_lengths) <- colnames_l

# IPHC ORWA - fleet 12


all_lengths <- do.call("rbind", list(c(
  tri_lengths,
  nwfsc_lengths
)))

inputs$dat$lencomp <- all_lengths

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


# Combine all ages together
all_ages <- do.call("rbind", list(
  ca_nontwl_wcgop,
  ca_rec_wdfw,
  ca_rec_don_pearson,
  nwfsc_ages
))

inputs$dat$agecomp <- all_ages
