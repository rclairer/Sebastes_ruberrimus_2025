#C Yelloweye 2017 control file
#C file created using an r4ss function
#C file write time: 2025-05-13  04:51:43
#
0 # 0 means do not read wtatage.ss; 1 means read and usewtatage.ss and also read and use growth parameters
1 #_N_Growth_Patterns
1 #_N_platoons_Within_GrowthPattern
2 # recr_dist_method for parameters
1 # not yet implemented; Future usage:Spawner-Recruitment; 1=global; 2=by area
2 # number of recruitment settlement assignments 
0 # unused option
# for each settlement assignment:
#_GPattern	month	area	age
1	1	1	0	#_recr_dist_pattern1
1	1	2	0	#_recr_dist_pattern2
#
0 #_N_movement_definitions goes here if N_areas > 1
4 #_Nblock_Patterns
1 1 1 1 #_blocks_per_pattern
#_begin and end years of blocks
1992 2004
2005 2024
2002 2024
2002 2024
#
# controls for all timevary parameters 
1 #_env/block/dev_adjust_method for all time-vary parms (1=warn relative to base parm bounds; 3=no bound check)
#
# AUTOGEN
1 1 1 1 1 # autogen: 1st element for biology, 2nd for SR, 3rd for Q, 4th reserved, 5th for selex
# where: 0 = autogen all time-varying parms; 1 = read each time-varying parm line; 2 = read then autogen if parm min==-12345
#
# setup for M, growth, maturity, fecundity, recruitment distibution, movement
#
1 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate;_5=Maunder_M;_6=Age-range_Lorenzen
1 #_N_breakpoints
4 # age(real) at M breakpoints
1 # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_specific_K_incr; 4=age_specific_K_decr;5=age_specific_K_each; 6=NA; 7=NA; 8=growth cessation
0 #_Age(post-settlement)_for_L1;linear growth below this
70 #_Growth_Age_for_L2 (999 to use as Linf)
-999 #_exponential decay for growth above maxage (value should approx initial Z; -999 replicates 3.24; -998 to not allow growth above maxage)
0 #_placeholder for future growth feature
#
0 #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)
0 #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
1 #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity matrix by growth_pattern; 4=read age-fecundity; 5=disabled; 6=read length-maturity
2 #_First_Mature_Age
2 #_fecundity option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
0 #_hermaphroditism option:  0=none; 1=female-to-male age-specific fxn; -1=male-to-female age-specific fxn
1 #_parameter_offset_approach (1=none, 2= M, G, CV_G as offset from female-GP1, 3=like SS2 V1.x)
#
#_growth_parms
#_LO	HI	INIT	PRIOR	PR_SD	PR_type	PHASE	env_var&link	dev_link	dev_minyr	dev_maxyr	dev_PH	Block	Block_Fxn
 0.01	    0.15	  0.0439034	   -3.12576	0.31	0	 -1	0	0	0	0	0	0	0	#_NatM_p_1_Fem_GP_1  
 0.01	      35	   0.877821	         30	  99	0	  2	0	0	0	0	0	0	0	#_L_at_Amin_Fem_GP_1 
   40	     120	     61.847	         66	  99	0	  2	0	0	0	0	0	0	0	#_L_at_Amax_Fem_GP_1 
 0.01	     0.2	  0.0761208	       0.05	  99	0	  1	0	0	0	0	0	0	0	#_VonBert_K_Fem_GP_1 
 0.01	     0.5	   0.150278	        0.1	  99	0	  3	0	0	0	0	0	0	0	#_CV_young_Fem_GP_1  
 0.01	     0.5	  0.0616582	        0.1	  99	0	  7	0	0	0	0	0	0	0	#_CV_old_Fem_GP_1    
   -3	       3	7.18331e-06	7.18331e-06	  99	0	-50	0	0	0	0	0	0	0	#_Wtlen_1_Fem_GP_1   
   -3	       4	     3.2448	     3.2448	  99	0	-50	0	0	0	0	0	0	0	#_Wtlen_2_Fem_GP_1   
   38	      45	    42.0705	     41.765	  99	0	-50	0	0	0	0	0	0	0	#_Mat50%_Fem_GP_1    
   -3	       3	  -0.402214	   -0.36886	  99	0	-50	0	0	0	0	0	0	0	#_Mat_slope_Fem_GP_1 
   -3	   3e+05	7.21847e-08	7.21847e-08	   1	0	 -6	0	0	0	0	0	0	0	#_Eggs_alpha_Fem_GP_1
   -3	   39000	      4.043	      4.043	   1	0	 -6	0	0	0	0	0	0	0	#_Eggs_beta_Fem_GP_1 
    0	       2	          1	          1	  99	0	-50	0	0	0	0	0	0	0	#_RecrDist_GP_1      
   -4	       4	          0	          0	  99	0	-50	0	0	0	0	0	0	0	#_RecrDist_Area_1    
   -4	       4	   0.420491	          0	  99	0	  3	0	0	0	0	0	0	0	#_RecrDist_Area_2    
    0	       2	          1	          1	  99	0	-50	0	0	0	0	0	0	0	#_RecrDist_month_1   
    0	       2	          1	          1	  99	0	-50	0	0	0	0	0	0	0	#_CohortGrowDev      
