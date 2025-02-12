

## purpose: this script compares the current proposed yelloweye catch time series for OR for the 2025 update 
# to the 2017 assessment time series 

# created by: A. Whitman (ODFW) on 2/12/2025
# updated: A. Whitman on 2/12/2025

rm(list = ls(all = TRUE))
graphics.off()

library(easypackages)
libraries("lattice", "Rmisc", "ggplot2", "tidyr", "reshape2", "readxl", 
          "writexl", "zoo", "RODBC", "splitstackshape",
          "lubridate","plyr","dplyr")

# pull in some data

dir<-file.path("C:/Users/daubleal/OneDrive - Oregon/Desktop/2025 Assesssment Cycle/01_Yelloweye RF")
setwd(dir)

# 2017 
oldcatch<-read.csv("2017_catch time series.csv")
head(oldcatch)

# new commercial 
newcomm<-read.csv("Oregon Commercial landings_457_2023.csv")
head(newcomm)
# new sport 
newrec<-read.csv("Oregon Recreational landings_457_2023.csv")
head(newrec)

### need to add the WA historical catches to the OR commercial time series 

# well I can at least plot the sport catches

# combine into a single dataframe for plotting (adapted from something else, clean up later)
names(oldcatch)
df1<-oldcatch[,c("Year","OR.sport..mt.")]
df2<-newrec[,c("Year","Total_MT")]

df3<-full_join(df1,df2,by = "Year")

df3 <- df3 %>% 
  pivot_longer(!Year,names_to = "assessment", values_to = "catch")

# df3 <- df1 %>%  mutate(Index = 'full (no temp)') %>%
#   bind_rows(df2 %>%
#               mutate(Index = 'temp_index (no month)')) %>%
#   bind_rows(df3 %>% 
#               mutate(Index = 'cdd8')) %>%
#   bind_rows(df4 %>%
#               mutate(Index = 'rolling'))
#df5$Year<-as.factor(df5$Year)

ggplot(df3[df3$Year>1960,],aes(x = Year,y = catch, color = assessment)) + 
  geom_line(aes(group = assessment))+
  geom_point(size = 1.5) +
  labs(y = "Annual catch (MT)", color = "Time Series")+
  theme_bw()+
  scale_color_discrete(labels = c("2017 OR Sport","Proposed 2025 Sport")) +
  theme(panel.border = element_rect(color = "black", fill = NA),
        axis.title.y=element_text(margin=margin(0,10,0,0)),
        axis.title.x = element_blank())
#ggsave("OR sport catch comparison.png",width = 10,height = 5)




