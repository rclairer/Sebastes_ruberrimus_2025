#V3.30.23.2;_safe;_compile_date:_Apr 17 2025;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.2
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:_https://groups.google.com/g/ss3-forum_and_NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:_https://nmfs-ost.github.io/ss3-website/
#_Source_code_at:_https://github.com/nmfs-ost/ss3-source-code

#C Yelloweye 2017 control file
#C file created using an r4ss function
#C file write time: 2025-04-23  00:42:27
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
 2005 2024
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
 1 35 1 30 99 0 2 0 0 0 0 0 0 0 # L_at_Amin_Fem_GP_1
 40 120 61.8695 66 99 0 2 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0.01 0.2 0.0758867 0.05 99 0 1 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_1
 0.01 0.5 0.150094 0.1 99 0 3 0 0 0 0 0 0 0 # CV_young_Fem_GP_1
 0.01 0.5 0.0618255 0.1 99 0 7 0 0 0 0 0 0 0 # CV_old_Fem_GP_1
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
 -4 4 0.37671 0 99 0 3 0 0 0 0 0 0 0 # RecrDist_Area_2
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
             3            15       5.37072             5            99             0          3          0          0          0          0          0          0          0 # SR_LN(R0)
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
 1926.13 #_last_yr_nobias_adj_in_MPD; begin of ramp
 2014.6 #_first_yr_fullbias_adj_in_MPD; begin of plateau
 2014.73 #_last_yr_fullbias_adj_in_MPD
 2022.14 #_end_yr_for_ramp_in_MPD (can be in forecast to shape ramp, but SS3 sets bias_adj to 0.0 for fcast yrs)
 0.6514 #_max_bias_adj_in_MPD (typical ~0.8; -3 sets all years to 0.0; -2 sets all non-forecast yrs w/ estimated recdevs to 1.0; -1 sets biasadj=1.0 for all yrs w/ recdevs)
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
#  0.0170539 0.017652 0.0182729 0.0189164 0.0195834 0.0202735 0.0209884 0.0217303 0.0224997 0.0233013 0.0241354 0.0250115 0.0259277 0.0268854 0.0278744 0.0289182 0.0300308 0.0312091 0.0325032 0.0338959 0.0354028 0.037008 0.0386999 0.0404638 0.042221 0.0438689 0.0452295 0.0460996 0.0462101 0.0452376 0.0428514 0.038774 0.0327757 0.0247325 0.014686 0.00284605 -0.0103703 -0.0243444 -0.038268 -0.0513299 -0.062831 -0.0724028 -0.0802042 -0.0869791 -0.0939631 -0.102559 -0.113817 -0.127879 -0.143643 -0.158932 -0.170968 -0.177066 -0.174802 -0.161653 -0.134206 -0.0877142 -0.0175395 0.0770717 0.184738 0.268532 0.266103 0.157274 -0.0046436 -0.164259 -0.293328 -0.38172 -0.42695 -0.428825 -0.389147 -0.313145 -0.218412 -0.166842 -0.234579 -0.37714 -0.483381 -0.474276 -0.329264 -0.155476 -0.050612 0.132747 0.2242 0.431106 0.816243 0.264251 -0.00659843 0.0830288 0.436344 0.282723 0.247278 -0.0382642 0.213843 0.378144 0.434735 0.421435 0.166052 0.464537 0.31395 -0.0656582 -0.330538 -0.611059 -0.764783 -0.852239 -0.956403 -0.806304 -0.139855 -0.242904 -0.947127 -0.970819 -0.753915 -0.273846 0.154439 -0.421144 -0.248683 0.941023 0.0444826 -0.369608 0.0393729 0.546294 0.567945 1.04806 0.83933 0.757692 0.488665 0.381698 1.17466 0.444196 0.716141 0.344211 -0.362763 -0.419195 -0.394131 -0.424531 -0.168468 -0.0786835 -0.0644062 0 0 0 0 0 0 0 0 0 0 0 0 0
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
# 1_CA_TWL 0 5.36113e-06 8.04188e-06 1.34037e-05 1.60854e-05 2.14489e-05 2.41322e-05 2.94977e-05 3.21822e-05 3.75486e-05 4.29149e-05 4.55983e-05 5.09626e-05 5.36433e-05 5.90043e-05 6.16817e-05 6.70388e-05 6.97127e-05 7.50656e-05 8.04163e-05 8.30846e-05 8.84306e-05 9.10949e-05 9.64359e-05 9.90959e-05 0.000104431 0.000107087 0.000112416 0.000176613 0.00020607 0.000144551 0.000147176 0.000120377 0.000104286 0.000112254 6.4114e-05 4.53981e-05 0.000165552 0.000280411 0.000358006 0.000422334 0.000393218 0.000235662 0.000281481 0.000437815 0.000432981 0.00045266 0.000402586 0.000479745 0.00045402 0.000471891 0.000437905 0.000318631 7.44547e-05 0.000566908 0.00232044 0.00519221 0.00465963 0.00206304 0.00190309 0.0011031 0.00102244 0.00298738 0.00265304 0.00263873 0.00154823 0.00175423 0.00270052 0.0033256 0.00330335 0.00278023 0.00243543 0.00116592 0.00120967 0.00199083 0.00104143 0.0012987 0.00123332 0.00213069 0.00132492 0.00776634 0.00883872 0.0156653 0.0217953 0.0176927 0.0190346 0.0225092 0.0213826 0.0212719 0.0650932 0.0356005 0.0097723 0.0198889 0.145036 0.0503322 0.0413094 0.0074301 0.0107132 0.0190499 0.0374251 0.0123917 0.0141841 0.0214937 0.0293861 0.0132173 0.0101994 0.00829644 0.0380809 0.0159667 0.0117843 0.0245826 0.00210523 0.00171036 0.000945765 0.000320365 4.65692e-05 4.38911e-05 8.29206e-06 0 3.16698e-05 3.8712e-05 0.000100155 0 4.43819e-06 1.2535e-05 7.18692e-05 3.66718e-06 3.42655e-06 1.16975e-05 9.92961e-07 3.61146e-05 0.000110721 9.43844e-05 7.19025e-05 6.21246e-05 0.000129408 0.000742744 0.000754707 0.000765342 0.000774464 0.000781965 0.000784988 0.000784988 0.000784988 0.000784988 0.000784988 0.000784988 0.000784988
# 2_CA_NONTWL 0 1.87562e-05 3.48338e-05 5.35927e-05 6.96749e-05 8.84403e-05 0.00010453 0.000123303 0.000139398 0.000158175 0.00017695 0.000193042 0.000211809 0.000227888 0.000246642 0.000262707 0.000281445 0.000297494 0.000316215 0.000334927 0.000350951 0.000369645 0.000385651 0.000404324 0.00042031 0.000438962 0.000454926 0.000473552 0.000791746 0.000930935 0.000433467 0.00049216 0.000494672 0.00044904 0.000478209 0.00068893 0.000984983 0.00113435 0.00130002 0.00111629 0.00108745 0.00141713 0.00126883 0.0018972 0.00075445 0.00112099 0.00169948 0.00178255 0.00116773 0.00127456 0.00128424 0.000812547 0.00115048 0.000854524 0.00106151 0.00458365 0.0112036 0.0118144 0.00267309 0.00492741 0.00182891 0.00137766 0.00213041 0.00165822 0.000981781 0.00210263 0.000571954 0.000569397 0.00128962 0.000973886 0.000529301 0.000728982 0.000553241 0.000575014 0.00185454 0.00152153 0.00185317 0.00151555 0.00151199 0.00136297 0.00139243 0.00126584 0.00177324 0.00288318 0.00238802 0.00492201 0.00444033 0.00632045 0.00747518 0.0162062 0.0223284 0.0167611 0.0786097 0.0112959 0.00681422 0.00414101 0.00422943 0.0253399 0.0429143 0.0427089 0.0558629 0.0986572 0.204131 0.179346 0.0993894 0.10777 0.106971 0.13084 0.146689 0.0506172 0.0389133 0.00953072 0.0107423 7.86979e-05 0.000123046 0.00174403 0.00159996 0.000414064 0.00181897 0.00119056 0.000333825 6.66654e-05 0.000313701 0.00129979 0.000778669 2.6089e-05 0.000488066 0 0.00130445 0 0 0 0.00195879 0.00423457 0.00130222 0 0 0 0 0 0 0 0 0 0 0 0 0
# 3_CA_REC 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.000169064 0.000340946 0.000391465 0.00052169 0.000654827 0.000786319 0.000917713 0.00105281 0.00118683 0.00141327 0.0013935 0.00122279 0.00176333 0.00163664 0.000873446 0.000837665 0.000689701 0.000928823 0.00162718 0.00132224 0.002665 0.00348743 0.00428797 0.0051195 0.00452554 0.00391272 0.00495867 0.00602599 0.00680446 0.00679121 0.0106652 0.00931219 0.00670362 0.0052885 0.00676101 0.00713068 0.00626328 0.00969676 0.010661 0.0109054 0.0130707 0.0143277 0.016543 0.0151166 0.0200881 0.0266714 0.0294554 0.0314072 0.0375117 0.0357821 0.035079 0.0434816 0.0445844 0.0300971 0.0718056 0.0438203 0.0697595 0.119704 0.0677457 0.0814758 0.0679874 0.0743787 0.061913 0.0488352 0.0363264 0.0160853 0.0286197 0.0276299 0.0265927 0.0368274 0.0137409 0.0354028 0.0221686 0.0132745 0.00506333 0.0095141 0.00225069 0.0021238 0.00200723 0.00758289 0.00180102 0.00849323 0.00160912 0.00302596 0.00284749 0.00133921 0.00125485 0.00234391 0.00136009 0.00460066 0.00474154 0.00545853 0.00161318 0.00306479 0.0027699 0.0066123 0.00305286 0.017522 0.0178042 0.0180551 0.0182703 0.0184473 0.0185186 0.0185186 0.0185186 0.0185186 0.0185186 0.0185186 0.0185186
# 4_ORWA_TWL 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3.35142e-06 2.02614e-06 1.80078e-07 2.02358e-06 6.00187e-06 1.17571e-05 2.35331e-07 1.71162e-05 0.000385349 0.000595304 0.00112151 0.00395699 0.00704176 0.0111088 0.00690283 0.00429484 0.00285357 0.00244683 0.00277564 0.0024633 0.00255861 0.00204076 0.00258304 0.00271432 0.00351576 0.00480619 0.00377755 0.00413427 0.00525327 0.00478539 0.00557103 0.00139155 0.000365256 0.0144994 0.00040776 0.00125697 0.000636287 0.00966242 0.000458943 0.00216963 0.000984432 0.000802254 9.33072e-05 0.000778309 0.00133188 0.00113079 0.00556569 0.0105002 0.0204476 0.022805 0.0351209 0.0297773 0.0160801 0.0312203 0.00994983 0.0227451 0.0451794 0.0692788 0.0302991 0.0522322 0.0605913 0.0668773 0.0491415 0.0753597 0.0536738 0.0571629 0.0375236 0.0183849 0.000561155 0.00161331 0.000801831 0.000972166 0.000311122 0.000218179 0.000489814 8.27668e-05 0.000114763 5.91909e-05 1.61276e-05 4.93065e-05 9.55667e-05 8.41807e-05 0.000109842 7.27498e-05 5.96462e-05 0.000144121 0.00030417 0.000314668 0.000163179 0.000189088 0.000351736 0.000176527 0.000187022 0.00107342 0.00109071 0.00110608 0.00111926 0.0011301 0.00113447 0.00113447 0.00113447 0.00113447 0.00113447 0.00113447 0.00113447
# 5_ORWA_NONTWL 7.14102e-06 8.15533e-06 1.42177e-05 0.000695096 0.000678998 0.000679427 0.000176254 4.21052e-05 4.29096e-05 2.42722e-05 4.3969e-05 5.78314e-05 7.46317e-05 9.13862e-05 0.000108151 0.000141022 0.000141611 0.00015834 0.000175056 0.000372603 0.000208441 0.000225114 0.000241772 0.000258415 0.000275022 0.000291632 0.000424657 0.000324818 0.000341359 0.00353237 0.00145396 0.00125598 0.00121037 0.000836817 0.000975221 0.00177719 0.00219689 0.00334787 0.00437203 0.00425133 0.00341952 0.00377022 0.00226533 0.00142158 0.00199709 0.00245694 0.00188332 0.00323782 0.00288809 0.00319263 0.00208077 0.00336144 0.00538932 0.00621365 0.0102155 0.00457185 0.00235775 0.00429566 0.00230316 0.00264531 0.00227602 0.00314123 0.00385901 0.00274131 0.00120651 0.00217236 0.00211431 0.000948318 0.00188553 0.000518972 0.00118852 0.00108411 0.00109364 0.00115314 0.000838534 0.00061798 0.00104982 0.000702592 0.00149602 0.00126603 0.00301927 0.00101043 0.00195969 0.00256776 0.00272739 0.0034676 0.00185197 0.00247318 0.00419167 0.00600582 0.0124344 0.00652547 0.00645944 0.00874629 0.0134565 0.0120654 0.0219768 0.0198784 0.0333554 0.0171798 0.015715 0.0281661 0.0365191 0.0417882 0.0709389 0.0465177 0.0256168 0.0645085 0.0880807 0.0392287 0.095954 0.0156201 0.0276057 0.00373103 0.00180368 0.00136652 0.00134984 0.000830275 0.00197263 0.00129225 0.000849644 0.0010868 0.000334751 0.000396302 0.000628686 0.000900958 0.000758022 0.00149232 0.0047605 0.00416584 0.00462518 0.00445788 0.00449437 0.0083191 0.0105241 0.00150475 0.00863655 0.00877566 0.00889932 0.00900539 0.00909261 0.00912776 0.00912776 0.00912776 0.00912776 0.00912776 0.00912776 0.00912776
# 6_OR_REC 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.00168431 0.00293058 0.0014418 0.00449838 0.00465111 0.00576423 0.0124928 0.00984833 0.00929754 0.0167056 0.0124202 0.01177 0.0036742 0.0287747 0.0130591 0.00355176 0.00463988 0.00647802 0.0106565 0.0114422 0.0116265 0.00838526 0.0114539 0.00507236 0.00959571 0.0125815 0.0102704 0.00996831 0.00443248 0.00300344 0.00313883 0.00142448 0.00192732 0.00152258 0.00183733 0.00178086 0.00153178 0.00153556 0.00164972 0.00233869 0.00227631 0.00185333 0.00276378 0.00175301 0.00249841 0.0022289 0.0026599 0.00301218 0.00159413 0.00236028 0.00166933 0.00153246 0.00879562 0.00893729 0.00906324 0.00917125 0.00926008 0.00929588 0.00929588 0.00929588 0.00929588 0.00929588 0.00929588 0.00929588
# 7_WA_REC 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.00101735 0.00106499 0.00219464 0.00108393 0.00110826 0.000644904 0.0012103 0.00175832 0.00249849 0.0043589 0.00336795 0.00337267 0.00437404 0.00356396 0.00650352 0.00583027 0.0149928 0.0143165 0.015846 0.0109422 0.0113724 0.012683 0.0146196 0.0211105 0.0189181 0.0223605 0.0246557 0.00341394 0.00237071 0.00404324 0.00390053 0.00148499 0.00212501 0.00175019 0.00167458 0.00192923 0.00191413 0.00256838 0.00169162 0.00209302 0.00195683 0.00190737 0.0017143 0.00167056 0.00253678 0.00123879 0.00133197 0.00133321 0.00140304 0.00139121 0.00798488 0.00811349 0.00822782 0.00832588 0.00840652 0.00843902 0.00843902 0.00843902 0.00843902 0.00843902 0.00843902 0.00843902
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
         6         1         0         1         0         1  #  6_OR_REC
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
           -15            15      -9.11684             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_3_CA_REC(3)
             0             5      0.134074          0.01            99             0          5          0          0          0          0          0          0          0  #  Q_extraSD_3_CA_REC(3)
           -15            15      -10.6512             0            99             0         -1          0          0          0          0          0          2          1  #  LnQ_base_6_OR_REC(6)
             0             5       1.00464          0.01            99             0          5          0          0          0          0          0          0          0  #  Q_extraSD_6_OR_REC(6)
           -20            15      -8.68775             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_7_WA_REC(7)
             0             5       0.45972          0.01            99             0          5          0          0          0          0          0          0          0  #  Q_extraSD_7_WA_REC(7)
           -15            15       -9.1606             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_8_CACPFV(8)
             0             5     0.0762782          0.01            99             0          5          0          0          0          0          0          0          0  #  Q_extraSD_8_CACPFV(8)
           -15            15      -11.1129             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_9_OR_RECOB(9)
             0             5      0.170466          0.01            99             0          5          0          0          0          0          0          0          0  #  Q_extraSD_9_OR_RECOB(9)
           -15            15      -1.35525             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_10_TRI_ORWA(10)
             0             5     0.0975158          0.01            99             0          5          0          0          0          0          0          0          0  #  Q_extraSD_10_TRI_ORWA(10)
           -15            15     -0.625087             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_11_NWFSC_ORWA(11)
             0             5             0          0.01            99             0         -5          0          0          0          0          0          0          0  #  Q_extraSD_11_NWFSC_ORWA(11)
           -15            15     -0.294378             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_12_IPHC_ORWA(12)
             0             5      0.561107          0.01            99             0          5          0          0          0          0          0          0          0  #  Q_extraSD_12_IPHC_ORWA(12)