1e-06	0.999999	        0.5	        0.5	 0.5	0	-99	0	0	0	0	0	0	0	#_FracFemale_GP_1    
#_no timevary MG parameters
#
#_seasonal_effects_on_biology_parms
0 0 0 0 0 0 0 0 0 0 #_femwtlen1,femwtlen2,mat1,mat2,fec1,fec2,Malewtlen1,malewtlen2,L1,K
#_ LO HI INIT PRIOR PR_SD PR_type PHASE
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no seasonal MG parameters
#
3 #_Spawner-Recruitment; 2=Ricker; 3=std_B-H; 4=SCAA;5=Hockey; 6=B-H_flattop; 7=survival_3Parm;8=Shepard_3Parm
0 # 0/1 to use steepness in initial equ recruitment calculation
0 # future feature: 0/1 to make realized sigmaR a function of SR curvature
#_LO	HI	INIT	PRIOR	PR_SD	PR_type	PHASE	env-var	use_dev	dev_mnyr	dev_mxyr	dev_PH	Block	Blk_Fxn # parm_name
  3	15	5.39184	    5	   99	0	  3	0	0	0	0	0	0	0	#_SR_LN(R0)  
0.2	 1	  0.718	0.718	0.158	0	 -3	0	0	0	0	0	0	0	#_SR_BH_steep
  0	 5	    0.5	  0.5	   99	0	 -2	0	0	0	0	0	0	0	#_SR_sigmaR  
 -5	 5	      0	    0	   99	0	-50	0	0	0	0	0	0	0	#_SR_regime  
 -1	 2	      0	    1	   99	0	-50	0	0	0	0	0	0	0	#_SR_autocorr
