library(r4ss)
library(dplyr)
library(ggplot2)
library(zoo)

wa_rec_hist_recfin <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "WA_rec_historical_catch_CTE503-1967---2002.csv"))
wa_rec_recfin_1990_2024 <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "CTE001-Washington-1990---2024.csv"))

# Use rec historical data from 1989
# ended up just using assessment data previous to 2005 because they were the same
wa_rec_hist_to_1989 <- wa_rec_hist_recfin |>
    filter(AREA < 5) |>
    filter(RECFIN_YEAR >= 1975) |>
    group_by(RECFIN_YEAR) |>
    summarise(catch = sum(RETAINED_NUM) / 1000) |>
    rename(year = RECFIN_YEAR)

# summarize recfin catch we were originally given (not Fabios most up to data data)
wa_rec_1990_to_2024 <- wa_rec_recfin_1990_2024 |>
  #filter(AREA < 5) |>
  #filter(RECFIN_YEAR >= 1975) |>
  group_by(RECFIN_YEAR) |>
  summarise(catch = sum(SUM_TOTAL_MORTALITY_NUM) / 1000) |>
  rename(year = RECFIN_YEAR)

# use data from previous assessment for years 1990 - 2004 since depth-dependent 
# mortality is not available for those years and it was already done for the previous assessment
input_files <- r4ss::SS_read(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe"))
wa_rec_old_all <- input_files$dat$catch |>
  filter(fleet == 7) |>
  filter(year > 0 ) |>
  #filter(year <= 2004) |>
  select(year, catch)

# use recfin for 2005 to 2024
# wa_rec_2005_2024 <- wa_rec_recfin_2005_2024 |>
#     filter(RECFIN_YEAR >= 2005) |>
#     group_by(RECFIN_YEAR) |>
#     summarise(catch = sum(SUM_TOTAL_MORTALITY_NUM) / 1000) |>
#     rename(year = RECFIN_YEAR)

# combine all years
# wa_rec_all <- wa_rec_1975_2004 |>
#   bind_rows(wa_rec_2005_2024)

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

# write.csv(wa_rec_all, file.path(getwd(), "Data", "Processed", "WA_historical_to_recent_rec_catch.csv"))

# Comparison plot of new data vs 2017
wa_rec_new <- rec_new_all <- as.data.frame(rbind(wa_rec_hist_to_1989,wa_rec_1990_to_2024)) |>
  mutate(
    type = "current assessment"
  ) |>
  select(year, catch, type)

wa_rec_old <- wa_rec_old_all |>
  mutate(type = "previous assessment") |>
  select(year, catch, type)

wa_rec_comparison <- rbind(wa_rec_new, wa_rec_old)

hist_wa_rec_catch_comps <- ggplot(wa_rec_comparison, aes(x = year, y = catch, fill = type)) +
  geom_bar(stat = "identity" , alpha = .8, position = "dodge") +
  scale_x_continuous(n.breaks = 10) +
  xlab("Years") +
  ylab("Catch (in numbers/1000)") +
  labs(
    title = "WA Recreational Catch Comparison",
  )
hist_wa_rec_catch_comps

## This plot is actually comparing the Washington Catch used in the 2017 assessment and the data that was provided way back in February. 
## For some reason it looks like the new data is half of the old assessment for some years.


#ggsave(plot = hist_wa_rec_catch_comps, "wa_rec_catch_comparison.png", path = file.path(getwd(), "Rcode", "removals"))

# Differences between 2005 and 2024 between current and previous assessment catch 
# is small and probably just small differences in how the depth-dependent mortality was calculated
# since Jason and Vlada did their own calculation for the 2017 assessment but now
# RecFIN has that calculation in it for those years.

#########################
# Down here I will load in the most recent data that Fabio provided.
# According to his emails, it looks like the historic data was updated and they think the last assessment used MT instead of Number of Fish
# So he thinks the total catch numbers for 1990-2002 need to be way lower and recalculated.

# read in 
wa_rec_hist_recfin_may <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "CTE503-1967---2002_may.csv"))
wa_rec_recfin_1990_2024_may <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "CTE501_WA_1990_2024_may.csv"))

wa_rec_hist_to_1989_may <- wa_rec_hist_recfin_may |>
  filter(AREA < 5) |>
  #filter(RECFIN_YEAR >= 1975) |>
  group_by(RECFIN_YEAR) |>
  summarise(catch = sum(RETAINED_NUM) / 1000) |>
  rename(year = RECFIN_YEAR)

wa_rec_1990_to_2024_may <- wa_rec_recfin_1990_2024_may |>
  group_by(Year) |>
  summarise(catch = sum(Numbers.of.Fish) / 1000) |>
  rename(year = Year)

# Comparison plot of new data given to us in May
wa_rec_new_may <- rec_new_may_all <- as.data.frame(rbind(wa_rec_hist_to_1989_may,wa_rec_1990_to_2024_may)) |>
  mutate(
    type = "raw may data"
  ) |>
  select(year, catch, type)

wa_rec_comparison <- rbind(wa_rec_new, wa_rec_old, wa_rec_new_may)

hist_wa_rec_catch_comps <- ggplot(wa_rec_comparison, aes(x = year, y = catch, fill = type)) +
  geom_bar(stat = "identity" , alpha = .8, position = "dodge") +
  scale_x_continuous(n.breaks = 10) +
  xlab("Years") +
  ylab("Catch (in numbers/1000)") +
  labs(
    title = "WA Recreational Catch Comparison",
  )
hist_wa_rec_catch_comps

