library(reshape2)

data_directory = file.path(here::here(), "Data", "raw", "nonconfidential")
IPHC.dat<-read.csv(file.path(data_directory, "IPHC_CPUE.csv"),header=TRUE)

function_directory = file.path(here::here(), "Rcode", "fish_dep_indices", "IPHC", "Code", "IPHC_utilities.r")
source(function_directory)

#Add depth bins
IPHC.dat$DEPTH_MAX_M<-IPHC.dat$`Max depth (fm)`*1.8288
#Remove depths >185
IPHC.dat.depths<-subset(IPHC.dat,DEPTH_MAX_M<185)
IPHCdepth_bins<-pretty(IPHC.dat.depths$DEPTH_MAX_M,n=10)
IPHCdepth_bins_ind<-.bincode(IPHC.dat.depths$DEPTH_MAX_M,IPHCdepth_bins)
IPHC.dat.depths$DEP_M_BINS<-IPHCdepth_bins[IPHCdepth_bins_ind]
IPHC.dat.depths<-subset(IPHC.dat.depths,DEP_M_BINS %in% c(100,120,140))

#Remove Stations
IPHC.dat.depths.stations<-subset(IPHC.dat.depths,Station %in% c(1010,1020,1024,1027,1082,1084,1528:1531,1533,1534))
#Label States
IPHC.dat.depths.stations$State<-"OR"
IPHC.dat.depths.stations$State[IPHC.dat.depths.stations$Station>1027]<-"WA"

#Checks each factor for presence of yelloweye
obj.in<-IPHC.dat.depths.stations
dcast(obj.in,SurveyYear~Station,sum,na.rm=T,value.var = "Yelloweye Rockfish")
dim(obj.in)[1]
sum(dcast(obj.in,1~SurveyYear,sum,na.rm=T,value.var = "Yelloweye Rockfish"))
sum(table(obj.in$`Yelloweye Rockfish`)[-1])
sum(table(obj.in$`Yelloweye Rockfish`)[-1])/dim(obj.in)[1]


cbind(
  c(
    dim(IPHC.dat)[1],
    dim(IPHC.dat.depths)[1],
    dim(IPHC.dat.depths.stations)[1]  ),
  c(
    sum(table(IPHC.dat$`Yelloweye Rockfish`)[-1]),
    sum(table(IPHC.dat.depths$`Yelloweye Rockfish`)[-1]),
    sum(table(IPHC.dat.depths.stations$`Yelloweye Rockfish`)[-1]))
)


#FINISHED DATA PREP
################

#################
### delat-GLM ###
#################
library(plyr) #colwise

#Add CPUE
IPHC.dat.depths.stations$CPUE<-IPHC.dat.depths.stations$`Yelloweye Rockfish`/IPHC.dat.depths.stations$`Skates hauled (100 hk/skt)`
#Combine depths 120 and 140
IPHC.dat.depths.stations$DEPTH_CATS<-IPHC.dat.depths.stations$DEP_M_BINS
IPHC.dat.depths.stations$DEPTH_CATS[IPHC.dat.depths.stations$DEP_M_BINS>100]<-120
#CPUE~SurveyYear+State+DEPTH_CATS
IPHC.dat.glm<-IPHC.dat.depths.stations[,c(105,1,104,106)] 


# runs until this point -------------------



#Convert to factors
IPHC.dat.glm[,2:ncol(IPHC.dat.glm)]<-colwise(as.factor)(IPHC.dat.glm[,2:ncol(IPHC.dat.glm)])


deltaglmselect.EJ(IPHC.dat.glm[,c(1:2)],"IPHC_Model_Select")
deltaglmselect.EJ(IPHC.dat.glm[,c(1:3)],"IPHC_Model_Select")
deltaglmselect.EJ(IPHC.dat.glm[,c(1:2,4)],"IPHC_Model_Select")
deltaglmselect.EJ(IPHC.dat.glm[,c(1:4)],"IPHC_Model_Select")


#OR only
IPHC.dat.glm.OR<-subset(IPHC.dat.glm,State=="OR")
dcast(IPHC.dat.glm.OR,SurveyYear~DEPTH_CATS,sum,na.rm=T,value.var = "CPUE")
IPHC.dat.glm.OR<-IPHC.dat.glm.OR[,c(1,2,4)]
#deltaglmselect.EJ(IPHC.dat.glm.OR[,c(1:2)],"IPHC_Model_Select_OR")
#deltaglmselect.EJ(IPHC.dat.glm.OR[,c(1:3)],"IPHC_Model_Select_OR")


IPHC.dat.glm.WA<-subset(IPHC.dat.glm,State=="WA")
dcast(IPHC.dat.glm.WA,SurveyYear~DEPTH_CATS,sum,na.rm=T,value.var = "CPUE")
IPHC.dat.glm.WA<-IPHC.dat.glm.WA[,c(1,2,4)]
#deltaglmselect.EJ(IPHC.dat.glm.WA[,c(1:2)],"IPHC_Model_Select_WA")
#deltaglmselect.EJ(IPHC.dat.glm.WA[,c(1:3)],"IPHC_Model_Select_WA")

#Run deltaGLM
IPHC.dat.glm.log.jack<-CPUEanalysis.EJ(IPHC.dat.glm,0,length(unique(IPHC.dat.glm$SurveyYear)),0,plotting=1, plotID='CPUE',J.in=TRUE)
IPHC.dat.glm.OR.log.jack<-CPUEanalysis.EJ(IPHC.dat.glm.OR[,c(1:2)],0,length(unique(IPHC.dat.glm.OR$SurveyYear)),1,plotting=1, plotID='CPUE',J.in=FALSE)
IPHC.dat.glm.WA.log.jack<-CPUEanalysis.EJ(IPHC.dat.glm.WA[,c(1:2)],0,length(unique(IPHC.dat.glm.WA$SurveyYear)),1,plotting=1, plotID='CPUE',J.in=FALSE)
save(IPHC.dat.glm.log.jack,file="IPHC_dat_glm_log_jack.DMP")
save(IPHC.dat.glm,file="IPHC_dat_glm.DMP")
save(IPHC.dat.depths.stations,file="IPHC_dat_depths_stations.DMP")


IPHC.index.plot<-read.table('clipboard',header=TRUE)
ggplot(IPHC.index.plot,aes(Year,Index,color=Type))+geom_line(lwd=1.5)+geom_point(size=4)

  

