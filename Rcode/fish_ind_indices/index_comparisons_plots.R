dodge_width <- 0.75

library(dplyr)
library(tidyr)
library(r4ss)
library(ggplot2)

# Get inputs from 2017 assessment that will get carried over to this assessment
model_2017_path <- file.path(getwd(), "model", "2017_yelloweye_model_updated_ss3_exe")
inputs <- SS_read(dir = model_2017_path, ss_new = TRUE)

###############
### Indices ###
###############

all_indices_2017 <- inputs$dat$CPUE
all_indices_2017$assessment <- "2017_assessment"

colnames_i <- c("year", "month", "index", "obs", "se_log")

# CA Rec MRFSS dockside CPUE - fleet 3
# I think we just bring over from 2017 assessment, because max year is 1999
CA_REC_MRFSS_index <- inputs$dat$CPUE |>
  filter(index == 3)

# OR Rec MRFSS - fleet 6
# Just bring over from 2017 assessment
OR_REC_MRFSS_index <- inputs$dat$CPUE |>
  filter(index == 6, year < 2000)

# OR ORBS - fleet 6
ORBS_index <- read.csv(file.path(getwd(), "Data", "processed", "ORBS_index_forSS.csv")) |>
  mutate(fleet = 6)
colnames(ORBS_index) <- colnames_i

# WA Rec CPUE - fleet 7
# Just bring over from the 2017 assessment, because max year is 2001
WA_REC_CPUE_index <- inputs$dat$CPUE |>
  filter(index == 7)

# CA onboard CPFV CPUE - fleet 8
# Just bring over from the 2017 assessment, because max year is 1998
CA_CPFV_CPUE_index <- inputs$dat$CPUE |>
  filter(index == 8)

# Oregon onboard Recreational Charter observer CPUE (ORFS) - fleet 9
# From Ali Whitman
ORFS_index <- read.csv(file.path(getwd(), "Data", "processed", "ORFS_index_forSS.csv")) |>
  mutate(
    fleet = 9,
    obs = round(obs, digits = 6),
    logse = round(logse, digits = 6)
  )
colnames(ORFS_index) <- colnames_i

# Triennial survey - fleet 10
tri_index <- inputs$dat$CPUE |>
  filter(index == 10)

# NWFSC ORWA - fleet 11
NWFSC_ORWA <- read.csv(file.path(getwd(), "Data", "processed", "wcgbts_indices", "updated_indices_ORWA_CA_split", "yelloweye_split_42_point_offanisotropy/yelloweye_rockfish/wcgbts", "delta_lognormal", "index", "est_by_area.csv"))
NWFSC_ORWA_index <- NWFSC_ORWA |>
  filter(area == "Coastwide") |>
  select(year, est, se) |>
  mutate(
    Month = 7,
    Fleet = 11
  ) |>
  select(year, Month, Fleet, est, se)
colnames(NWFSC_ORWA_index) <- colnames_i

# IPHC ORWA - fleet 12
IPHC_ORWA <- read.csv(file.path(getwd(), "Data", "processed", "IPHC_index", "IPHC_model_based_index_forSS3.csv"))
IPHC_ORWA_index <- IPHC_ORWA
colnames(IPHC_ORWA_index) <- colnames_i

all_indices <- do.call("rbind", list(
  CA_REC_MRFSS_index,
  OR_REC_MRFSS_index,
  ORBS_index,
  WA_REC_CPUE_index,
  CA_CPFV_CPUE_index,
  ORFS_index,
  tri_index,
  NWFSC_ORWA_index,
  IPHC_ORWA_index
))

#inputs$dat$indices <- all_indices

all_indices_2025 <- all_indices
all_indices_2025$assessment <- "2025_assessment"

all_indices_2017_2025 <- rbind(all_indices_2017, all_indices_2025)


#Plot ORBS
#need to standardize indices with mean of 1 to compare...
tibble(all_indices_2017_2025)%>%
  #filter(year >= 1900)%>% #remove the VAST index (negative years)
  filter(index == 6, year > 2000)%>%
  #mutate(index = "NWFSC")%>% 
  # mutate(obs = obs/exp(lnQ_nwfsc))%>%#NWFSC
  ggplot(aes(x = year, y = obs, col = assessment))+
  geom_point(position = position_dodge(width = dodge_width))+
  geom_errorbar(aes(x = year, ymin = qlnorm(.025,log(obs), sd = se_log) ,  #se in log space so convert
                    ymax = qlnorm(.975,log(obs), sd = se_log) , col = as.factor(assessment)),
                position = position_dodge(width = dodge_width))+
  #ggtitle("NWFSC/WCGBTS")+
  scale_color_manual(values = c("2017_assessment" = "black", "2025_assessment" = "cyan"),
                     labels = c("2017_assessment" = "2017 assessment", "2025_assessment" = "2025 assessment"))+
  labs(color = "Assessment")+
  theme_minimal()

