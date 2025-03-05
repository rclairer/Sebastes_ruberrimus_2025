library(r4ss)
library(dplyr)
library(ggplot2)
library(zoo)

<<<<<<< HEAD
wa_rec_hist_recfin <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "WA_rec_historical_catch_CTE503-1967---2002.csv"))
wa_rec_hist_recfin_1990 <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "CTE001-Washington-1990---2024.csv"))

wa_rec_hist <- wa_rec_hist_recfin |>
=======
wa_rec_hist_pacfin <- read.csv(file.path(getwd(), "Data", "WA_rec_historical_catch_CTE503-1967---2002.csv"))

wa_rec_hist <- wa_rec_hist_pacfin |>
>>>>>>> 881bd12 (Add comp plots and model forecast update (#39))
    filter(AREA < 5) |>
    filter(RECFIN_YEAR >= 1975) |>
    group_by(RECFIN_YEAR) |>
    summarise(catch = sum(RETAINED_NUM) / 1000) |>
    rename(year = RECFIN_YEAR)

<<<<<<< HEAD
wa_rec_hist_1990 <- wa_rec_hist_recfin_1990 |>
    group_by(RECFIN_YEAR) |>
    summarise(catch = sum(SUM_TOTAL_MORTALITY_NUM) / 1000) |>
    rename(year = RECFIN_YEAR)

wa_rec_hist_all <- rbind(wa_rec_hist, wa_rec_hist_1990)

=======
>>>>>>> 881bd12 (Add comp plots and model forecast update (#39))
input_files <- r4ss::SS_read(file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe"))

wa_rec_catch <- input_files$dat$catch |>
    filter(fleet == 7) |>
    filter(year >= 0) |>
    filter(year <= 2002) |>
    mutate(type = "previous assessment") |>
    select(year, catch, type)

<<<<<<< HEAD
### Redo
years_to_interpolate <- wa_rec_catch |>
    dplyr::filter(!year %in% wa_rec_hist_all$year) |>
=======
years_to_interpolate <- wa_rec_catch |>
    dplyr::filter(!year %in% wa_rec_hist$year) |>
>>>>>>> 881bd12 (Add comp plots and model forecast update (#39))
    dplyr::filter(year > 0) |>
    select(year) |>
    mutate(catch = NA)

<<<<<<< HEAD
all_years <- rbind(wa_rec_hist_all, years_to_interpolate) |>
    arrange(year) |>
    mutate(catch = na.approx(catch)) |>
    mutate(type = "current assessment")

write.csv(all_years, file.path(getwd(), "Data", "Processed", "WA_historical_to_recent_rec_catch.csv"))
=======
model <- lm(wa_rec_hist$catch ~ wa_rec_hist$year)

all_years <- rbind(wa_rec_hist, years_to_interpolate) |>
    arrange(year) |>
    mutate(catch = case_when(
        is.na(catch) ~ year * model$coefficients[2] + model$coefficients[1],
        !is.na(catch) ~ catch
    )) |>
    mutate(type = "current assessment")

write.csv(all_years, file.path(getwd(), "Data", "Processed", "WA_historical_rec_catch.csv"))
>>>>>>> 881bd12 (Add comp plots and model forecast update (#39))

# Comparison plot
both_assessments <- rbind(wa_rec_catch, all_years)

hist_wa_rec_catch_comps <- ggplot(all_years, aes(year, catch)) +
    geom_bar(stat = "identity", fill = "#5a8ccd", alpha = .8) +
    geom_point(wa_rec_catch, mapping = aes(x = year, y = catch), size = 5, color = "#595d63") +
    scale_x_continuous(n.breaks = 10) +
    xlab("Years") +
    ylab("Catch (in numbers/1000)") +
    labs(
        title = "WA Historical Recreational Catch Comparison",
        subtitle = "(bars are current data and points are from the 2017 assessment)"
    )

<<<<<<< HEAD
ggsave(plot = hist_wa_rec_catch_comps, "hist_to_recent_wa_catch_comparison.png", path = file.path(getwd(), "Rcode", "removals"))
=======
ggsave(plot = hist_wa_rec_catch_comps, "hist_wa_rec_catch_comparison.png", path = file.path(getwd(), "Rcode", "removals"))
>>>>>>> 881bd12 (Add comp plots and model forecast update (#39))
