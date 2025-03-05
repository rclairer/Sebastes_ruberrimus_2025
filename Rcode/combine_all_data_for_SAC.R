#################################
### Prepare data for SAC tool ###
#################################

# Load libraries
library(dplyr)
library(tidyr)
library(r4ss)

# Get inputs from 2017 assessment that will get carried over to this assessment
inputs <- SS_read(dir = file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe"))

#############
### Catch ###
#############

# colnames for catch is Year and then each fleet with a name which
# needs to match names of indices if they overlap

# CA TWL - fleet 1
ca_hist_catch <- read.csv(file.path(getwd(), "Data", "processed", "CA_all_fleets_historical_catches.csv"))
ca_hist_catch_TWL <- ca_hist_catch |>
  filter(fleet == 1) |>
  select(year, catch) |>
  rename(Year = year,
         CA_TWL = catch) 

# CA NONTWL - fleet 2
ca_hist_catch_NONTWL <- ca_hist_catch |>
  filter(fleet == 2) |>
  select(year, catch) |>
  rename(Year = year,
         CA_TWL = catch) 

# CA Rec - fleet 3
ca_hist_catch_REC <- ca_hist_catch |>
  filter(fleet == 3) |>
  select(year, catch) |>
  rename(Year = year,
         CA_REC = catch) 

# ORWA TWL - fleet 4

# ORWA NONTWL - fleet 5

# OR Rec - fleet 6

# WA Rec - fleet 7
wa_rec_catch <- read.csv(file.path(getwd(),"Data", "processed", "WA_historical_to_recent_rec_catch.csv")) |>
  select(year, catch) |>
  rename(Year = year,
         WA_REC = catch)

all_catch <- do.call("rbind", list(c(wa_rec_catch,
                                     ))) |>
write.csv(all_catch, file = file.path(getwd(), "Data", "for_SS", "all_catch_SAC.csv"), row.names = FALSE)

###############
### Indices ###
###############

colnames_i <- c("Year",	"Month",	"Fleet",	"Index",	"CV", "Label")

# CA Rec MRFSS dockside CPUE - fleet 3
 
# OR Rec MRFSS - fleet 6
 
# OR ORBS - fleet 6

# WA Rec CPUE - fleet 7
 
# CA onboard CPFV CPUE - fleet 8
 
# Oregon onboard Recreational Charter observer CPUE - fleet 9
 
# TRI ORWA - fleet 10
tri_index <- inputs$dat$CPUE |>
  filter(index == 10) |>
  mutate(Label = "Triennial")
colnames(tri_index) <- colnames_i
 
# NWFSC ORWA - fleet 11
NWFSC_ORWA <- read.csv(file.path(getwd(), "Data", "processed", "wcgbts_indices", "updated_indices_ORWA_CA_split", "yelloweye_split_42_point/yelloweye_rockfish/wcgbts", "delta_lognormal", "index", "est_by_area.csv"))
NWFSC_ORWA_index <- NWFSC_ORWA |>
  filter(area == "Coastwide") |>
  select(year, est, se) |>
  mutate(Month = 7,
         Fleet = 11,
         Label = "NWFSC ORWA") |>
  select(year, Month, Fleet, est, se, Label)
colnames(NWFSC_ORWA_index) <- colnames_i
 
# IPHC ORWA - fleet 12

all_indices <- do.call("rbind", list(c(tri_index,
                                       )))
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
tri_lengths <- inputs$dat$lencom |>
  filter(fleet == 10) |>
  select(-part)
colnames(tri_lengths) <- colnames_l

# NWFSC survey - fleet 11
nwfsc_lengths <- read.csv(file.path(getwd(), "Data", "processed", "NWFSC.Combo_and_Tri_length_comps", 
                                    "NWFSC.Combo_length_cm_unsexed_raw_10_74_yelloweye rockfish_groundfish_slope_and_shelf_combination_survey.csv")) |>
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
  filter(fleet %in% c(-2,2)) |>
  select(-part) |>
  filter(year == 2005)
colnames(ca_nontwl_wcgop) <- colnames_a

# CA REC CAAL and MAAL (aged by WDFW, 1983 and 1996 only) - fleet -3 and 3
ca_rec_wdfw <- inputs$dat$agecom |>
  filter(fleet %in% c(-3,3)) |>
  select(-part)
ca_rec_wdfw <- ca_rec_wdfw[1:4,]
colnames(ca_rec_wdfw) <- colnames_a

# CA REC CAAL (data from Don Pearson 1979 - 1984, aged by Betty) - fleet -3 and 3
ca_rec_don_pearson <- inputs$dat$agecom |>
  filter(fleet %in% c(-3,3)) |>
  select(-part)
ca_rec_don_pearson <- ca_rec_don_pearson[-c(1:4),] |>
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
nwfsc_caal <- read.csv(file.path(getwd(), "Data", "processed", "NWFSC.Combo_CAAL", 
                                    "processed_one_sex_caal.csv")) |>
  select(-partition)
colnames(nwfsc_caal) <- colnames_a

nwfsc_maal <- read.csv(file.path(getwd(), "Data", "processed", "NWFSC.Combo_age_comps",
                                 "NWFSC.Combo_age_unsexed_raw_0_65_yelloweye rockfish_groundfish_slope_and_shelf_combination_survey.csv")) |>
              select(-partition) |>
              mutate(ageerr = 2,
                     fleet = -11)
colnames(nwfsc_maal) <- colnames_a

nwfsc_ages <- rbind(nwfsc_caal, nwfsc_maal)

# IPHC survey CAAL and MAAL - fleet -12 and 12

# Combine all ages together
all_ages <- do.call("rbind", list(ca_nontwl_wcgop, 
                                  ca_rec_wdfw, 
                                  ca_rec_don_pearson, 
                                  nwfsc_ages))

write.csv(all_ages, file = file.path(getwd(), "Data", "for_SS", "all_ages_SAC.csv"), row.names = FALSE)