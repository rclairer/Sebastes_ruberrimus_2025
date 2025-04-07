library(reshape2)
library(here)
library(dplyr)
library(ggplot2)
library(nwfscDeltaGLM) 
library(rstan)
library(ggmcmc)
library(ggpubr)
library(MASS)
library(MuMIn)
library(sdmTMB)
library(r4ss)

# Read-in data -----------------------------------------------------------------
data_directory  = paste0(here::here(), "/Data/raw/nonconfidential/IPHC_survey_1998_2024.csv")
IPHC_data       = read.csv(data_directory, header=TRUE)
data_directory2 = paste0(here::here(), "/Data/raw/nonconfidential/set_data.csv")
set_data        = read.csv(data_directory2,header=TRUE)

# Left-join data from set data -------------------------------------------------
# Recover information on Depth, Latitude, and Vessels
# Joins by "Stlkey" identifier
IPHC_data = IPHC_data %>%
  left_join(set_data %>% dplyr::select(Stlkey, MidLat.fished, Vessel.code, AvgDepth..fm., Effective.skates.hauled, Avg.no..hook.skate))

# Filter out other species -----------------------------------------------------
IPHC_data = IPHC_data %>%
  filter(Species.Name == "Yelloweye Rockfish")

# Remove stations as per 2017 assessment ---------------------------------------
IPHC_data = subset(
  IPHC_data,
  Station %in% c(1010,1020,1024,1027,1082,1084,1528:1531,1533,1534)
)

# Label states -----------------------------------------------------------------
IPHC_data$State = "OR"
IPHC_data$State[IPHC_data$Station > 1027] = "WA"

# Label years ------------------------------------------------------------------
IPHC_data$Year = substr(as.character(IPHC_data$Stlkey), 1, 4)
# Calculate design-based index -------------------------------------------------

#1. Calculate CPUE for each tow
IPHC_data$Effort = ifelse(IPHC_data$Year < 2013 & IPHC_data$Year > 2019,
                          as.numeric(IPHC_data$HooksObserved) / IPHC_data$Avg.no..hook.skate,
                          as.numeric(IPHC_data$HooksObserved) / ((IPHC_data$Avg.no..hook.skate*4)/3) )

# IPHC_data$Effort = IPHC_data$Effective.skates.hauled

IPHC_data$CPUE   = IPHC_data$Number.Observed / IPHC_data$Effort

IPHC_data = IPHC_data %>% filter(Effort != 0)

# Exploratory plots 
station_plot = IPHC_data %>%
  ggplot(aes(x = as.factor(Station), y = CPUE)) +
  geom_boxplot() +
  ylim(0,20) +
  theme_minimal() +
  ylab("") +
  xlab("Station")

vessel_plot = IPHC_data %>%
  ggplot(aes(x = as.factor(Vessel.code), y = CPUE)) +
  geom_boxplot() +
  ylim(0,20) +
  theme_minimal() +
  ylab("CPUE (ind./hook)") +
  xlab("Vessel")

depth_plot = IPHC_data %>%
  ggplot(aes(x = AvgDepth..fm., y = CPUE)) +
  geom_point() +
  theme_minimal() +
  ylab("") +
  xlab("Depth (m)")


ggarrange(station_plot, vessel_plot, depth_plot, ncol = 1)

figure_diretory = file.path(here::here(), "Rcode", "fish_dep_indices", "IPHC", "Figures")
ggsave("exploratory_plots_IPHC_hook_and_line.pdf", width = 6, height = 8.2, path = figure_diretory)

# 2. Calculate average CPUE in stratum (station)
## This calculates average yearly CPUE for OR and WA across stations, sets, and vessels
IPHC_data_sum = 
  IPHC_data %>%
  group_by(Year) %>%
  dplyr::summarise(mean_CPUE = mean(CPUE, na.rm = TRUE),
                   sd        = sd(CPUE, na.rm = TRUE),
                   se        = sd/sqrt(n()),
                   n         = n())

IPHC_data_sum = IPHC_data_sum[-c(1, 2),] # remove 1999 and 2001

# 3. Plot index
index_design = IPHC_data_sum %>%
  ggplot(aes(x = as.numeric(Year), y = mean_CPUE)) +
  geom_line() +
  geom_point() +
  geom_errorbar(aes(ymin = mean_CPUE - se, ymax = mean_CPUE + se), width = 0.1) +
  theme_minimal() + 
  ylab("CPUE (ind./set)") +
  xlab("Year")

ggsave("design_based_index.pdf", width = 7.7, height = 4, path = figure_diretory)

# 4. Export index file
write.csv(IPHC_data_sum[,c(1,2,4)], file.path(here::here(), "Data", "processed", "IPHC_index", "IPHC_design_based.csv"))

# Model-based index ------------------------------------------------------------
IPHC_data_glm = data.frame(IPHC_data$CPUE, IPHC_data$Number.Observed, IPHC_data$Year, 
                           IPHC_data$Station, IPHC_data$Vessel.code, IPHC_data$AvgDepth..fm.,
                           IPHC_data$Effort)
names(IPHC_data_glm) = c("CPUE", "Count", "Year", "Station", "Vessel", "Depth", "Effort")


constant = 1e-10 # to avoid NaNs in log-transformations

