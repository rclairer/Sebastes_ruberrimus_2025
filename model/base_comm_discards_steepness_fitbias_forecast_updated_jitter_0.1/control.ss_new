#V3.30.23.2;_safe;_compile_date:_Apr 17 2025;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.2
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:_https://groups.google.com/g/ss3-forum_and_NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:_https://nmfs-ost.github.io/ss3-website/
#_Source_code_at:_https://github.com/nmfs-ost/ss3-source-code

#C Yelloweye 2017 control file
#C file created using an r4ss function
#C file write time: 2025-05-28  23:15:06
#_data_and_control_files: yelloweye_data.ss // yelloweye_control.ss
0  # 0 means do not read wtatage.ss; 1 means read and use wtatage.ss and also read and use growth parameters
1  #_N_Growth_Patterns (Growth Patterns, Morphs, Bio Patterns, GP are terms used interchangeably in SS3)
1 #_N_platoons_Within_GrowthPattern 
#_Cond 1 #_Platoon_within/between_stdev_ratio (no read if N_platoons=1)
#_Cond sd_ratio_rd < 0: platoon_sd_ratio parameter required after movement params.
#_Cond  1 #vector_platoon_dist_(-1_in_first_val_gives_normal_approx)
#
2 # recr_dist_method for parameters:  2=main effects for GP, Area, Settle timing; 3=each Settle entity; 4=none (only when N_GP*Nsettle*pop==1)
1 # not yet implemented; Future usage: Spawner-Recruitment: 1=global; 2=by area
2 #  number of recruitment settlement assignments 
0 # unused option
#GPattern month  area  age (for each settlement assignment)
 1 1 1 0
 1 1 2 0
#
0 #_N_movement_definitions
#_Cond 1.0 # first age that moves (real age at begin of season, not integer) if do_migration>0
#_Cond 1 1 1 2 4 10 # example move definition for seas=1, GP=1, source=1 dest=2, age1=4, age2=10
#
4 #_Nblock_Patterns
 1 1 1 1 #_blocks_per_pattern 
# begin and end years of blocks
 1992 2004
 2004 2024
 2002 2024
 2002 2024
#
# controls for all timevary parameters 
1 #_time-vary parm bound check (1=warn relative to base parm bounds; 3=no bound check); Also see env (3) and dev (5) options to constrain with base bounds
#
# AUTOGEN
 1 1 1 1 1 # autogen: 1st element for biology, 2nd for SR, 3rd for Q, 4th reserved, 5th for selex
# where: 0 = autogen time-varying parms of this category; 1 = read each time-varying parm line; 2 = read then autogen if parm min==-12345
#
#_Available timevary codes
#_Block types: 0: P_block=P_base*exp(TVP); 1: P_block=P_base+TVP; 2: P_block=TVP; 3: P_block=P_block(-1) + TVP
#_Block_trends: -1: trend bounded by base parm min-max and parms in transformed units (beware); -2: endtrend and infl_year direct values; -3: end and infl as fraction of base range
#_EnvLinks:  1: P(y)=P_base*exp(TVP*env(y));  2: P(y)=P_base+TVP*env(y);  3: P(y)=f(TVP,env_Zscore) w/ logit to stay in min-max;  4: P(y)=2.0/(1.0+exp(-TVP1*env(y) - TVP2))
#_DevLinks:  1: P(y)*=exp(dev(y)*dev_se;  2: P(y)+=dev(y)*dev_se;  3: random walk;  4: zero-reverting random walk with rho;  5: like 4 with logit transform to stay in base min-max
#_DevLinks(more):  21-25 keep last dev for rest of years
#
#_Prior_codes:  0=none; 6=normal; 1=symmetric beta; 2=CASAL's beta; 3=lognormal; 4=lognormal with biascorr; 5=gamma
#
# setup for M, growth, wt-len, maturity, fecundity, (hermaphro), recr_distr, cohort_grow, (movement), (age error), (catch_mult), sex ratio 
#_NATMORT
1 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate;_5=BETA:_Maunder_link_to_maturity;_6=Lorenzen_range
1 #_N_breakpoints
 4 # age(real) at M breakpoints
#
1 # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_specific_K_incr; 4=age_specific_K_decr; 5=age_specific_K_each; 6=NA; 7=NA; 8=growth cessation
0 #_Age(post-settlement) for L1 (aka Amin); first growth parameter is size at this age; linear growth below this
70 #_Age(post-settlement) for L2 (aka Amax); 999 to treat as Linf
-999 #_exponential decay for growth above maxage (value should approx initial Z; -999 replicates 3.24; -998 to not allow growth above maxage)
0  #_placeholder for future growth feature
#
0 #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)
0 #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
#
1 #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity matrix by growth_pattern; 4=read age-fecundity; 5=disabled; 6=read length-maturity
2 #_First_Mature_Age
2 #_fecundity_at_length option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
0 #_hermaphroditism option:  0=none; 1=female-to-male age-specific fxn; -1=male-to-female age-specific fxn
1 #_parameter_offset_approach for M, G, CV_G:  1- direct, no offset**; 2- male=fem_parm*exp(male_parm); 3: male=female*exp(parm) then old=young*exp(parm)
#_** in option 1, any male parameter with value = 0.0 and phase <0 is set equal to female parameter
#
#_growth_parms
#_ LO HI INIT PRIOR PR_SD PR_type PHASE env_var&link dev_link dev_minyr dev_maxyr dev_PH Block Block_Fxn
# Sex: 1  BioPattern: 1  NatMort
 0.01 0.15 0.0439034 -3.12576 0.31 0 -1 0 0 0 0 0 0 0 # NatM_break_1_Fem_GP_1
