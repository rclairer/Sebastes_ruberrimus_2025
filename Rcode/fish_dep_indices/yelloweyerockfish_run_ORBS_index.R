

#########################################################################
### Run the ORBS data to get an index of abundance
### Black rockfish assessment 2023
### Melissa Monk, edited by Ali Whitman (ODFW)
#########################################################################
# updated 6/14/2023 by A. Whitman to grab tables

# re-run with a charter boat  filter on 7/18/23

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
pacfinSpecies <- 'BLCK'
speciesName <- "black"
modelArea = "oregon"
indexName <-  "ORBS"
modelName <- "full"


# emailed Melissa to find these... 

# # Load in some helper functions for processing and plotting the data
# # #R path
#  github_path <- "C:/Users/melissa.monk/Documents/GitHub/copper_rockfish_2023"
#  all <- list.files(file.path(github_path, "R", "sdmTMB"))
#  for (a in 1:length(all)) { source(file.path(github_path, "R", "sdmTMB", all[a]))}

# loading helper functions 

dir<-file.path("C:/Users/daubleal/Desktop/2023 Assessment Cycle/Raw Index Scripts")
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
dir <- file.path("C:/Users/daubleal/Desktop/2023 Assessment Cycle/Index_ORBS")
setwd(dir)

# load data # note using alternative version of dataset (see notes)
#dat<-read.csv("ORBS-CPUE_filtered_442_2022.csv")
dat<-read.csv("ORBS-CPUE_filtered_alt_fixed_442_2022.csv")

# reset dir # issues - will need to manually call
dir <- file.path("C:/Users/daubleal/Desktop/2023 Assessment Cycle/Index_ORBS/black_oregon_ORBS_charter_alt")
setwd(dir)

# explore the data 

summary(dat)

#Look at the data
pos <- subset(dat, tgt.count>0)

#sparse data
with(pos, table(BoatType)) # nothing looks particularly sparse
with(pos, table(GF_OpenDepth)) 
with(pos, table(MegaRegion))

ggplot(pos, aes(GF_OpenDepth, tgt.CPUE)) + # looks pretty even
  geom_point(alpha = .5)

ggplot(pos, aes(Port, tgt.CPUE)) +  # not so even, include this one
  geom_point(alpha = .5)

ggplot(pos, aes(Season, tgt.CPUE)) + # even 
  geom_point(alpha = .5)

ggplot(pos, aes(Month, tgt.CPUE)) + # not even! include, correlated with port?   
  geom_point(alpha = .5)

ggplot(pos, aes(BoatType, tgt.CPUE)) + # slightly different, include?
  geom_point(alpha = .5)

ggplot(pos, aes(MegaRegion, tgt.CPUE)) + # boring
  geom_point(alpha = .5)

# create a variable for black rockfish bag limits 
# rockfish bag limit 2001 - 2002, marine bag limit for all other years except 2017
# where we had a black sub bag

dat <- dat %>%
  rename(year = Year)

with(dat,table(year, BlackSubBag))

dat$tgt.bag<-ifelse(dat$year %in% c(2001:2002),dat$RckfishBagLim,
                    ifelse(dat$year== 2017,dat$BlackSubBag,dat$MarBagLim))
summary(dat$tgt.bag)

# also have binary variable with whether a trip hit the bag limit 

with(dat,table(year, HitBag))

pos <- subset(dat, tgt.count>0)

ggplot(pos, aes(tgt.bag, tgt.CPUE)) + # not even but prob correlated with year... include?
  geom_point(alpha = .5)

with(dat,table(year, tgt.bag))

ggplot(pos, aes(HitBag, tgt.CPUE)) + # 
  geom_point(alpha = .5)

# fix some names and include a categorized bag limit variable, remove NAs in whether a trip
# exceeded the bag limit
# added a charter boat filter here
dat <- dat %>%
  filter(dat$BoatType == "C") %>%
  #filter(!is.na(dat$HitBag)) %>%
  rename(Effort = Effort) %>%
  mutate(logEffort = log(Effort))
  #mutate(tgt.bag_bin = cut(tgt.bag, breaks = c(0,5,7,10)))

