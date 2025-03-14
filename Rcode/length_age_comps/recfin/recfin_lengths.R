library(r4ss)
library(ggplot2)
library(tidyverse)
library(nwfscSurvey)
library(dplyr)


df <- read.csv('~/Git/Sebastes_ruberrimus_2025/Data/raw/confidential/recfin_states_length.csv')


ca_data <- df %>% filter(state == "CALIFORNIA")
or_data <- df %>% filter(state == "OREGON")
wa_data <- df %>% filter(state == "WASHINGTON")


ca_lengths <- get_raw_comps(
  data = ca_data,
  comp_bins = seq(10, 74, 2),
  comp_column_name = "length",
  input_n_method = "stewart_hamel",
  two_sex_comps = FALSE,
  month = 7,
  fleet = 3,
  partition = 0,
  dir = NULL,
  printfolder = "",
  verbose = TRUE
)

or_lengths <- get_raw_comps(
  data = or_data,
  comp_bins = seq(10, 74, 2),
  comp_column_name = "length",
  input_n_method = "stewart_hamel",
  two_sex_comps = FALSE,
  month = 7,
  fleet = 6,
  partition = 0,
  dir = NULL,
  printfolder = "",
  verbose = TRUE
)

wa_lengths <- get_raw_comps(
  data = wa_data,
  comp_bins = seq(10, 74, 2),
  comp_column_name = "length",
  input_n_method = "stewart_hamel",
  two_sex_comps = FALSE,
  month = 7,
  fleet = 7,
  partition = 0,
  dir = NULL,
  printfolder = "",
  verbose = TRUE
)

ca_lengths <- data.frame(ca_lengths)
colnames(ca_lengths) <- gsub("^unsexed\\.", "", colnames(ca_lengths))
colnames(ca_lengths) <- gsub("^U", "L", colnames(ca_lengths))

or_lengths <- data.frame(or_lengths)
colnames(or_lengths) <- gsub("^unsexed\\.", "", colnames(or_lengths))
colnames(or_lengths) <- gsub("^U", "L", colnames(or_lengths))

wa_lengths <- data.frame(wa_lengths)
colnames(wa_lengths) <- gsub("^unsexed\\.", "", colnames(wa_lengths))
colnames(wa_lengths) <- gsub("^U", "L", colnames(wa_lengths))

write.csv(ca_lengths, file.path(getwd(), "Data", "processed", "recfin_bio_data", "recfin_ca_lengths.csv"))
write.csv(or_lengths, file.path(getwd(), "Data", "processed", "recfin_bio_data",  "recfin_or_lengths.csv"))
write.csv(wa_lengths,file.path(getwd(), "Data", "processed", "recfin_bio_data",  "recfin_wa_lengths.csv"))

# Comparison plots
# CA lengths
# Read new data
ca_lengths_new <- read.csv(file.path(getwd(), "Data", "processed", "recfin_bio_data", "recfin_ca_lengths.csv")) |>
  mutate(assessment = "Current") |>
  dplyr::select(year, assessment, L10:L74) |>
  tidyr::pivot_longer(cols = c(-year, -assessment), names_to = "length", values_to = "freq") |>
  dplyr::mutate(length = gsub("L", "", length)) |>
  dplyr::group_by(year) |>
  dplyr::mutate(
    freq = freq / sum(freq),
    length = as.numeric(length),
  )