# Sex: 1  BioPattern: 1  Growth
 0.01 35 1.54445 30 99 0 2 0 0 0 0 0 0 0 # L_at_Amin_Fem_GP_1
 40 120 61.3664 66 99 0 2 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0.01 0.2 0.0759253 0.05 99 0 1 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_1
 0.01 0.5 0.14792 0.1 99 0 3 0 0 0 0 0 0 0 # CV_young_Fem_GP_1
 0.01 0.5 0.0643925 0.1 99 0 7 0 0 0 0 0 0 0 # CV_old_Fem_GP_1
# Sex: 1  BioPattern: 1  WtLen
 -3 3 7.18331e-06 7.18331e-06 99 0 -50 0 0 0 0 0 0 0 # Wtlen_1_Fem_GP_1
 -3 4 3.2448 3.2448 99 0 -50 0 0 0 0 0 0 0 # Wtlen_2_Fem_GP_1
# Sex: 1  BioPattern: 1  Maturity&Fecundity
 38 45 42.0705 41.765 99 0 -50 0 0 0 0 0 0 0 # Mat50%_Fem_GP_1
 -3 3 -0.402214 -0.36886 99 0 -50 0 0 0 0 0 0 0 # Mat_slope_Fem_GP_1
 -3 300000 7.21847e-08 7.21847e-08 1 0 -6 0 0 0 0 0 0 0 # Eggs_scalar_Fem_GP_1
 -3 39000 4.043 4.043 1 0 -6 0 0 0 0 0 0 0 # Eggs_exp_len_Fem_GP_1
# Hermaphroditism
#  Recruitment Distribution 
 0 2 1 1 99 0 -50 0 0 0 0 0 0 0 # RecrDist_GP_1
 -4 4 0 0 99 0 -50 0 0 0 0 0 0 0 # RecrDist_Area_1
 -4 4 0.472395 0 99 0 3 0 0 0 0 0 0 0 # RecrDist_Area_2
 0 2 1 1 99 0 -50 0 0 0 0 0 0 0 # RecrDist_month_1
#  Cohort growth dev base
 0 2 1 1 99 0 -50 0 0 0 0 0 0 0 # CohortGrowDev
#  Movement
#  Platoon StDev Ratio 
#  Age Error from parameters
#  catch multiplier
#  fraction female, by GP
 1e-06 0.999999 0.5 0.5 0.5 0 -99 0 0 0 0 0 0 0 # FracFemale_GP_1
#  M2 parameter for each predator fleet
#
#_no timevary MG parameters
#
#_seasonal_effects_on_biology_parms
 0 0 0 0 0 0 0 0 0 0 #_femwtlen1,femwtlen2,mat1,mat2,fec1,fec2,Malewtlen1,malewtlen2,L1,K
#_ LO HI INIT PRIOR PR_SD PR_type PHASE
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no seasonal MG parameters
#
3 #_Spawner-Recruitment; Options: 1=NA; 2=Ricker; 3=std_B-H; 4=SCAA; 5=Hockey; 6=B-H_flattop; 7=survival_3Parm; 8=Shepherd_3Parm; 9=RickerPower_3parm
0  # 0/1 to use steepness in initial equ recruitment calculation
0  #  future feature:  0/1 to make realized sigmaR a function of SR curvature
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn #  parm_name
             3            15       5.48813             5            99             0          3          0          0          0          0          0          0          0 # SR_LN(R0)
           0.2             1          0.72          0.72         0.158             0         -3          0          0          0          0          0          0          0 # SR_BH_steep
             0             5           0.5           0.5            99             0         -2          0          0          0          0          0          0          0 # SR_sigmaR
            -5             5             0             0            99             0        -50          0          0          0          0          0          0          0 # SR_regime
            -1             2             0             1            99             0        -50          0          0          0          0          0          0          0 # SR_autocorr
#_no timevary SR parameters
1 #do_recdev:  0=none; 1=devvector (R=F(SSB)+dev); 2=deviations (R=F(SSB)+dev); 3=deviations (R=R0*dev; dev2=R-f(SSB)); 4=like 3 with sum(dev2) adding penalty
1980 # first year of main recr_devs; early devs can precede this era
2023 # last year of main recr_devs; forecast devs start in following year
7 #_recdev phase 
1 # (0/1) to read 13 advanced options
 1889 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
 7 #_recdev_early_phase
 0 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
 1 #_lambda for Fcast_recr_like occurring before endyr+1
 1918.84 #_last_yr_nobias_adj_in_MPD; begin of ramp
 2011.35 #_first_yr_fullbias_adj_in_MPD; begin of plateau
 2015 #_last_yr_fullbias_adj_in_MPD
 2022.58 #_end_yr_for_ramp_in_MPD (can be in forecast to shape ramp, but SS3 sets bias_adj to 0.0 for fcast yrs)
 0.5981 #_max_bias_adj_in_MPD (typical ~0.8; -3 sets all years to 0.0; -2 sets all non-forecast yrs w/ estimated recdevs to 1.0; -1 sets biasadj=1.0 for all yrs w/ recdevs)
 0 #_period of cycles in recruitment (N parms read below)
 -5 #min rec_dev
 5 #max rec_dev
 0 #_read_recdevs
