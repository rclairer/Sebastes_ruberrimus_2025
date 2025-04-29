library(here)
library(r4ss)
library(dplyr)


model_directory <- here::here('model')
base_model_path <- here::here('model', '2025_base_model', "updated_alldata_tunecomps_fitbias_ctl_tunecomps_start_20250416")
sensitivity_dir <- here::here('model', 'sensitivities', 'X')


inputs <- SS_read(base_model_path, ss_new = TRUE)
base_out <- SS_output(base_model_path)


copy_SS_inputs(dir.old = base_model_path, 
               dir.new = sensitivity_dir)

other_files <- c("Report.sso", "CompReport.sso", "warning.sso")
lapply(other_files, function(files){
  file.copy(
    from = here::here(base_model_path, files),
    to = here::here(sensitivity_dir, files),
    overwrite = TRUE
  )
})


#' @params data_type list of types of data to remove all or only certain fleets or only certain years
#' data_type = c("catch", "CPUE", "lencomp", "agecomp", "MeanSize_at_Age_obs")
#' 
type <- c("CPUE")
fleet_or_index <- c(9,10,11,12)
only_these_years <- c(2020,2021,2022,2023)

toggle_off_data <- function(
    data_type = c("CPUE"),
    fleet_or_index = c(9,10,11,12),
    only_these_years = c(2020,2021,2022,2023)
    )
{
  ##### Removing catches ##### ---------------------------------------------------
  if("catch" %in% type){
    catch_chr <- paste0("(", fleet_or_index, ")$")
    not_in_indices <- setdiff(fleet_or_index, inputs$dat$CPUE$index)
    catch_und <- paste0(not_in_indices, "_")
    catch_chr2 <- paste0("(", not_in_indices, ")$")
  
    if(is.null(only_these_years)){
      years_to_match <- unique(inputs$dat$catch$year)
      
      # QUESTION: If catch is removed, and you do have to remove length and age comp associated with 
      # that catch fleet, do you also have to remove the selectivity parameters for that fleet?
      
      # Remove selex types and params for catch data that was removed for all years
      # QUESTION: Do these need to be removed, or can they be fixed?
      inputs$ctl$size_selex_types <- inputs$ctl$size_selex_types[-grep(paste(catch_und, collapse = "|"), rownames(inputs$ctl$size_selex_types)),]
      inputs$ctl$size_selex_parms <- inputs$ctl$size_selex_parms[-grep(paste(catch_chr2, collapse = "|"), rownames(inputs$ctl$size_selex_parms)),]
      inputs$ctl$age_selex_types <- inputs$ctl$age_selex_types[-grep(paste(catch_und, collapse = "|"), rownames(inputs$ctl$age_selex_types)),]
      inputs$ctl$age_selex_parms <- inputs$ctl$age_selex_parms[-grep(paste(catch_chr2, collapse = "|"), rownames(inputs$ctl$age_selex_parms)),]
      
      # QUESTION: If catch selectivity is mirrored elsewhere, and the catch, length , 
      # and age comp data for that fleet are removed what do you do to that selectivity?
      
      
    } else{
      years_to_match <- only_these_years
    }
    
    inputs$dat$catch <- inputs$dat$catch |>
      mutate(year = case_when(index %in% fleet_or_index & year %in% years_to_match ~ -1*abs(year), 
                              TRUE ~ year))
    
    # QUESTION: You do have to remove length and age comps for a catch fleet if that 
    # catch fleet is removed, right?
    
    # Set length and age comp data to negative year if catch is removed and 
    # doesn't have associated catch or index data
    inputs$dat$lencomp <- inputs$dat$lencomp |>
      mutate(year = case_when(fleet %in% not_in_indices & year %in% years_to_match ~ -1*abs(year), 
                              TRUE ~ year))
    inputs$dat$agecomp <- inputs$dat$agecomp |>
      mutate(year = case_when(fleet %in% not_in_indices & year %in% years_to_match ~ -1*abs(year), 
                              TRUE ~ year))
    if(!is.null(inputs$dat$MeanSize_at_Age_obs)){
      inputs$dat$MeanSize_at_Age_obs <- inputs$dat$MeanSize_at_Age_obs |>
        mutate(year = case_when(fleet %in% not_in_indices & year %in% years_to_match ~ -1*abs(year), 
                                TRUE ~ year))
    }
    
  }
  ##### Removing indices ##### ---------------------------------------------------
  ## TO DO: add option if fleet_or_index isn't filled in then remove all fleets for that data set
  ## TO DO: add option if only_these_years IS filled in to only remove data for those years for all fleets if no fleets named and 
  ##        for only the list of fleets if it is filled in
  
  # Creates variations of vectors to remove that are seen in fleets and row names of data and parameters
  if("CPUE" %in% type){
    indices_chr <- paste0("(", fleet_or_index, ")$")
    not_in_catch <- setdiff(fleet_or_index, inputs$dat$catch$fleet)
    indices_und <- paste0(not_in_catch, "_")
    indices_chr2 <- paste0("(", not_in_catch, ")$")
    indices_chr2_und <- paste0("(", not_in_catch, ")$")
    
    
    # If no years in only_these_years, then remove all years
    if(is.null(only_these_years)){
      years_to_match <- unique(inputs$dat$CPUE$year)
    } else{
      years_to_match <- only_these_years
    }
    
    # Set indices to negative year to remove
    inputs$dat$CPUE <- inputs$dat$CPUE |>
      mutate(year = case_when(index %in% fleet_or_index & year %in% years_to_match ~ -1*abs(year), 
                              TRUE ~ year))
    
    # Set length and age comp data to negative year if index is removed and 
    # doesn't have associated catch data
    inputs$dat$lencomp <- inputs$dat$lencomp |>
      mutate(year = case_when(fleet %in% not_in_catch & year %in% years_to_match ~ -1*abs(year), 
                              TRUE ~ year))
    inputs$dat$agecomp <- inputs$dat$agecomp |>
      mutate(year = case_when(fleet %in% not_in_catch & year %in% years_to_match ~ -1*abs(year), 
                               TRUE ~ year))
    if(!is.null(inputs$dat$MeanSize_at_Age_obs)){
      inputs$dat$MeanSize_at_Age_obs <- inputs$dat$MeanSize_at_Age_obs |>
        mutate(year = case_when(fleet %in% not_in_catch & year %in% years_to_match ~ -1*abs(year), 
                                TRUE ~ year))
    }
    
    ## Remove Q, Selex, and T-V params if indices are fully removed
    if(is.null(only_these_years)){
      # Remove catchability params if indices are removed
      inputs$ctl$Q_options <- inputs$ctl$Q_options |>
        filter(! fleet %in% indices_to_remove)
      inputs$ctl$Q_parms <- inputs$ctl$Q_parms[!grepl(paste(indices_chr, collapse = "|"), rownames(inputs$ctl$Q_parms)),]
      
      # Remove selectivity params if indices are removed and doesn't have associated catch data
      # QUESTION: Do these need to be removed, or can they be fixed?
      inputs$ctl$size_selex_types <- inputs$ctl$size_selex_types[!grepl(paste(indices_und, collapse = "|"), rownames(inputs$ctl$size_selex_types)),]
      inputs$ctl$size_selex_parms <- inputs$ctl$size_selex_parms[!grepl(paste(indices_chr2, collapse = "|"), rownames(inputs$ctl$size_selex_parms)),]
      inputs$ctl$age_selex_types <- inputs$ctl$age_selex_types[!grepl(paste(indices_und, collapse = "|"), rownames(inputs$ctl$age_selex_types)),]
      inputs$ctl$age_selex_parms <- inputs$ctl$age_selex_parms[!grepl(paste(indices_chr2, collapse = "|"), rownames(inputs$ctl$age_selex_parms)),]
      
      ## TO DO: add code to remove time-varying parameters and other parameters for 
      #  an index if it is removed
      inputs$ctl$Q_parms_tv[grepl(paste(indices_chr2_und, collapse = "|"), rownames(inputs$ctl$Q_parms_tv)),] <- NULL
    }
  }
  ##### Removing length comps ##### ---------------------------------------------
  if("lencomp" %in% type){
    if(is.null(only_these_years)){
      years_to_match <- unique(inputs$dat$lencomp$year)

      # If lencomp belongs to an index, need to fix selex params
      if(!fleet_or_index %in% unique(inputs$dat$catch$fleet)){
        
        inputs$ctl$size_selex_parms <- inputs$ctl$size_selex_parms |>
          mutate(PHASE = case_when(grepl(paste(not_in_catch, collapse = "|"), rownames()) ~ abs(PHASE)*-1,
                                  TRUE ~ PHASE))
        
      }
    } else{
      years_to_match <- only_these_years
    }
    
    inputs$dat$lencomp <- inputs$dat$lencomp |>
      mutate(year = case_when(fleet %in% fleet_or_index & year %in% years_to_match ~ -1*abs(year), 
                              TRUE ~ year))
  }
}


## TO DO - DEAL WITH MIRRORING SELEX PARAMS
# In terms of a toggling function, it would be good to figuring out mirroring and check presence/absence of comp data for at least 1 of the fleets in the set that are sharing the parameters.
# Copy mirrored selex types and params to CACPFV now that CA dockside is removed
# You don't need to remove the mirroring selex types

inputs$ctl$size_selex_types[grepl("8_", rownames(inputs$ctl$size_selex_types)),1:4] <- inputs$ctl$size_selex_types[grepl("3_", rownames(inputs$ctl$size_selex_types)),1:4]

# TO DO: FIX selex params instead of removing them when length/age data is removed
# Fix params if catch data is removed but still have length/age data
sensi_mod$ctl$size_selex_parms[grepl('IPHC_ORWA', rownames(sensi_mod$ctl$size_selex_parms)),]$PHASE <- 
  abs(sensi_mod$ctl$size_selex_parms[grepl('IPHC_ORWA', rownames(sensi_mod$ctl$size_selex_parms)),]$PHASE)*-1
