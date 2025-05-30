#C file created using an r4ss function
#C file write time: 2025-05-30  11:49:04
#
1 #_benchmarks
2 #_MSY
0.5 #_SPRtarget
0.4 #_Btarget
#_Bmark_years: beg_bio, end_bio, beg_selex, end_selex, beg_relF, end_relF,  beg_recr_dist, end_recr_dist, beg_SRparm, end_SRparm (enter actual year, or values of 0 or -integer to be rel. endyr)
0 0 0 0 0 0 0 0 0 0
2 #_Bmark_relF_Basis
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
        10      1      -4        0
        11      1      -4        0
        12      1      -4        0
-9999 0 0 0
3 #_ControlRuleMethod
0.4 #_BforconstantF
0.1 #_BfornoF
-1 #_Flimitfraction
 #_year buffer
   2025      1
   2026      1
   2027      1
   2028      1
   2029      1
   2030      1
   2031      1
   2032      1
   2033      1
   2034      1
   2035      1
   2036      1
-9999 0
3 #_N_forecast_loops
3 #_First_forecast_loop_with_stochastic_recruitment
0 #_fcast_rec_option
1 #_fcast_rec_val
0 #_Fcast_loop_control_5
2037 #_FirstYear_for_caps_and_allocations
0 #_stddev_of_log_catch_ratio
0 #_Do_West_Coast_gfish_rebuilder_output
0 #_Ydecl
0 #_Yinit
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
 #_#Year Seas Fleet dead(N)               comment
    2025    1     1    0.14  #sum_for_2025: 43.91
    2025    1     2   10.00                      
    2025    1     3    9.00                      
    2025    1     4    7.76                      
    2025    1     5    8.88                      
    2025    1     6    6.60                      
    2025    1     7    1.53                      
    2026    1     1    0.14  #sum_for_2026: 44.61
    2026    1     2   10.00                      
    2026    1     3    9.00                      
    2026    1     4    7.76                      
    2026    1     5    9.58                      
    2026    1     6    6.60                      
    2026    1     7    1.53                      
    2027    1     1    0.52 #sum_for_2027: 107.03
    2027    1     2   10.74                      
    2027    1     3   19.25                      
    2027    1     4    1.85                      
    2027    1     5   52.51                      
    2027    1     6   17.41                      
    2027    1     7    4.75                      
    2028    1     1    0.52 #sum_for_2028: 107.15
    2028    1     2   10.85                      
    2028    1     3   19.39                      
    2028    1     4    1.83                      
    2028    1     5   52.67                      
    2028    1     6   17.27                      
    2028    1     7    4.62                      
    2029    1     1    0.53 #sum_for_2029: 106.98
    2029    1     2   10.92                      
    2029    1     3   19.47                      
    2029    1     4    1.82                      
    2029    1     5   52.66                      
    2029    1     6   17.11                      
    2029    1     7    4.47                      
    2030    1     1    0.53  #sum_for_2030: 106.5
    2030    1     2   10.96                      
    2030    1     3   19.51                      
    2030    1     4    1.80                      
    2030    1     5   52.45                      
    2030    1     6   16.92                      
    2030    1     7    4.33                      
    2031    1     1    0.53 #sum_for_2031: 105.75
    2031    1     2   10.96                      
    2031    1     3   19.51                      
    2031    1     4    1.78                      
    2031    1     5   52.06                      
    2031    1     6   16.72                      
    2031    1     7    4.19                      
    2032    1     1    0.53 #sum_for_2032: 104.83
    2032    1     2   10.94                      
    2032    1     3   19.48                      
    2032    1     4    1.76                      
    2032    1     5   51.54                      
    2032    1     6   16.51                      
    2032    1     7    4.07                      
    2033    1     1    0.53 #sum_for_2033: 103.77
    2033    1     2   10.91                      
    2033    1     3   19.43                      
    2033    1     4    1.73                      
    2033    1     5   50.91                      
    2033    1     6   16.30                      
    2033    1     7    3.96                      
    2034    1     1    0.52 #sum_for_2034: 102.79
    2034    1     2   10.88                      
    2034    1     3   19.39                      
    2034    1     4    1.71                      
    2034    1     5   50.29                      
    2034    1     6   16.12                      
    2034    1     7    3.88                      
    2035    1     1    0.52 #sum_for_2035: 101.64
    2035    1     2   10.83                      
    2035    1     3   19.32                      
    2035    1     4    1.69                      
    2035    1     5   49.57                      
    2035    1     6   15.91                      
    2035    1     7    3.80                      
    2036    1     1    0.52  #sum_for_2036: 100.5
    2036    1     2   10.78                      
    2036    1     3   19.23                      
    2036    1     4    1.67                      
    2036    1     5   48.85                      
    2036    1     6   15.71                      
    2036    1     7    3.74                      
-9999 0 0 0
#
999 # verify end of input 