#_end of advanced SR options
#
#_placeholder for full parameter lines for recruitment cycles
# read specified recr devs
#_year Input_value
#
# all recruitment deviations
#  1889E 1890E 1891E 1892E 1893E 1894E 1895E 1896E 1897E 1898E 1899E 1900E 1901E 1902E 1903E 1904E 1905E 1906E 1907E 1908E 1909E 1910E 1911E 1912E 1913E 1914E 1915E 1916E 1917E 1918E 1919E 1920E 1921E 1922E 1923E 1924E 1925E 1926E 1927E 1928E 1929E 1930E 1931E 1932E 1933E 1934E 1935E 1936E 1937E 1938E 1939E 1940E 1941E 1942E 1943E 1944E 1945E 1946E 1947E 1948E 1949E 1950E 1951E 1952E 1953E 1954E 1955E 1956E 1957E 1958E 1959E 1960E 1961E 1962E 1963E 1964E 1965E 1966E 1967E 1968E 1969E 1970E 1971E 1972E 1973E 1974E 1975E 1976E 1977E 1978E 1979E 1980R 1981R 1982R 1983R 1984R 1985R 1986R 1987R 1988R 1989R 1990R 1991R 1992R 1993R 1994R 1995R 1996R 1997R 1998R 1999R 2000R 2001R 2002R 2003R 2004R 2005R 2006R 2007R 2008R 2009R 2010R 2011R 2012R 2013R 2014R 2015R 2016R 2017R 2018R 2019R 2020R 2021R 2022R 2023R 2024F 2025F 2026F 2027F 2028F 2029F 2030F 2031F 2032F 2033F 2034F 2035F 2036F
#  0.00545081 0.00563332 0.00582392 0.00602138 0.00622754 0.00643614 0.00665169 0.00687787 0.00710639 0.00734615 0.00759903 0.00786996 0.00816174 0.00847394 0.00878584 0.00913098 0.00952116 0.00995588 0.0104851 0.0110854 0.0117929 0.0125871 0.0134717 0.0144396 0.0154271 0.0163453 0.0170286 0.0172891 0.0168659 0.0154359 0.0126622 0.00822239 0.0018553 -0.00662581 -0.0172562 -0.0298779 -0.0441171 -0.0593651 -0.0748207 -0.0896281 -0.103036 -0.114633 -0.124528 -0.133412 -0.142413 -0.152777 -0.165352 -0.180097 -0.195812 -0.210346 -0.221044 -0.225371 -0.220966 -0.205186 -0.174182 -0.122348 -0.0437294 0.0642087 0.191552 0.297686 0.302554 0.179065 -0.0010743 -0.173988 -0.312001 -0.40655 -0.455987 -0.460329 -0.421123 -0.343156 -0.245009 -0.194341 -0.273035 -0.429107 -0.543998 -0.537947 -0.389837 -0.205633 -0.0939956 0.0871968 0.183676 0.382503 0.840635 0.25396 -0.0460119 0.0545498 0.430822 0.244786 0.18505 -0.139666 0.139723 0.298448 0.401994 0.514823 0.142038 0.4155 0.243023 -0.0937386 -0.329236 -0.613605 -0.756521 -0.832118 -0.920671 -0.75749 -0.0470425 -0.194288 -0.921746 -0.947984 -0.737808 -0.242963 0.224415 -0.410249 -0.269571 0.985693 0.0636385 -0.344268 0.0683667 0.587547 0.580308 1.09754 0.826359 0.791469 0.520378 0.368686 1.21672 0.428386 0.729522 0.314979 -0.404209 -0.472668 -0.46758 -0.501545 -0.258836 -0.154023 -0.141673 0 0 0 0 0 0 0 0 0 0 0 0 0
#
#Fishing Mortality info 
0.09 # F ballpark value in units of annual_F
1999 # F ballpark year (neg value to disable)
1 # F_Method:  1=Pope midseason rate; 2=F as parameter; 3=F as hybrid; 4=fleet-specific parm/hybrid (#4 is superset of #2 and #3 and is recommended)
0.9 # max F (methods 2-4) or harvest fraction (method 1)
# F_Method 1:  no additional input needed
#
#_initial_F_parms; for each fleet x season that has init_catch; nest season in fleet; count = 0
#_for unconstrained init_F, use an arbitrary initial catch and set lambda=0 for its logL
#_ LO HI INIT PRIOR PR_SD  PR_type  PHASE
#
# F rates by fleet x season
#_year:  1889 1890 1891 1892 1893 1894 1895 1896 1897 1898 1899 1900 1901 1902 1903 1904 1905 1906 1907 1908 1909 1910 1911 1912 1913 1914 1915 1916 1917 1918 1919 1920 1921 1922 1923 1924 1925 1926 1927 1928 1929 1930 1931 1932 1933 1934 1935 1936 1937 1938 1939 1940 1941 1942 1943 1944 1945 1946 1947 1948 1949 1950 1951 1952 1953 1954 1955 1956 1957 1958 1959 1960 1961 1962 1963 1964 1965 1966 1967 1968 1969 1970 1971 1972 1973 1974 1975 1976 1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 2033 2034 2035 2036
# seas:  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
# 1_CA_TWL 0 5.15532e-06 7.73315e-06 1.28891e-05 1.54679e-05 2.06254e-05 2.32058e-05 2.83657e-05 3.09481e-05 3.61106e-05 4.12746e-05 4.38602e-05 4.90269e-05 5.16145e-05 5.67839e-05 5.93738e-05 6.45463e-05 6.71387e-05 7.23148e-05 7.7493e-05 8.00902e-05 8.52724e-05 8.78727e-05 9.30592e-05 9.56628e-05 0.000100854 0.000103461 0.000108656 0.00017078 0.000199352 0.0001399 0.000142509 0.000116617 0.000101079 0.000108858 6.22073e-05 4.40714e-05 0.0001608 0.000272508 0.000348104 0.000410879 0.000382766 0.000229527 0.000274313 0.000426913 0.000422461 0.000441939 0.000393301 0.000468986 0.000444141 0.000461949 0.000428993 0.000312384 7.30518e-05 0.000556687 0.00228051 0.00510679 0.00458584 0.00203164 0.00187565 0.00108801 0.00100923 0.00295092 0.00262225 0.00260948 0.00153167 0.00173581 0.00267216 0.00328994 0.00326662 0.00274777 0.0024056 0.00115101 0.00119364 0.00196361 0.00102676 0.00127999 0.00121514 0.00209862 0.00130463 0.0076456 0.00869892 0.0154137 0.0214398 0.0173971 0.0187093 0.0221134 0.0209935 0.0208673 0.0637954 0.0348121 0.00953527 0.0193766 0.140838 0.0485118 0.0397035 0.00711862 0.0102265 0.0181467 0.035511 0.0117058 0.0133372 0.0200645 0.0269878 0.0119471 0.00917051 0.00740538 0.0337291 0.0139201 0.0100717 0.0209241 0.00177655 0.00144384 0.00079926 0.00027169 3.95918e-05 3.74201e-05 7.08541e-06 0 2.71104e-05 3.31492e-05 8.56743e-05 0 3.79121e-06 1.0694e-05 6.12453e-05 3.12188e-06 2.91382e-06 9.93896e-06 8.42931e-07 3.06474e-05 9.39508e-05 8.01521e-05 6.10991e-05 5.28267e-05 0.000112056 7.69381e-05 7.41854e-05 0.000266272 0.000263527 0.000261087 0.000258647 0.000256207 0.000253767 0.000251327 0.000249192 0.000246752 0.000244312
# 2_CA_NONTWL 0 1.8079e-05 3.3576e-05 5.16574e-05 6.71588e-05 8.52466e-05 0.000100756 0.000118853 0.000134371 0.000152479 0.000170592 0.000186126 0.00020425 0.000219794 0.000237928 0.000253483 0.00027163 0.000287196 0.000305357 0.000323526 0.000339114 0.000357299 0.000372903 0.000391104 0.000406724 0.000424942 0.000440578 0.000458813 0.00076744 0.000902755 0.000420534 0.000477705 0.000480379 0.000436286 0.000464867 0.000670062 0.000958518 0.00110446 0.00126644 0.00108805 0.00106052 0.00138279 0.00123877 0.00185331 0.000737416 0.00109634 0.00166313 0.00174549 0.00114417 0.00124967 0.00126002 0.000797791 0.00113042 0.000840267 0.00104465 0.00451453 0.011043 0.0116523 0.00263805 0.00486675 0.00180775 0.00136279 0.00210897 0.0016426 0.000973102 0.00208506 0.000567358 0.000564902 0.00127935 0.000965862 0.000524687 0.00072221 0.000547766 0.000568986 0.00183401 0.00150382 0.00183074 0.00149654 0.00149247 0.00134497 0.00137373 0.00124852 0.00174857 0.0028424 0.0023534 0.00484917 0.00437313 0.00622256 0.00735613 0.0159412 0.0219283 0.0164361 0.0770059 0.011035 0.00661172 0.00400794 0.00408171 0.024372 0.0411998 0.0408587 0.0532345 0.093638 0.19249 0.166565 0.0909249 0.0980731 0.0966083 0.117178 0.129218 0.0436792 0.0334136 0.00810879 0.00913879 6.70045e-05 0.000105104 0.00149305 0.00137321 0.000356107 0.00156695 0.00102578 0.000287781 5.74299e-05 0.000270205 0.00111875 0.00066946 2.24082e-05 0.000418864 0 0.00111797 0 0 0 0.00167758 0.00362764 0.00111583 0.00189877 0.0055258 0.00532503 0.00553718 0.00548009 0.00542935 0.00537861 0.00532787 0.00527713 0.00522638 0.00518199 0.00513124 0.0050805
# 3_CA_REC 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.000164419 0.000331762 0.000381135 0.000508211 0.000638284 0.000766906 0.000895618 0.00102811 0.00115974 0.00138192 0.00136353 0.00119735 0.00172793 0.00160501 0.000857237 0.000822807 0.000678036 0.000913815 0.00160188 0.00130249 0.00262728 0.00344058 0.0042335 0.00505789 0.00447353 0.00386946 0.00490527 0.00596161 0.00673104 0.00671594 0.0105424 0.00919988 0.00661923 0.00521944 0.00667009 0.00703219 0.00617455 0.00955661 0.0105037 0.0107415 0.0128712 0.0141063 0.0162837 0.0148766 0.0197647 0.0262319 0.0289586 0.0308614 0.0368354 0.035106 0.0343825 0.0425215 0.0435064 0.0293253 0.0697408 0.0422554 0.0670983 0.114813 0.0647621 0.0777418 0.0646247 0.0703872 0.0583192 0.0456754 0.0334475 0.0145894 0.0258309 0.0247607 0.0236446 0.0322252 0.0117844 0.0302224 0.0187561 0.0112311 0.00428744 0.00808219 0.00191613 0.00181253 0.00171617 0.00649179 0.00154141 0.00726919 0.00137557 0.00258539 0.00243049 0.00114163 0.00106857 0.0019942 0.000929404 0.00390887 0.00402623 0.00463467 0.00136987 0.00260506 0.0023563 0.0056297 0.00260172 0.00481896 0.00466376 0.00969204 0.00959212 0.0095033 0.00941449 0.00932567 0.00923686 0.00914804 0.00907033 0.00898151 0.00889269
# 4_ORWA_TWL 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3.23935e-06 1.62113e-06 0 1.62703e-06 4.89004e-06 9.81111e-06 0 1.48152e-05 0.000340087 0.000525702 0.000993246 0.00350151 0.00622932 0.00982427 0.0061026 0.00379595 0.00270477 0.00227499 0.00248012 0.0021931 0.00234976 0.00183988 0.00237279 0.00243955 0.00316329 0.00427929 0.00343415 0.00372746 0.00471867 0.00426794 0.00497687 0.00135862 0.000370281 0.0129104 0.000584906 0.00132013 0.000577739 0.00932831 0.00139733 0.00272046 0.0014766 0.00192653 0.000900472 0.00110381 0.00142938 0.00103433 0.00494955 0.00942144 0.01816 0.0202079 0.0353381 0.0681252 0.0292727 0.0533855 0.0263837 0.021561 0.0410878 0.0651378 0.0282098 0.0436137 0.0517616 0.0565364 0.038963 0.0628098 0.0428766 0.0439979 0.0248677 0.0119216 0.00339885 0.00109236 0.00106766 0.000362732 0.000323385 0.000786337 0.000883071 5.4758e-05 9.51242e-05 5.21532e-05 4.50443e-05 3.27368e-05 3.16598e-05 5.60474e-05 1.47096e-05 1.40996e-05 3.14612e-05 0.000104518 0.000221 0.000229184 0.00011913 0.000138456 0.000258457 0.00013006 0.000154896 0.00235735 0.00229715 0.000533098 0.000527602 0.000522717 0.000517832 0.000512947 0.000508061 0.000503176 0.000498902 0.000494016 0.000489131
# 5_ORWA_NONTWL 6.67364e-06 6.67368e-06 1.1679e-05 0.000607315 0.00059264 0.000592968 0.000153754 3.67716e-05 3.67715e-05 2.17283e-05 3.84409e-05 5.01384e-05 6.51771e-05 8.02145e-05 9.35792e-05 0.000121981 0.000123647 0.000138679 0.000152038 0.000325779 0.000182121 0.000197149 0.000210506 0.000225533 0.00024056 0.000255587 0.000372511 0.000283997 0.000299025 0.00309709 0.00127457 0.00110131 0.00106176 0.000735102 0.00085614 0.00156002 0.00192962 0.00294188 0.00384401 0.00373722 0.00300825 0.00331576 0.00199267 0.00125102 0.00175898 0.00216459 0.00165961 0.00285563 0.00254869 0.00281923 0.00183864 0.00297185 0.00476671 0.00549714 0.00904116 0.00404437 0.00208605 0.00379645 0.00203407 0.00250532 0.0021147 0.002807 0.003437 0.00251889 0.00108941 0.0019994 0.00190401 0.000854747 0.00168127 0.000474102 0.00107449 0.000978622 0.000978667 0.00103023 0.000820901 0.000622465 0.000936031 0.000656489 0.00133892 0.00115262 0.00267225 0.000893081 0.001737 0.00227972 0.00242406 0.00308939 0.00165169 0.00220791 0.00373998 0.00535346 0.0110656 0.00578776 0.0057047 0.00769247 0.0118052 0.0109918 0.0202536 0.0204945 0.0319192 0.0163865 0.0149081 0.026562 0.0341979 0.0382764 0.0634386 0.0403327 0.0216807 0.0532369 0.0705579 0.0301416 0.0707709 0.0110843 0.0193127 0.00304513 0.00161071 0.00167567 0.00114515 0.00146206 0.00244199 0.00223221 0.00138953 0.000535548 0.000734311 0.0011275 0.00168622 0.00120016 0.00168949 0.00133772 0.00345393 0.00302713 0.0033672 0.00325069 0.00328449 0.00609608 0.00772568 0.00484497 0.00304975 0.00317136 0.0167729 0.0166 0.0164463 0.0162926 0.0161389 0.0159852 0.0158315 0.015697 0.0155433 0.0153896
# 6_OR_REC 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.00150078 0.00261665 0.00128922 0.00402335 0.004158 0.00514751 0.0111366 0.00874954 0.00823002 0.0147295 0.0109268 0.0107513 0.00339564 0.027174 0.0125321 0.00339649 0.00441113 0.00611776 0.00998689 0.0104918 0.0104249 0.00730473 0.00975707 0.00422098 0.00776391 0.0097824 0.0077122 0.00717286 0.00314455 0.00208782 0.00218887 0.000996472 0.00135291 0.00107257 0.00130071 0.00126551 0.00109307 0.00110006 0.00118534 0.00168643 0.00164658 0.00134507 0.00201114 0.00127979 0.00182991 0.00163666 0.0019585 0.0022229 0.00117952 0.00175187 0.00124187 0.00114246 0.00199438 0.00194605 0.00501726 0.00496553 0.00491955 0.00487358 0.0048276 0.00478162 0.00473565 0.00469542 0.00464944 0.00460346
# 7_WA_REC 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.000453981 8.92771e-05 0.000220402 0.000344032 0.000549575 0.00072755 0.000926386 0.000869407 0.000887634 0.000929602 0.00191439 0.000943872 0.00110578 0.00055743 0.00104139 0.00150651 0.00213648 0.00386776 0.00302334 0.00309323 0.00407526 0.00330934 0.00600216 0.00320687 0.00593973 0.00559589 0.00599784 0.0037617 0.00384246 0.00440512 0.00483112 0.00686721 0.00538658 0.00626726 0.00681544 0.00150753 0.00110009 0.0018081 0.00211429 0.000788763 0.00115122 0.000961282 0.000954418 0.00114087 0.00123046 0.00169954 0.00102789 0.00131873 0.00114288 0.00126176 0.00119918 0.00115693 0.00178869 0.00089441 0.000959453 0.000950544 0.000988503 0.000968572 0.00219265 0.00216437 0.00316896 0.00313629 0.00310725 0.00307821 0.00304917 0.00302013 0.00299109 0.00296568 0.00293664 0.0029076
#
#_Q_setup for fleets with cpue or survey or deviation data
#_1:  fleet number
#_2:  link type: 1=simple q; 2=mirror; 3=power (+1 parm); 4=mirror with scale (+1p); 5=offset (+1p); 6=offset & power (+2p)
#_     where power is applied as y = q * x ^ (1 + power); so a power value of 0 has null effect
#_     and with the offset included it is y = q * (x + offset) ^ (1 + power)
#_3:  extra input for link, i.e. mirror fleet# or dev index number
#_4:  0/1 to select extra sd parameter
#_5:  0/1 for biasadj or not
#_6:  0/1 to float
#_   fleet      link link_info  extra_se   biasadj     float  #  fleetname
         3         1         0         1         0         1  #  3_CA_REC
         6         1         0         1         0         0  #  6_OR_REC
         7         1         0         1         0         1  #  7_WA_REC
         8         1         0         1         0         1  #  8_CACPFV
         9         1         0         1         0         1  #  9_OR_RECOB
        10         1         0         1         0         1  #  10_TRI_ORWA
        11         1         0         1         0         1  #  11_NWFSC_ORWA
        12         1         0         1         0         1  #  12_IPHC_ORWA
