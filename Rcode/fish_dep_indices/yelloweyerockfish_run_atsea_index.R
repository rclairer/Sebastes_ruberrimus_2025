
#########################################################################
### Run the At Sea CPFV observer data to get an index of abundance
### Black rockfish assessment 2023
### Melissa Monk, edited by Ali Whitman (ODFW)
#########################################################################
# updated 5/11/2023 by A. Whitman 

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
indexName <-  "atsea_cpfv_observer"
modelName <- "full"

# emailed Melissa to find these... 

# # Load in some helper functions for processing and plotting the data
# #R path
# github_path <- "C:/Users/melissa.monk/Documents/GitHub/copper_rockfish_2023"
# all <- list.files(file.path(github_path, "R", "sdmTMB"))
# for (a in 1:length(all)) { source(file.path(github_path, "R", "sdmTMB", all[a]))}

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
dir <- file.path("C:/Users/daubleal/Desktop/2023 Assessment Cycle/Index_AT SEA OBSERVER")
setwd(dir)

# load data
#load("data_for_GLM.RData")
dat<-read.csv("AtSea-CPUE_filtered_442_2022.csv")

# reset dir 
dir <- file.path("C:/Users/daubleal/Desktop/2023 Assessment Cycle/Index_AT SEA OBSERVER/black_oregon_atsea_cpfv_observer_full")
setwd(dir)

# explore the data 

names(dat)

#Look at the data
pos <- subset(dat, Total_target>0)

#sparse data
with(pos, table(Port)) # hmm, should remove Port Orford
with(pos, table(Year))  # 2019 is light on samples
with(pos, table(GF_OpenDepth))

ggplot(pos, aes(GF_OpenDepth, CPUE)) + # looks pretty even
  geom_point(alpha = .5)

ggplot(pos, aes(Megaregion, CPUE)) + # pretty even
  geom_point(alpha = .5)

ggplot(pos, aes(as.factor(Port), CPUE)) +  # even, except for PO
  geom_point(alpha = .5)

ggplot(pos, aes(DepthBin, CPUE)) + # not super even, include
  geom_point(alpha = .5)

ggplot(pos, aes(Month, CPUE)) + # not even! include. maybe change to wave   
  geom_point(alpha = .5)

ggplot(pos, aes(Depth_FM, CPUE)) + # fairly even.. try binned depth
  geom_point(alpha = .5)

 # fix or add anything 
dat <- dat %>%
  rename(year = Year) %>%
  #create 2- month waves
  mutate(wave = case_when(Month %in% c(1,2) ~ "Wave1",
                          Month %in% c(3,4) ~ "Wave2",
                          Month %in% c(5,6) ~ "Wave3",
                          Month %in% c(7,8) ~ "Wave4",
                          Month %in% c(9,10) ~ "Wave5")) %>%
  rename(Effort = AngHrs) %>%
  mutate(logEffort = log(Effort)) %>% 
  # remove PO 
  filter(Port != "38")

pos <- subset(dat, Total_target>0)

ggplot(pos, aes(wave, CPUE)) + # fairly even but include if month doesn't work.   
  geom_point(alpha = .5)


# reset dir if running model different than full model 
dir <- file.path("C:/Users/daubleal/Desktop/2023 Assessment Cycle/Index_AT SEA OBSERVER/black_oregon_atsea_cpfv_observer_wave")
setwd(dir)

# define your covariates 
#covars <- c("year","Month","Port","DepthBin") # original full model 
covars <- c("year","wave","Port","DepthBin")

#Ensure covariates are factors

dat <- dat %>%
  mutate_at(covars, as.factor) 


