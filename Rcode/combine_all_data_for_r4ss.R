####################################################
### Prepare data for r4ss to format SS3 dat file ###
####################################################

# Load libraries
library(dplyr)
library(tidyr)
library(r4ss)

# Get inputs from 2017 assessment that will get carried over to this assessment
model_2017_path <- file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")
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
  mutate(index = 6)
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
    ORFS_index,
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

# Might need to retroactively divide nsamps and actual numbers of fish by 2
# from last assessment

# CA TWL (from PacFIN) - fleet 1
# Provided by Juliette
# QUESTION: Where is this dataset?
CA_TWL_lengths_old <- inputs$dat$lencomp |>
  filter(fleet == 1)
CA_TWL_lengths_new <-

# CA NONTWL (from PacFIN) up until 2002 - fleet 2
# Provided by Juliette
# QUESTION: Where is this dataset?
CA_NONTWL_lengths_pacfin_old <- inputs$dat$lencomp |>
  filter(fleet == 2) |>
  filter(year <= 2002)
CA_NONTWL_lengths_pacfin_new <- 

# CA NONTWL (from WCGOP) - fleet 2
# Provided by Juliette
# QUESTION: Where is this dataset?
CA_NONTWL_lengths_old <- inputs$dat$lencomp |>
  filter(fleet == 2) |>
  filter(year > 2002)
CA_NONTWL_lengths_new <- 

# CA REC - fleet 3
# Provided by Morgan and Abby
# Previous data to 2016
CA_REC_lengths_old <- inputs$dat$lencomp |>
  filter(fleet == 3)
# Recent data 2017 and onward
CA_REC_lengths_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "ca_rec_lengths.csv"
)) |>
  select(-X) |>
  filter(year > 2016)
colnames(CA_REC_lengths_new) <- colnames_l
CA_REC_lengths <- rbind(CA_REC_lengths_old, CA_REC_lengths_new)

# ORWA TWL (PacFIN and WCGOP combined) - fleet 4
# Provided by Juliette
# QUESTION: Where is this dataset?
ORWA_TWL_lengths_old <- inputs$dat$lencomp |>
  filter(fleet == 4)
ORWA_TWL_lengths_new

# ORWA NONTWL (PacFIN and WCGOP combined) - fleet 5
# Provided by Juliette
# QUESTION: Where is this dataset?
ORWA_NONTWL_lengths_old <- inputs$dat$lencomp |>
  filter(fleet == 5)
ORWA_NONTWL_lengths_new

# OR REC (MRFSS and ORBS combined, plus data associated with WDFW ages (1979-2002) 
# and ODFW (2009-2016) ages, not included in RecFIN) - fleet 6
# Provided by Morgan and Abby
# Previous data until 2016
OR_REC_lengths_old <- inputs$dat$lencomp |>
  filter(fleet == 6)
# Recent data from 2017 onward
OR_REC_lengths_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "or_rec_lengths.csv"
)) |>
  filter(year > 2016) |>
  select(-X)
colnames(OR_REC_lengths_new) <- colnames_l
OR_REC_lengths <- rbind(OR_REC_lengths_old, OR_REC_lengths_new)

# WA REC (data from WDFW) - fleet 7
# Provided by Morgan and Abby
WA_REC_lengths_old <- inputs$dat$lencomp |>
  filter(fleet == 7)
WA_REC_lengths_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "wa_rec_lengths.csv"
)) |>
  filter(year > 2016) |>
  select(-X)
colnames(WA_REC_lengths_new) <- colnames_l
WA_REC_lengths <- rbind(WA_REC_lengths_old, WA_REC_lengths_new)

# CA observer - fleet 8
# Provided by Morgan and Abby
CA_observer_lengths_old <- inputs$dat$lencomp |>
  filter(fleet == 8)
CA_observer_lengths_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "ca_obs_lengths.csv"
)) |>
  filter(year > 2016) |>
  select(-X)
colnames(CA_observer_lengths_new) <- colnames_l
CA_observer_lengths <- rbind(CA_observer_lengths_old, CA_observer_lengths_new)

# OR observer - fleet 9
# Provided by Morgan and Abby
OR_observer_lengths_old <- inputs$dat$lencomp |>
  filter(fleet == 9)
OR_observer_lengths_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "or_obs_lengths.csv"
)) |>
  filter(year > 2016) |>
  select(-X)
colnames(OR_observer_lengths_new) <- colnames_l
OR_observer_lengths <- rbind(OR_observer_lengths_old, OR_observer_lengths_new)

# Nsamp method used for all survey length comps is the old Stewart Hamel method from the 2017 assessment where
# Nsamp = n_trips + 0.0707 * n_fish when n_fish/n_tows < 55 and
# Nsamp = 4.89 * n_trips when n_fish/n_tows >= 55
# Triennial survey - fleet 10
TRI_lengths <- inputs$dat$lencom |>
  filter(fleet == 10)

# NWFSC survey - fleet 11
# Provided by Elizabeth
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
colnames(NWFSC_lengths_new) <- colnames_l
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
colnames(IPHC_lengths_new) <- colnames_l
IPHC_lengths <- rbind(IPHC_lengths_old, IPHC_lengths_new)