-9999 0 0 0 0 0
#
#_Q_parameters
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
           -15            15      -9.19589             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_3_CA_REC(3)
             0             5      0.121999          0.01            99             0          5          0          0          0          0          0          0          0  #  Q_extraSD_3_CA_REC(3)
           -15            15      -9.13381             0            99             0          1          0          0          0          0          0          2          1  #  LnQ_base_6_OR_REC(6)
             0             5     0.0841553          0.01            99             0          5          0          0          0          0          0          0          0  #  Q_extraSD_6_OR_REC(6)
           -20            15      -8.85286             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_7_WA_REC(7)
             0             5      0.383537          0.01            99             0          5          0          0          0          0          0          0          0  #  Q_extraSD_7_WA_REC(7)
           -15            15      -9.25364             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_8_CACPFV(8)
             0             5     0.0965383          0.01            99             0          5          0          0          0          0          0          0          0  #  Q_extraSD_8_CACPFV(8)
           -15            15      -11.4245             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_9_OR_RECOB(9)
             0             5      0.164859          0.01            99             0          5          0          0          0          0          0          0          0  #  Q_extraSD_9_OR_RECOB(9)
           -15            15      -1.50539             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_10_TRI_ORWA(10)
             0             5      0.139599          0.01            99             0          5          0          0          0          0          0          0          0  #  Q_extraSD_10_TRI_ORWA(10)
           -15            15     -0.955022             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_11_NWFSC_ORWA(11)
             0             5             0          0.01            99             0         -5          0          0          0          0          0          0          0  #  Q_extraSD_11_NWFSC_ORWA(11)
           -15            15     -0.645656             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_12_IPHC_ORWA(12)
             0             5      0.551904          0.01            99             0          5          0          0          0          0          0          0          0  #  Q_extraSD_12_IPHC_ORWA(12)