# Read old data
inputs_old <- r4ss::SS_read(dir = file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe"))
ca_lengths_old <- inputs_old$dat$lencomp |>
  dplyr::filter(fleet == 3) |>
  mutate(assessment = "Previous") |>
  dplyr::select(year, assessment, Nsamp, `l10`:`l74`) |>
  tidyr::pivot_longer(cols = c(-year, -assessment, -Nsamp), names_to = "length", values_to = "freq") |>
  dplyr::mutate(length = gsub("^l", "", length)) |>
  dplyr::group_by(year) |>
  dplyr::mutate(
    freq = freq / sum(freq),
    length = as.numeric(length)
  )

together <- rbind(ca_lengths_old, ca_lengths_new)
comparison_plot_ca <- together |>
  dplyr::filter(freq > 0) |>
  ggplot2::ggplot(aes(x = year, y = length, col = assessment, size = freq)) +
  ggplot2::geom_point(position = position_dodge(0.5))
ggsave(plot = comparison_plot_ca, "recfin_ca_length_comp_comparisons.png", path = file.path(getwd(), "Rcode", "length_age_comps", "recfin"))

# OR lengths
# Read new data
or_lengths_new <- read.csv(file.path(getwd(), "Data", "processed", "recfin_bio_data", "recfin_or_lengths.csv")) |>
  mutate(assessment = "Current") |>
  dplyr::select(year, assessment, L10:L74) |>
  tidyr::pivot_longer(cols = c(-year, -assessment), names_to = "length", values_to = "freq") |>
  dplyr::mutate(length = gsub("L", "", length)) |>
  dplyr::group_by(year) |>
  dplyr::mutate(
    freq = freq / sum(freq),
    length = as.numeric(length),
  )


# Read old data
inputs_old <- r4ss::SS_read(dir = file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe"))
or_lengths_old <- inputs_old$dat$lencomp |>
  dplyr::filter(fleet == 6) |>
  mutate(assessment = "Previous") |>
  dplyr::select(year, assessment, Nsamp, `l10`:`l74`) |>
  tidyr::pivot_longer(cols = c(-year, -assessment, -Nsamp), names_to = "length", values_to = "freq") |>
  dplyr::mutate(length = gsub("^l", "", length)) |>
  dplyr::group_by(year) |>
  dplyr::mutate(
    freq = freq / sum(freq),
    length = as.numeric(length)
  )

together <- rbind(or_lengths_old, or_lengths_new)
comparison_plot_or <- together |>
  dplyr::filter(freq > 0) |>
  ggplot2::ggplot(aes(x = year, y = length, col = assessment, size = freq)) +
  ggplot2::geom_point(position = position_dodge(0.5))
ggsave(plot = comparison_plot_or, "recfin_or_length_comp_comparisons.png", path = file.path(getwd(), "Rcode", "length_age_comps", "recfin"))


# WA lengths
# Read new data
wa_lengths_new <- read.csv(file.path(getwd(), "Data", "processed", "recfin_bio_data", "recfin_wa_lengths.csv")) |>
  mutate(assessment = "Current") |>
  dplyr::select(year, assessment, L10:L74) |>
  tidyr::pivot_longer(cols = c(-year, -assessment), names_to = "length", values_to = "freq") |>
  dplyr::mutate(length = gsub("L", "", length)) |>
  dplyr::group_by(year) |>
  dplyr::mutate(
    freq = freq / sum(freq),
    length = as.numeric(length),
  )


# Read old data
inputs_old <- r4ss::SS_read(dir = file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe"))
wa_lengths_old <- inputs_old$dat$lencomp |>
  dplyr::filter(fleet == 7) |>
  mutate(assessment = "Previous") |>
  dplyr::select(year, assessment, Nsamp, `l10`:`l74`) |>
  tidyr::pivot_longer(cols = c(-year, -assessment, -Nsamp), names_to = "length", values_to = "freq") |>
  dplyr::mutate(length = gsub("^l", "", length)) |>
  dplyr::group_by(year) |>
  dplyr::mutate(
    freq = freq / sum(freq),
    length = as.numeric(length)
  )

together <- rbind(wa_lengths_old, wa_lengths_new)
comparison_plot_wa <- together |>
  dplyr::filter(freq > 0) |>
  ggplot2::ggplot(aes(x = year, y = length, col = assessment, size = freq)) +
  ggplot2::geom_point(position = position_dodge(0.5))
ggsave(plot = comparison_plot_wa, "recfin_wa_length_comp_comparisons.png", path = file.path(getwd(), "Rcode", "length_age_comps", "recfin"))