#_no timevary SR parameters
1 #do_recdev:  0=none; 1=devvector (R=F(SSB)+dev); 2=deviations (R=F(SSB)+dev); 3=deviations (R=R0*dev; dev2=R-f(SSB)); 4=like 3 with sum(dev2) adding penalty
1980 # first year of main recr_devs; early devs can preceed this era
2023 # last year of main recr_devs; forecast devs start in following year
7 #_recdev phase
1 # (0/1) to read 13 advanced options
1889 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
7 #_recdev_early_phase
0 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
1 #_lambda for Fcast_recr_like occurring before endyr+1
1927.52 #_last_yr_nobias_adj_in_MPD; begin of ramp
2011 #_first_yr_fullbias_adj_in_MPD; begin of plateau
2014.98 #_last_yr_fullbias_adj_in_MPD
2021.96 #_end_yr_for_ramp_in_MPD (can be in forecast to shape ramp, but SS sets bias_adj to 0.0 for fcast yrs)
0.6373 #_max_bias_adj_in_MPD (-1 to override ramp and set biasadj=1.0 for all estimated recdevs)
0 #_period of cycles in recruitment (N parms read below)
-5 #min rec_dev
5 #max rec_dev
0 #_read_recdevs
#_end of advanced SR options
#
#_placeholder for full parameter lines for recruitment cycles
# read specified recr devs
#_Yr Input_value
#
#Fishing Mortality info
0.09 # F ballpark
1999 # F ballpark year (neg value to disable)
1 # F_Method:  1=Pope; 2=instan. F; 3=hybrid (hybrid is recommended)
0.9 # max F or harvest rate, depends on F_Method
#
#_initial_F_parms; count = 0
#
#_Q_setup for fleets with cpue or survey data
#_fleet	link	link_info	extra_se	biasadj	float  #  fleetname
    3	1	0	1	0	1	#_3_CA_REC     
    6	1	0	1	0	1	#_6_OR_REC     
    7	1	0	1	0	1	#_7_WA_REC     
    8	1	0	1	0	1	#_8_CACPFV     
    9	1	0	1	0	1	#_9_OR_RECOB   
   10	1	0	1	0	1	#_10_TRI_ORWA  
   11	1	0	1	0	1	#_11_NWFSC_ORWA
   12	1	0	1	0	1	#_12_IPHC_ORWA 
-9999	0	0	0	0	0	#_terminator   
#_Q_parms(if_any);Qunits_are_ln(q)
#_LO	HI	INIT	PRIOR	PR_SD	PR_type	PHASE	env-var	use_dev	dev_mnyr	dev_mxyr	dev_PH	Block	Blk_Fxn  #  parm_name
-15	15	 -9.10244	   0	99	0	-1	0	0	0	0	0	0	0	#_LnQ_base_3_CA_REC(3)       
  0	 5	 0.142048	0.01	99	0	 5	0	0	0	0	0	0	0	#_Q_extraSD_3_CA_REC(3)      
-15	15	 -10.6644	   0	99	0	-1	0	0	0	0	0	2	1	#_LnQ_base_6_OR_REC(6)       
  0	 5	  1.02498	0.01	99	0	 5	0	0	0	0	0	0	0	#_Q_extraSD_6_OR_REC(6)      
-20	15	 -8.66904	   0	99	0	-1	0	0	0	0	0	0	0	#_LnQ_base_7_WA_REC(7)       
  0	 5	 0.449116	0.01	99	0	 5	0	0	0	0	0	0	0	#_Q_extraSD_7_WA_REC(7)      
-15	15	 -9.13637	   0	99	0	-1	0	0	0	0	0	0	0	#_LnQ_base_8_CACPFV(8)       
  0	 5	0.0681269	0.01	99	0	 5	0	0	0	0	0	0	0	#_Q_extraSD_8_CACPFV(8)      
-15	15	 -11.1479	   0	99	0	-1	0	0	0	0	0	0	0	#_LnQ_base_9_OR_RECOB(9)     
  0	 5	 0.169627	0.01	99	0	 5	0	0	0	0	0	0	0	#_Q_extraSD_9_OR_RECOB(9)    
-15	15	 -1.31776	   0	99	0	-1	0	0	0	0	0	0	0	#_LnQ_base_10_TRI_ORWA(10)   
  0	 5	 0.110614	0.01	99	0	 5	0	0	0	0	0	0	0	#_Q_extraSD_10_TRI_ORWA(10)  
-15	15	-0.662781	   0	99	0	-1	0	0	0	0	0	0	0	#_LnQ_base_11_NWFSC_ORWA(11) 
  0	 5	        0	0.01	99	0	-5	0	0	0	0	0	0	0	#_Q_extraSD_11_NWFSC_ORWA(11)
-15	15	-0.330768	   0	99	0	-1	0	0	0	0	0	0	0	#_LnQ_base_12_IPHC_ORWA(12)  
  0	 5	 0.560441	0.01	99	0	 5	0	0	0	0	0	0	0	#_Q_extraSD_12_IPHC_ORWA(12) 