# timevary Q parameters 
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type     PHASE  #  parm_name
            -4             4      -2.66505             0            99            -1      1  # LnQ_base_6_OR_REC(6)_BLK2add_2004
# info on dev vectors created for Q parms are reported with other devs after tag parameter section 
#
#_size_selex_patterns
#Pattern:_0;  parm=0; selex=1.0 for all sizes
#Pattern:_1;  parm=2; logistic; with 95% width specification
#Pattern:_5;  parm=2; mirror another size selex; PARMS pick the min-max bin to mirror
#Pattern:_11; parm=2; selex=1.0  for specified min-max population length bin range
#Pattern:_15; parm=0; mirror another age or length selex
#Pattern:_6;  parm=2+special; non-parm len selex
#Pattern:_43; parm=2+special+2;  like 6, with 2 additional param for scaling (mean over bin range)
#Pattern:_8;  parm=8; double_logistic with smooth transitions and constant above Linf option
#Pattern:_9;  parm=6; simple 4-parm double logistic with starting length; parm 5 is first length; parm 6=1 does desc as offset
#Pattern:_21; parm=2*special; non-parm len selex, read as N break points, then N selex parameters
#Pattern:_22; parm=4; double_normal as in CASAL
#Pattern:_23; parm=6; double_normal where final value is directly equal to sp(6) so can be >1.0
#Pattern:_24; parm=6; double_normal with sel(minL) and sel(maxL), using joiners
#Pattern:_2;  parm=6; double_normal with sel(minL) and sel(maxL), using joiners, back compatibile version of 24 with 3.30.18 and older
#Pattern:_25; parm=3; exponential-logistic in length
#Pattern:_27; parm=special+3; cubic spline in length; parm1==1 resets knots; parm1==2 resets all 
#Pattern:_42; parm=special+3+2; cubic spline; like 27, with 2 additional param for scaling (mean over bin range)
#_discard_options:_0=none;_1=define_retention;_2=retention&mortality;_3=all_discarded_dead;_4=define_dome-shaped_retention
#_Pattern Discard Male Special
 24 0 0 0 # 1 1_CA_TWL
 24 0 0 0 # 2 2_CA_NONTWL
 24 0 0 0 # 3 3_CA_REC
 24 0 0 0 # 4 4_ORWA_TWL
 24 0 0 0 # 5 5_ORWA_NONTWL
 24 0 0 0 # 6 6_OR_REC
 24 0 0 0 # 7 7_WA_REC
 15 0 0 3 # 8 8_CACPFV
 24 0 0 0 # 9 9_OR_RECOB
 24 0 0 0 # 10 10_TRI_ORWA
 24 0 0 0 # 11 11_NWFSC_ORWA
 24 0 0 0 # 12 12_IPHC_ORWA
