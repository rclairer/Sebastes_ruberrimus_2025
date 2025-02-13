# IPHC length comps and CAAL data

library(dplyr)
library(tidyr)
library(ggplot2)

iphc_bio <- read.csv(file.path(getwd(), "Data", "processed", "IPHC_bio_data", "iphc_biodata.csv"))

##### Length Comps #####
# method used for assigning bins in nwfscSurvey package
l_bins <- c(10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 62, 64, 66, 68, 70, 72, 74)
bins <- c(l_bins, Inf)
iphc_bio$l_bin <- as.numeric(bins[findInterval(iphc_bio[, "fish_length_cm"], bins, all.inside = T)])

# get length comps by year and bin
# unable to provide nsamps yet until Fabio gets the stlkey
length_comps <- iphc_bio |>
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
iphc_lengths <- read.csv(file.path(getwd(), "Rcode", "survey_length_age", "IPHC", "iphc_comparison_lengths.csv"))

long_iphc_lengths <- iphc_lengths |>
  dplyr::mutate(type = dplyr::case_when(
    Fleet == 12 ~ "previous assessment",
    Fleet == 13 ~ "current assessment"
  )) |>
  dplyr::select(Year, type, Nsamps, `X10`:`X74`) |>
  tidyr::pivot_longer(cols = c(-Year, -type, -Nsamps), names_to = "length", values_to = "freq") |>
  dplyr::mutate(length = gsub("X", "", length))

old_comps <- long_iphc_lengths |>
  dplyr::filter(type == "previous assessment") |>
  dplyr::group_by(Year) |>
  dplyr::mutate(
    freq = freq / sum(freq),
    # NsampsFreq = freq/unique(Nsamps), still waiting on these
    length = as.numeric(length)
  )
new_comps <- long_nwfsc_lengths |>
  dplyr::filter(type == "current assessment") |>
  dplyr::group_by(Year) |>
  dplyr::mutate(
    freq = freq / sum(freq),
    # NsampsFreq = freq/unique(Nsamps), still waiting on these
    length = as.numeric(length)
  )

together <- rbind(old_comps, new_comps)
comparison_plot <- together |>
  dplyr::filter(freq > 0) |>
  ggplot2::ggplot(aes(x = Year, y = length, col = type, size = freq)) +
  ggplot2::geom_point(position = position_dodge(0.5))
ggsave(plot = comparison_plot, "iphc_length_comp_comparisons.png", path = file.path(getwd(), "Rcode", "survey_length_age", "IPHC"))

### IPHC ages
iphc_ages <- read.csv(file.path(getwd(), "Rcode", "survey_length_age", "IPHC", "iphc_comparison_ages.csv"))

long_iphc_ages <- iphc_ages |>
  dplyr::mutate(
    type = dplyr::case_when(
      Fleet == 12 ~ "previous assessment",
      Fleet == -12 ~ "previous assessment",
      Fleet == 13 ~ "current assessment",
      Fleet == -13 ~ "current assessment"
    ),
    age_type = dplyr::case_when(
      Fleet == 12 ~ "caal",
      Fleet == -12 ~ "maal",
      Fleet == 13 ~ "caal",
      Fleet == -13 ~ "maal"
    )
  ) |>
  dplyr::select(Year, type, age_type, `X0`:`X65`) |>
  tidyr::pivot_longer(cols = c(-Year, -type, -age_type), names_to = "age", values_to = "freq") |>
  dplyr::mutate(age = gsub("X", "", age))


old_comps <- long_iphc_ages |>
  dplyr::filter(type == "previous assessment") |>
  dplyr::filter(age_type == "maal") |>
  dplyr::group_by(Year) |>
  dplyr::mutate(
    freq = freq / sum(freq),
    age = as.numeric(age)
  )
new_comps <- long_iphc_ages |>
  dplyr::filter(type == "current assessment") |>
  dplyr::filter(age_type == "maal") |>
  dplyr::group_by(Year) |>
  dplyr::mutate(
    freq = freq / sum(freq),
    age = as.numeric(age)
  )

together <- rbind(old_comps, new_comps)
comparison_plot <- together |>
  dplyr::filter(freq > 0) |>
  ggplot2::ggplot(aes(x = Year, y = age, col = type, size = freq)) +
  ggplot2::geom_point(position = position_dodge(0.5))
ggsave(plot = comparison_plot, "iphc_age_comp_comparisons.png", path = file.path(getwd(), "Rcode", "survey_length_age", "IPHC"))