# timevary Q parameters 
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type     PHASE  #  parm_name
            -4             4      -0.59813             0            99            -1      1  # LnQ_base_6_OR_REC(6)_BLK2add_2005
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
            20            60       44.2448            40            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_1_CA_TWL(1)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_1_CA_TWL(1)
            -1             9       5.14799             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_1_CA_TWL(1)
            -1            30       18.3007             9            99             0          5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_1_CA_TWL(1)
          -999             9          -999          -999            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_1_CA_TWL(1)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_1_CA_TWL(1)
# 2   2_CA_NONTWL LenSelex
            20            60       44.2795            30            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_2_CA_NONTWL(2)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_2_CA_NONTWL(2)
            -1             9       5.17743             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_2_CA_NONTWL(2)
            -1            30       17.3086             9            99             0          5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_2_CA_NONTWL(2)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_2_CA_NONTWL(2)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_2_CA_NONTWL(2)
# 3   3_CA_REC LenSelex
            20            60       41.9138            40            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_3_CA_REC(3)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_3_CA_REC(3)
            -1             9       5.22646             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_3_CA_REC(3)
            -1            30            20             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_3_CA_REC(3)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_3_CA_REC(3)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_3_CA_REC(3)
# 4   4_ORWA_TWL LenSelex
            20            60       43.9178            40            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_4_ORWA_TWL(4)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_4_ORWA_TWL(4)
            -1             9       5.63523             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_4_ORWA_TWL(4)
            -1            30       18.2918             9            99             0          5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_4_ORWA_TWL(4)
          -999             9          -999          -999            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_4_ORWA_TWL(4)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_4_ORWA_TWL(4)