#
#_age_selex_patterns
#Pattern:_0; parm=0; selex=1.0 for ages 0 to maxage
#Pattern:_10; parm=0; selex=1.0 for ages 1 to maxage
#Pattern:_11; parm=2; selex=1.0  for specified min-max age
#Pattern:_12; parm=2; age logistic
#Pattern:_13; parm=8; age double logistic. Recommend using pattern 18 instead.
#Pattern:_14; parm=nages+1; age empirical
#Pattern:_15; parm=0; mirror another age or length selex
#Pattern:_16; parm=2; Coleraine - Gaussian
#Pattern:_17; parm=nages+1; empirical as random walk  N parameters to read can be overridden by setting special to non-zero
#Pattern:_41; parm=2+nages+1; // like 17, with 2 additional param for scaling (mean over bin range)
#Pattern:_18; parm=8; double logistic - smooth transition
#Pattern:_19; parm=6; simple 4-parm double logistic with starting age
#Pattern:_20; parm=6; double_normal,using joiners
#Pattern:_26; parm=3; exponential-logistic in age
#Pattern:_27; parm=3+special; cubic spline in age; parm1==1 resets knots; parm1==2 resets all 
#Pattern:_42; parm=2+special+3; // cubic spline; with 2 additional param for scaling (mean over bin range)
#Age patterns entered with value >100 create Min_selage from first digit and pattern from remainder
#_Pattern Discard Male Special
 10 0 0 0 # 1 1_CA_TWL
 10 0 0 0 # 2 2_CA_NONTWL
 10 0 0 0 # 3 3_CA_REC
 10 0 0 0 # 4 4_ORWA_TWL
 10 0 0 0 # 5 5_ORWA_NONTWL
 10 0 0 0 # 6 6_OR_REC
 10 0 0 0 # 7 7_WA_REC
 10 0 0 0 # 8 8_CACPFV
 10 0 0 0 # 9 9_OR_RECOB
 10 0 0 0 # 10 10_TRI_ORWA
 10 0 0 0 # 11 11_NWFSC_ORWA
 10 0 0 0 # 12 12_IPHC_ORWA