#model selection
model.full <- MASS::glm.nb(
  Total_target ~ year + Month + Port + GF_OpenDepth + DepthBin + offset(logEffort),
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


# sdmTMB model 

  #set the grid
  grid <- expand.grid(
    year = unique(dat$year),
    #Month = levels(dat$Month)[1],
    wave = levels(dat$wave)[1],
    Port = levels(dat$Port)[1],
    DepthBin = levels(dat$DepthBin)[1]
  )

  fit.nb <- sdmTMB(
    Total_target ~ year + wave + Port + DepthBin,
    data = dat,
    offset = dat$logEffort,
    time = "year",
    spatial="off",
    spatiotemporal = "off",
    family = nbinom2(link = "log"),
    control = sdmTMBcontrol(newton_loops = 1)) #documentation states sometimes aids convergence?

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
#View(dataFilters)

dataFilters <- dataFilters %>%
  rowwise() %>%
  filter(!all(is.na(across((everything()))))) %>%
  ungroup() %>%
  rename(`Positive Samples` = Positive_Samples)
dataFilters <- data.frame(lapply(dataFilters, as.character), stringsasFactors = FALSE)
#write.csv(dataFilters, file = file.path(dir, "data_filters.csv"), row.names = FALSE)

View(Model_selection)
#format table for the document
out <- Model_selection %>%
  dplyr::select(-`(Intercept)`) %>%
  mutate_at(vars(covars,"year","offset(logEffort)"), as.character) %>%
  mutate(across(c("logLik","AICc","delta"), round, 1)) %>%
  #replace_na(list(district = "Excluded", 
   #               targetSpecies = "Excluded", month = "Excluded")) %>%
  mutate_at(c(covars,"year","offset(logEffort)"), 
            funs(stringr::str_replace(.,"\\+","Included"))) %>%
  rename(`Effort offset` = `offset(logEffort)`, 
         `log-likelihood` = logLik) %>%
  rename_with(stringr::str_to_title,-AICc)
View(out)
#write.csv(out, file = file.path(dir,  "model_selection.csv"), row.names = FALSE)

#summary of trips and  percent pos per year
summaries <- dat %>%
  group_by(Year) %>%
  summarise(tripsWithTarget = sum(Total_target>0),
            tripsWOTarget = sum(Total_target==0)) %>%
  mutate(totalTrips = tripsWithTarget+tripsWOTarget,
         percentpos = tripsWithTarget/(tripsWithTarget+tripsWOTarget)) 
View(summaries)
# write.csv(summaries, 
#           file.path(dir,  "percent_pos.csv"),
#           row.names=FALSE)

#-------------------------------------------------------------------------------
#Area-weighted index
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
if(grepl("area_weighted", modelName) == TRUE){
  #fraction of rocky habitat by district in state waters only
  north_district_weights <- data.frame(district = c(3,4,5,6),
                                       area_weight = c(0.3227, 0.321, 0.162, 0.1943))
  
  #Model selection
  #full model
  model.full <- MASS::glm.nb(
    kept ~ year + district + month + targetSpecies + year:district + offset(logEffort),
    data = dat,
    na.action = "na.fail")
  summary(model.full)
  anova(model.full)
  #use ggpredict to get an estimate of the logEffort for sdmTMB predictions
  ggpredict(model.full, terms = "year")
  #MuMIn will fit all models and then rank them by AICc
  model.suite <- MuMIn::dredge(model.full,
                               rank = "AICc", 
                               fixed= c("offset(logEffort)", "year"))
  
  #Create model selection dataframe for the document
  Model_selection <- as.data.frame(model.suite) %>%
    dplyr::select(-weight)
  Model_selection
  
  # if(modelArea=="north"){
  #set the grid
  grid <- expand.grid(
    year = unique(dat$year),
    district = levels(dat$district),
    targetSpecies = levels(dat$targetSpecies)[1],
    month = levels(dat$month)[1])
  
  grid$district_year <- 1
  
  district3 <- round(0.32 * 100, 0)
  district4 <- round(0.32 * 100, 0)
  district5 <- round(0.16 * 100, 0)
  district6 <- round(0.20 * 100, 0)
  
  grid_north <- NULL
  for (a in 1:32){
    grid_north <- rbind(grid_north, grid[grid$district == 3, ])
  }
  for (a in 1:32){
    grid_north <- rbind(grid_north, grid[grid$district == 4, ])
  }
  for (a in 1:16){
    grid_north <- rbind(grid_north, grid[grid$district == 5, ])
  }
  for (a in 1:20){
    grid_north <- rbind(grid_north, grid[grid$district == 6, ])
  }
  
  fit.nb <- sdmTMB(
    kept ~ year + district + month + targetSpecies + year:district,
    data = dat,
    offset = dat$logEffort,
    time = "year",
    spatial="off",
    spatiotemporal = "off",
    family = nbinom2(link = "log"),
    control = sdmTMBcontrol(newton_loops = 1))
  
  do_diagnostics(
    dir = file.path(dir), 
    fit = fit.nb,
    plot_resid = FALSE)
  
  calc_index(
    dir = file.path(dir), 
    fit = fit.nb,
    grid = grid_north)
  
  
  
  # } else {
  #   #set the grid
  #   grid <- expand.grid(
  #     year = unique(dat$year),
  #     district = levels(dat$district)[1],
  #     month = levels(dat$month)[1],
  #     targetSpecies = levels(dat$targetSpecies)[1]
  #   )
  #   
  #   fit.nb <- sdmTMB(
  #     kept ~ year + district + month + targetSpecies,
  #     data = dat,
  #     offset = dat$logEffort,
  #     time = "year",
  #     spatial="off",
  #     spatiotemporal = "off",
  #     family = nbinom2(link = "log"),
  #     silent = TRUE,
  #     do_index = TRUE,
  #     predict_args = list(newdata = grid, re_form_iid = NA),   
  #     index_args = list(area = 1),
  #     control = sdmTMBcontrol(newton_loops = 1) #not entirely sure what this does
  #   )
  # }
  # 
  
  #Get diagnostics and index for SS
  # do_diagnostics(
  #   dir = file.path(dir, "area_weighted"), 
  #   fit = fit.nb)
  # 
  # calc_index(
  #   dir = file.path(dir, "area_weighted"), 
  #   fit = fit.nb,
  #   grid = grid)
  # 
  
  
  #-------------------------------------------------------------------------------
  #Format data filtering table and the model selection table for document
  dataFilters <- data.frame(lapply(dataFilters, as.character), stringsasFactors = FALSE)
  write.csv(dataFilters, 
            file = file.path(dir, "dataFilters.csv"), 
            row.names = FALSE)
  
  #View(Model_selection)
  #format table for the document
  out <- Model_selection %>%
    dplyr::select(-`(Intercept)`) %>%
    mutate_at(vars(covars_weighted,"year","offset(logEffort)"), as.character) %>%
    mutate(across(c("logLik","AICc","delta"), round, 1)) %>%
    replace_na(list(district = "Excluded", `district:year` = "Excluded",
                    targetSpecies = "Excluded", month = "Excluded")) %>%
    mutate_at(c(covars_weighted,"year","offset(logEffort)"), 
              funs(stringr::str_replace(.,"\\+","Included"))) %>%
    rename(`Effort offset` = `offset(logEffort)`, 
           `log-likelihood` = logLik,
           `Primary target species` = targetSpecies,
           `Interaction` = `district:year`) %>%
    rename_with(stringr::str_to_title,-AICc)
  #View(out)
  write.csv(out, file = file.path(dir, "model_selection.csv"), 
            row.names = FALSE)
  
}
#-------------------------------------------------------------------------------
#4/4/23 taking way too long to run on Melissa's computer
#diagnostic of prop zero without the interaction looks good!
#so I know the negativ binomial fits
# # Source delta glm plotting functions
# source(file.path(here(),"R","rec_indices", "Delta_bayes_functions.R"))
#  # use STAN to see how well 'best model' fits the data
#   Dnbin <- stan_glm.nb(
#     kept ~ year + district + month + targetSpecies + year:district,
#   offset = logEffort,
#   data = dat,
#   prior_intercept = normal(location = 0, scale = 10),
#   prior = normal(location = 0, scale = 10),
#   prior_aux = cauchy(0, 5),
#   chains = 4,
#   iter = 5000) # iterations per chain
#   Sys.time() - start.time
#   save(Dnbin, file = "Dnbin.RData")

# load("Dnbin.RData")
#   # nb Model checks
#   # Create index
#   yearvar <- "year"
#   yrvec <- as.numeric(levels(droplevels(dat$year))) # years
#   yrvecin <- as.numeric(levels(droplevels(dat$year))) # years

#   # Create index
#   ppnb <- posterior_predict(Dnbin, draws = 1000)
#   inb <- plotindex_bayes(Dnbin, yrvec,
#     backtrans = "exp", standardize = F,
#     title = "negative binomial"
#   )


#   nbin.draws <- as.data.frame(Dnbin)
#   nbin.yrs <- cbind.data.frame(nbin.draws[, 1], nbin.draws[, 1] + nbin.draws[, 2:length(yrvec)])
#   colnames(nbin.yrs)[1] <- paste0(yearvar, yrvec[1])
#   index.draws <- exp(nbin.yrs)


#   # calculate the index and sd
#   # logSD goes into the model
#   Index <- apply(index.draws, 2, mean) # mean(x)
#   SDIndex <- apply(index.draws, 2, sd) # sd(x)
#   int95 <- apply(index.draws, 2, quantile, probs = c(0.025, 0.975))
#   outdf <- cbind.data.frame(Year = yrvec, Index, SDIndex, t(int95))
#   # index draws already backtransformed
#   outdf$logIndex <- log(outdf$Index)
#   outdf$logmean <- apply(index.draws, 2, function(x) {
#     mean(log(x))
#   })
#   outdf$logSD <- apply(index.draws, 2, function(x) {
#     sd(log(x))
#   })

#   # add raw standardized index to outdf
#   raw.cpue.year <- dat %>%
#     group_by(YEAR) %>%
#     summarise(avg_cpue = mean(CPUE)) %>%
#     mutate(std.raw.cpue = avg_cpue / mean(avg_cpue))

#   outdf$stdzd.raw.cpue <- raw.cpue.year$std.raw.cpue
#   outdf$stdzd.Index <- outdf$Index / mean(outdf$Index)
#   # write csv
#   write.csv(outdf, paste0(
#     out.dir, "/", Model_region[Model.number], "_negativebinomial_",
#     species.name, "_",
#     survey.name, "_Index.csv"
#   ))

#   ## pp_check
#   prop_zero <- function(y) mean(y == 0)
#   # figure of proportion zero
#   figure_Dnbin_prop_zero <- pp_check(Dnbin, 
#   plotfun = "stat", stat = "prop_zero", binwidth = 0.001)
#   figure_Dnbin_prop_zero
#  ggsave(paste0(dir, "/negbin_prop_zero.png"))
# # figure of mean and sd from model
#   pp_check(Dnbin, plotfun = "stat_2d", stat = c("mean", "sd"))
#   ggsave(paste0(out.dir, "/negbin_pp_stat_mean_sd.png"))

# # boxplot of the posterior draws (light blue) compared to data (in dark blue)
#   pp_check(Dnbin, plotfun = "boxplot", nreps = 10, notch = FALSE) +
#     ggtitle("negative binomial model")

# # plot of mean and sd together  from posterior predictive
#   ppc_stat_2d(y = dat$kept, yrep = ppnb, stat = c("mean", "sd")) + ggtitle("Negative Binomial")