# 5   5_ORWA_NONTWL LenSelex
            20            60        51.542            30            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_5_ORWA_NONTWL(5)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_5_ORWA_NONTWL(5)
            -1             9       5.46771             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_5_ORWA_NONTWL(5)
            -1            30            20             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_5_ORWA_NONTWL(5)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_5_ORWA_NONTWL(5)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_5_ORWA_NONTWL(5)
# 6   6_OR_REC LenSelex
            20            60       37.1766            30            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_6_OR_REC(6)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_6_OR_REC(6)
            -1             9        4.1776             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_6_OR_REC(6)
            -1            30            12             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_6_OR_REC(6)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_6_OR_REC(6)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_6_OR_REC(6)
# 7   7_WA_REC LenSelex
            20            60       43.7951            30            99             0          6          0          0          0          0          0          0          0  #  Size_DblN_peak_7_WA_REC(7)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_7_WA_REC(7)
            -1             9       4.45513             6            99             0          6          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_7_WA_REC(7)
            -1            30            20             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_7_WA_REC(7)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_7_WA_REC(7)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_7_WA_REC(7)
# 8   8_CACPFV LenSelex
# 9   9_OR_RECOB LenSelex
            20            60       35.2829            30            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_9_OR_RECOB(9)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_9_OR_RECOB(9)
            -1             9       4.61113             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_9_OR_RECOB(9)
            -1            30            20             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_9_OR_RECOB(9)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_9_OR_RECOB(9)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_9_OR_RECOB(9)
