library(r4ss)
library(ggplot2)
library(tidyverse)
library(nwfscSurvey)
library(dplyr)


df <- read.csv('~/Git/Sebastes_ruberrimus_2025/Data/raw/confidential/recfin_WDFW_length_age.csv')

wa_ages <- get_raw_comps(
  data = df,
  comp_bins = seq(0, 65, 1),
  comp_column_name = "age",
  input_n_method = "stewart_hamel",
  two_sex_comps = FALSE,
  month = 7,
  fleet = 7,
  partition = 0,
  dir = NULL,
  printfolder = "",
  verbose = TRUE
)

wa_ages <- data.frame(wa_ages)
colnames(wa_ages) <- gsub("^unsexed\\.", "", colnames(wa_ages))
colnames(wa_ages) <- gsub("^U", "A", colnames(wa_ages))

write.csv(wa_ages, file.path(getwd(), "Data", "processed", "recfin_bio_data", "recfin_wa_ages.csv"))

# Comparison plots
# WA ages
# Read new data
wa_ages_new <- read.csv(file.path(getwd(), "Data", "processed", "recfin_bio_data", "recfin_wa_ages.csv")) |>
  mutate(assessment = "Current") |>
  dplyr::select(year, assessment, A0:A65) |>
  tidyr::pivot_longer(cols = c(-year, -assessment), names_to = "age", values_to = "freq") |>
  dplyr::mutate(age = gsub("A", "", age)) |>
  dplyr::group_by(year) |>
  dplyr::mutate(
    freq = freq / sum(freq),
    age = as.numeric(age),
  )

# Read old data
inputs_old <- r4ss::SS_read(dir = file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe"))
wa_ages_old <- inputs_old$dat$agecomp |>
  dplyr::filter(fleet == 7) |>
  mutate(assessment = "Previous") |>
  dplyr::select(year, assessment, Nsamp, `a0`:`a65`) |>
  tidyr::pivot_longer(cols = c(-year, -assessment, -Nsamp), names_to = "age", values_to = "freq") |>
  dplyr::mutate(age = gsub("^a", "", age)) |>
  dplyr::group_by(year) |>
  dplyr::mutate(
    freq = freq / sum(freq),
    age = as.numeric(age)
  )

together <- rbind(wa_ages_old, wa_ages_new)
comparison_plot_wa_age <- together |>
  dplyr::filter(freq > 0) |>
  ggplot2::ggplot(aes(x = year, y = age, col = assessment, size = freq)) +
  ggplot2::geom_point(position = position_dodge(0.5))
ggsave(plot = comparison_plot_wa_age, "recfin_wa_age_comp_comparisons.png", path = file.path(getwd(), "Rcode", "length_age_comps", "recfin"))

