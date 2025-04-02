################################################################################
### Process the CDFW PR data for an index of abundance
### Depending on the species and the area you may need to modify the filters
### Copper assessment 2023
### Melissa Monk
################################################################################
rm(list = ls(all = TRUE))
graphics.off()
library(RColorBrewer)
library(dplyr)
library(tidyr)
library(ggplot2)
library(here)
library(glue)

#species and area identifiers - eventually put in function
pacfinSpecies <- 'COPP'
speciesName <- "copper"
modelArea = "north"
modelName = "rm_last2yrs_area_weighted"
#setwd to the north or the south
#set working directory
setwd("S:/copper_rockfish_2023/data/rec_indices/crfs_pr_dockside")
#setwd(glue::glue(here(),"/data/rec_indices/crfs_pr_dockside/"))
out.dir <- file.path(getwd(), modelArea, modelName)

#load data for processing
load("all_pr_data.RData")

# Data filter dataframe
filter.num <- 1
dataFilters <- data.frame(matrix(vector(), 10, 4,
                                 dimnames = list(c(), c(
                                   "Filter", "Description", "Samples",
                                   "Positive_Samples"
                                 ))), stringsAsFactors = F)
#-------------------------------------------------------------------------------
#Filter to north or south
#Need to get the individual trips
#remove blank species names
cdfwpr <- all_pr_data %>% 
  mutate(area = ifelse(district > 2, "north", "south")) %>%
  filter(area == modelArea) %>%
  mutate(cpue = kept/anglers)

#look at total sample sizes by year to see if there is a post-covid difference
cdfwpr_samplesize <- all_pr_data %>%
  mutate(area = ifelse(district > 2, "north", "south")) %>%
  group_by(area, year) %>%
  tally() %>%
  pivot_wider(names_from = area, values_from = n)
write.csv(cdfwpr_samplesize, "pr_trip_sample_size_by_year.csv")


#cpue over time to see if there's a reduction in copper cpue in 2022
#will run with and without 2022
#will eventually add in the angler reported catches as well for a more complete 
#analysis
q = c(.25, .5, .75)
cpue_year <- cdfwpr %>%
  filter(kept>0) %>%
  group_by(year) %>%
  summarize(
    min = min(cpue),
    quant25 = quantile(cpue, probs = q[1]), 
    quant50 = quantile(cpue, probs = q[2]),
    quant75 = quantile(cpue, probs = q[3]),
    max = max(cpue))
cpue_year
write.csv(cpue_year, 
          file.path(getwd(),modelArea, modelName, "forSS","observed_cpue_by_year.csv"),
          row.names = FALSE)
#histogram of the number of fish per bag
#-------------------------------------------------------------------------------
# Add to filter dataframe
dataFilters$Filter[filter.num] <- c("All data")
dataFilters$Description[filter.num] <- c("All data")
dataFilters$Samples[filter.num] <- cdfwpr %>% tally()
dataFilters$Positive_Samples[filter.num] <- cdfwpr %>% filter(kept>0) %>% tally()
filter.num <- filter.num + 1
#-------------------------------------------------------------------------------

#Get the number of available samples by year
samples_year_district <- cdfwpr %>%
  group_by(year, district) %>%
  tally() %>%
  pivot_wider(names_from=district, values_from = n)

#Remove 2020 due to covid
cdfwpr <- cdfwpr %>%
  filter(!year %in% c(2020, 2021, 2022))