# 10   10_TRI_ORWA LenSelex
            20            80         79.97            30            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_10_TRI_ORWA(10)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_10_TRI_ORWA(10)
            -1             9       7.08601             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_10_TRI_ORWA(10)
            -1            30            12             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_10_TRI_ORWA(10)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_10_TRI_ORWA(10)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_10_TRI_ORWA(10)
# 11   11_NWFSC_ORWA LenSelex
            20            60       49.8442            40            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_11_NWFSC_ORWA(11)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_11_NWFSC_ORWA(11)
            -1             9       6.26022             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_11_NWFSC_ORWA(11)
            -1            30            20             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_descend_se_11_NWFSC_ORWA(11)
          -999             9          -999            -5            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_11_NWFSC_ORWA(11)
          -999             9          -999             9            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_11_NWFSC_ORWA(11)
# 12   12_IPHC_ORWA LenSelex
            20            60        54.362            40            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_12_IPHC_ORWA(12)
           -15             4           -15           -15            99             0         -5          0          0          0          0          0          0          0  #  Size_DblN_top_logit_12_IPHC_ORWA(12)
            -1             9       4.17934             6            99             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_12_IPHC_ORWA(12)
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
      4      1  0.530617
      4      2  0.287985
      4      3  0.530612
      4      4  0.248134
      4      5  0.360935
      4      6  0.372521
      4      7         1
      4      8  0.544796
      4      9  0.544345
      4     10  0.481012
      4     11   0.52232
      4     12   0.40092
      5      2         1
      5      3         1
      5      4         1
      5      5  0.169746
      5      6  0.861957
      5      7         1
      5     11         1
      5     12  0.040995
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

