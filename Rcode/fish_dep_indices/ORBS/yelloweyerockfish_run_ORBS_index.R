

#########################################################################
### Run the ORBS data to get an index of abundance
### Yelloweye rockfish assessment 2025
### Melissa Monk, edited by Ali Whitman (ODFW)
#########################################################################
# updated 03/3/2025 by A. Whitman 


rm(list = ls(all = TRUE))
graphics.off()

library(sdmTMB)
library(tmbstan)
library(ggeffects)
library(MuMIn)
library(here)
library(glue)
library(tidyr)
library(dplyr)
library(rstanarm)
options(mc.cores = parallel::detectCores())
library(ggplot2)
library(bayesplot)
library(grid)
library(devtools)
library(ggeffects)
library(tidybayes)
library(gridExtra)
library(fitdistrplus)

#species and area identifiers - eventually put in function
pacfinSpecies <- 'YEYE'
speciesName <- "yelloweye"
modelArea = "oregon"
indexName <-  "ORBS"
modelName <- "full"

# loading helper functions 

dir<-file.path("C:/Users/daubleal/OneDrive - Oregon/Desktop/2025 Assesssment Cycle/Index_ORBS/Raw Index Scripts")
setwd(dir)
list.files()
#source("helper_functions.R")
source("diagnostics.R")
source("do_diagnostics.R")
source("format_hkl_data.R")
source("format_index.R")
source("get_index.R")
source("match.f.R")
source("plot_betas.R")
source("plot_index.R")
source("refactor.R")

# Set working directories
dir <- file.path("C:/Users/daubleal/OneDrive - Oregon/Desktop/2025 Assesssment Cycle/Index_ORBS")
setwd(dir)

# load data 
dat<-read.csv("ORBS-CPUE_filtered_457_2024.csv") # note using angler-reported released CPUE

# reset dir to full model subfolder
dir.create(paste0(speciesName,"_",modelArea,"_",indexName,"_",modelName))
dir_model<-paste0(dir,"/",speciesName,"_",modelArea,"_",indexName,"_",modelName)
setwd(dir_model)
getwd()

# explore the data 

names(dat)
summary(dat)

#Look at the data
pos <- subset(dat, tgt.count>0)

with(pos,table(Year)) # remove 2001 - 2003 due to sample size (these aren't release years!)
with(pos, table(BoatType)) 
with(pos, table(GF_OpenDepth)) # pretty limited outside 40fm, should probably remove
with(pos, table(MegaRegion))
with(pos,table(Season)) # more in summer
with(pos, table(LLTrip))
with(pos, table(Port))
with(pos, table(Month))

ggplot(pos, aes(GF_OpenDepth, tgt.CPUE)) + # not too variable, once remove >40
  geom_point(alpha = .5)

ggplot(pos, aes(Port, tgt.CPUE)) +  # not so even, include this one
  geom_point(alpha = .5)

ggplot(pos, aes(Season, tgt.CPUE)) + # fairly even
  geom_point(alpha = .5)

ggplot(pos, aes(Month, tgt.CPUE)) + # not even! fewer in winter months, correlated with port - subset?
  geom_point(alpha = .5)

ggplot(pos, aes(BoatType, tgt.CPUE)) + # different, include.
  geom_point(alpha = .5)

ggplot(pos, aes(as.factor(Year), tgt.CPUE)) +
  geom_boxplot()

ggplot(pos, aes(MegaRegion, tgt.CPUE)) + # even, meh
  geom_point(alpha = .5)

# create a single variable for general rockfish bag limits 
# yelloweye was required to be released from 2004 - 2024 but the marine bag limit might impact effort
# covered under the rockfish bag in 2001 - 2002, marine bag limit from 2003 - 2024

with(dat,table(Year,MarBagLim)) # 4 - 10 over the years, generally decreasing with time
dat$tgt.bag<-ifelse(dat$Year %in% c(2001:2002), dat$RckfishBagLim,dat$MarBagLim)
with(dat,table(Year,tgt.bag))

# also create a binary variable with whether a trip hit the bag limit - not needed for yelloweye
# 
# dat$HitBag<-ifelse(dat$tgt.count>=dat$tgt.bag,1,0)
# with(dat,table(year, HitBag)) # hmm that seems like a lot? 

pos <- subset(dat, tgt.count>0)

ggplot(pos, aes(tgt.bag, tgt.CPUE)) + # not even but prob correlated with year... include?
  geom_point(alpha = .5)

# ggplot(pos, aes(as.factor(HitBag), tgt.CPUE)) + # higher CPUE when hit the bag
#   geom_point(alpha = .5)

# added a filter for 2001 - 2003 and removed trips outside 40fm (M1 - 3)
# added an additional filter for summer months only (M4 - 6)

dat <- dat %>%
  #filter(BoatType == "C") %>%
  filter(Year %in% c(2004:2024)) %>%
  #filter(Season=="S") %>%
  filter(!GF_OpenDepth==">40 fm") %>%
  rename(Effort = Effort) %>%
  mutate(logEffort = log(Effort)) %>%
  rename(year = Year) %>% # oops
  mutate(tgt.bag_bin = cut(tgt.bag, breaks = c(0,6.1,10.1))) # categorized into high and low

table(dat$tgt.bag_bin)
#table(dat$HitBag)

hist(dat$tgt.count) # yeah.
hist(log(dat$tgt.CPUE))

with(dat,table(tgt.bag,GF_OpenDepth)) # might have issues between the bag limit and the open depth
with(dat,table(year,GF_OpenDepth)) # geez and year
#with(dat,table(year,tgt.bag_bin))

