# For class
model_2017_path <- file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")

# Copy input files to new folders using r4ss
copy_SS_inputs(
  dir.old = model_2017_path,
  dir.new = file.path(getwd(), "model", "2025_updated_catch"),
  create.dir = FALSE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

copy_SS_inputs(
  dir.old = model_2017_path,
  dir.new = file.path(getwd(), "model", "2025_updated_WCGBTS"),
  create.dir = FALSE,
  overwrite = TRUE,
  use_ss_new = TRUE,
  verbose = TRUE
)

#######################
# Catch Updated Model #
#######################

inputs_catch <- SS_read(dir = file.path(getwd(), "model", "2025_updated_catch"))
inputs_catch$dat$endyr <- 2024

colnames_c <- c("year", "seas", "fleet", "catch", "catch_se")

# Load recent commercial catch data for CA, OR, and WA
yelloweye_recent_comm_catch <- read.csv(file.path(getwd(), "Data", "processed", "yelloweye_commercial_catch_2016_2024_25Mar2025.csv")) |>
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
  select(YEAR, SEAS, fleet, TOTAL_CATCH, CATCH_SE)|>
  mutate(TOTAL_CATCH = round(TOTAL_CATCH, 3))
colnames(CA_2016_2024_NONTWL) <- colnames_c

# fill in zeros for years w/o data
years_no_data <- data.frame(
  year = c(2018, 2019, 2020, 2024),
  seas = c(1,1,1,1),
  fleet = c(2,2,2,2),
  catch = c(0,0,0,0),
  catch_se = c(0.01,0.01,0.01,0.01)
)

CA_NONTWL <- CA_1889_2015_NONTWL |>
  bind_rows(CA_2016_2024_NONTWL) |>
  bind_rows(years_no_data) |>
  arrange(year)

# CA REC - fleet 3
# CA historical catch the same as the previous assessment
CA_hist_catch_REC <- inputs_catch$dat$catch |>
  filter(fleet == 3 & year < 2016) |>
  filter(!between(year, 1880, 1927)) #for some reason r4ss or ss3 put zeros in here

# RecFIN obtained data for 2004 provided by Julia Coates
# CA_2004_REC <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "CTE510-2004CRFSYelloweye.csv")) |>
#   select(Year, Wgt.Ab1) |>
#   filter(Wgt.Ab1 != "-") |>
#   group_by(Year) |>
#   summarize(
#     seas = 1,
#     fleet = 3,
#     catch = sum(as.numeric(Wgt.Ab1)) / 1000,
#     catch_se = 0.01
#   ) |>
#   rename(year = Year)

#CA data provided from Julia Coates
# CA_1981_2004_REC <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "MRFSS_catch_est_yelloweye_CA.csv")) |>
#   select(YEAR_, WGT_AB1) |>
#   group_by(YEAR_) |>
#   summarize(
#     seas = 1,
#     fleet = 3,
#     catch = sum(WGT_AB1) / 1000,
#     catch_se = 0.01
#   ) |>
#   rename(year = YEAR_) |>
#   bind_rows(CA_2004_REC) |>
#   filter(!is.na(catch))|>
#   filter(year > 1980)

# Use interpolated values from the last assessment
# CA_missing_1981_2004_rec <- inputs_catch$dat$catch |>
#   filter(fleet == 3 & year > 1980 & year < 2005) |>
#   filter(!year %in% CA_1981_2004_REC$year)
# 
# CA_1981_2004_REC <- CA_1981_2004_REC |>
#   bind_rows(CA_missing_1981_2004_rec) |>
#   arrange(year)


# RecFIN data for 2016 - 2024
CA_recent_catch_REC <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "CTE001-California-1990---2024.csv")) |>
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

# WA historical catch with unchanged reconstruction provided from Fabio
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

# add start line for data
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

# add start line for data
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
  filter(year <= 1978)|>
  filter(!between(year, 1880, 1972))  # For some reason r4ss or ss3 put these in as zeros, a problem for another day

OR_REC <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "ORRecLandings_457_2024.csv")) |>
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
  filter(!between(year, 1880, 1974)) # For some reason r4ss or ss3 put these in as zeros, a problem for another day

WA_REC <- read.csv(file.path(getwd(), "Data", "processed", "WA_historical_to_recent_rec_catch.csv")) |>
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

SS_write(inputs_catch, dir = file.path(getwd(), "model", "2025_updated_catch"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "2025_updated_catch"))

# run(dir = file.path(getwd(), "model", "2025_updated_catch"), show_in_console = TRUE)
replist <- SS_output(dir = file.path(getwd(), "model", "2025_updated_catch"))
SS_plots(replist)

####################################
# WCGBTS and Catches Updated Model #
####################################

# Use ss_new files from the catches run
inputs_wcgbts <- SS_read(dir = file.path(getwd(), "model", "2025_updated_catch"))

colnames_i <- c("year", "month", "index", "obs", "se_log")

NWFSC_ORWA <- read.csv(file.path(getwd(), "Data", "processed", "wcgbts_indices", "updated_indices_ORWA_CA_split", "yelloweye_split_42_point/yelloweye_rockfish/wcgbts", "delta_lognormal", "index", "est_by_area.csv"))
NWFSC_ORWA_index <- NWFSC_ORWA |>
  filter(area == "Coastwide") |>
  select(year, est, se) |>
  mutate(
    Month = 7,
    Fleet = 11
  ) |>
  select(year, Month, Fleet, est, se) |>
  rename(month = Month,
         index = Fleet) |>
  arrange(year)
colnames(NWFSC_ORWA_index) <- colnames_i

inputs_wcgbts$dat$CPUE <- inputs_wcgbts$dat$CPUE |>
  filter(index != 11) |>
  bind_rows(NWFSC_ORWA_index) |>
  arrange(index, year)

SS_write(inputs_wcgbts, dir = file.path(getwd(), "model", "2025_updated_WCGBTS"), overwrite = TRUE)

get_ss3_exe(dir = file.path(getwd(), "model", "2025_updated_WCGBTS"))

# run(dir = file.path(getwd(), "model", "2025_updated_WCGBTS"), show_in_console = TRUE)

replist <- SS_output(dir = file.path(getwd(), "model", "2025_updated_WCGBTS"))
SS_plots(replist)

# Compare models
# Get branch that SSsummarize fix is on for now until it is merged into main
# devtools::install_github("r4ss/r4ss", ref = "fix_SSsummarize")
# library(r4ss)
models <- list.dirs(file.path(getwd(), "model"), recursive = FALSE)
models_output <- SSgetoutput(dirvec = models)
models_summary <- SSsummarize(models_output)
SSplotComparisons(models_summary,
  plotdir = file.path(getwd(), "Rcode", "SSplotComparisons_output", "presentation_2_comparisons"),
  print = TRUE,
  legendlabels = c("2017 with bias adjustment", "2017 base", "2025 updated catch", "2025 updated WCGBTS")
)
