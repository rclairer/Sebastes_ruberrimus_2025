#V3.30.23.2;_safe;_compile_date:_Apr 17 2025;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.2
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:_https://groups.google.com/g/ss3-forum_and_NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:_https://nmfs-ost.github.io/ss3-website/
#_Source_code_at:_https://github.com/nmfs-ost/ss3-source-code

#C Yelloweye 2017 control file
#C file created using an r4ss function
#C file write time: 2025-05-23  18:50:10
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
 0.01 35 1.54201 30 99 0 2 0 0 0 0 0 0 0 # L_at_Amin_Fem_GP_1
 40 120 61.3656 66 99 0 2 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0.01 0.2 0.0759335 0.05 99 0 1 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_1
 0.01 0.5 0.147906 0.1 99 0 3 0 0 0 0 0 0 0 # CV_young_Fem_GP_1
 0.01 0.5 0.0643978 0.1 99 0 7 0 0 0 0 0 0 0 # CV_old_Fem_GP_1
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
 -4 4 0.471386 0 99 0 3 0 0 0 0 0 0 0 # RecrDist_Area_2
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
             3            15       5.48578             5            99             0          3          0          0          0          0          0          0          0 # SR_LN(R0)
           0.2             1         0.718         0.718         0.158             0         -3          0          0          0          0          0          0          0 # SR_BH_steep
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
 1926.69 #_last_yr_nobias_adj_in_MPD; begin of ramp
 2013 #_first_yr_fullbias_adj_in_MPD; begin of plateau
 2014.75 #_last_yr_fullbias_adj_in_MPD
 2022.2 #_end_yr_for_ramp_in_MPD (can be in forecast to shape ramp, but SS3 sets bias_adj to 0.0 for fcast yrs)
 0.6532 #_max_bias_adj_in_MPD (typical ~0.8; -3 sets all years to 0.0; -2 sets all non-forecast yrs w/ estimated recdevs to 1.0; -1 sets biasadj=1.0 for all yrs w/ recdevs)
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
#  0.00538247 0.00556482 0.00575451 0.00595151 0.00615401 0.00636351 0.00657678 0.00679906 0.00702824 0.00726765 0.00752051 0.00779168 0.00808361 0.00839267 0.00870737 0.00905143 0.00944272 0.00987676 0.0104063 0.0110055 0.0117091 0.0125014 0.0133794 0.014338 0.0153134 0.0162144 0.0168735 0.0171042 0.0166428 0.0151671 0.0123412 0.00784577 0.00140509 -0.00716971 -0.0179162 -0.0306796 -0.0450843 -0.0605196 -0.0761608 -0.0911042 -0.104636 -0.116341 -0.126331 -0.135294 -0.14436 -0.15477 -0.167371 -0.182123 -0.197828 -0.212339 -0.223007 -0.2273 -0.222859 -0.20704 -0.175998 -0.124136 -0.0455144 0.0623735 0.189579 0.295533 0.300511 0.177412 -0.00240145 -0.175119 -0.313004 -0.407456 -0.456808 -0.461073 -0.421799 -0.34377 -0.245561 -0.194791 -0.273331 -0.429266 -0.544052 -0.537913 -0.389698 -0.205347 -0.0935751 0.0877855 0.184322 0.383064 0.841857 0.254708 -0.0451621 0.0555023 0.432137 0.245862 0.186314 -0.138619 0.141641 0.298755 0.403024 0.516075 0.141738 0.416139 0.243159 -0.094019 -0.329757 -0.61444 -0.757543 -0.833238 -0.922001 -0.75888 -0.0480298 -0.195078 -0.922569 -0.948396 -0.737806 -0.242474 0.226656 -0.409619 -0.269188 0.988752 0.0647264 -0.343064 0.0700522 0.59 0.581436 1.09979 0.827747 0.793284 0.521949 0.369704 1.22011 0.429043 0.729617 0.31306 -0.406617 -0.475498 -0.470385 -0.504359 -0.261459 -0.156447 -0.143947 0 0 0 0 0 0 0 0 0 0 0 0 0
# implementation error by year in forecast:  0 0 0 0 0 0 0 0 0 0 0 0
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
# 1_CA_TWL 0 5.16405e-06 7.74625e-06 1.29109e-05 1.54941e-05 2.06604e-05 2.32451e-05 2.84138e-05 3.10005e-05 3.61718e-05 4.13446e-05 4.39347e-05 4.91102e-05 5.17022e-05 5.68806e-05 5.94749e-05 6.46564e-05 6.72533e-05 7.24384e-05 7.76257e-05 8.02274e-05 8.54188e-05 8.80238e-05 9.32194e-05 9.58277e-05 0.000101028 0.000103639 0.000108844 0.000171076 0.000199698 0.000140144 0.000142758 0.000116821 0.000101256 0.000109049 6.23164e-05 4.41489e-05 0.000161083 0.000272989 0.000348719 0.000411603 0.000383438 0.000229927 0.000274785 0.000427635 0.000423159 0.000442648 0.000393909 0.000469682 0.000444769 0.000462567 0.000429535 0.000312753 7.31324e-05 0.000557257 0.00228267 0.00511125 0.00458957 0.00203317 0.00187694 0.00108869 0.0010098 0.00295242 0.00262345 0.00261053 0.00153222 0.00173636 0.00267289 0.00329074 0.00326731 0.00274829 0.002406 0.00115118 0.0011938 0.00196385 0.00102688 0.00128012 0.00121526 0.00209882 0.00130475 0.00764631 0.00869974 0.0154152 0.021442 0.0173991 0.0187116 0.0221164 0.0209968 0.020871 0.0638081 0.0348205 0.00953799 0.019383 0.140895 0.0485388 0.0397295 0.00712414 0.010236 0.0181662 0.035557 0.0117241 0.0133619 0.0201101 0.0270705 0.011994 0.00921117 0.00744301 0.0339243 0.0140161 0.0101545 0.0211068 0.00179333 0.00145779 0.000807105 0.000274356 3.99816e-05 3.77882e-05 7.15504e-06 0 2.73776e-05 3.34756e-05 8.65213e-05 0 3.82866e-06 1.07998e-05 6.18514e-05 3.15278e-06 2.94271e-06 1.00376e-05 8.5134e-07 3.09546e-05 9.48986e-05 8.09635e-05 6.17218e-05 5.33696e-05 0.000111276 0.000819128 0.000819975 0.000819975 0.000819975 0.000819975 0.000819975 0.000819975 0.000819975 0.000819975 0.000819975 0.000819975 0.000819975
# 2_CA_NONTWL 0 1.81089e-05 3.36316e-05 5.1743e-05 6.727e-05 8.53877e-05 0.000100922 0.00011905 0.000134594 0.000152732 0.000170875 0.000186435 0.000204589 0.000220159 0.000238324 0.000253905 0.000272082 0.000287676 0.000305867 0.000324067 0.000339682 0.000357898 0.000373529 0.000391762 0.000407409 0.000425659 0.000441323 0.00045959 0.000768741 0.000904287 0.00042125 0.000478519 0.000481199 0.000437032 0.000465663 0.000671211 0.000960165 0.00110636 0.00126863 0.00108993 0.00106235 0.00138517 0.00124089 0.00185644 0.000738638 0.00109811 0.00166574 0.00174813 0.00114583 0.0012514 0.00126167 0.000798774 0.00113172 0.000841169 0.00104569 0.00451866 0.0110523 0.0116614 0.00263996 0.00486995 0.00180883 0.00136351 0.00210998 0.00164329 0.000973463 0.00208573 0.000567514 0.000565035 0.0012796 0.000966022 0.00052476 0.000722296 0.000547822 0.000569037 0.00183416 0.00150393 0.00183086 0.00149663 0.00149256 0.00134505 0.00137381 0.00124859 0.00174868 0.00284259 0.00235358 0.00484958 0.00437356 0.00622325 0.00735706 0.0159434 0.0219321 0.0164395 0.0770245 0.0110384 0.00661469 0.0040101 0.00408439 0.0243917 0.0412389 0.0409061 0.0533098 0.0937976 0.192896 0.167046 0.091264 0.098489 0.097081 0.117835 0.130089 0.0440317 0.0337006 0.00818433 0.00922599 6.76545e-05 0.000106124 0.00150759 0.00138658 0.00035957 0.00158216 0.00103578 0.000290583 5.79912e-05 0.000272841 0.00112966 0.000676 2.26271e-05 0.000422956 0 0.00112891 0 0 0 0.00169433 0.00366412 0.00112715 0 0 0 0 0 0 0 0 0 0 0 0 0
# 3_CA_REC 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.000164709 0.000332348 0.000381803 0.000509093 0.000639375 0.000768189 0.000897077 0.00102974 0.0011615 0.00138393 0.00136542 0.00119891 0.00173006 0.00160686 0.000858162 0.000823631 0.000678664 0.000914598 0.00160316 0.00130346 0.00262905 0.0034427 0.00423585 0.00506042 0.00447554 0.00387101 0.00490701 0.00596348 0.0067329 0.00671759 0.0105447 0.00920169 0.0066204 0.00522028 0.00667106 0.00703313 0.00617531 0.0095577 0.0105048 0.0107426 0.0128725 0.0141078 0.0162853 0.0148782 0.0197669 0.0262351 0.0289625 0.030866 0.0368415 0.0351126 0.0343898 0.0425325 0.0435198 0.0293358 0.0697711 0.0422804 0.0671445 0.114906 0.0648249 0.0778288 0.0647114 0.0705006 0.0584309 0.0457823 0.0335522 0.0146475 0.0259469 0.0248879 0.0237825 0.0324487 0.0118815 0.0304865 0.0189332 0.0113395 0.00432949 0.00816146 0.00193499 0.00183036 0.00173303 0.0065555 0.0015566 0.00734078 0.00138917 0.00261094 0.00245453 0.00115294 0.00107916 0.00201398 0.000938642 0.00394777 0.00406653 0.00468131 0.00138375 0.00263154 0.00238041 0.00568777 0.00262879 0.0193512 0.0193712 0.0193712 0.0193712 0.0193712 0.0193712 0.0193712 0.0193712 0.0193712 0.0193712 0.0193712 0.0193712
# 4_ORWA_TWL 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3.24827e-06 1.62553e-06 0 1.63128e-06 4.90254e-06 9.83554e-06 0 1.485e-05 0.00034086 0.000526857 0.000995359 0.00350872 0.0062418 0.0098434 0.00611416 0.00380293 0.00270958 0.00227891 0.00248424 0.00219662 0.00235343 0.00184266 0.00237626 0.00244302 0.00316768 0.00428509 0.00343872 0.00373233 0.00472475 0.00427338 0.00498314 0.00136031 0.00037074 0.0129262 0.000585626 0.00132175 0.000578444 0.00933966 0.00139904 0.0027238 0.00147842 0.00192891 0.000901595 0.0011052 0.00143119 0.00103565 0.00495599 0.00943395 0.018185 0.020237 0.0353912 0.0682349 0.029325 0.0534872 0.0264387 0.02161 0.0411889 0.0653104 0.0282927 0.0437517 0.0519436 0.0567598 0.0391411 0.063126 0.0431167 0.0442726 0.0250445 0.012013 0.00342748 0.00110183 0.00107721 0.000366013 0.000326334 0.000793566 0.000891261 5.527e-05 9.60218e-05 5.26498e-05 4.54768e-05 3.30537e-05 3.19689e-05 5.66002e-05 1.48562e-05 1.42415e-05 3.17812e-05 0.000105591 0.000223298 0.000231596 0.0001204 0.000139949 0.000261273 0.000131496 0.000139695 0.00102833 0.00102939 0.00102939 0.00102939 0.00102939 0.00102939 0.00102939 0.00102939 0.00102939 0.00102939 0.00102939 0.00102939
# 5_ORWA_NONTWL 6.6913e-06 6.69134e-06 1.17099e-05 0.000608923 0.000594209 0.000594539 0.000154162 3.68691e-05 3.6869e-05 2.17859e-05 3.85428e-05 5.02714e-05 6.53501e-05 8.04274e-05 9.38277e-05 0.000122305 0.000123976 0.000139047 0.000152442 0.000326646 0.000182606 0.000197675 0.000211068 0.000226136 0.000241203 0.000256271 0.000373509 0.000284759 0.000299827 0.00310541 0.00127801 0.00110428 0.00106463 0.000737092 0.000858462 0.00156425 0.00193487 0.0029499 0.00385453 0.00374748 0.00301654 0.0033249 0.00199816 0.00125445 0.00176377 0.00217043 0.00166404 0.00286311 0.00255524 0.00282631 0.00184313 0.00297888 0.00477763 0.00550933 0.00906055 0.00405279 0.00209025 0.00380386 0.00203792 0.00250988 0.00211841 0.00281174 0.00344259 0.00252285 0.00109106 0.00200232 0.0019067 0.000855914 0.0016835 0.000474712 0.00107584 0.000979824 0.000979849 0.00103146 0.000821868 0.000623191 0.000937111 0.000657252 0.00134047 0.00115395 0.00267532 0.000894118 0.00173902 0.00228238 0.0024269 0.00309304 0.00165366 0.00221055 0.00374451 0.00536001 0.0110794 0.00579524 0.00571235 0.00770321 0.0118228 0.0110101 0.0202895 0.0205344 0.0319872 0.0164243 0.0149452 0.0266355 0.0342998 0.0384034 0.0636759 0.0405084 0.0217851 0.0535231 0.070983 0.0303498 0.0712989 0.0111756 0.0194769 0.00307188 0.00162501 0.00169066 0.00115548 0.00147537 0.00246439 0.00225286 0.0014025 0.000540584 0.000741265 0.00113826 0.00170247 0.00121183 0.00170607 0.00135098 0.00348849 0.00305778 0.00340168 0.0032844 0.00331895 0.00616076 0.0078088 0.00111856 0.008234 0.00824252 0.00824252 0.00824252 0.00824252 0.00824252 0.00824252 0.00824252 0.00824252 0.00824252 0.00824252 0.00824252
# 6_OR_REC 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.00150263 0.00261991 0.00129084 0.00402843 0.00416331 0.00515416 0.0111513 0.00876155 0.0082418 0.0147515 0.0109443 0.0107705 0.00340208 0.0272304 0.0125605 0.0034048 0.00442275 0.00613562 0.0100183 0.0105285 0.0104659 0.00733803 0.00980611 0.0042446 0.00781235 0.00985193 0.00777123 0.00723321 0.0031718 0.00210649 0.00220864 0.00100555 0.00136534 0.00108251 0.00131286 0.00127744 0.00110346 0.00111061 0.0011968 0.00170288 0.0016628 0.00135846 0.00203134 0.00129278 0.00184867 0.00165366 0.00197908 0.00224656 0.00119222 0.00177094 0.00125557 0.00115523 0.00850394 0.00851274 0.00851274 0.00851274 0.00851274 0.00851274 0.00851274 0.00851274 0.00851274 0.00851274 0.00851274 0.00851274
# 7_WA_REC 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.00045446 8.93721e-05 0.000220638 0.000344409 0.000550184 0.000728368 0.000927443 0.000870414 0.000888678 0.000930707 0.00191669 0.00094502 0.00110715 0.000558147 0.00104278 0.00150864 0.00213974 0.00387438 0.0030289 0.00309948 0.00408428 0.00331728 0.00601772 0.0032161 0.0059582 0.00561526 0.00602125 0.0037787 0.00386164 0.00442967 0.00486119 0.00691585 0.00542775 0.00631982 0.00687438 0.00152098 0.00111002 0.00182457 0.00213374 0.000796098 0.00116203 0.0009704 0.000963559 0.0011519 0.00124244 0.00171624 0.0010381 0.00133197 0.00115447 0.00127469 0.00121157 0.00116902 0.00180759 0.00090398 0.000969841 0.000960947 0.000999464 0.000979457 0.00721001 0.00721747 0.00721747 0.00721747 0.00721747 0.00721747 0.00721747 0.00721747 0.00721747 0.00721747 0.00721747 0.00721747
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
           -15            15       -9.1926             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_3_CA_REC(3)
             0             5      0.122885          0.01            99             0          5          0          0          0          0          0          0          0  #  Q_extraSD_3_CA_REC(3)
           -15            15      -9.12907             0            99             0          1          0          0          0          0          0          2          1  #  LnQ_base_6_OR_REC(6)
             0             5     0.0843759          0.01            99             0          5          0          0          0          0          0          0          0  #  Q_extraSD_6_OR_REC(6)
           -20            15      -8.84878             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_7_WA_REC(7)
             0             5      0.385708          0.01            99             0          5          0          0          0          0          0          0          0  #  Q_extraSD_7_WA_REC(7)
           -15            15      -9.24929             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_8_CACPFV(8)
             0             5     0.0949664          0.01            99             0          5          0          0          0          0          0          0          0  #  Q_extraSD_8_CACPFV(8)
           -15            15      -11.4144             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_9_OR_RECOB(9)
             0             5      0.164776          0.01            99             0          5          0          0          0          0          0          0          0  #  Q_extraSD_9_OR_RECOB(9)
           -15            15      -1.50142             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_10_TRI_ORWA(10)
             0             5      0.138624          0.01            99             0          5          0          0          0          0          0          0          0  #  Q_extraSD_10_TRI_ORWA(10)
           -15            15     -0.945339             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_11_NWFSC_ORWA(11)
             0             5             0          0.01            99             0         -5          0          0          0          0          0          0          0  #  Q_extraSD_11_NWFSC_ORWA(11)
           -15            15     -0.636189             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_12_IPHC_ORWA(12)
             0             5       0.55178          0.01            99             0          5          0          0          0          0          0          0          0  #  Q_extraSD_12_IPHC_ORWA(12)