# timevary Q parameters
#_LO	HI	INIT	PRIOR	PR_SD	PR_type	PHASE
-4	4	-0.598246	0	99	-1	1	#_LnQ_base_6_OR_REC(6)_BLK2add_2005
# info on dev vectors created for Q parms are reported with other devs after tag parameter section
#
#_size_selex_patterns
#_Pattern	Discard	Male	Special
24	0	0	0	#_1 1_CA_TWL      
24	0	0	0	#_2 2_CA_NONTWL   
24	0	0	0	#_3 3_CA_REC      
24	0	0	0	#_4 4_ORWA_TWL    
24	0	0	0	#_5 5_ORWA_NONTWL 
24	0	0	0	#_6 6_OR_REC      
24	0	0	0	#_7 7_WA_REC      
15	0	0	3	#_8 8_CACPFV      
24	0	0	0	#_9 9_OR_RECOB    
24	0	0	0	#_10 10_TRI_ORWA  
24	0	0	0	#_11 11_NWFSC_ORWA
24	0	0	0	#_12 12_IPHC_ORWA 
#
#_age_selex_patterns
#_Pattern	Discard	Male	Special
10	0	0	0	#_1 1_CA_TWL      
10	0	0	0	#_2 2_CA_NONTWL   
10	0	0	0	#_3 3_CA_REC      
10	0	0	0	#_4 4_ORWA_TWL    
10	0	0	0	#_5 5_ORWA_NONTWL 
10	0	0	0	#_6 6_OR_REC      
10	0	0	0	#_7 7_WA_REC      
10	0	0	0	#_8 8_CACPFV      
10	0	0	0	#_9 9_OR_RECOB    
10	0	0	0	#_10 10_TRI_ORWA  
10	0	0	0	#_11 11_NWFSC_ORWA
10	0	0	0	#_12 12_IPHC_ORWA 
#
#_SizeSelex
#_LO	HI	INIT	PRIOR	PR_SD	PR_type	PHASE	env-var	use_dev	dev_mnyr	dev_mxyr	dev_PH	Block	Blk_Fxn  #  parm_name
  20	60	44.0769	  40	99	0	 4	0	0	0	0	0	0	0	#_SizeSel_P_1_1_CA_TWL(1)      
 -15	 4	    -15	 -15	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_2_1_CA_TWL(1)      
  -1	 9	5.13226	   6	99	0	 4	0	0	0	0	0	0	0	#_SizeSel_P_3_1_CA_TWL(1)      
  -1	30	18.2973	   9	99	0	 5	0	0	0	0	0	0	0	#_SizeSel_P_4_1_CA_TWL(1)      
-999	 9	   -999	-999	99	0	-4	0	0	0	0	0	0	0	#_SizeSel_P_5_1_CA_TWL(1)      
-999	 9	   -999	   9	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_6_1_CA_TWL(1)      
  20	60	44.5354	  30	99	0	 4	0	0	0	0	0	0	0	#_SizeSel_P_1_2_CA_NONTWL(2)   
 -15	 4	    -15	 -15	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_2_2_CA_NONTWL(2)   
  -1	 9	 5.1918	   6	99	0	 4	0	0	0	0	0	0	0	#_SizeSel_P_3_2_CA_NONTWL(2)   
  -1	30	17.3582	   9	99	0	 5	0	0	0	0	0	0	0	#_SizeSel_P_4_2_CA_NONTWL(2)   
-999	 9	   -999	  -5	99	0	-4	0	0	0	0	0	0	0	#_SizeSel_P_5_2_CA_NONTWL(2)   
-999	 9	   -999	   9	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_6_2_CA_NONTWL(2)   
  20	60	41.8448	  40	99	0	 4	0	0	0	0	0	0	0	#_SizeSel_P_1_3_CA_REC(3)      
 -15	 4	    -15	 -15	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_2_3_CA_REC(3)      
  -1	 9	5.22065	   6	99	0	 4	0	0	0	0	0	0	0	#_SizeSel_P_3_3_CA_REC(3)      
  -1	30	     20	   9	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_4_3_CA_REC(3)      