#-------------------------------------------------------------------------------
# Add to filter dataframe
dataFilters$Filter[filter.num] <- c("Year")
dataFilters$Description[filter.num] <- c("Remove 2020-2022 due to COVID sampling restrictions 
                                         and avoidance")
dataFilters$Samples[filter.num] <- cdfwpr %>% tally()
dataFilters$Positive_Samples[filter.num] <- cdfwpr %>% filter(kept>0) %>% tally()
filter.num <- filter.num + 1
#-------------------------------------------------------------------------------

#Look at where the target is found within the possible remaining data
target <- cdfwpr %>% filter(kept>0)
summary(as.factor(cdfwpr$area_x))
summary(as.factor(target$area_x))
#remove mexico, na, and bays and harbors
area.to.remove <- c("Mexico","Bay/estuary/harbor")

cdfwpr <- cdfwpr %>%
  filter(!area_x %in% area.to.remove,
         !is.na(area_x))
#Look at where the target is found within the possible remaining data
target <- cdfwpr %>% filter(kept>0)
summary(as.factor(cdfwpr$area_x))
summary(as.factor(target$area_x))
#-------------------------------------------------------------------------------
# Add to filter dataframe
dataFilters$Filter[filter.num] <- c("Areas fished")
dataFilters$Description[filter.num] <- c("Retain trips occuring in ocean areas")
dataFilters$Samples[filter.num] <- cdfwpr %>% tally()
dataFilters$Positive_Samples[filter.num] <- cdfwpr %>% filter(kept>0) %>% tally()
filter.num <- filter.num + 1
#-------------------------------------------------------------------------------
#remove uncommon gears and then look at the target
gears <- cdfwpr %>%
  group_by(geara) %>%
  tally() %>%
  filter(n>100)

#remove uncommon gears
cdfwpr <- cdfwpr %>%
  filter(geara %in% gears$geara)

#new target table
target <- cdfwpr %>% filter(kept>0)
summary(as.factor(target$geara))
summary(as.factor(cdfwpr$geara))
#1 = Hook & line
#2 = Dip net
#3 = Cast net
#4 = Gill net
#5 = Seine
#6 = Trawl
#7 = Trap
#8 = Spear/spear gun
#9 = Hand
#10 = Other
#Blank = no gear recorded or not the first species and location in a PR1 sample


#keep only hook and line - explore keeping troll as well
gears.to.keep <- c('H','Hook and Line', 'T', 'Troll')
cdfwpr <- cdfwpr %>%
  filter(geara %in% gears.to.keep) %>%
  mutate(geara = case_when(geara == "H" ~ "Hook and Line",
                           geara == "T" ~ "Troll",
                           TRUE ~ geara))

target <- cdfwpr %>% filter(kept>0)
summary(as.factor(target$geara))
summary(as.factor(cdfwpr$geara))
#-------------------------------------------------------------------------------
# Add to filter dataframe
dataFilters$Filter[filter.num] <- c("Gear")
dataFilters$Description[filter.num] <- c("Retain trips with primary gear of hook-and-line or troll")
dataFilters$Samples[filter.num] <- cdfwpr %>% tally()
dataFilters$Positive_Samples[filter.num] <- cdfwpr %>% filter(kept>0) %>% tally()
filter.num <- filter.num + 1
#-------------------------------------------------------------------------------

#number of anglers
summary(cdfwpr$anglers)
#seems reasonable

#months
summary(as.factor(cdfwpr$month))
target <- cdfwpr %>% filter(kept>0)
summary(as.factor(target$month))
#remove Jan-March in the north - no rockfishing these months
#remove Jan-Feb in the south - no rockfishing these months
if(modelArea =="north"){
  cdfwpr <- cdfwpr %>%
    filter(month > 3)
} else {
  cdfwpr <- cdfwpr %>%
    filter(month > 2)
}
#-------------------------------------------------------------------------------
# Add to filter dataframe
dataFilters$Filter[filter.num] <- c("Months fished")
if(modelArea=="north"){
  dataFilters$Description[filter.num] <- c("Remove Jan-March; recreational rockfish fishery closed")
} else{
  dataFilters$Description[filter.num] <- c("Remove Jan-Feb; recreational rockfish fishery closed")
}
dataFilters$Samples[filter.num] <- cdfwpr %>% tally()
dataFilters$Positive_Samples[filter.num] <- cdfwpr %>% filter(kept>0) %>% tally()
filter.num <- filter.num + 1
#-------------------------------------------------------------------------------
#LOOK AT THE TARGET SPECIES 
#trips by target species and put all rockfish entries in the rockfish genus 
#trips with lingcod in bottomfish
cdfwpr$prim1Common <- trimws(cdfwpr$prim1Common, which = c("right"))
cdfwpr$prim1Common[grepl("rockfish",cdfwpr$prim1Common)] <- "rockfish genus"
cdfwpr$prim1Common[grepl("lingcod",cdfwpr$prim1Common)] <- "bottomfish (groundfish)"
cdfwpr$prim1Common[grepl("bocaccio",cdfwpr$prim1Common)] <- "rockfish genus"
cdfwpr$prim1Common[grepl("salmon",cdfwpr$prim1Common)] <- "salmon"
cdfwpr$prim1Common[grepl("shark",cdfwpr$prim1Common)] <- "sharks"
cdfwpr$prim1Common[grepl("tuna",cdfwpr$prim1Common)] <- "tunas/albacore"
cdfwpr$prim1Common[grepl("albacore",cdfwpr$prim1Common)] <- "tunas/albacore"
cdfwpr$prim1Common[grepl("sanddab",cdfwpr$prim1Common)] <- "sanddabs"
cdfwpr$prim1Common[grepl("mackerel",cdfwpr$prim1Common)] <- "mackerels"

#same for prim2
cdfwpr$prim2Common <- trimws(cdfwpr$prim2Common, which = c("right"))
cdfwpr$prim2Common[grepl("rockfish",cdfwpr$prim2Common)] <- "rockfish genus"
cdfwpr$prim2Common[grepl("lingcod",cdfwpr$prim2Common)] <- "bottomfish (groundfish)"
cdfwpr$prim2Common[grepl("bocaccio",cdfwpr$prim2Common)] <- "rockfish genus"
cdfwpr$prim2Common[grepl("salmon",cdfwpr$prim2Common)] <- "salmon"
cdfwpr$prim2Common[grepl("shark",cdfwpr$prim2Common)] <- "sharks"
cdfwpr$prim2Common[grepl("tuna",cdfwpr$prim2Common)] <- "tunas/albacore"
cdfwpr$prim2Common[grepl("albacore",cdfwpr$prim2Common)] <- "tunas/albacore"
cdfwpr$prim2Common[grepl("sanddab",cdfwpr$prim2Common)] <- "sanddabs"
cdfwpr$prim2Common[grepl("mackerel",cdfwpr$prim2Common)] <- "mackerels"

#primary target species only
tripTargets <- cdfwpr %>%
  group_by(prim1Common) %>%
  summarise(tripsWithTarget = sum(kept>0),
            tripsWOTarget = sum(kept==0)) %>%
  mutate(totalTrips = tripsWithTarget+tripsWOTarget,
         percentpos = tripsWithTarget/(tripsWithTarget+tripsWOTarget)) 
write.csv(tripTargets, 
          file.path(getwd(),modelArea, modelName, "forSS","prim1summary.csv"),
          row.names=FALSE)

tripTargetFilter  <- tripTargets %>%
  filter(tripsWithTarget > 0) %>%
  filter(totalTrips >= 100) %>%
  filter(percentpos > 0.02)

#filter to keept only identified primary targets chose in tripTargetFilter
cdfwpr <- cdfwpr %>%
  filter(prim1Common %in% tripTargetFilter$prim1Common)

#create the same table with the secondary targets
#when rockfish and bottomfish are not the primary
secondary_target <- cdfwpr %>%
  filter(!prim1Common %in% 
           c("rockfish genus", "bottomfish (groundfish)")) %>%
  group_by(prim2Common) %>%
  summarise(tripsWithTarget = sum(kept>0),
            tripsWOTarget = sum(kept==0)) %>%
  mutate(totalTrips = tripsWithTarget+tripsWOTarget,
         percentpos = tripsWithTarget/(tripsWithTarget+tripsWOTarget)) 
write.csv(secondary_target, 
          file.path(getwd(),modelArea, modelName, "forSS","prim2summary.csv"),
          row.names=FALSE)

secondary_filter1 <- secondary_target %>%
  filter(tripsWithTarget > 0) %>%
  filter(totalTrips >= 100) %>%
  filter(percentpos > 0.02)
View(secondary_filter1)


#suggests that keeping the secondary target of bottomfish and 
#rockfish is reasonable
#cdfwpr <- cdfwpr %>%
#mutate(keep.trip = ifelse(
#  prim1Common %in% c('bottomfish (groundfish)', 'rockfish genus') |
#  prim2Common %in% secondary_filter1$prim2Common, 1,0)) %>%
#  filter(keep.trip==1)

#create a matrix fro the document
#look at secondary trip target
prim1_2summary <- cdfwpr %>%
  group_by(prim1Common, prim2Common) %>%
  summarise(tripsWithTarget = sum(kept>0),
            tripsWOTarget = sum(kept==0)) %>%
  mutate(totalTrips = tripsWithTarget+tripsWOTarget,
         percentpos = tripsWithTarget/(tripsWithTarget+tripsWOTarget))  %>%
  dplyr::select(prim1Common,prim2Common, percentpos) %>%
  pivot_wider(names_from = prim2Common, values_from = percentpos)
View(prim1_2summary)
#
trip2Targets <- cdfwpr %>%
  filter(!prim1Common %in% 
           c("rockfish genus", "bottomfish (groundfish)")) %>%
  group_by(prim2Common) %>%
  summarise(tripsWithTarget = sum(kept),
            tripsWOTarget = sum(kept == 0)) %>%
  mutate(totalTrips = tripsWithTarget+tripsWOTarget,
         percentpos = tripsWithTarget/(tripsWithTarget+tripsWOTarget)) 
View(trip2Targets)
#-------------------------------------------------------------------------------
#Retain trips with just the primary species being bottom fish or rockfish
#want to try and avoid mixed trip effort
#Could change this - esp. for the south...more mixed trips, but really want just
#trips with rockfihs effort
prim2north <- c('bottomfish (groundfish)', 'rockfish genus')
prim2south <- c('rockfish genus')
if(modelArea=="north"){
  prim2keep <- prim2north 
} else{
  prim2keep = prim2south
}

cdfwpr <- cdfwpr %>%
  mutate(keep.trip = ifelse(
    prim1Common %in% c('bottomfish (groundfish)', 'rockfish genus') |
      prim2Common %in% prim2keep , 1,0)) %>%
  filter(keep.trip==1)

cdfwpr <- cdfwpr %>%
  mutate(targetSpecies = prim1Common) %>%
  mutate(targetSpecies = 
           case_when(!targetSpecies %in% c('bottomfish (groundfish)', 'rockfish genus') ~ "other",
                     TRUE ~ targetSpecies))
#-------------------------------------------------------------------------------
# Add to filter dataframe
dataFilters$Filter[filter.num] <- c("Target species")
if(modelArea=="north"){
  dataFilters$Description[filter.num] <- c("Retain trips with primary target of 
rockfish or bottomfish target; or as secondary target species for trips identified in 
the previous table") 
} else{
  dataFilters$Description[filter.num] <- c("Retain trips with primary target of 
rockfish or bottomfish target; or rockfish as secondary target species for trips identified in 
the previous table")
}
dataFilters$Samples[filter.num] <- cdfwpr %>% tally()
dataFilters$Positive_Samples[filter.num] <- cdfwpr %>% filter(kept>0) %>% tally()
filter.num <- filter.num + 1
#-------------------------------------------------------------------------------



#final tables and visualizations
#Get the number of available samples by year
samples_year_district <- cdfwpr %>%
  group_by(year, district) %>%
  tally() %>%
  tidyr::pivot_wider(names_from=district, values_from = n)
samples_year_district
write.csv(samples_year_district, 
          file.path(getwd(),modelArea, modelName, "forSS","samples_by_year_district.csv"),
          row.names=FALSE)

#sample sizes by month
samples_month_year <- cdfwpr %>%
  group_by(year, month) %>%
  tally() %>%
  tidyr::pivot_wider(names_from = month, values_from = n)
samples_month_year


#average cpue by county
#might want to add a look up table and have the 
#county names
cpue_by_county <- cdfwpr %>%
  group_by(year, county, district) %>%
  summarise(average_cpue = mean(cpue)) %>%
  mutate_at(vars(county,district), as.factor)

cpue_by_district <- cdfwpr %>%
  group_by(year,  district) %>%
  summarise(average_cpue = mean(cpue)) %>%
  mutate_at(vars(district), as.factor)

#didn't see anything with county-too messy - look at district
ggplot(cpue_by_district, aes(x = year, 
                             y = average_cpue, colour = district)) +
  geom_point(size = 3)  + theme_bw() +
  geom_line(aes(x = year, y = average_cpue, 
                colour = district)) +
  xlab("Year") + ylab("Average CPUE") + ylim(c(0, 1.5)) + 
  scale_color_viridis_d()
ggsave(file = file.path(getwd(),modelArea, modelName, "average_cpue_by_cnty.png"), width = 7, height = 7)

#look at district 4 in 2017
#several trips with high cpue!
#could spot-check a few of them
aa<- cdfwpr %>% 
  filter(year==2017,district==4)
View(aa)


#save the datafile and filters for the run file
save(cdfwpr, dataFilters, 
     file = file.path(getwd(),modelArea, modelName, "/data_for_glm.RData"))