library(reshape2)
library(here)
library(dplyr)
library(ggplot2)
library(nwfscDeltaGLM) 
library(rstan)
library(ggmcmc)
library(ggpubr)

# Read-in data -----------------------------------------------------------------
data_directory  = paste0(here::here(), "/Data/raw/IPHC_survey_1998_2024.csv")
IPHC_data       = read.csv(data_directory, header=TRUE)
data_directory2 = paste0(here::here(), "/Data/raw/set_data.csv")
set_data        = read.csv(data_directory2,header=TRUE)

# Left-join data from set data -------------------------------------------------
# Recover information on Depth, Latitude, and Vessels
# Joins by "Stlkey" identifier
IPHC_data = IPHC_data %>%
  left_join(set_data %>% select(Stlkey, MidLat.fished, Vessel.code, AvgDepth..fm.,Effective.skates.hauled, Avg.no..hook.skate))


# Filter out other species -----------------------------------------------------
IPHC_data = IPHC_data %>%
  filter(Species.Name == "Yelloweye Rockfish")

# Remove stations as per Jason Cope's code -------------------------------------
#Why are these stations removed??
IPHC_data = subset(
  IPHC_data,
  Station %in% c(1010,1020,1024,1027,1082,1084,1528:1531,1533,1534)
)

# Label states -----------------------------------------------------------------
IPHC_data$State = "OR"
IPHC_data$State[IPHC_data$Station > 1027] = "WA"

# Calculate design-based index -------------------------------------------------

# 1. Calculate CPUE for each tow 
## CPUE is in individuals/hook
#IPHC_data$CPUE = IPHC_data$Number.Observed / (as.numeric(IPHC_data$HooksObserved) / IPHC_data$Effective.skates.hauled)
IPHC_data$CPUE = IPHC_data$Number.Observed / as.numeric(IPHC_data$HooksObserved) * IPHC_data$Avg.no..hook.skate
#IPHC_data$CPUE = IPHC_data$Number.Observed / as.numeric(IPHC_data$HooksObserved)

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

figure_diretory = file.path(here::here(), "Rcode", "fish_dep_indices", "IPHC")
ggsave("exploratory_plots_IPHC_hook_and_line.pdf", width = 6, height = 8.2, path = figure_diretory)

# 2. Calculate average CPUE in stratum (station)
## This calculates average yearly CPUE for OR and WA across stations, sets, and vessels
IPHC_data_sum = 
  IPHC_data %>%
  group_by(Year) %>%
  summarise(mean_CPUE = mean(CPUE, na.rm = TRUE),
            sd        = sd(CPUE, na.rm = TRUE),
            se        = sd/sqrt(n()),
            n         = n())

IPHC_data_sum = IPHC_data_sum[-c(1),] # remove 1999

# 3. Plot index
IPHC_data_sum %>%
  ggplot(aes(x = Year, y = mean_CPUE)) +
  geom_line() +
  geom_point() +
  geom_errorbar(aes(ymin = mean_CPUE - se, ymax = mean_CPUE + se), width = 0.1) +
  theme_minimal() + 
  ylab("CPUE (ind./hook)")

ggsave("design_based_index.pdf", width = 7.7, height = 4, path = figure_diretory)

# 4. Export index file
write.csv(IPHC_data_sum[,c(1,2,4)], file.path(here::here(), "Data", "processed", "IPHC_design_based.csv"))

# Model-based index (detalGLMM) ------------------------------------------------
# This is an attempt at running the model via Stan since I could not figure out the
# exact data formatting for the nwfscDeltaGLM package

# 1.Organize data 
IPHC_data_glm = data.frame(IPHC_data$CPUE, IPHC_data$Year, IPHC_data$Station,
                           IPHC_data$Vessel.code, IPHC_data$AvgDepth..fm.)
names(IPHC_data_glm) = c("CPUE", "Year", "Station", "Vessel", "Depth")
IPHC_data_glm$Detect = ifelse(IPHC_data_glm$CPUE == 0, 0, 1)

data_list = list(
  CPUE    = log(IPHC_data_glm$CPUE+1),
  Detect  = IPHC_data_glm$Detect,
  year    = as.numeric(as.factor(IPHC_data_glm$Year)),
  station = as.numeric(as.factor(IPHC_data_glm$Station)),
  vessel  = as.numeric(as.factor(IPHC_data_glm$Vessel)),
  depth   = as.numeric(IPHC_data_glm$Depth),
  N       = dim(IPHC_data_glm)[1],                                        # number of data points
  SS      = length(unique(as.numeric(as.factor(IPHC_data_glm$Station)))), # number of stations
  N_years = length(unique(as.numeric(as.factor(IPHC_data_glm$Year)))),    # number of years
  V       = length(unique(as.numeric(as.factor(IPHC_data_glm$Vessel))))   # number of vessels
)

# 2.Run deltaGLM
model_directory = paste0(here::here(), "/Rcode", "/stan_files", "/deltaGLMM.stan")
stanc(model_directory)

# the model needs quite a few iterations due to random effects
out = stan(file   = model_directory,
           data   = data_list,
           warmup = 1000,
           iter   = 3000,
           chains = 2)

# 3. Extract random effects from model
RE = out %>%
  ggs() %>%
  filter(grepl("Y", Parameter)) %>%
  group_by(Parameter) %>%
  summarise(mean = mean(value),
            sd   = sd(value)) %>%
  slice(-(data_list$N_years+1:46)) %>%
  mutate(Year = 2001:2023)
  
names(RE) = c("Par", "mean", "sd", "Year", "mean_CPUE", "se")

RE = RE[-c(20),] # remove 2020

RE$adj_CPUE = IPHC_data_sum$mean_CPUE + RE$mean
RE$se = IPHC_data_sum$se


RE %>%
  ggplot(aes(x = Year, y = adj_CPUE)) +
  geom_line() +
  geom_point() +
  geom_errorbar(aes(x = Year, ymin = adj_CPUE - se, ymax = adj_CPUE + se), width = 0.1) +
  theme_minimal() +
  ylab("Index")

ggsave("glm_normal_index.pdf", width = 7.7, height = 4, path = figure_diretory)
write.csv(RE[,c(4,5,6)], file.path(here::here(), "Data", "processed", "IPHC_normal_glm.csv"))

# Compare the two indices
RE = RE[,c(4,5,6)] %>% mutate(type = "Normal Delta GLM")
names(RE) = c("year", "index", "se", "type")

IPHC_data_sum = IPHC_data_sum[,c(1,2,4)] %>% mutate(type = "Design-based")
names(IPHC_data_sum) = c("year", "index", "se", "type")

df = rbind(RE, IPHC_data_sum)

df %>%
  ggplot(aes(x = year, y = index, color = type)) +
  geom_line(position=position_dodge(width = .25)) +
  geom_point(position=position_dodge(width = .25)) +
  geom_errorbar(aes(x = year, ymin = index - se, ymax = index + se),
                width = 0.1,
                position=position_dodge(width = .25)) +
  theme_minimal() +
  theme(legend.title = element_blank(),
        legend.position = "top") +
  ylab("Index") + xlab("Year")
 
ggsave("index_comparison.pdf", width = 7.7, height = 4, path = figure_diretory)

# Format index for SS3 .dat file
model_based_index = df %>%
  filter(type == "Normal Delta GLM") %>%
  select(year, index, se) 
model_based_index = model_based_index[-c(1),]

index_df = data.frame(
  year = model_based_index$year,
  month = rep(7, dim(model_based_index)[1]),
  fleet = rep(12, dim(model_based_index)[1]),
  obs = model_based_index$index,
  se = model_based_index$se
)





