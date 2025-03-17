# IPHC length comps and CAAL data

library(dplyr)
library(tidyr)
library(ggplot2)
library(r4ss)

iphc_bio_new <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "IPHCFISS_YEYE_Biodata_2025-03-12.csv"))

#for ages until I can get the age data
iphc_bio_old <- read.csv(file.path(getwd(), "Data", "raw", "nonconfidential", "iphc_biodata.csv"))

# join the old and new ones to have the STLKEY for the ages
# Will not be necessary when we get the updated age data
iphc_bio <- iphc_bio_new |>
  dplyr::select(sample_year, BDS.sample.code, BDS.fish.number, weight_gm, YearTag, fish_length_cm, STLKEY) |>
  dplyr::mutate(tag_number = stringr::str_sub(YearTag, 5, stringr::str_length(YearTag))) |>
  inner_join(iphc_bio_old, by = c("sample_year", "BDS.sample.code" = "sample_code", "BDS.fish.number" = "fish_number", "weight_gm")) |>
  select(-tag_number.y, -fish_length_cm.y) |>
  rename(fish_length_cm = fish_length_cm.x)

# Nsamp method is the Stewart Hammel method where 
# Nsamp = n_trips + 0.0707 * n_fish when n_fish/n_tows < 55 and
# Nsamp = 4.89 * n_trips when n_fish/n_tows >= 55
N_samp <- iphc_bio |>
  group_by(sample_year, STLKEY) |>
  summarize(n_fish_stlkey = n()) |>
  ungroup() |>
  group_by(sample_year) |>
  summarize(n_trips = n(),
            n_fish = sum(n_fish_stlkey),
            n_fish_per_trip = n_fish/n_trips,
            Nsamp = ifelse(n_fish_per_trip < 55, (n_trips + 0.0707 * n_fish_per_trip), 4.89*n_trips)) |>
  ungroup() |>
  rename(year = sample_year) |>
  select(year, Nsamp)


##### Length Comps #####
# method used for assigning bins in nwfscSurvey package
l_bins <- c(10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 62, 64, 66, 68, 70, 72, 74)
l_bins_inf <- c(l_bins, Inf)
iphc_bio$l_bin <- as.numeric(l_bins_inf[findInterval(iphc_bio[, "fish_length_cm"],l_bins_inf, all.inside = T)])

# get length comps by year and bin
length_comps <- iphc_bio |>
  filter(case_when(sample_year <= 2016 ~ !is.na(best_age), TRUE ~ TRUE)) |>
  # dplyr::filter(!is.na(best_age)) |>
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
    part = 0
  ) |>
  dplyr::rename(year = sample_year) |>
  inner_join(N_samp, by = "year") |>
  dplyr::select(year, month, fleet, sex, part, Nsamp, everything())

column_names <- length_comps |>
  ungroup() |>
  dplyr::select(-year, -month, -fleet, -sex, -part, -Nsamp) |>
  colnames() |>
  as.numeric()

# add zeros for lengths that are missing
need_to_add <- l_bins[!(l_bins %in% column_names)]

to_add <- data.frame(matrix(0, nrow = length(length_comps$year), ncol = length(need_to_add)))
colnames(to_add) <- need_to_add

length_comps_all <- cbind(length_comps, to_add)
length_comps <- length_comps_all |>
  dplyr::select(year, month, fleet, sex, part, Nsamp, stringr::str_sort(colnames(length_comps_all_all), decreasing = FALSE, numeric = TRUE))

write.csv(length_comps, file.path(getwd(), "Data", "processed", "IPHC_bio_data", "iphc_length_comps.csv"), row.names = FALSE)


##### CAAL #####
a_bins <- 0:65
a_bins_inf <- c(-999, a_bins, Inf)
iphc_bio$a_bin <- a_bins_inf[findInterval(iphc_bio$best_age, a_bins_inf, all.inside = T)]

early_age_values <- as.character(0:(min(iphc_bio$a_bin, na.rm = TRUE) - 1))

caal <- iphc_bio |>
  dplyr::filter(sample_year <= 2016) |> # will remove when we get updated age data
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

caal <- caal |>
  select(year, month, fleet, sex, part, ageerr, Lbin_lo, Lbin_hi, Nsamp) |>
  mutate(!!!setNames(rep(0, length(early_age_values)), early_age_values)) |>
  left_join(caal, by = c("year", "month", "fleet", "sex", "part", "ageerr", "Lbin_lo", "Lbin_hi", "Nsamp"))

write.csv(caal, file.path(getwd(), "Data", "processed", "IPHC_bio_data", "iphc_caal.csv"), row.names = FALSE)

### MAAL ###
maal <- iphc_bio |>
  dplyr::filter(sample_year <= 2016) |> # will remove when we get updated age data
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
    Lbin_hi = -1
  ) |>
  dplyr::rename(year = sample_year) |>
  inner_join(N_samp, by = "year") |>
  dplyr::select(year, month, fleet, sex, part, ageerr, Lbin_lo, Lbin_hi, Nsamp, everything()) 

column_names <- maal |>
  ungroup() |>
  dplyr::select(-year, -month, -fleet, -sex, -part, -ageerr, -Lbin_lo, -Lbin_hi, -Nsamp) |>
  colnames() |>
  as.numeric()

need_to_add <- a_bins[!(a_bins %in% column_names)]

to_add <- data.frame(matrix(0, nrow = length(maal$year), ncol = length(need_to_add)))
colnames(to_add) <- as.numeric(need_to_add)

maal_all <- cbind(maal, to_add)
maal <- maal_all |>
  dplyr::select(year, month, fleet, sex, part, ageerr, Lbin_lo, Lbin_hi, Nsamp, stringr::str_sort(colnames(maal_all), decreasing = FALSE, numeric = TRUE))

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


### IPHC ages
iphc_ages_new <- read.csv(file.path(getwd(), "Data", "processed", "IPHC_bio_data", "iphc_marginal_ages.csv")) |>
  mutate(assessment = "Current") |>
  dplyr::select(year, assessment, Nsamp, `X0`:`X65`) |>
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
  dplyr::select(year, assessment, Nsamp, `a1`:`a65`) |>
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
