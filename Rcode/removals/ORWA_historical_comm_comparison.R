# Comparison of WA and OR Historical Commercial Catches
library(dplyr)
library(r4ss)
library(ggplot2)
library(tidyr)
library(scales)

WA_twl <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "WA_hist_catch_twl.csv")) |>
  select(Year, Catches..mtons.) |
  filter(Year <= 2000) |>
    rename(
      year = Year,
      catch = Catches..mtons.
    )

WA_nontwl <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "WA_hist_catch_nontwl.csv")) |>
  select(Year, Catches..mtons.) |>
  filter(Year <= 2000) |>
  rename(
    year = Year,
    catch = Catches..mtons.
  )

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
  mutate(diff = round(catch_2025 - catch_2017, 2)) |>
  filter(!is.na(diff))
write.csv(ORWA_twl_comp, file.path(getwd(), "Rcode", "removals", "ORWA_hist_twl_comparison.csv"), row.names = FALSE)

ORWA_nontwl_comp <- left_join(ORWA_nontwl, ORWA_nontwl_old, by = "year") |>
  mutate(diff = round(catch_2025 - catch_2017, 2)) |>
  filter(!is.na(diff))
write.csv(ORWA_nontwl_comp, file.path(getwd(), "Rcode", "removals", "ORWA_hist_nontwl_comparison.csv"), row.names = FALSE)


ORWA_twl_hist_comp <- ORWA_twl_comp |>
  pivot_longer(cols = c(catch_2025, catch_2017), names_to = "assessment_yr", values_to = "catch") |>
  ggplot(aes(year, catch, fill = assessment_yr)) +
  geom_bar(stat = "identity", alpha = .8, position = position_dodge(width = 0.7)) +
  scale_x_continuous(n.breaks = 10) +
  xlab("Years") +
  ylab("Catch (in MT)") +
  labs(
    title = "ORWA Historical Commerical TWL Catch Comparison"
  )

ORWA_nontwl_hist_comp <- ORWA_nontwl_comp |>
  pivot_longer(cols = c(catch_2025, catch_2017), names_to = "assessment_yr", values_to = "catch") |>
  ggplot(aes(year, catch, fill = assessment_yr)) +
  geom_bar(stat = "identity", alpha = .8, position = position_dodge(width = 0.7)) +
  scale_x_continuous(n.breaks = 10) +
  xlab("Years") +
  ylab("Catch (in MT)") +
  labs(
    title = "ORWA Historical Commerical NONTWL Catch Comparison"
  )
