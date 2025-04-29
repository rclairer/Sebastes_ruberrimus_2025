#C file created using an r4ss function
#C file write time: 2025-04-29  15:58:05
#
1 #_benchmarks
2 #_MSY
0.5 #_SPRtarget
0.4 #_Btarget
#_Bmark_years: beg_bio, end_bio, beg_selex, end_selex, beg_relF, end_relF,  beg_recr_dist, end_recr_dist, beg_SRparm, end_SRparm (enter actual year, or values of 0 or -integer to be rel. endyr)
2010 2010 2010 2010 2010 2010 1916 2010 1916 2010
1 #_Bmark_relF_Basis
1 #_Forecast
12 #_Nforecastyrs
0.2 #_F_scalar
-12345  # code to invoke new format for expanded fcast year controls
# biology and selectivity vectors are updated annually in the forecast according to timevary parameters, so check end year of blocks and dev vectors
# input in this section directs creation of averages over historical years to override any time_vary changes
#_Types implemented so far: 1=M, 4=recr_dist, 5=migration, 10=selectivity, 11=rel. F, recruitment
#_list: type, method (1, 2), start year, end year
#_Terminate with -9999 for type
#_ year input can be actual year, or values <=0 to be rel. styr or endyr
#_Method = 0 (or omitted) means continue using time_vary parms; 1 means to use average of derived factor
 #_MG_type method st_year end_year
        10      1       0        0
        11      1       0        0
        12      1    -999        0
-9999 0 0 0
1 #_ControlRuleMethod
0.4 #_BforconstantF
0.1 #_BfornoF
1 #_Flimitfraction
3 #_N_forecast_loops
3 #_First_forecast_loop_with_stochastic_recruitment
0 #_fcast_rec_option
1 #_fcast_rec_val
0 #_Fcast_loop_control_5
2013 #_FirstYear_for_caps_and_allocations
1e-04 #_stddev_of_log_catch_ratio
1 #_Do_West_Coast_gfish_rebuilder_output
2013 #_Ydecl
2011 #_Yinit
1 #_fleet_relative_F
# Note that fleet allocation is used directly as average F if Do_Forecast=4 
2 #_basis_for_fcast_catch_tuning
# enter list of fleet number and max for fleets with max annual catch; terminate with fleet=-9999
-9999 -1
# enter list of area ID and max annual catch; terminate with area=-9999
-9999 -1
# enter list of fleet number and allocation group assignment, if any; terminate with fleet=-9999
-9999 -1
2 #_InputBasis
 #_year seas fleet catch_or_F
   2011    1     1       4.83
   2011    1     2       2.55
   2011    1     3       2.91
   2011    1     4       3.13
   2011    1     5       2.33
   2011    1     6       1.26
   2012    1     1       4.83
   2012    1     2       2.55
   2012    1     3       2.91
   2012    1     4       3.13
   2012    1     5       2.33
   2012    1     6       1.26
-9999 0 0 0
#
999 # verify end of input 