-999	 9	   -999	  -5	99	0	-4	0	0	0	0	0	0	0	#_SizeSel_P_5_3_CA_REC(3)      
-999	 9	   -999	   9	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_6_3_CA_REC(3)      
  20	60	42.9935	  40	99	0	 4	0	0	0	0	0	0	0	#_SizeSel_P_1_4_ORWA_TWL(4)    
 -15	 4	    -15	 -15	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_2_4_ORWA_TWL(4)    
  -1	 9	5.55383	   6	99	0	 4	0	0	0	0	0	0	0	#_SizeSel_P_3_4_ORWA_TWL(4)    
  -1	30	18.0098	   9	99	0	 5	0	0	0	0	0	0	0	#_SizeSel_P_4_4_ORWA_TWL(4)    
-999	 9	   -999	-999	99	0	-4	0	0	0	0	0	0	0	#_SizeSel_P_5_4_ORWA_TWL(4)    
-999	 9	   -999	   9	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_6_4_ORWA_TWL(4)    
  20	60	51.2558	  30	99	0	 4	0	0	0	0	0	0	0	#_SizeSel_P_1_5_ORWA_NONTWL(5) 
 -15	 4	    -15	 -15	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_2_5_ORWA_NONTWL(5) 
  -1	 9	5.45085	   6	99	0	 4	0	0	0	0	0	0	0	#_SizeSel_P_3_5_ORWA_NONTWL(5) 
  -1	30	     20	   9	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_4_5_ORWA_NONTWL(5) 
-999	 9	   -999	  -5	99	0	-4	0	0	0	0	0	0	0	#_SizeSel_P_5_5_ORWA_NONTWL(5) 
-999	 9	   -999	   9	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_6_5_ORWA_NONTWL(5) 
  20	60	37.2003	  30	99	0	 4	0	0	0	0	0	0	0	#_SizeSel_P_1_6_OR_REC(6)      
 -15	 4	    -15	 -15	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_2_6_OR_REC(6)      
  -1	 9	4.18066	   6	99	0	 4	0	0	0	0	0	0	0	#_SizeSel_P_3_6_OR_REC(6)      
  -1	30	     12	   9	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_4_6_OR_REC(6)      
-999	 9	   -999	  -5	99	0	-4	0	0	0	0	0	0	0	#_SizeSel_P_5_6_OR_REC(6)      
-999	 9	   -999	   9	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_6_6_OR_REC(6)      
  20	60	43.3497	  30	99	0	 6	0	0	0	0	0	0	0	#_SizeSel_P_1_7_WA_REC(7)      
 -15	 4	    -15	 -15	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_2_7_WA_REC(7)      
  -1	 9	 4.3905	   6	99	0	 6	0	0	0	0	0	0	0	#_SizeSel_P_3_7_WA_REC(7)      
  -1	30	     20	   9	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_4_7_WA_REC(7)      
-999	 9	   -999	  -5	99	0	-4	0	0	0	0	0	0	0	#_SizeSel_P_5_7_WA_REC(7)      
-999	 9	   -999	   9	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_6_7_WA_REC(7)      
  20	60	35.2255	  30	99	0	 4	0	0	0	0	0	0	0	#_SizeSel_P_1_9_OR_RECOB(9)    
 -15	 4	    -15	 -15	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_2_9_OR_RECOB(9)    
  -1	 9	4.60943	   6	99	0	 4	0	0	0	0	0	0	0	#_SizeSel_P_3_9_OR_RECOB(9)    
  -1	30	     20	   9	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_4_9_OR_RECOB(9)    
-999	 9	   -999	  -5	99	0	-4	0	0	0	0	0	0	0	#_SizeSel_P_5_9_OR_RECOB(9)    
-999	 9	   -999	   9	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_6_9_OR_RECOB(9)    
  20	80	79.9721	  30	99	0	 4	0	0	0	0	0	0	0	#_SizeSel_P_1_10_TRI_ORWA(10)  
 -15	 4	    -15	 -15	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_2_10_TRI_ORWA(10)  
  -1	 9	7.06079	   6	99	0	 4	0	0	0	0	0	0	0	#_SizeSel_P_3_10_TRI_ORWA(10)  
  -1	30	     12	   9	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_4_10_TRI_ORWA(10)  
