#### Commercial Catch Calculations ----
# Calculation of commercial landings from PacFIN data (post species filtering)
# Exported as .csv at the end
# Refer to Rcode/removals/commercial_landings.qmd for data investigation

# By: S.Schiano

#### Loading in data/data paths for script ----
# Directory for PacFIN catch file
file_catch <- fs::path(getwd(), "data", "confidential", "PacFIN.YEYE.CompFT.12.Dec.2024.RData")
# Object name = catch.pacfin
load(file_catch)

# Directory for commercial discards
comm_discards <- file.path(getwd(), "commercial_discards.csv")

# Read in recent OR state data for landings
# Using this to replace PacFIN bc data includes additional, more updated information
or <- read.csv(file.path(getwd(), "data", "Oregon Commercial landings_457_2024.csv")) |>
  dplyr::mutate(STATE = "OR",
                FLEET = dplyr::case_when(
                  FLEET == "NTRW" ~ "NONTWL",
                  FLEET == "TRW" ~ "TWL",
                  TRUE ~ NA
                ))

#### Data Analysis ----

# Indicate PacFIN gear type
pacfin_gears <- pacfintools::get_codelist() |> dplyr::select(GRID, GROUP)

# Calculate landings from catch.pacfin
# Does not use OR state data
catch <- catch.pacfin |>
  dplyr::left_join(pacfin_gears, by = c("PACFIN_GEAR_CODE" = "GRID")) |>
  dplyr::mutate(FLEET = dplyr::case_when(
    GROUP == "TWL" ~ "TWL",
    GROUP == "TWS" ~ "TWL",
    TRUE ~ "NONTWL"
  )) |>
  dplyr::group_by(LANDING_YEAR, FLEET, COUNTY_STATE) |>
  dplyr::summarise(TOTAL_CATCH = sum(LANDED_WEIGHT_MTONS)) |>
  dplyr::rename(YEAR = LANDING_YEAR,
                TOTAL = TOTAL_CATCH,
                STATE = COUNTY_STATE
  ) |>
  dplyr::ungroup() |>
  dplyr::select(YEAR, FLEET, STATE, TOTAL) |>
  dplyr::filter(!is.na(STATE)
                # filter data to above 2016 since we are only adding this into it
                # YEAR > 2015
  )

# Final Calculations
# Summarize OR state data > 2015 bc updating data from last (2017) assessment for yelloweye
or2 <- or |>
  dplyr::select(YEAR, FLEET, TOTAL, STATE) |>
  dplyr::filter(YEAR > 2015)

# remove OR data from catch
pacfin.cawa <- catch |>
  dplyr::filter(STATE != "OR")

# combine subset PacFIN catch data (WA and CA) and OR state data
catch2 <- rbind(pacfin.cawa, or2)

# read in commercial discards
discards <- read.csv(comm_discards) |> 
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

# Combine WA and OR fleets
catch_orwa <- catch2 |>
  dplyr::filter(STATE %in% c("WA", "OR")) |>
  dplyr::group_by(YEAR, FLEET) |>
  dplyr::summarise(CATCH = sum(TOTAL)) |>
  dplyr::ungroup() |>
  dplyr::mutate(STATE = "ORWA")

# Subset catch to just CA and add back in ORWA then restrucutre DF for final output
comm_catch <- catch2 |>
  dplyr::filter(STATE == "CA") |>
  dplyr::rename(CATCH = TOTAL) |>
  rbind(catch_orwa) |>
  dplyr::mutate(ST_FLEET = glue::glue("{STATE}_{FLEET}")) |>
  dplyr::filter(YEAR > 2015) |>
  dplyr::left_join(discards_all, by = c("YEAR" = "year", "ST_FLEET" = "ST_FLEET")) |>
  dplyr::mutate(discards = dplyr::case_when(is.na(discards) ~ 0,
                                            TRUE ~ discards),
                CATCH = dplyr::case_when(is.na(CATCH) ~ 0,
                                         TRUE ~ CATCH),
                TOTAL_CATCH = CATCH + discards,
                SEAS = "1",
                CATCH_SE = 0.01) |>
  dplyr::select(YEAR, SEAS, ST_FLEET, TOTAL_CATCH, CATCH_SE)

#### Export df ----
# export catches
# write.csv(comm_catch, file = file.path(getwd(), "yelloweye_commercial_catch_2016_2024.csv"), append = FALSE)


# Replicate r4ss catches plot
  # library(ggplot2)
  # rich.colors.short <- function(n, alpha = 1) {
  #   x <- seq(0, 1, length = n)
  #   r <- 1 / (1 + exp(20 - 35 * x))
  #   g <- pmin(pmax(0, -0.8 + 6 * x - 5 * x^2), 1)
  #   b <- dnorm(x, 0.25, 0.15) / max(dnorm(x, 0.25, 0.15))
  #   rgb.m <- matrix(c(r, g, b), ncol = 3)
  #   rich.vector <- apply(rgb.m, 1, function(v) rgb(v[1], v[2], v[3], alpha = alpha))
  # }
  # hist_c <- read.csv(file.path(getwd(), "data", "ss3_input_comm_catch.csv")) |>
  #   dplyr::select(YEAR, SEAS, ST_FLEET, CATCH, CATCH_SE) |>
  #   dplyr::rename(TOTAL_CATCH = CATCH)
  # 
  # all_catch <- rbind(hist_c, comm_catch) |>
  #   dplyr::mutate(
  #     # YEAR = as.factor(YEAR),
  #     CATCH = as.numeric(TOTAL_CATCH)
  #   )
  # 
  # # identify colors for plot
  # all_fleets <- c("CA_TWL", "CA_NONTWL", "CA_REC", "ORWA_TWL", "ORWA_NONTWL", "OR_REC", "WA_REC")
  # colors <- rich.colors.short(length(unique(all_fleets)) + 1)[-1]
  # 
  # fleetcols <- c("CA_TWL" = "#0000CBFF", "CA_NONTWL" = "#0081FFFF", "CA_REC" = "#02DA81FF", "ORWA_TWL" = "#80FE1AFF", "ORWA_NONTWL" = "#FDEE02FF", "OR_REC" = "#FFAB00FF", "WA_REC" = "#FF3300FF")
  # 
  # ggplot(data = all_catch, aes(x = YEAR, y = CATCH, fill = ST_FLEET)) +
  #   geom_bar(position = "stack", stat = "identity", color = "black") +
  #   labs(
  #     x = "Year",
  #     y = "Catch (mt)",
  #     fill = ""
  #   ) +
  #   ggtitle("Yelloweye Rockfish Commercial Catch (landings + discards)") +
  #   scale_fill_manual(values = fleetcols) +
  #   theme_minimal()