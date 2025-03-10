
#########################################################################
### Run the CDFW PR dockside data to get an index of abundance
### Copper assessment 2023
### Melissa Monk
#########################################################################
# Run the MRFSS cpfv dockside index
# Melissa Monk June 2021; modified for copper 2023

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
pacfinSpecies <- 'COPP'
speciesName <- "copper"
modelArea = "south"
indexName <-  "crfs_pr_dockside"
modelName <- "rm_last2yrs_area_weighted"
covars <- c("month", "district", "year", "targetSpecies")#, "geara")
covars_weighted <- c("month", "district", "year", "targetSpecies", "district:year")
# Load in some helper functions for processing and plotting the data
#R path
github_path <- "C:/Users/melissa.monk/Documents/GitHub/copper_rockfish_2023"
all <- list.files(file.path(github_path, "R", "sdmTMB"))
for (a in 1:length(all)) { source(file.path(github_path, "R", "sdmTMB", all[a]))}
# Set working directories
#set working directory
dir <- file.path("S:/copper_rockfish_2023/data/rec_indices/crfs_pr_dockside",
                 modelArea, modelName)

#dir <- file.path(here(),"data","rec_indices", indexName, modelArea)
setwd(dir)

# load data
load("data_for_GLM.RData")


#Ensure columns named appropriately and covariates are factors
dat <- cdfwpr %>%
  rename(Effort = anglers) %>%
  mutate(logEffort = log(Effort)) %>%
  mutate_at(covars, as.factor) # make sure covariates are factors

#-------------------------------------------------------------------------------
#Main effects model
#Model selection
#full model
model.full <- MASS::glm.nb(
  kept ~ year + district + month + targetSpecies + offset(logEffort),
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


if(modelArea=="north"){
  #set the grid
  grid <- expand.grid(
    year = unique(dat$year),
    district = levels(dat$district)[1],
    targetSpecies = levels(dat$targetSpecies)[1],
    month = levels(dat$month)[1])
  
  fit.nb <- sdmTMB(
    kept ~ year + district + month + targetSpecies,
    data = dat,
    offset = dat$logEffort,
    time = "year",
    spatial="off",
    spatiotemporal = "off",
    family = nbinom2(link = "log"),
    control = sdmTMBcontrol(newton_loops = 1))
  
} else {
  
  #set the grid
  grid <- expand.grid(
    year = unique(dat$year),
    district = levels(dat$district)[1],
    month = levels(dat$month)[1],
    targetSpecies = levels(dat$targetSpecies)[1]
  )
  
  fit.nb <- sdmTMB(
    kept ~ year + district + month + targetSpecies,
    data = dat,
    offset = dat$logEffort,
    time = "year",
    spatial="off",
    spatiotemporal = "off",
    family = nbinom2(link = "log"),
    silent = TRUE,
    do_index = TRUE,
    predict_args = list(newdata = grid, re_form_iid = NA),   
    index_args = list(area = 1),
    control = sdmTMBcontrol(newton_loops = 1)) #not entirely sure what this does
  
}

#Get diagnostics and index for SS
do_diagnostics(
  dir = file.path(dir), 
  fit = fit.nb)

calc_index(
  dir = file.path(dir), 
  fit = fit.nb,
  grid = grid)

#-------------------------------------------------------------------------------
#Format data filtering table and the model selection table for document
View(dataFilters)

dataFilters <- dataFilters %>%
  rowwise() %>%
  filter(!all(is.na(across((everything()))))) %>%
  ungroup() %>%
  rename(`Positive Samples` = Positive_Samples)
dataFilters <- data.frame(lapply(dataFilters, as.character), stringsasFactors = FALSE)

write.csv(dataFilters, file = file.path(dir, "data_filters.csv"), row.names = FALSE)

#View(Model_selection)
#format table for the document
out <- Model_selection %>%
  dplyr::select(-`(Intercept)`) %>%
  mutate_at(vars(covars,"year","offset(logEffort)"), as.character) %>%
  mutate(across(c("logLik","AICc","delta"), round, 1)) %>%
  replace_na(list(district = "Excluded", 
                  targetSpecies = "Excluded", month = "Excluded")) %>%
  mutate_at(c(covars,"year","offset(logEffort)"), 
            funs(stringr::str_replace(.,"\\+","Included"))) %>%
  rename(`Effort offset` = `offset(logEffort)`, 
         `log-likelihood` = logLik,
         `Primary target species` = targetSpecies) %>%
  rename_with(stringr::str_to_title,-AICc)
#View(out)
write.csv(out, file = file.path(dir,  "model_selection.csv"), row.names = FALSE)

#summary of trips and  percent pos per year
summaries <- cdfwpr %>%
  group_by(year) %>%
  summarise(tripsWithTarget = sum(kept>0),
            tripsWOTarget = sum(kept==0)) %>%
  mutate(totalTrips = tripsWithTarget+tripsWOTarget,
         percentpos = tripsWithTarget/(tripsWithTarget+tripsWOTarget)) 
View(summaries)
write.csv(summaries, 
          file.path(dir,  "percent_pos.csv"),
          row.names=FALSE)

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