-999	 9	   -999	  -5	99	0	-4	0	0	0	0	0	0	0	#_SizeSel_P_5_10_TRI_ORWA(10)  
-999	 9	   -999	   9	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_6_10_TRI_ORWA(10)  
  20	60	49.4873	  40	99	0	 4	0	0	0	0	0	0	0	#_SizeSel_P_1_11_NWFSC_ORWA(11)
 -15	 4	    -15	 -15	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_2_11_NWFSC_ORWA(11)
  -1	 9	6.24491	   6	99	0	 4	0	0	0	0	0	0	0	#_SizeSel_P_3_11_NWFSC_ORWA(11)
  -1	30	     20	   9	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_4_11_NWFSC_ORWA(11)
-999	 9	   -999	  -5	99	0	-4	0	0	0	0	0	0	0	#_SizeSel_P_5_11_NWFSC_ORWA(11)
-999	 9	   -999	   9	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_6_11_NWFSC_ORWA(11)
  20	60	54.4599	  40	99	0	 4	0	0	0	0	0	0	0	#_SizeSel_P_1_12_IPHC_ORWA(12) 
 -15	 4	    -15	 -15	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_2_12_IPHC_ORWA(12) 
  -1	 9	4.19767	   6	99	0	 4	0	0	0	0	0	0	0	#_SizeSel_P_3_12_IPHC_ORWA(12) 
  -1	30	     20	   9	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_4_12_IPHC_ORWA(12) 
-999	 9	   -999	  -5	99	0	-4	0	0	0	0	0	0	0	#_SizeSel_P_5_12_IPHC_ORWA(12) 
-999	 9	   -999	   9	99	0	-5	0	0	0	0	0	0	0	#_SizeSel_P_6_12_IPHC_ORWA(12) 
#_AgeSelex
#_No age_selex_parm
#_no timevary selex parameters
#
0 #  use 2D_AR1 selectivity(0/1):  experimental feature
#_no 2D_AR1 selex offset used
# Tag loss and Tag reporting parameters go next
0 # TG_custom:  0=no read; 1=read if tags exist
#_Cond -6 6 1 1 2 0.01 -4 0 0 0 0 0 0 0  #_placeholder if no parameters
#
# Input variance adjustments factors: 
#_factor	fleet	value
    4	 1	0.530942	#_Variance_adjustment_list1 
    4	 2	0.296588	#_Variance_adjustment_list2 
    4	 3	0.529941	#_Variance_adjustment_list3 
    4	 4	0.242588	#_Variance_adjustment_list4 
    4	 5	 0.36315	#_Variance_adjustment_list5 
    4	 6	 0.39127	#_Variance_adjustment_list6 
    4	 7	       1	#_Variance_adjustment_list7 
    4	 8	0.546384	#_Variance_adjustment_list8 
    4	 9	0.548321	#_Variance_adjustment_list9 
    4	10	 0.48402	#_Variance_adjustment_list10
    4	11	0.517661	#_Variance_adjustment_list11
    4	12	0.401955	#_Variance_adjustment_list12
    5	 2	       1	#_Variance_adjustment_list13
    5	 3	       1	#_Variance_adjustment_list14
    5	 4	       1	#_Variance_adjustment_list15
    5	 5	0.173248	#_Variance_adjustment_list16
    5	 6	0.862882	#_Variance_adjustment_list17
    5	 7	       1	#_Variance_adjustment_list18
    5	11	       1	#_Variance_adjustment_list19
    5	12	0.040942	#_Variance_adjustment_list20
-9999	 0	       0	#_terminator                
#
1 #_maxlambdaphase
1 #_sd_offset; must be 1 if any growthCV, sigmaR, or survey extraSD is an estimated parameter
# read 0 changes to default Lambdas (default value is 1.0)
-9999 0 0 0 0 # terminator
#
0 # 0/1 read specs for more stddev reporting
#
999
