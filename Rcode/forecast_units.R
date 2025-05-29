# converting GMT forecast catch from biomass to numbers for the WA_REC fleet

# fixed forecast for 2025-2026 from GMT rep are in biomass
GMT_catch_biomass <- data.frame(
  year = rep(2025:2026, each = 7),
  seas = 1,
  fleet = rep(1:7, 2),
  catch_or_F = c(0.14, 10, 9, 7.76, 8.88, 6.6, 3.22, 0.14, 10, 9, 7.76, 9.58, 6.6, 3.22)
) # Sent by Christian Heath 5/5/25

GMT_catch_biomass
#    year seas fleet catch_or_F
# 1  2025    1     1       0.14
# 2  2025    1     2      10.00
# 3  2025    1     3       9.00
# 4  2025    1     4       7.76
# 5  2025    1     5       8.88
# 6  2025    1     6       6.60
# 7  2025    1     7       3.22
# 8  2026    1     1       0.14
# 9  2026    1     2      10.00
# 10 2026    1     3       9.00
# 11 2026    1     4       7.76
# 12 2026    1     5       9.58
# 13 2026    1     6       6.60
# 14 2026    1     7       3.22

replist <- SS_output("model/base_comm_discards_steepness_fitbias_tuned_forecast")
# which fleets have catch in numbers (catch_units == 2) and are fishery fleets (fleet_type == 1)
replist$FleetNames[replist$catch_units == 2 & replist$fleet_type == 1]
# [1] "7_WA_REC"

# calculate model expectation for mean weight for the WA_REC fleet
# which is based on the combination of parameters for growth and selectivity
WA_REC_meanwt <- mod$timeseries |>
  dplyr::filter(Area == 2 & Yr == 2024) |>
  dplyr::mutate(meanwt = as.numeric(`dead(B):_7`) / as.numeric(`dead(N):_7`)) |>
  dplyr::pull(meanwt) |>
  round(3)
WA_REC_meanwt
# [1] 2.105

GMT_catch_input <- GMT_catch_biomass |>
  dplyr::mutate(catch_or_F = ifelse(fleet != 7, catch_or_F, round(catch_or_F / WA_REC_meanwt, 3)))

# resulting table has 1.53 (1000s) for fleet 7 vs 3.22 (metric tons) in GMT_catch_biomass
GMT_catch_input
#    year seas fleet catch_or_F
# 1  2025    1     1       0.14
# 2  2025    1     2      10.00
# 3  2025    1     3       9.00
# 4  2025    1     4       7.76
# 5  2025    1     5       8.88
# 6  2025    1     6       6.60
# 7  2025    1     7       1.53
# 8  2026    1     1       0.14
# 9  2026    1     2      10.00
# 10 2026    1     3       9.00
# 11 2026    1     4       7.76
# 12 2026    1     5       9.58
# 13 2026    1     6       6.60
# 14 2026    1     7       1.53