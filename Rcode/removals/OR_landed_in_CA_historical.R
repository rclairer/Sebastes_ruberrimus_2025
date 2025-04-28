
CA_OR <- read.csv(here::here("Data", "raw", "nonconfidential", "CA_historical_com_lands_from_OR_WA_waters.csv")) |>
  dplyr::rename(Catch_CA = Yelloweye.MTONS)

OR_comm_all <- read.csv(file.path(
  getwd(),
  "Data",
  "raw",
  "nonconfidential",
  "ORCommLandings_457_2024.csv"
))

OR_TWL <- OR_comm_all |>
  select(YEAR, FLEET, TOTAL) |>
  filter(
    FLEET == "TRW",
    YEAR <= 1968,
    YEAR >= 1948
  )  |>
  select(-FLEET) |>
  rename(Year = YEAR,
         Catch_TWL = TOTAL)

OR_NONTWL <- OR_comm_all |>
  select(YEAR, FLEET, TOTAL) |>
  filter(
    FLEET == "NTRW",
    YEAR <= 1968,
    YEAR >= 1948
  ) |>
  select(-FLEET) |>
  rename(Year = YEAR,
         Catch_NONTWL = TOTAL)

OR_BOTH <- OR_TWL |>
  full_join(OR_NONTWL, by = "Year") |>
  mutate(Total_Catch = Catch_TWL + Catch_NONTWL,
         Prop_TWL = Catch_TWL/Total_Catch, 
         Prop_NONTWL = Catch_NONTWL/Total_Catch) |>
  full_join(CA_OR, by = "Year") |>
  mutate(CA_OR_TWL = Prop_TWL * Catch_CA,
         CA_OR_NONTWL = Prop_NONTWL * Catch_CA)

OR_landed_in_CA_TWL <- OR_BOTH |>
  select(Year, CA_OR_TWL) |>
  mutate(
    year = Year,
    seas = 1,
    fleet = 4,
    catch = CA_OR_TWL,
    catch_se = 0.01
  ) |>
  select(-Year, -CA_OR_TWL) |>
  write.csv(file.path(getwd(), "Data", "processed", "OR_landed_in_CA_TWL.csv"), row.names = FALSE)

OR_landed_in_CA_NONTWL <- OR_BOTH |>
  select(Year, CA_OR_NONTWL) |>
  mutate(
    year = Year,
    seas = 1,
    fleet = 5,
    catch = CA_OR_NONTWL,
    catch_se = 0.01
  ) |>
  select(-Year, -CA_OR_NONTWL) |>
  write.csv(file.path(getwd(), "Data", "processed", "OR_landed_in_CA_NONTWL.csv"), row.names = FALSE)

