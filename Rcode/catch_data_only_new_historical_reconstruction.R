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


# CA TWL - fleet 1
# Use CA TWL from 1889-2015 from previous assessment
CA_1889_2016_TWL <- inputs$dat$catch |>
  filter(fleet == 1)

# CA NONTWL - fleet 2
# Use CA TWL from 1889-2016 from previous assessment
CA_1889_2016_NONTWL <- inputs$dat$catch |>
  filter(fleet == 2)

# CA REC - fleet 3
# CA historical catch the same as the previous assessment
CA_hist_catch_REC <- inputs$dat$catch |>
  filter(fleet == 3) |>
  filter(!between(year, 1880, 1927))


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
    YEAR <= 2016
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
  filter(Year <= 2016) |>
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

# Combine historical catch to 2016
ORWA_TWL_until_2016 <- OR_TWL |>
  bind_rows(WA_TWL) |>
  group_by(year) |>
  summarize(
    seas = 1,
    fleet = 4,
    catch = sum(catch),
    catch_se = 0.01
  )


# ORWA NONTWL - fleet 5
# All OR data provided from Ali with updated historical catch reconstruction
OR_NONTWL <- OR_comm_all |>
  select(YEAR, FLEET, TOTAL) |>
  filter(
    FLEET == "NTRW",
    YEAR <= 2016
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
  filter(Year <= 2016) |>
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

# Combine historical catch to 2016
ORWA_NONTWL_until_2015 <- OR_NONTWL |>
  bind_rows(WA_NONTWL) |>
  group_by(year) |>
  summarize(
    seas = 1,
    fleet = 5,
    catch = sum(catch),
    catch_se = 0.01
  )

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
  filter(year <= 2016) |>
  select(-Total_MT) |>
  mutate(catch = round(catch, 2)) |>
  bind_rows(OR_REC_to_1978) |>
  arrange(year)

# WA REC - fleet 7
# WA Rec data from RecFIN - See Rcode > removals > WA_rec_catch.r file for how this was compiled
# Discards are included unlike they were in the 2017 assessment and I think we should use those
# but it's not that much different from the previous asssessment so also good with using this assessment
WA_hist_catch_REC <- inputs$dat$catch |>
  filter(fleet == 7 & year <= 2016) |>
  filter(!between(year, 1880, 1974))

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

SS_write(inputs, dir = file.path(getwd(), "model", "2026_updated_historical_reconstruction"), overwrite = TRUE)