###########################
# After comparing all the data with Fabio (state rep), we decided to replace all recent and historical data with the most recent RecFin pull (May):
# 1. 1967-2024, use most recent CTE 503, updated in May
# 2. For the missing years (71, 74, 79), assign the average of the two previous and two post years together
# 3. Calculate the total mortality for 2002-2004 based on Theresa's numbers for Total Retained and Total Released 

# Call newest raw data files
wa_rec_hist_recfin_may <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "CTE503-1967---2002_may.csv"))
wa_rec_recfin_1990_2024_may <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "CTE501_WA_1990_2024_may.csv"))

# Add missing Years averages to historic data
wa_rec_hist_to_1989_may <- wa_rec_hist_recfin_may |>
  filter(AREA < 5) |>
  group_by(RECFIN_YEAR) |>
  summarise(catch = sum(RETAINED_NUM) / 1000) |>
  rename(year = RECFIN_YEAR)
# Compute averages for specific ranges
yr71 <- wa_rec_hist_to_1989_may |> filter(year >= 1969 & year <= 1973) |> summarise(catch = mean(catch)) |> pull()
yr74 <- wa_rec_hist_to_1989_may |> filter(year >= 1972 & year <= 1976) |> summarise(catch = mean(catch)) |> pull()
yr79 <- wa_rec_hist_to_1989_may |> filter(year >= 1977 & year <= 1981) |> summarise(catch = mean(catch)) |> pull()
# Create a tibble with the missing years and corresponding average catch
missing_years <- tibble(
  year = c(1971, 1974, 1979),
  catch = c(yr71, yr74, yr79)
)
# Combine the original data with the missing years
wa_rec_hist_to_1989_may <- bind_rows(wa_rec_hist_to_1989_may, missing_years) |>
  arrange(year)

# make current catch data set
wa_rec_1990_to_2024_may <- wa_rec_recfin_1990_2024_may |>
  group_by(Year) |>
  summarise(catch = sum(Numbers.of.Fish) / 1000) |>
  rename(year = Year)

# Fix 2002, 2003, and 2004 data according to Fabio and Thereasa 
# The problem is that Thereasa has 
t_data <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "Theresa_2017_YEYE.csv"))
cte001 <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "CTE001-Washington-1990---2024_Final_Data.csv"))
cte001 <- cte001 |> mutate(across(13:16, as.numeric)) 

# take raw CTE001 data file and summarize retained, released, and total mortality by Year
cte001_summarized <- cte001 |> group_by(RecFIN.Year) |> summarise(summed_retained = sum(Retained....fish.), summed_released_alive = sum(Released.Alive....fish.), summed_released_dead = sum(Released.Dead....fish.), total_mort = sum(Total.Mortality....fish.))

# Now we need to calculate the proportion of dead released fish if the total released (alive and dead) for 2002, 2003, and 2004 = 1356, 846, and 1641 fish
# we do this by taking the average proportion of dead released fish for the following 5 years
# Total Mortality ≈ Retained + (Released × mortality rate)

cte001_summarized_proportion <- cte001_summarized |> 
  filter(RecFIN.Year >= 2005) |> 
  mutate(total_released = summed_released_alive + summed_released_dead) |>
  mutate(mortality_rate = (total_mort - summed_retained) / total_released)

mort_rate <- cte001_summarized_proportion |> filter(RecFIN.Year <= 2009) 
mortality_rate <- mean(mort_rate$mortality_rate)

# Now to get the Total Mortality for 2002-2004
# Total Mortality ≈ Total Retained + (Total Released × mortality rate)

d <- tibble(year = c(2002,2003,2004),
            total_retained = c(55,136,80),
            total_released = c(1356,846,1641))
d <- d |> 
  mutate(total_mortality = total_retained + (total_released*mortality_rate)) |>
  mutate(catch = total_mortality / 1000) |>
  select(-c(2:4))

# Now that we have total mortality for 2002-4, take the old dataframe, get rid of those years, and add it the new calculated years
wa_rec_1990_to_2024_may_test <- wa_rec_1990_to_2024_may |>
  filter(year < 2002 | year > 2004)

wa_rec_1990_to_2024_may <- bind_rows(wa_rec_1990_to_2024_may_test,d) |>
  arrange(year)

# Put both data sets together
WA_REC <- bind_rows(wa_rec_hist_to_1989_may,wa_rec_1990_to_2024_may) |>
  mutate(
    seas = 1,
    fleet = 7,
    catch_se = 0.01
  )|>
  select(year, seas, fleet, catch, catch_se) |>
  mutate(catch = round(catch, 3)) |>
  arrange(year)

##### Wohoo!! now plot the comparison to 2017 to make sure we have filled in all the gaps

input_files <- r4ss::SS_read(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe"))
wa_rec_old_all <- input_files$dat$catch |>
  filter(fleet == 7) |>
  filter(year > 0 ) |>
  select(year, catch)
wa_rec_old <- wa_rec_old_all |>
  mutate(type = "previous assessment") |>
  select(year, catch, type)

wa_rec_new <- WA_REC |>
  mutate(type = "May RecFin Data") |>
  select(year, catch, type)

wa_rec_comparison <- rbind(wa_rec_new, wa_rec_old)

hist_wa_rec_catch_comps <- ggplot(wa_rec_comparison, aes(x = year, y = catch, fill = type)) +
  geom_bar(stat = "identity" , alpha = .8, position = "dodge") +
  scale_x_continuous(n.breaks = 10) +
  xlab("Years") +
  ylab("Catch (in numbers/1000)") +
  labs(
    title = "WA Recreational Catch Comparison",
  )
hist_wa_rec_catch_comps
ggsave(plot = hist_wa_rec_catch_comps, "wa_rec_catch_comparison_WDFW_data.png", width = 11, height = 6, path = file.path(getwd(), "Rcode", "removals"))
