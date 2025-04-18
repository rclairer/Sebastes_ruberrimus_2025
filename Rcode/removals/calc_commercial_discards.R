#### Calc discards ----
# Calculate commercial discards using GEMM and WCGOP data for yelloweye
# Exported as .csv at the end

# By: S.Schiano and E.Perl

# Libararies
library(nwfscSurvey)

#### Extract or load data ----

# Pull GEMM data
gemm <- pull_gemm(common_name = "yelloweye rockfish") |>
  suppressWarnings()

# Read in WCGOP data
# WCGOP discards directory
disdir <- file.path("~/GitHub/Sebastes_ruberrimus_2025", "Data","raw","nonconfidential","discards")

# All extracted WCGOP discards files
# combine catch share data
# Data used for catch share - 100% observed discards
disrate_comb <- utils::read.csv(file.path(disdir, "discard_rates_combined_catch_share.csv"))
disrate_emcatch <- utils::read.csv(file.path(disdir, "discards_rates_em_catch_share.csv"))
disrate_catchsh <- utils::read.csv(file.path(disdir, "discards_rates_catch_share.csv"))
# non-catch share data
disrate_noncatch <- utils::read.csv(file.path(disdir, "discard_rates_noncatch_share.csv"))

# Indicate trawl vs non-trawl fleets
# Grouping based on key from V. Gertseva excel sheet
trawl <- c(
  "At-Sea Hake CP", # UNSURE
  "At-Sea Hake MSCV", #UNSURE       
  "CS - Bottom Trawl",            
  "CS EM - Bottom Trawl",
  "Midwater Hake", # UNSURE                  
  "Midwater Rockfish",                 
  "Tribal Shoreside",            
  "Directed P Halibut", # GUES            
  "Midwater Rockfish EM",         
  "Pink Shrimp" ,                    
  "LE Fixed Gear DTL - Hook & Line", 
  "Midwater Hake EM"="TWL" ,        
  "CS - Bottom and Midwater Trawl",
  "Limited Entry Trawl",       
  "Tribal At-Sea Hake",         
  "Shoreside Hake",              
  "LE CA Halibut"
)

nontrawl <- c(
  "CS EM - Pot",                  
  "Incidental",                 
  "LE Sablefish - Hook & Line",  
  "LE Sablefish - Pot" ,
  "Nearshore" ,                    
  "OA Fixed Gear - Hook & Line" ,  
  "Research", #GUESS  
  "CS - Pot" ,            
  "CS - Hook & Line",            
  "OA Fixed Gear - Pot"
)

#### Data Analysis ----

# Pull out commercial data from GEMM
commercial_gemm <- gemm |>
  dplyr::filter(sector %in% c(trawl, nontrawl)) |>
  # renames fleets based on categorization
  dplyr::mutate(fleet = dplyr::case_when(
    sector %in% trawl ~ "TWL",
    sector %in% nontrawl ~ "NONTWL",
    TRUE ~ NA
  )) |>
  dplyr::group_by(year, fleet) |>
  dplyr::summarise(total_discards = sum(total_discard_mt),
                   cv = max(cv))

# Calculate WCGOP data

# Calculate total discards by fleet and year for non-catch share
all_noncatch <- disrate_noncatch |>
tidyr::separate_wider_delim(fleet, delim = "-", names = c("fleet", "state")) |>
  dplyr::group_by(fleet, year) |>
  dplyr::summarise(total_discards = sum(obs_discard)) |>
  dplyr::mutate(fleet = dplyr::case_when(
    fleet == "fixed" ~ "NONTWL",
    fleet == "trawl" ~ "TWL", 
    TRUE ~ "TWL"
  ))

# Calculate proportion of discards by year and fleet for each non-catch share entry
non_catchshare_prop <- disrate_noncatch |>
  tidyr::separate_wider_delim(fleet, delim = "-", names = c("fleet", "state")) |>
  dplyr::mutate(fleet = dplyr::case_when(
    fleet == "fixed" ~ "NONTWL",
    fleet == "trawl" ~ "TWL", 
    TRUE ~ "TWL"
  )) |>
  dplyr::full_join(all_noncatch, by = c("year", "fleet")) |>
  dplyr::mutate(prop_disc = obs_discard / total_discards) |>
  dplyr::select(year, fleet, state, prop_disc) |>
  dplyr::mutate(fleet = dplyr::case_when(
    grepl("fixed", fleet) ~ stringr::str_replace(fleet, "fixed", "NONTWL"),
    grepl("trawl", fleet) ~ stringr::str_replace(fleet, "trawl", "TWL"),
    TRUE ~ fleet
  ))

# Calculate non-catch share discards
# Expand using GEMM data and multiple total discards from GEMM by proportion discarded from WCGOP
non_catchshare <- non_catchshare_prop |>
  dplyr::full_join(commercial_gemm, by = c("year", "fleet")) |> # ,"fleet"
  dplyr::mutate(nonshare_discard = total_discards * prop_disc) |>
  dplyr::select(year, fleet, state, nonshare_discard)

# Combine non-catch share and catch share discards
# Final data set
all_comm_discards <- disrate_comb |>
  dplyr::select(year, fleet, observed_discard_mt) |>
  dplyr::mutate(fleet = dplyr::case_when(
    grepl("fixed", fleet) ~ stringr::str_replace(fleet, "fixed", "NONTWL"),
    grepl("trawl", fleet) ~ stringr::str_replace(fleet, "trawl", "TWL"),
    TRUE ~ fleet
  )) |>
  tidyr::separate_wider_delim(fleet, delim = "-", names = c("fleet", "state")) |>
  dplyr::full_join(non_catchshare, by = c("year", "fleet", "state")) |>
  dplyr::mutate(nonshare_discard = dplyr::case_when(is.na(nonshare_discard) ~ 0,
                                                    TRUE ~ nonshare_discard),
                observed_discard_mt = dplyr::case_when(is.na(observed_discard_mt) ~ 0,
                                                       TRUE ~ observed_discard_mt),
                total_discards = round(observed_discard_mt + nonshare_discard, 2)) |>
  # Set up fleet name for SS3 input
  dplyr::mutate(fleet = glue::glue("{fleet}-{state}")) |>
  dplyr::select(year, fleet, total_discards)

#### Export df ----
# Export
# write.csv(all_comm_discards, file = "~/GitHub/Sebastes_ruberrimus_2025/Data/processed/discards/commercial_discards.csv")


