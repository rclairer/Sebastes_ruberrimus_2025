# IPHC length comps and CAAL data

library(dplyr)
library(tidyr)

iphc_bio <- read.csv(file.path(getwd(), "Data", "processed", "iphc_biodata.csv"))

##### Length Comps #####
# method used for assigning bins in nwfscSurvey package
l_bins <- c(10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 62, 64, 66, 68, 70, 72, 74)
bins <- c(l_bins, Inf)
iphc_bio$l_bin <- as.numeric(bins[findInterval(iphc_bio[, "fish_length_cm"], bins, all.inside = T)])

# get length comps by year and bin
length_comps <- iphc_bio |>
  dplyr::filter(!is.na(l_bin)) |>
  dplyr::group_by(sample_year, l_bin) |>
  dplyr::summarize(n = n()) |>
  dplyr::arrange(l_bin) |>
  tidyr::pivot_wider(names_from = "l_bin", values_from = "n", values_fill = 0) |>
  dplyr::arrange(sample_year)

write.csv(length_comps, file.path(getwd(), "Data", "processed", "iphc_length_comps.csv"), row.names = FALSE)

# get just those until 2016 so it can be compared to the spreadsheet Jason sent me
test_against_2017 <- length_comps |>
  dplyr::filter(sample_year < 2017) |>
  dplyr::mutate(
    sample_year = sample_year,
    sum = rowSums(across(where(is.numeric)))
  )

View(test_against_2017)


##### CAAL #####
a_bin <- c(-999, 10:65, Inf)
iphc_bio$a_bin <- a_bin[findInterval(iphc_bio$best_age, a_bin, all.inside = T)]

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
    Nsamp = rowSums(across(`-999`:`65`))
  ) |>
  dplyr::select(sample_year, month, fleet, sex, part, ageerr, Lbin_lo, Lbin_hi, Nsamp, everything())

write.csv(caal, file.path(getwd(), "Data", "processed", "iphc_caal.csv"), row.names = FALSE)
