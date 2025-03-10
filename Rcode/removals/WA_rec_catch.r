library(r4ss)
library(dplyr)
library(ggplot2)
library(zoo)

wa_rec_hist_recfin <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "WA_rec_historical_catch_CTE503-1967---2002.csv"))
wa_rec_recfin_2005_2024 <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "CTE001-Washington-1990---2024.csv"))

# Use rec historical data from 1989
# ended up just using assessment data previous to 2005 because they were the same
# wa_rec_hist_to_1989 <- wa_rec_hist_recfin |>
#     filter(AREA < 5) |>
#     filter(RECFIN_YEAR >= 1975) |>
#     group_by(RECFIN_YEAR) |>
#     summarise(catch = sum(RETAINED_NUM) / 1000) |>
#     rename(year = RECFIN_YEAR)

# use data from previous assessment for years 1990 - 2004 since depth-dependent 
# mortality is not available for those years and it was already done for the previous assessment
input_files <- r4ss::SS_read(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe"))
wa_rec_1975_2004 <- input_files$dat$catch |>
  filter(fleet == 7) |>
  filter(year > 0 ) |>
  filter(year <= 2004) |>
  select(year, catch)

# use recfin for 2005 to 2024
wa_rec_2005_2024 <- wa_rec_recfin_2005_2024 |>
    filter(RECFIN_YEAR >= 2005) |>
    group_by(RECFIN_YEAR) |>
    summarise(catch = sum(SUM_TOTAL_MORTALITY_NUM) / 1000) |>
    rename(year = RECFIN_YEAR)

# combine all years
wa_rec_all <- wa_rec_1975_2004 |>
  bind_rows(wa_rec_2005_2024)

# interpolate catch for missing year 1979, only would do this if using recfin historical data
# but the interpolation was different so just used data from previous assessment
# wa_rec_catch_interpolate_1979 <- input_files$dat$catch |>
#     filter(fleet == 7) |>
#     dplyr::filter(!year %in% wa_rec_all$year) |>
#     dplyr::filter(year > 0) |>
#     select(year) |>
#     mutate(catch = NA)
# 
# wa_rec_all <- rbind(wa_rec_all, wa_rec_catch_interpolate_1979) |>
#     arrange(year) |>
#     mutate(catch = na.approx(catch))

write.csv(wa_rec_all, file.path(getwd(), "Data", "Processed", "WA_historical_to_recent_rec_catch.csv"))

# Comparison plot
wa_rec_current <- read.csv(file.path(getwd(), "Data", "processed", "WA_historical_to_recent_rec_catch.csv")) |>
  mutate(
    type = "current assessment"
  ) |>
  select(year, catch, type)

wa_rec_previous <- input_files$dat$catch |>
  filter(fleet == 7) |>
  filter(year >= 0) |>
  mutate(type = "previous assessment") |>
  select(year, catch, type)

wa_rec_comparison <- rbind(wa_rec_current, wa_rec_previous)

hist_wa_rec_catch_comps <- ggplot(wa_rec_comparison, aes(x = year, y = catch, fill = type)) +
  geom_bar(stat = "identity" , alpha = .8, position = "dodge") +
  scale_x_continuous(n.breaks = 10) +
  xlab("Years") +
  ylab("Catch (in numbers/1000)") +
  labs(
    title = "WA Recreational Catch Comparison",
  )

ggsave(plot = hist_wa_rec_catch_comps, "wa_rec_catch_comparison.png", path = file.path(getwd(), "Rcode", "removals"))

# Differences between 2005 and 2024 between current and previous assessment catch 
# is small and probably just small differences in how the depth-dependent mortality was calculated
# since Jason and Vlada did their own calculation for the 2017 assessment but now
# RecFIN has that calculation in it for those years.