#
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
# 1   1_CA_TWL LenSelex
            20            60       43.9648            40            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_1_CA_TWL(1)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_1_CA_TWL(1)
            -1             9       5.12596             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_1_CA_TWL(1)
            -1            30        18.281             9            99             0          5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_1_CA_TWL(1)
          -999             9          -999          -999            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_1_CA_TWL(1)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_1_CA_TWL(1)
# 2   2_CA_NONTWL LenSelex
            20            60       44.6725            30            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_2_CA_NONTWL(2)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_2_CA_NONTWL(2)
            -1             9       5.20223             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_2_CA_NONTWL(2)
            -1            30       17.3873             9            99             0          5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_2_CA_NONTWL(2)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_2_CA_NONTWL(2)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_2_CA_NONTWL(2)
# 3   3_CA_REC LenSelex
            20            60       41.7128            40            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_3_CA_REC(3)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_3_CA_REC(3)
            -1             9       5.21215             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_3_CA_REC(3)
            -1            30            20             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_3_CA_REC(3)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_3_CA_REC(3)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_3_CA_REC(3)
# 4   4_ORWA_TWL LenSelex
            20            60        41.946            40            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_4_ORWA_TWL(4)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_4_ORWA_TWL(4)
            -1             9       5.49563             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_4_ORWA_TWL(4)
            -1            30       18.2288             9            99             0          5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_4_ORWA_TWL(4)
          -999             9          -999          -999            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_4_ORWA_TWL(4)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_4_ORWA_TWL(4)
# 5   5_ORWA_NONTWL LenSelex
            20            60       50.8797            30            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_5_ORWA_NONTWL(5)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_5_ORWA_NONTWL(5)
            -1             9       5.43985             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_5_ORWA_NONTWL(5)
            -1            30            20             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_5_ORWA_NONTWL(5)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_5_ORWA_NONTWL(5)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_5_ORWA_NONTWL(5)
# 6   6_OR_REC LenSelex
            20            60        36.729            30            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_6_OR_REC(6)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_6_OR_REC(6)
            -1             9        4.1432             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_6_OR_REC(6)
            -1            30            12             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_6_OR_REC(6)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_6_OR_REC(6)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_6_OR_REC(6)
# 7   7_WA_REC LenSelex
            20            60       42.7628            30            99             0          6          0          0          0          0          0          0          0  #  Size_DblN_peak_7_WA_REC(7)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_7_WA_REC(7)
            -1             9       4.31751             6            99             0          6          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_7_WA_REC(7)
            -1            30            20             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_7_WA_REC(7)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_7_WA_REC(7)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_7_WA_REC(7)
# 8   8_CACPFV LenSelex
# 9   9_OR_RECOB LenSelex
            20            60       35.1235            30            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_9_OR_RECOB(9)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_9_OR_RECOB(9)
            -1             9        4.6072             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_9_OR_RECOB(9)
            -1            30            20             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_9_OR_RECOB(9)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_9_OR_RECOB(9)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_9_OR_RECOB(9)
# 10   10_TRI_ORWA LenSelex
            20            80       79.9717            30            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_10_TRI_ORWA(10)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_10_TRI_ORWA(10)
            -1             9       7.07955             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_10_TRI_ORWA(10)
            -1            30            12             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_10_TRI_ORWA(10)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_10_TRI_ORWA(10)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_10_TRI_ORWA(10)
# 11   11_NWFSC_ORWA LenSelex
            20            60       48.8733            40            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_11_NWFSC_ORWA(11)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_11_NWFSC_ORWA(11)
            -1             9       6.23507             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_11_NWFSC_ORWA(11)
            -1            30            20             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_11_NWFSC_ORWA(11)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_11_NWFSC_ORWA(11)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_11_NWFSC_ORWA(11)
# 12   12_IPHC_ORWA LenSelex
            20            60       53.9958            40            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_12_IPHC_ORWA(12)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_12_IPHC_ORWA(12)
            -1             9        4.1375             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_12_IPHC_ORWA(12)
            -1            30            20             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_12_IPHC_ORWA(12)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_12_IPHC_ORWA(12)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_12_IPHC_ORWA(12)
