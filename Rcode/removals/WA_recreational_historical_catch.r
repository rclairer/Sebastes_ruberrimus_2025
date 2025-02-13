library(r4ss)
library(dplyr)
library(ggplot2)
library(zoo)

wa_rec_hist_pacfin <- read.csv(file.path(getwd(), "Data", "WA_rec_historical_catch_CTE503-1967---2002.csv"))

wa_rec_hist <- wa_rec_hist_pacfin |>
    filter(AREA < 5) |>
    filter(RECFIN_YEAR >= 1975) |>
    group_by(RECFIN_YEAR) |>
    summarise(catch = sum(RETAINED_NUM) / 1000) |>
    rename(year = RECFIN_YEAR)


input_files <- r4ss::SS_read(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe"))
wa_rec_catch <- input_files$dat$catch |>
    filter(fleet == 7) |>
    filter(year >= 0) |>
    filter(year <= 2002)

years_to_interpolate <- wa_rec_catch |>
    dplyr::filter(!year %in% wa_rec_hist$year) |>
    dplyr::filter(year > 0) |>
    select(year)
df <- data.frame(
    year = years_to_interpolate,
    catch = rep(NA, length(years_to_interpolate))
)
