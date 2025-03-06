# IPHC length comps and CAAL data

library(dplyr)
library(tidyr)
library(ggplot2)
library(r4ss)

iphc_bio <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "iphc_biodata.csv"))

##### Length Comps #####
# method used for assigning bins in nwfscSurvey package
l_bins <- c(10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 62, 64, 66, 68, 70, 72, 74)
bins <- c(l_bins, Inf)
iphc_bio$l_bin <- as.numeric(bins[findInterval(iphc_bio[, "fish_length_cm"], bins, all.inside = T)])

# get length comps by year and bin
# unable to provide nsamps yet until Fabio gets the stlkey

# Previous method was just the following
# length_comps <- iphc_bio |>
#   dplyr::filter(!is.na(l_bin)) |>
#   dplyr::group_by(sample_year, l_bin) |>
#   dplyr::summarize(n = n()) |>
#   dplyr::arrange(l_bin) |>
#   tidyr::pivot_wider(names_from = "l_bin", values_from = "n", values_fill = 0) |>
#   dplyr::arrange(sample_year) |>
#   dplyr::mutate(
#     month = 7,
#     fleet = 12,
#     sex = 0,
#     part = 0,
#     Nsamp = NA
#   ) |>
#   dplyr::select(sample_year, month, fleet, sex, part, Nsamp, everything()) |>
#   dplyr::rename(year = sample_year)

length_comps <- iphc_bio |>
  dplyr::filter(!is.na(best_age)) |>
  dplyr::filter(!is.na(l_bin)) |>
  dplyr::group_by(sample_year, l_bin) |>
  dplyr::summarize(n = n()) |>
  dplyr::arrange(l_bin) |>
  tidyr::pivot_wider(names_from = "l_bin", values_from = "n", values_fill = 0) |>
  dplyr::arrange(sample_year) |>
  dplyr::mutate(
    month = 7,
    fleet = 12,
    sex = 0,
    part = 0,
    Nsamp = NA
  ) |>
  dplyr::select(sample_year, month, fleet, sex, part, Nsamp, everything()) |>
  dplyr::rename(year = sample_year)

column_names <- length_comps |>
  ungroup() |>
  dplyr::select(-year, -month, -fleet, -sex, -part, -Nsamp) |>
  colnames() |>
  as.numeric()

need_to_add <- l_bins[!(l_bins %in% column_names)]

to_add <- data.frame(matrix(0, nrow = length(length_comps$year), ncol = length(need_to_add)))
colnames(to_add) <- need_to_add

length_comps_all <- cbind(length_comps, to_add)
length_comps <- length_comps_all[order(names(length_comps_all), as.numeric(names(length_comps_all)))] |>
  dplyr::select(year, month, fleet, sex, part, Nsamp, everything())

write.csv(length_comps, file.path(getwd(), "Data", "processed", "IPHC_bio_data", "iphc_length_comps.csv"), row.names = FALSE)


##### CAAL #####
age_bins <- 0:65
a_bin <- c(-999, age_bins, Inf)
iphc_bio$a_bin <- a_bin[findInterval(iphc_bio$best_age, a_bin, all.inside = T)]

unique(!is.na(iphc_bio$best_age))

caal <- iphc_bio |>
  dplyr::filter(!is.na(l_bin)) |>
  dplyr::filter(!is.na(a_bin)) |>
  dplyr::group_by(sample_year, l_bin, a_bin) |>
  dplyr::summarise(n = n()) |>
  dplyr::arrange(a_bin) |>
  tidyr::pivot_wider(names_from = "a_bin", values_from = "n", values_fill = 0) |>
  dplyr::arrange(sample_year, l_bin) |>
  dplyr::mutate(
    month = 7,
    fleet = 12,
    sex = 0,
    part = 0,
    ageerr = 1,
    Lbin_lo = l_bin,
    Lbin_hi = l_bin,
    Nsamp = rowSums(across(`9`:`65`))
  ) |>
  dplyr::ungroup() |>
  dplyr::select(-l_bin) |>
  dplyr::select(sample_year, month, fleet, sex, part, ageerr, Lbin_lo, Lbin_hi, Nsamp, everything()) |>
  dplyr::rename(year = sample_year)

write.csv(caal, file.path(getwd(), "Data", "processed", "IPHC_bio_data", "iphc_caal.csv"), row.names = FALSE)

# Need to get stlkey column from Fabio to do nsamps
#### Figure out how to add rows for each year for ages 0-8
#### Figure out how to add rows for each year for ages 0-8
maal <- iphc_bio |>
  dplyr::filter(!is.na(a_bin)) |>
  dplyr::group_by(sample_year, a_bin) |>
  dplyr::summarise(n = n()) |>
  dplyr::arrange(a_bin) |>
  dplyr::filter(a_bin > 0) |>
  tidyr::pivot_wider(names_from = "a_bin", values_from = "n", values_fill = 0) |>
  dplyr::arrange(sample_year) |>
  dplyr::mutate(
    month = 7,
    fleet = -12,
    sex = 0,
    part = 0,
    ageerr = 1,
    Lbin_lo = -1,
    Lbin_hi = -1,
    Nsamp = NA,
  ) |>
  dplyr::select(sample_year, month, fleet, sex, part, ageerr, Lbin_lo, Lbin_hi, Nsamp, everything()) |>
  dplyr::rename(year = sample_year)

write.csv(maal, file.path(getwd(), "Data", "processed", "IPHC_bio_data", "iphc_marginal_ages.csv"), row.names = FALSE)

