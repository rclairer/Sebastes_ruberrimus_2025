rm(list=ls())
library(dplyr)
library(tidyr)
library(ggplot2)
#remotes::install_github("r4ss/r4ss")
library(r4ss)
library(readr)
library(nwfscSurvey)
library(here)
#remotes::install_github("pfmc-assessments/pacfintools")
library(pacfintools)
exe_loc <- here::here('model/ss3.exe')

#all catch
inputs <- SS_read(dir = file.path(getwd(), "model", "updated_alldata_tunecomps_fitbias_ctl_tunecomps_start_20250512"))

#catch <- inputs$dat$catch

#ONLY NEED TO ADD THESE COMMERCIAL DISCARDS

################################################
#discards in 2024 by fleet

#CA_TWL FLEET 1

#CA_NONTWL FLEET 2

#ORWA_TWL FLEET 4

#ORWA_NONTWL FLEET 5

# read in commercial discards
discards <- read.csv(file.path(getwd(),"Data","processed","discards","commercial_discards.csv")) |> 
  # remove column of row names from previous save
  dplyr::select(-X)

# Combine OR and WA discards for fleet
discards_ORWA <- discards |>
  dplyr::filter(grepl("OR|WA", fleet)) |>
  tidyr::separate_wider_delim(fleet, delim = "-", names = c("fleet", "state")) |>
  dplyr::group_by(year, fleet) |>
  dplyr::summarise(discards = sum(total_discards)) |>
  dplyr::ungroup() |>
  dplyr::mutate(state = "ORWA")

# Combine CA and ORWA discards into final discards df
discards_all <- discards |>
  dplyr::filter(grepl("CA", fleet)) |>
  tidyr::separate_wider_delim(fleet, delim = "-", names = c("fleet", "state")) |>
  dplyr::rename(discards = total_discards) |>
  rbind(discards_ORWA) |>
  dplyr::mutate(ST_FLEET = glue::glue("{state}_{fleet}")) |>
  dplyr::select(-c(fleet, state)) |>
  dplyr::filter(year > 2015)

discards_all_ave_2021to2023 <- discards_all %>%
  filter(year %in% c(2021, 2022, 2023)) %>%
  group_by(ST_FLEET) %>%
  summarise(avg_discards = mean(discards, na.rm = TRUE, .groups = "drop"))
  
##############################################

inputs$dat$catch <- inputs$dat$catch %>%
  mutate(catch = if_else(fleet == 1 & year == 2024, catch + discards_all_ave_2021to2023$avg_discards[discards_all_ave_2021to2023$ST_FLEET == "CA_TWL"], catch)) %>%
  mutate(catch = if_else(fleet == 2 & year == 2024, catch + discards_all_ave_2021to2023$avg_discards[discards_all_ave_2021to2023$ST_FLEET == "CA_NONTWL"], catch)) %>%
  mutate(catch = if_else(fleet == 4 & year == 2024, catch + discards_all_ave_2021to2023$avg_discards[discards_all_ave_2021to2023$ST_FLEET == "ORWA_TWL"], catch)) %>%
  mutate(catch = if_else(fleet == 5 & year == 2024, catch + discards_all_ave_2021to2023$avg_discards[discards_all_ave_2021to2023$ST_FLEET == "ORWA_NONTWL"], catch))
  

catch <- inputs$dat$catch