# 1   1_CA_TWL AgeSelex
# 2   2_CA_NONTWL AgeSelex
# 3   3_CA_REC AgeSelex
# 4   4_ORWA_TWL AgeSelex
# 5   5_ORWA_NONTWL AgeSelex
# 6   6_OR_REC AgeSelex
# 7   7_WA_REC AgeSelex
# 8   8_CACPFV AgeSelex
# 9   9_OR_RECOB AgeSelex
# 10   10_TRI_ORWA AgeSelex
# 11   11_NWFSC_ORWA AgeSelex
# 12   12_IPHC_ORWA AgeSelex
#_No_Dirichlet parameters
#_no timevary selex parameters
#
0   #  use 2D_AR1 selectivity? (0/1)
#_no 2D_AR1 selex offset used
#_specs:  fleet, ymin, ymax, amin, amax, sigma_amax, use_rho, len1/age2, devphase, before_range, after_range
#_sigma_amax>amin means create sigma parm for each bin from min to sigma_amax; sigma_amax<0 means just one sigma parm is read and used for all bins
#_needed parameters follow each fleet's specifications
# -9999  0 0 0 0 0 0 0 0 0 0 # terminator
#
# Tag loss and Tag reporting parameters go next
0  # TG_custom:  0=no read and autogen if tag data exist; 1=read
#_Cond -6 6 1 1 2 0.01 -4 0 0 0 0 0 0 0  #_placeholder if no parameters
#
# deviation vectors for timevary parameters
#  base   base first block   block  env  env   dev   dev   dev   dev   dev
#  type  index  parm trend pattern link  var  vectr link _mnyr  mxyr phase  dev_vector
#      3     3     1     2     1     0     0     0     0     0     0     0
     #
# Input variance adjustments factors: 
 #_1=add_to_survey_CV
 #_2=add_to_discard_stddev
 #_3=add_to_bodywt_CV
 #_4=mult_by_lencomp_N
 #_5=mult_by_agecomp_N
 #_6=mult_by_size-at-age_N
 #_7=mult_by_generalized_sizecomp
#_factor  fleet  value
      4      1   0.51995
      4      2  0.287639
      4      3  0.524137
      4      4  0.254344
      4      5  0.373636
      4      6  0.365238
      4      7         1
      4      8  0.559252
      4      9  0.542121
      4     10  0.456885
      4     11  0.510701
      4     12  0.892108
      5      2         1
      5      3         1
      5      4         1
      5      5  0.220324
      5      6         1
      5      7         1
      5     11         1
      5     12  0.087666
 -9999   1    0  # terminator
#
1 #_maxlambdaphase
1 #_sd_offset; must be 1 if any growthCV, sigmaR, or survey extraSD is an estimated parameter
# read 0 changes to default Lambdas (default value is 1.0)
# Like_comp codes:  1=surv; 2=disc; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=catch; 9=init_equ_catch; 
# 10=recrdev; 11=parm_prior; 12=parm_dev; 13=CrashPen; 14=Morphcomp; 15=Tag-comp; 16=Tag-negbin; 17=F_ballpark; 18=initEQregime
#like_comp fleet  phase  value  sizefreq_method
-9999  1  1  1  1  #  terminator
#
# lambdas (for info only; columns are phases)
#  0 #_CPUE/survey:_1
#  0 #_CPUE/survey:_2
#  1 #_CPUE/survey:_3
#  0 #_CPUE/survey:_4
#  0 #_CPUE/survey:_5
#  1 #_CPUE/survey:_6
#  1 #_CPUE/survey:_7
#  1 #_CPUE/survey:_8
#  1 #_CPUE/survey:_9
#  1 #_CPUE/survey:_10
#  1 #_CPUE/survey:_11
#  1 #_CPUE/survey:_12
#  1 #_lencomp:_1
#  1 #_lencomp:_2
#  1 #_lencomp:_3
#  1 #_lencomp:_4
#  1 #_lencomp:_5
#  1 #_lencomp:_6
#  1 #_lencomp:_7
#  1 #_lencomp:_8
#  1 #_lencomp:_9
#  1 #_lencomp:_10
#  1 #_lencomp:_11
#  1 #_lencomp:_12
#  0 #_agecomp:_1
#  1 #_agecomp:_2
#  1 #_agecomp:_3
#  1 #_agecomp:_4
#  1 #_agecomp:_5
#  1 #_agecomp:_6
#  1 #_agecomp:_7
#  0 #_agecomp:_8
#  0 #_agecomp:_9
#  0 #_agecomp:_10
#  1 #_agecomp:_11
#  1 #_agecomp:_12
#  1 #_init_equ_catch1
#  1 #_init_equ_catch2
#  1 #_init_equ_catch3
#  1 #_init_equ_catch4
#  1 #_init_equ_catch5
#  1 #_init_equ_catch6
#  1 #_init_equ_catch7
#  1 #_init_equ_catch8
#  1 #_init_equ_catch9
#  1 #_init_equ_catch10
#  1 #_init_equ_catch11
#  1 #_init_equ_catch12
#  1 #_recruitments
#  1 #_parameter-priors
#  1 #_parameter-dev-vectors
#  1 #_crashPenLambda
#  1 # F_ballpark_lambda
0 # (0/1/2) read specs for more stddev reporting: 0 = skip, 1 = read specs for reporting stdev for selectivity, size, and numbers, 2 = add options for M,Dyn. Bzero, SmryBio
 # 0 2 0 0 # Selectivity: (1) fleet, (2) 1=len/2=age/3=both, (3) year, (4) N selex bins
 # 0 0 # Growth: (1) growth pattern, (2) growth ages
 # 0 0 0 # Numbers-at-age: (1) area(-1 for all), (2) year, (3) N ages
 # -1 # list of bin #'s for selex std (-1 in first bin to self-generate)
 # -1 # list of ages for growth std (-1 in first bin to self-generate)
 # -1 # list of ages for NatAge std (-1 in first bin to self-generate)
999