# Put all lengths together
all_lengths <- do.call(
  "rbind",
  list(
    CA_REC_lengths,
    OR_REC_lengths,
    WA_REC_lengths,
    CA_observer_lengths,
    OR_observer_lengths,
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

# CA NONTWL CAAL and MAAL - fleet 2 and -2
# From Juliette
# QUESTION: Where is this dataset?

# CA NONTWL WCGOP - fleet -2 and 2
CA_NONTWL_wcgop <- inputs$dat$agecom |>
  filter(fleet %in% c(-2, 2)) |>
  filter(year == 2005)
colnames(CA_NONTWL_wcgop) <- colnames_a

# CA REC CAAL and MAAL (aged by WDFW, 1983 and 1996 only) - fleet -3 and 3
CA_REC_wdfw <- inputs$dat$agecom |>
  filter(fleet %in% c(-3, 3))
CA_REC_wdfw <- CA_REC_wdfw[1:4, ]
colnames(CA_REC_wdfw) <- colnames_a

# CA REC CAAL and MAAL (data from Don Pearson 1979 - 1984, aged by Betty) - fleet -3 and 3
CA_REC_don_pearson <- inputs$dat$agecom |>
  filter(fleet %in% c(-3, 3))
CA_REC_don_pearson <- CA_REC_don_pearson[-c(1:4), ] |>
  filter(year < 1985)
colnames(CA_REC_don_pearson) <- colnames_a


# CA REC CAAL and MAAL (data from CDFW Julia Coates) - fleet -3 and 3
# QUESTION: There are no updates to these since 2016?
CA_REC_caal <- inputs$dat$agecomp |>
  filter(fleet == 3) |>
  filter(year >=2009)
CA_REC_maal <- inputs$dat$agecomp |>
  filter(fleet == -3) |>
  filter(year >= 2009)
CA_REC_ages <- rbind(CA_REC_caal, CA_REC_maal)

# ORWA TWL CAAL and MAAL (PacFIN and WCGOP combined) - fleet 4 and -4
# Provided by Juliette
# QUESTION: Where is this dataset?


# ORWA NONTWL CAAL and MAAL (PacFIN and WCGOP combined) - fleet 5 and -5
# Provided by Juliette
# QUESTION: Where is this dataset?


# OR REC CAAL and MAAL - fleet -6 and 6
# Morgan and Abby need to provide an updated data set
# Do we only have these up until 2016 still?
OR_REC_caal_old <- inputs$dat$agecom |>
  filter(fleet == 6)
OR_REC_caal_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "or_rec_caal.csv"
)) |>
  filter(year > 2016) |>
  select(-X)
colnames(OR_REC_caal_new) <- colnames_a
OR_REC_caal <- rbind(OR_REC_caal_old, OR_REC_caal_new)

OR_REC_maal_old <- inputs$dat$agecom |>
  filter(fleet == -6)
OR_REC_maal_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "or_rec_maal.csv"
))|>
  filter(year > 2016) |>
  select(-X)
colnames(OR_REC_maal_new) <- colnames_a
OR_REC_maal <- rbind(OR_REC_maal_old, OR_REC_maal_new)

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
  select(-X)
colnames(WA_REC_caal) <- colnames_a

WA_REC_maal <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "rec_comps",
  "wa_rec_maal.csv"
)) |>
  select(-X)
colnames(WA_REC_maal) <- colnames_a

WA_REC_ages <- rbind(WA_REC_caal, WA_REC_maal)

# Nsamp method used for all survey maal is the old Stewart Hamel method from the 2017 assessment where
# Nsamp = n_trips + 0.0707 * n_fish when n_fish/n_tows < 55 and
# Nsamp = 4.89 * n_trips when n_fish/n_tows >= 55
# NWFSC survey CAAL and MAAL - fleet -11 and 11
# QUESTION: The age comps were a little different between the old assessment and the new assessment, are we
# going to use updated ages? for all years?
# NWFSC_caal_old <- inputs$dat$agecom |>
#   filter(fleet == 11)
NWFSC_caal_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "NWFSC.Combo_CAAL",
  "processed_one_sex_caal.csv"
)) 
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
  ) 
# |>
#   filter(year > 2016)
colnames(NWFSC_maal_new) <- colnames_a
NWFSC_maal <- NWFSC_maal_new
# NWFSC_maal <- rbind(NWFSC_maal_old, NWFSC_maal_new)

NWFSC_ages <- rbind(NWFSC_caal, NWFSC_maal)

# IPHC survey CAAL and MAAL - fleet -12 and 12
# Data provided by Fabio, bio comps processed by Elizabeth
IPHC_caal_old <- inputs$dat$agecom |>
  filter(fleet == 12) |>
  filter(year <= 2016)
IPHC_caal_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "IPHC_bio_data",
  "iphc_caal.csv"
)) |>
  filter(year > 2016)
colnames(IPHC_caal_new) <- colnames_a
IPHC_caal <- rbind(IPHC_caal_old, IPHC_caal_new)

IPHC_maal_old <- inputs$dat$agecom |>
  filter(fleet == -12) |>
  filter(year <= 2016)
IPHC_maal_new <- read.csv(file.path(
  getwd(),
  "Data",
  "processed",
  "IPHC_bio_data",
  "iphc_marginal_ages.csv"
)) |>
  filter(year > 2016)
colnames(IPHC_maal_new) <- colnames_a
IPHC_maal <- rbind(IPHC_maal_old, IPHC_maal_new)

IPHC_ages <- rbind(IPHC_caal, IPHC_maal)

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