# timevary Q parameters 
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type     PHASE  #  parm_name
            -4             4      -2.65956             0            99            -1      1  # LnQ_base_6_OR_REC(6)_BLK2add_2004
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
            20            60       43.9609            40            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_1_CA_TWL(1)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_1_CA_TWL(1)
            -1             9       5.12592             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_1_CA_TWL(1)
            -1            30       18.2834             9            99             0          5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_1_CA_TWL(1)
          -999             9          -999          -999            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_1_CA_TWL(1)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_1_CA_TWL(1)
# 2   2_CA_NONTWL LenSelex
            20            60       44.6577            30            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_2_CA_NONTWL(2)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_2_CA_NONTWL(2)
            -1             9       5.20137             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_2_CA_NONTWL(2)
            -1            30       17.3814             9            99             0          5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_2_CA_NONTWL(2)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_2_CA_NONTWL(2)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_2_CA_NONTWL(2)
# 3   3_CA_REC LenSelex
            20            60       41.7101            40            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_3_CA_REC(3)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_3_CA_REC(3)
            -1             9       5.21234             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_3_CA_REC(3)
            -1            30            20             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_3_CA_REC(3)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_3_CA_REC(3)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_3_CA_REC(3)
# 4   4_ORWA_TWL LenSelex
            20            60       41.9442            40            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_4_ORWA_TWL(4)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_4_ORWA_TWL(4)
            -1             9       5.49607             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_4_ORWA_TWL(4)
            -1            30       18.2404             9            99             0          5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_4_ORWA_TWL(4)
          -999             9          -999          -999            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_4_ORWA_TWL(4)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_4_ORWA_TWL(4)