with(dat,table(year,tgt.bag_bin)) # still a lot of zeros :) 
with(dat,table(year,BoatType))

ggplot(dat, aes(GF_OpenDepth, tgt.CPUE)) + # re-doing charter only 
  geom_point(alpha = .5)

ggplot(dat, aes(x=GF_OpenDepth, y=tgt.CPUE)) + 
  geom_boxplot() +
#  labs(y = "Adjusted Trip Hours") +
  theme(axis.title.x = element_blank(),
        axis.title.y=element_text(margin=margin(0,10,0,0)))
#ggsave("Black ORBS_TripHours.png",width = 10,height = 5)

with(dat, table(GF_OpenDepth))

hist(log(dat$tgt.count))

# define covars

# have a lot for black rockfish - selected final ones based on scatterplots with CPUE and 
# last assessment 
#covars <- c("year","tgt.bag","BoatType","Port","Month","GF_OpenDepth") # full model
#covars <- c("year","HitBag","BoatType","Port","Month","GF_OpenDepth") # full alt
# other model
covars <- c("year","Port","Month","GF_OpenDepth","HitBag")


# Ensure covariates are factors
dat <- dat %>%
  mutate_at(covars, as.factor) 

# look at multicollinearity 

datrim<-data.frame(dat$tgt.count,dat[,covars])
#pairs(datrim)

#-------------------------------------------------------------------------------
#Main effects model
#Model selection
#full model
model.full <- MASS::glm.nb(
  tgt.count ~ year + Month + Port + GF_OpenDepth + HitBag + offset(logEffort), 
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
dir <- file.path("C:/Users/daubleal/Desktop/2023 Assessment Cycle/Index_ORBS/black_oregon_ORBS_charter")
setwd(dir)

#set the grid
grid <- expand.grid(
  year = unique(dat$year),
  Month = levels(dat$Month)[1],
  Port = levels(dat$Port)[1],
  #BoatType = levels(dat$BoatType)[1],
  #tgt.bag = levels(dat$tgt.bag)[1],
  #tgt.bag_bin = levels(dat$tgt.bag_bin)[1],
  HitBag = levels(dat$HitBag)[1],
  GF_OpenDepth = levels(dat$GF_OpenDepth)[1]
)

fit.nb <- sdmTMB(
  tgt.count ~ year + Month + Port + GF_OpenDepth + HitBag, 
  data = dat,
  offset = dat$logEffort,
  time = "year",
  spatial="off",
  spatiotemporal = "off",
  family = nbinom2(link = "log"),
  control = sdmTMBcontrol(newton_loops = 1)) #documentation states sometimes aids convergence

#}

#Get diagnostics and index for SS
do_diagnostics(
  dir = file.path(dir), 
  fit = fit.nb,
  plot_resids = F)

calc_index(
  dir = file.path(dir), 
  fit = fit.nb,
  grid = grid)

#-------------------------------------------------------------------------------
#Format data filtering table and the model selection table for document

# will need to modify my filter script to get the dataFilters to work
View(dataFilters)

dataFilters <- dataFilters %>%
  rowwise() %>%
  filter(!all(is.na(across((everything()))))) %>%
  ungroup() %>%
  rename(`Positive Samples` = Positive_Samples)
dataFilters <- data.frame(lapply(dataFilters, as.character), stringsasFactors = FALSE)
write.csv(dataFilters, file = file.path(dir, "data_filters.csv"), row.names = FALSE)

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
#write.csv(out, file = file.path(dir,  "model_selection.csv"), row.names = FALSE)

#summary of trips and  percent pos per year
summaries <- dat %>%
  group_by(year) %>%
  summarise(tripsWithTarget = sum(tgt.count>0),
            tripsWOTarget = sum(tgt.count==0)) %>%
  mutate(totalTrips = tripsWithTarget+tripsWOTarget,
         percentpos = round(tripsWithTarget/(tripsWithTarget+tripsWOTarget),2)) 
View(summaries)
# write.csv(summaries,
#           file.path(dir,  "percent_pos.csv"),
#           row.names=FALSE)