IPHC_data_glm$Year       = as.numeric(as.factor(IPHC_data_glm$Year))
IPHC_data_glm$Station    = as.numeric(as.factor(IPHC_data_glm$Station))
IPHC_data_glm$Vessel     = as.numeric(as.factor(IPHC_data_glm$Vessel))
IPHC_data_glm$log_Effort = log(IPHC_data_glm$Effort + constant)

IPHC_data_glm = na.exclude(IPHC_data_glm)

# FULL MODEL
full_model = MASS::glm.nb(
  
  CPUE ~ Year + Station + Vessel + Depth + offset(log(Effort)),
  data = IPHC_data_glm,
  na.action = "na.fail"
  
)
summary(full_model)
anova(full_model)

# MODEL SELECTION
model_suite = MuMIn::dredge(full_model,   
                            rank = "AICc",
                            fixed = c("offset(log(Effort))"))

model_selection = as.data.frame(model_suite) %>% dplyr::select(-weight)

# filter out zeros in CPUE column
IPHC_data_glm = IPHC_data_glm %>% filter(CPUE != 0)

fit = sdmTMB(
  CPUE ~ Year + Station + Depth,
  data           = IPHC_data_glm,
  #  offset         = log(IPHC_data_glm$Effort + constant),
  time           = "Year",
  spatial        = "off",
  spatiotemporal = "off",
  family         = lognormal(link = "log"),#= nbinom1(link = "log"),
  control        = sdmTMBcontrol(newton_loops = 1)
)

sanity(fit) # model looks OK

# extract predictions
preds = predict(fit, return_tmb_object = TRUE, newdata = IPHC_data_glm, offset = log(IPHC_data_glm$CPUE + constant))

# get index file
index = get_index(preds, bias_correct = TRUE)

#index = index[-c(1),]
mu1 = mean(index$est) # sdm tmb
sd1 = sd(index$est)   # sdm tmb
mu2 = mean(IPHC_data_sum$mean_CPUE) # design-based
sd2 = sd(IPHC_data_sum$mean_CPUE)   # design-based

logNormal = data.frame(
  year  =  IPHC_data_sum$Year,
  index = ((index$est - mu1) / sd1) [-c(1,2)],
  se    = index$se[-c(1,2)],
  model = rep("logNormal", dim(index)[1]-2)
)

designBased = data.frame(
  year  =  IPHC_data_sum$Year,
  index = (IPHC_data_sum$mean_CPUE - mu2) / sd2,
  se    = IPHC_data_sum$se/sd2,
  model = rep("designBased", dim(IPHC_data_sum)[1])
)


scaled_index = rbind(logNormal, designBased)

scaled_index %>%
  ggplot(aes(x = as.numeric(year), y = index, color = model)) +
  geom_point(position=position_dodge(width = 0.5)) +
  geom_errorbar(aes(x    = as.numeric(year),
                    ymin = index - 2*se,
                    ymax = index + 2*se),
                width = 0.1,
                position=position_dodge(width = 0.5)) +
  theme_bw() +
  xlab("Year") + ylab("Scaled index")


# Format index for SS3 .dat file
index_df = data.frame(
  year = logNormal$year,
  month = rep(7, dim(logNormal)[1]),
  fleet = rep(12, dim(logNormal)[1]),
  obs = logNormal$index,
  se = logNormal$se
)

write.csv(index_df, file.path(here::here(), "Data", "processed", "IPHC_index", "IPHC_model_based_index_forSS3_SCALED.csv"), row.names = FALSE)

# unscaled index for use in assessment
index_df$obs = index_df$obs * sd1 + mu1
index_df$se = index_df$se * sd1

index_df %>%
  ggplot(aes(x = as.numeric(year), y = obs)) +
  geom_point(position=position_dodge(width = 0.5)) +
  geom_errorbar(aes(x    = as.numeric(year),
                    ymin = obs - 2*se,
                    ymax = obs + 2*se),
                width = 0.1,
                position=position_dodge(width = 0.5)) +
  geom_line()

write.csv(index_df, file.path(here::here(), "Data", "processed", "IPHC_index", "IPHC_model_based_index_forSS3_UNSCALED.csv"), row.names = FALSE)

# Compare with 2017 index ------------------------------------------------------

model_2017_path = file.path(here::here(), "model", "2017_yelloweye_model_updated_ss3_exe")
inputs          = SS_read(dir = model_2017_path, ss_new = TRUE)

index_2017     = inputs$dat$CPUE %>% filter(index == 12) %>% mutate(Assessment = "2017")
index_2017$obs = (index_2017$obs - mean(index_2017$obs)) / sd(index_2017$obs) # scale index

index_df   = index_df %>% mutate(Assessment = "2025")
colnames(index_2017) = colnames(index_df)

all_indexes = rbind(index_df, index_2017)

all_indexes %>% 
  ggplot(aes(x = as.numeric(year), y = obs, color = Assessment)) +
  #  geom_line() +
  geom_point(position=position_dodge(width = 0.5)) +
  geom_errorbar(aes(x    = as.numeric(year),
                    ymin = obs - 1.96*se,
                    ymax = obs + 1.96*se),
                width = 0.1,
                position=position_dodge(width = 0.5)) +
  theme_minimal() +
  xlab("Year") +
  ylab("Scaled index")

ggsave("scaled_index_comp.pdf", width = 7.7, height = 4, path = figure_diretory)