#Plot ORFS
#need to standardize indices with mean of 1 to compare...
tibble(all_indices_2017_2025)%>%
  #filter(year >= 1900)%>% #remove the VAST index (negative years)
  filter(index == 9)%>%
  #mutate(index = "NWFSC")%>% 
  # mutate(obs = obs/exp(lnQ_nwfsc))%>%#NWFSC
  ggplot(aes(x = year, y = obs, col = assessment))+
  geom_point(position = position_dodge(width = dodge_width))+
  geom_errorbar(aes(x = year, ymin = qlnorm(.025,log(obs), sd = se_log) ,  #se in log space so convert
                    ymax = qlnorm(.975,log(obs), sd = se_log) , col = as.factor(assessment)),
                position = position_dodge(width = dodge_width))+
  #ggtitle("NWFSC/WCGBTS")+
  scale_color_manual(values = c("2017_assessment" = "black", "2025_assessment" = "cyan"),
                     labels = c("2017_assessment" = "2017 assessment", "2025_assessment" = "2025 assessment"))+
  labs(color = "Assessment")+
  theme_minimal()



#Plot WCGBTS
tibble(all_indices_2017_2025)%>%
  #filter(year >= 1900)%>% #remove the VAST index (negative years)
  filter(index == 11)%>%
  #mutate(index = "NWFSC")%>% 
  # mutate(obs = obs/exp(lnQ_nwfsc))%>%#NWFSC
  ggplot(aes(x = year, y = obs, col = assessment))+
  geom_point(position = position_dodge(width = dodge_width))+
  geom_errorbar(aes(x = year, ymin = qlnorm(.025,log(obs), sd = se_log) ,  #se in log space so convert
                    ymax = qlnorm(.975,log(obs), sd = se_log) , col = as.factor(assessment)),
                position = position_dodge(width = dodge_width))+
  #ggtitle("NWFSC/WCGBTS")+
  scale_color_manual(values = c("2017_assessment" = "black", "2025_assessment" = "cyan"),
                     labels = c("2017_assessment" = "2017 assessment", "2025_assessment" = "2025 assessment"))+
  labs(color = "Assessment")+
  theme_minimal()

#Plot IPHC
tibble(all_indices_2017_2025)%>%
  #filter(year >= 1900)%>% #remove the VAST index (negative years)
  filter(index == 12)%>%
  #mutate(index = "NWFSC")%>% 
  # mutate(obs = obs/exp(lnQ_nwfsc))%>%#NWFSC
  ggplot(aes(x = year, y = obs, col = assessment))+
  geom_point(position = position_dodge(width = dodge_width))+
  geom_errorbar(aes(x = year, ymin = (obs - 1.96 * se_log) ,  #se in log space so convert
                    ymax =  (obs + 1.96 * se_log), col = as.factor(assessment)),
                position = position_dodge(width = dodge_width))+
  scale_color_manual(values = c("2017_assessment" = "black", "2025_assessment" = "cyan"),
                     labels = c("2017_assessment" = "2017 assessment", "2025_assessment" = "2025 assessment"))+
  labs(color = "Assessment")+
  theme_minimal()



#Plot IPHC with 2017 standardized and centered at 0


IPHC_2017 <- all_indices_2017_2025 %>%
  dplyr::filter(index == 12 & assessment == "2017_assessment")

IPHC_2017_standardized <- IPHC_2017 %>%
  mutate(
    obs = (obs - mean(obs))/ sd(obs),
    se_log = se_log /sd(obs)
  )

IPHC_2025 <- all_indices_2017_2025 %>%
  dplyr::filter(index == 12 & assessment == "2025_assessment")

IPHC_2017_2025 <- rbind(IPHC_2017_standardized, IPHC_2025)

tibble(IPHC_2017_2025)%>%
  #filter(year >= 1900)%>% #remove the VAST index (negative years)
  filter(index == 12)%>%
  #mutate(index = "NWFSC")%>% 
  # mutate(obs = obs/exp(lnQ_nwfsc))%>%#NWFSC
  ggplot(aes(x = year, y = obs, col = assessment))+
  geom_point(position = position_dodge(width = dodge_width))+
  geom_errorbar(aes(x = year, ymin = (obs - 1.96 * se_log) ,  #se in log space so convert
                    ymax =  (obs + 1.96 * se_log), col = as.factor(assessment)),
                position = position_dodge(width = dodge_width))+
  scale_color_manual(values = c("2017_assessment" = "black", "2025_assessment" = "cyan"),
                     labels = c("2017_assessment" = "2017 assessment", "2025_assessment" = "2025 assessment"))+
  labs(color = "Assessment")+
  theme_minimal()