# define covars
#covars <- c("year","Port","Month","BoatType","GF_OpenDepth","tgt.bag") # full - singular
#covars <- c("year","Port","Month","BoatType","GF_OpenDepth") # M2
#covars <- c("year","Port","Month","BoatType","tgt.bag") # M3 - singular

# series 2 - removed winter months
#covars <- c("year","Port","Month","BoatType","GF_OpenDepth","tgt.bag") # M4 - singular
#covars <- c("year","Port","Month","BoatType","GF_OpenDepth") # M5
#covars <- c("year","Port","Month","BoatType","tgt.bag") # M6 - singular

# series 3 - bin the bag limit *sigh, retain all records
#covars <- c("year","Port","Month","BoatType","GF_OpenDepth","tgt.bag_bin") # M7
covars <- c("year","Port","Month","BoatType","tgt.bag_bin") # M8

# next steps? other filters or model series?


# subset to fields needed
dat<-dat[,names(dat) %in% c("tgt.count","Effort","logEffort",covars)] #

# Ensure covariates are factors and remove NAs
dat <- dat %>%
  mutate_at(covars, as.factor) %>%
  filter(complete.cases(dat))

# look at multicollinearity 

#datrim<-data.frame(dat$tgt.count,dat[,covars])
#pairs(datrim)

###### Model selection #####

#full model
model.full <- MASS::glm.nb(
  tgt.count ~ year + Month + Port + BoatType + GF_OpenDepth + tgt.bag + offset(logEffort), 
  data = dat,
  na.action = "na.fail")
summary(model.full)
anova(model.full)
#use ggpredict to get an estimate of the logEffort for sdmTMB predictions
#MuMIn will fit all models and then rank them by AICc
model.suite <- MuMIn::dredge(model.full,
                             rank = "AICc", 
                             fixed= c("offset(logEffort)", "year"))

#Create model selection dataframe for the document
Model_selection <- as.data.frame(model.suite) %>%
  dplyr::select(-weight)
Model_selection

#-------------------------------------------------------------------------------
#sdmTMB model

# reset dir if running model different than full model 
setwd(dir)
modelName<-"M8_tgt.bag_bin_noGFOpenDepth"
dir.create(paste0(speciesName,"_",modelArea,"_",indexName,"_",modelName))
dir_model<-paste0(dir,"/",speciesName,"_",modelArea,"_",indexName,"_",modelName)
setwd(dir_model)
getwd()

#set the grid
grid <- expand.grid(
  year = unique(dat$year),
  Month = levels(dat$Month)[1],
  #Season = levels(dat$Season)[1],
  #MegaRegion = levels(dat$MegaRegion)[1],
  Port = levels(dat$Port)[1],
  BoatType = levels(dat$BoatType)[1],
  #GF_OpenDepth = levels(dat$GF_OpenDepth)[1],
  tgt.bag_bin = levels(dat$tgt.bag_bin)[1]
  #tgt.bag = levels(dat$tgt.bag)[1]
  #HitBag = levels(dat$HitBag)[1]
  #LLTrip = levels(dat$LLTrip)[1]
)

fit.nb <- sdmTMB(
  tgt.count ~ year + Month + Port + BoatType + tgt.bag_bin, 
  data = dat,
  offset = dat$logEffort,
  time = "year",
  spatial="off",
  spatiotemporal = "off",
  family = nbinom1(link = "log"),  
  control = sdmTMBcontrol(newton_loops = 1)) #documentation states sometimes aids convergence

#}

#Get diagnostics and index for SS
do_diagnostics(
  dir = dir_model, # going to the model directory
  fit = fit.nb,
  plot_resids = F)

calc_index(
  dir = dir_model, # going to the model directory
  fit = fit.nb,
  grid = grid)

#-------------------------------------------------------------------------------
#Format data filtering table and the model selection table for document - use with final model

# will need to modify my filter script to get the dataFilters to work
# View(dataFilters)
# 
# dataFilters <- dataFilters %>%
#   rowwise() %>%
#   filter(!all(is.na(across((everything()))))) %>%
#   ungroup() %>%
#   rename(`Positive Samples` = Positive_Samples)
# dataFilters <- data.frame(lapply(dataFilters, as.character), stringsasFactors = FALSE)
# write.csv(dataFilters, file = file.path(dir, "data_filters.csv"), row.names = FALSE)

View(Model_selection)
#format table for the document
out <- Model_selection %>%
  dplyr::select(-`(Intercept)`) %>%
  mutate_at(vars(covars,"year","offset(logEffort)"), as.character) %>%
  mutate(across(c("logLik","AICc","delta"), round, 1)) %>%
  # replace_na(list(district = "Excluded",                      # fix these later
  #                 targetSpecies = "Excluded", month = "Excluded")) %>% # fix later
  mutate_at(c(covars,"year","offset(logEffort)"), 
            funs(stringr::str_replace(.,"\\+","Included"))) %>%
  rename(`Effort offset` = `offset(logEffort)`, 
         `log-likelihood` = logLik) %>%
  rename_with(stringr::str_to_title,-AICc)
View(out)
#write.csv(out, file = file.path(dir,  paste0(speciesName,"_","model_selection.csv")), row.names = FALSE) # going to parent directory

#summary of trips and  percent pos per year
summaries <- dat %>%
  group_by(year) %>%
  summarise(tripsWithTarget = sum(tgt.count>0),
            tripsWOTarget = sum(tgt.count==0)) %>%
  mutate(totalTrips = tripsWithTarget+tripsWOTarget,
         percentpos = round(tripsWithTarget/(tripsWithTarget+tripsWOTarget),2)) 
View(summaries)
#write.csv(summaries,file.path(dir, paste0(speciesName,"_","percent_pos.csv")),row.names=FALSE)
