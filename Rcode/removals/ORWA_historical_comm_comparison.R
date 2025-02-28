# Comparison of WA and OR Historical Commercial Catches
library(dplyr)
library(r4ss)
library(scales)

WA_twl <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "WA_hist_catch_twl.csv")) |>
  select(Year, Catches..mtons.) |>
  rename(year = Year,
         catch = Catches..mtons.)
  
WA_nontwl <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "WA_hist_catch_nontwl.csv")) |>
  select(Year, Catches..mtons.) |>
  rename(year = Year,
         catch = Catches..mtons.)

OR_all <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "OR_YEYE_combined historical landings.csv"))

OR_nontwl <- OR_all |>
  select(year, comm_NTWL) |>
  rename(catch = comm_NTWL)

OR_twl <- OR_all |>
  select(year, comm_TWL) |>
  rename(catch = comm_TWL)
  
ORWA_twl <- rbind(WA_twl, OR_twl) |>
  group_by(year) |>
  summarize(catch_2025 = sum(round(catch, 2)))

ORWA_nontwl <- rbind(WA_nontwl, OR_nontwl) |>
  group_by(year) |>
  summarize(catch_2025 = sum(round(catch, 2)))

inputs <- r4ss::SS_read(dir = file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe"))

ORWA_twl_old <- inputs$dat$catch |>
  filter(fleet == 4) |>
  select(year, catch) |>
  rename(catch_2017 = catch)

ORWA_nontwl_old <- inputs$dat$catch |>
  filter(fleet == 5) |>
  select(year, catch) |>
  rename(catch_2017 = catch)

ORWA_twl_comp <- left_join(ORWA_twl, ORWA_twl_old, by = "year") |>
  mutate(diff = round(catch_2025-catch_2017, 2)) |>
  write.csv(file.path(getwd(), "Rcode", "removals", "ORWA_hist_twl_comparison.csv"), row.names = FALSE)
  
ORWA_nontwl_comp <- left_join(ORWA_nontwl, ORWA_nontwl_old, by = "year") |>
  mutate(diff = round(catch_2025-catch_2017, 2)) |>
  write.csv(file.path(getwd(), "Rcode", "removals", "ORWA_hist_nontwl_comparison.csv"), row.names = FALSE)
  
  
