library(ggplot2)
library(tidyverse)

setwd("C:/Users/msand/OneDrive/Documents/GitHub/Sebastes_ruberrimus_2025")
inputs <- SS_read(dir = file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe"))

# Cleaning CA recreational from the reconstruction data from Ralston
ca_rec <- read.csv(file.path(getwd(), "Data/CA_historical_Ralston_rec_recon_1928_1980.csv"))
ca_rec <- ca_rec %>% 
  mutate("State" = "CA") %>% 
  mutate('DataType' = "Rec") %>% 
  mutate('Fleet' = "Rec") %>% 
  mutate('DataSource' = "CA reconstruction") %>% 
  mutate('GearGroup' = "All") %>% 
  mutate('Providedby' = "EJ Dick") %>% 
  select(-AREA,-SPECIES, -POUNDS, -FREQ) %>% 
  rename(Year = YEAR) %>% 
  rename('Catches' = MTONS)
  

# Cleaning CA 1916-1968 commercial catches from CA reconstruction 
# need to separate out trawl vs non trawl then sum the catches to match format of last assessment
ca_com_earlier <- read.csv("Data/CA_historical_Ralston_comm_recon_1916_68.csv")
ca_com_earlier_TWL <- ca_com_earlier %>% 
  filter(gear == "TWL") %>% #filters for trawl
  group_by(year) %>% 
  mutate("Catches" = sum(MTONS)) %>% 
  select(-species, -pounds, -Source, -MTONS, -region) %>% 
  mutate("State" = "CA") %>% 
  mutate('DataType' = "Comm") %>%  #because recreational
  mutate('Fleet' = "Shoreside") %>% 
  mutate('DataSource' = "CalCom") %>% 
  mutate('Providedby' = "EJ Dick") %>% 
  rename(Year = year) %>% 
  rename('GearGroup' = gear) %>% 
  distinct()

# CA trawl interpolation to match other states in the assessment
catch_1916 <- ca_com_earlier_TWL$`Catches`[ca_com_earlier_TWL$Year == 1916]
Year <- c(1889, 1915)
Catches <- c(0, catch_1916)
interpolated <- approx(Year, Catches, xout = seq(1889, 1915, by = 1))
interpolated
df_interpolated <- data.frame(
  Year = interpolated$x,
  Catches = interpolated$y,
  State = "CA", 
  DataType = "Comm",
  Fleet = "Shoreside",
  DataSource = "CalCom",
  Providedby = "EJ Dick",
  GearGroup = "TWL"
)
ca_com_earlier_TWL <- bind_rows(ca_com_earlier_TWL, df_interpolated)
print(ca_com_earlier_TWL)

# Nontrawl data from 1916-1968
ca_com_earlier_NONTWL <- ca_com_earlier %>% 
  filter(!gear == "TWL") %>% #filters for trawl
  group_by(year) %>% 
  mutate("Catches" = sum(MTONS)) %>% 
  select(-species, -pounds, -Source, -MTONS, -region, -gear) %>% 
  mutate("State" = "CA") %>% 
  mutate('DataType' = "Comm") %>%  #because recreational
  mutate('Fleet' = "Shoreside") %>% 
  mutate('DataSource' = "CalCom") %>% 
  mutate('Providedby' = "EJ Dick") %>% 
  rename(Year = year) %>% 
  mutate('GearGroup' = "NONTWL") %>% 
  distinct()

# Interpolation for nontrawl
catch_1916 <- ca_com_earlier_NONTWL$`Catches`[ca_com_earlier_NONTWL$Year == 1916]
Year <- c(1889, 1915)
Catches <- c(0, catch_1916)
interpolated <- approx(Year, Catches, xout = seq(1889, 1915, by = 1))
interpolated
df_interpolated <- data.frame(
  Year = interpolated$x,
  Catches = interpolated$y,
  State = "CA", 
  DataType = "Comm",
  Fleet = "Shoreside",
  DataSource = "CalCom",
  Providedby = "EJ Dick",
  GearGroup = "NONTWL"
)
ca_com_earlier_NONTWL <- bind_rows(ca_com_earlier_NONTWL, df_interpolated)
print(ca_com_earlier_NONTWL)

  
# Cleaning CA 1969-1980 Commercial catches from CA reconstruction 
# need to separate out trawl vs non trawl then sum the catches to match format of last assessment
ca_com_later <- read.csv("Data/CA_historical_comm_1969_1980.csv")
ca_com_later_TWL <- ca_com_later %>% 
  filter(GEAR_GRP == "TWL") %>% #filters for trawl
  group_by(YEAR) %>% 
  mutate("Catches" = sum(MTONS)) %>% 
  select(YEAR,GEAR_GRP,'Catches') %>% 
  mutate("State" = "CA") %>% 
  mutate('DataType' = "Comm") %>%  #because recreational
  mutate('Fleet' = "Shoreside") %>% 
  mutate('DataSource' = "CalCom") %>% 
  mutate('Providedby' = "EJ Dick") %>% 
  rename(Year = YEAR) %>% 
  rename('GearGroup' = GEAR_GRP) %>% 
  distinct()

ca_com_later_NONTWL <- ca_com_later %>% 
  filter(!GEAR_GRP == "TWL") %>% 
  group_by(YEAR) %>% 
  mutate("Catches" = sum(MTONS)) %>% 
  select(YEAR,'Catches') %>% 
  mutate("State" = "CA") %>% 
  mutate('DataType' = "Comm") %>% 
  mutate('Fleet' = "Shoreside") %>% 
  mutate('DataSource' = "CalCom") %>% 
  mutate('Providedby' = "EJ Dick") %>% 
  mutate('GearGroup' = "NONTWL") %>% 
  rename(Year = YEAR) %>% 
  distinct()


# foreign catch in california 
foreign <- read.csv("Data/Rogers_2003_Foreign_Catch.csv")
# within the csv it says there is 1ton for 1967, so I will just manually put that in 
foreign_catches_ca <- data.frame(Year = 1979, `Catches (mtons)` = 1)%>% 
  mutate("State" = "CA") %>% 
  mutate('DataType' = "Comm") %>%  #because recreational
  mutate('Fleet' = "FORIEGN POP") %>% 
  mutate('DataSource' = "Roger 2023") %>% 
  mutate('Providedby' = "EJ DICK") %>% 
  mutate('GearGroup' = "TWL") %>% 
  rename('Catches' = Catches..mtons.)
  
  

# Combined everything from the data frames that were just cleaned
Ca_historical_catches <- rbind(ca_com_earlier_NONTWL,ca_com_earlier_TWL,ca_com_later_NONTWL,
                               ca_com_later_TWL,ca_rec, foreign_catches_ca) %>% 
  mutate("From"= "2025 recheck") %>% 
  mutate("In.the.model."= "unsure") %>% 
  mutate("Final."= "unsure") %>% 
  mutate("Notes"= "")

CA_historical_catches_csv <- Ca_historical_catches |>
                             mutate(GearGroup = case_when(GearGroup == "All" ~ "REC",
                                                          GearGroup != "All" ~ GearGroup),
                                    fleet = case_when(GearGroup == "REC" ~ 3,
                                                      GearGroup == "TWL" ~ 1,
                                                      GearGroup == "NONTWL" ~ 2)) |>
                             group_by(GearGroup, Year) |>
                             summarize(catch = sum(Catches),
                                       fleet = unique(fleet)) |>
                             ungroup() |>
                             arrange(GearGroup, Year) |>
                             select(Year, catch, fleet, GearGroup) |>
                             write.csv(file.path(getwd(), "Data", "processed", "CA_all_fleets_historical_catches.csv"), row.names = FALSE)

ca_both_assessments_comparison <- CA_historical_catches_csv |>
                       select(-GearGroup) |>
                       rename(year = Year) |> 
                       mutate(assessment = "Current") |>
                       bind_rows(inputs$dat$catch |>
                                 filter(fleet %in% c(1,2,3),
                                        catch > 0,
                                        year <= 1980) |>
                                 mutate(assessment = "Previous")) |>
                      ggplot(aes(x = year, y = catch, fill = assessment)) +
                      geom_bar(stat = "identity") +
                      facet_grid(~fleet)
ggsave(plot = ca_both_assessments_comparison, "ca_historical_catch_comparisons_all_fleets.png",
       path = file.path(getwd(), "Rcode", "removals"))
              

# plot for fun
ggplot(Ca_historical_catches, aes(x = Year, y = Catches, fill = DataType)) + 
  geom_bar(stat = "identity")+
  labs(title = "CA historical catches")+
  theme_classic()


# check w/ previous assessment catch data for CA
previous <- read.csv("Data/Yelloweye catches 2017 assessment.csv") %>% 
  filter(State == "CA") %>% 
  filter(Year < 1981) %>% 
  rename('DataType' = Data.Type) %>% 
  rename('Catches' = Catches..mtons.) %>% 
  rename('DataSource' = Data.source) %>% 
  rename('Providedby' = Provided.by) %>% 
  mutate("From"= "2017 Assessment")

# calculate annual sums for both 2017 update and current CA data
previous_all <- previous %>% 
  group_by(Year)%>% 
  mutate("Yearly.catches" = sum(Catches)) %>% 
  mutate(Yearly.catches = round(sum(Catches), 2)) %>% 
  select(Year,From,Yearly.catches)
Ca_historical_catches_all <- Ca_historical_catches %>% 
  group_by(Year)%>% 
  mutate("Yearly.catches" = sum(Catches)) %>% 
  mutate(Yearly.catches = round(sum(Catches), 2)) %>% 
  select(Year,From,Yearly.catches)
comparison <- full_join(previous_all, Ca_historical_catches_all, 
                        by = c("Year"), 
                        suffix = c("_prev", "_new"))
# Calculate the difference
comparison <- comparison %>%
  mutate(Difference = Yearly.catches_new - Yearly.catches_prev)%>% 
  #filter(Difference > .1) %>% 
  select(-From_prev,-From_new) %>% 
  distinct()
print(comparison)