# Comparison plots
# IPHC lengths
# Read new data
iphc_lengths_new <- read.csv(file.path(getwd(), "Data", "processed", "IPHC_bio_data", "iphc_length_comps.csv")) |>
  mutate(assessment = "Current") |>
  dplyr::select(year, assessment, Nsamp, `X10`:`X74`) |>
  tidyr::pivot_longer(cols = c(-year, -assessment, -Nsamp), names_to = "length", values_to = "freq") |>
  dplyr::mutate(length = gsub("X", "", length)) |>
  dplyr::group_by(year) |>
  dplyr::mutate(
    freq = freq / sum(freq),
    # NsampsFreq = freq/unique(Nsamps), still waiting on these
    length = as.numeric(length)
  )

# Read old data
inputs_old <- r4ss::SS_read(dir = file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe"))

iphc_lengths_old <- inputs_old$dat$lencomp |>
  dplyr::filter(fleet == 12) |>
  mutate(assessment = "Previous") |>
  dplyr::select(year, assessment, Nsamp, `l10`:`l74`) |>
  tidyr::pivot_longer(cols = c(-year, -assessment, -Nsamp), names_to = "length", values_to = "freq") |>
  dplyr::mutate(length = gsub("^l", "", length)) |>
  dplyr::group_by(year) |>
  dplyr::mutate(
    freq = freq / sum(freq),
    # NsampsFreq = freq/unique(Nsamps), still waiting on these
    length = as.numeric(length)
  )

together <- rbind(iphc_lengths_old, iphc_lengths_new)
comparison_plot <- together |>
  dplyr::filter(freq > 0) |>
  ggplot2::ggplot(aes(x = year, y = length, col = assessment, size = freq)) +
  ggplot2::geom_point(position = position_dodge(0.5))
ggsave(plot = comparison_plot, "iphc_length_comp_comparisons.png", path = file.path(getwd(), "Rcode", "survey_length_age", "IPHC"))


# Previous method used to do comparison plots
# iphc_lengths <- read.csv(file.path(getwd(), "Rcode", "survey_length_age", "IPHC", "iphc_comparison_lengths.csv"))
#
# long_iphc_lengths <- iphc_lengths |>
#   dplyr::mutate(type = dplyr::case_when(
#     Fleet == 12 ~ "previous assessment",
#     Fleet == 13 ~ "current assessment"
#   )) |>
#   dplyr::select(Year, type, Nsamps, `X10`:`X74`) |>
#   tidyr::pivot_longer(cols = c(-Year, -type, -Nsamps), names_to = "length", values_to = "freq") |>
#   dplyr::mutate(length = gsub("X", "", length))
#
# old_comps <- long_iphc_lengths |>
#   dplyr::filter(type == "previous assessment") |>
#   dplyr::group_by(Year) |>
#   dplyr::mutate(
#     freq = freq / sum(freq),
#     # NsampsFreq = freq/unique(Nsamps), still waiting on these
#     length = as.numeric(length)
#   )
# new_comps <- long_nwfsc_lengths |>
#   dplyr::filter(type == "current assessment") |>
#   dplyr::group_by(Year) |>
#   dplyr::mutate(
#     freq = freq / sum(freq),
#     # NsampsFreq = freq/unique(Nsamps), still waiting on these
#     length = as.numeric(length)
#   )
#
# together <- rbind(old_comps, new_comps)
# comparison_plot <- together |>
#   dplyr::filter(freq > 0) |>
#   ggplot2::ggplot(aes(x = Year, y = length, col = type, size = freq)) +
#   ggplot2::geom_point(position = position_dodge(0.5))
# ggsave(plot = comparison_plot, "iphc_length_comp_comparisons.png", path = file.path(getwd(), "Rcode", "survey_length_age", "IPHC"))

### IPHC ages
iphc_ages_new <- read.csv(file.path(getwd(), "Data", "processed", "IPHC_bio_data", "iphc_marginal_ages.csv")) |>
  mutate(assessment = "Current") |>
  dplyr::select(year, assessment, Nsamp, `X9`:`X65`) |>
  tidyr::pivot_longer(cols = c(-year, -assessment, -Nsamp), names_to = "age", values_to = "freq") |>
  dplyr::mutate(age = gsub("X", "", age)) |>
  dplyr::group_by(year) |>
  dplyr::mutate(
    freq = freq / sum(freq),
    # NsampsFreq = freq/unique(Nsamps), still waiting on these
    # NsampsFreq = freq/unique(Nsamps), still waiting on these
    age = as.numeric(age)
  )

iphc_ages_old <- inputs_old$dat$agecomp |>
  dplyr::filter(fleet == -12) |>
  mutate(assessment = "Previous") |>
  dplyr::select(year, assessment, Nsamp, `a1`:`l65`) |>
  tidyr::pivot_longer(cols = c(-year, -assessment, -Nsamp), names_to = "age", values_to = "freq") |>
  dplyr::mutate(age = gsub("^a", "", age)) |>
  dplyr::group_by(year) |>
  dplyr::mutate(
    freq = freq / sum(freq),
    # NsampsFreq = freq/unique(Nsamps), still waiting on these
    age = as.numeric(age)
  )

together <- rbind(iphc_ages_old, iphc_ages_new)
comparison_plot <- together |>
  dplyr::filter(freq > 0) |>
  ggplot2::ggplot(aes(x = year, y = age, col = assessment, size = freq)) +
  ggplot2::geom_point(position = position_dodge(0.5))
ggsave(plot = comparison_plot, "iphc_age_comp_comparisons.png", path = file.path(getwd(), "Rcode", "survey_length_age", "IPHC"))