# 5   5_ORWA_NONTWL LenSelex
            20            60       50.8705            30            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_5_ORWA_NONTWL(5)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_5_ORWA_NONTWL(5)
            -1             9       5.43964             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_5_ORWA_NONTWL(5)
            -1            30            20             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_5_ORWA_NONTWL(5)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_5_ORWA_NONTWL(5)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_5_ORWA_NONTWL(5)
# 6   6_OR_REC LenSelex
            20            60       36.7222            30            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_6_OR_REC(6)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_6_OR_REC(6)
            -1             9       4.14256             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_6_OR_REC(6)
            -1            30            12             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_6_OR_REC(6)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_6_OR_REC(6)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_6_OR_REC(6)
# 7   7_WA_REC LenSelex
            20            60       42.7554            30            99             0          6          0          0          0          0          0          0          0  #  Size_DblN_peak_7_WA_REC(7)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_7_WA_REC(7)
            -1             9        4.3168             6            99             0          6          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_7_WA_REC(7)
            -1            30            20             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_7_WA_REC(7)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_7_WA_REC(7)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_7_WA_REC(7)
# 8   8_CACPFV LenSelex
# 9   9_OR_RECOB LenSelex
            20            60       35.1187            30            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_9_OR_RECOB(9)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_9_OR_RECOB(9)
            -1             9       4.60715             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_9_OR_RECOB(9)
            -1            30            20             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_9_OR_RECOB(9)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_9_OR_RECOB(9)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_9_OR_RECOB(9)
# 10   10_TRI_ORWA LenSelex
            20            80       79.9717            30            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_10_TRI_ORWA(10)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_10_TRI_ORWA(10)
            -1             9       7.08041             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_10_TRI_ORWA(10)
            -1            30            12             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_10_TRI_ORWA(10)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_10_TRI_ORWA(10)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_10_TRI_ORWA(10)
# 11   11_NWFSC_ORWA LenSelex
            20            60       48.8443            40            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_11_NWFSC_ORWA(11)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_11_NWFSC_ORWA(11)
            -1             9       6.23401             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_11_NWFSC_ORWA(11)
            -1            30            20             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_11_NWFSC_ORWA(11)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_11_NWFSC_ORWA(11)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_11_NWFSC_ORWA(11)
# 12   12_IPHC_ORWA LenSelex
            20            60       53.9917            40            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_12_IPHC_ORWA(12)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_12_IPHC_ORWA(12)
            -1             9       4.13724             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_12_IPHC_ORWA(12)
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

