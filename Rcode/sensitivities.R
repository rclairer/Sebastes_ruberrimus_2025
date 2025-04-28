<<<<<<< HEAD
### RUN SENSITIVITIES FOR YELLOWEYE 2025 UPDATE ASSESSMENT
# CODE ADAPTED BY A. WHITMAN (ODFW) FROM K. OKEN (NWFSC)

# LAST UPDATE: 4/28/2025
=======

### RUN SENSITIVITIES FOR YELLOWEYE 2025 UPDATE ASSESSMENT 
# CODE ADAPTED BY A. WHITMAN (ODFW) FROM K. OKEN (NWFSC)

# LAST UPDATE: 4/28/2025 
>>>>>>> 00bc5e7e (writing sensitivity model files)

library(here)
library(r4ss)
library(dplyr)
<<<<<<< HEAD
library(purrr)
library(furrr)

# dir<-"C:/Users/daubleal/OneDrive - Oregon/Desktop/Sebastes_ruberrimus_2025"

model_directory <- here::here('model')
base_model_name <- here::here('model', 'updated_alldata_tunecomps_fitbias_ctl_tunecomps_start_20250427')
exe_loc <- here::here('model/ss3_win.exe')
base_model <- SS_read(base_model_name, ss_new = TRUE)
base_out <- SS_output(base_model_name)
=======

dir<-"C:/Users/daubleal/OneDrive - Oregon/Desktop/Sebastes_ruberrimus_2025"

model_directory <- 'model'
base_model_name <- 'updated_alldata_tunecomps_20250427'  # might need to update later? 
exe_loc <- here('model/ss3_win.exe')
base_model <- SS_read(file.path(dir,model_directory, base_model_name), ss_new = F)
base_out <- SS_output(file.path(dir,model_directory, base_model_name))
>>>>>>> 00bc5e7e (writing sensitivity model files)

# Write sensitivities -----------------------------------------------------

# Remove Indices ----------------------------------------------------------

## remove CA dockside (CA_REC)

sensi_mod <- base_model

sensi_mod$dat$CPUE <- sensi_mod$dat$CPUE |>
  filter(index != 3)

sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('CA_REC', rownames(sensi_mod$ctl$Q_options)),]
sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('CA_REC', rownames(sensi_mod$ctl$Q_parms)),]

<<<<<<< HEAD
SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '01_no_CA_dockside'), overwrite = TRUE)
=======
SS_write(sensi_mod, file.path(dir,model_directory, 'sensitivities', '01_no_CA_dockside'), overwrite = TRUE)
>>>>>>> 00bc5e7e (writing sensitivity model files)

## remove OR dockside (OR_REC)

sensi_mod <- base_model

sensi_mod$dat$CPUE <- sensi_mod$dat$CPUE |>
  filter(index != 6)

sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('OR_REC', rownames(sensi_mod$ctl$Q_options)),]
sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('OR_REC', rownames(sensi_mod$ctl$Q_parms)),]
<<<<<<< HEAD
sensi_mod$ctl$Q_parms_tv <- NULL

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '02_no_OR_dockside'), overwrite = TRUE)

## remove WA dockside
=======

SS_write(sensi_mod, file.path(dir,model_directory, 'sensitivities', '02_no_OR_dockside'), overwrite = TRUE)

## remove WA dockside 
>>>>>>> 00bc5e7e (writing sensitivity model files)

sensi_mod <- base_model

sensi_mod$dat$CPUE <- sensi_mod$dat$CPUE |>
  filter(index != 7)

sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('WA_REC', rownames(sensi_mod$ctl$Q_options)),]
sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('WA_REC', rownames(sensi_mod$ctl$Q_parms)),]

<<<<<<< HEAD
SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '03_no_WA_dockside'), overwrite = TRUE)

## remove CA CPFV
=======
SS_write(sensi_mod, file.path(dir,model_directory, 'sensitivities', '03_no_WA_dockside'), overwrite = TRUE)

## remove CA CPFV 
>>>>>>> 00bc5e7e (writing sensitivity model files)

sensi_mod <- base_model

sensi_mod$dat$CPUE <- sensi_mod$dat$CPUE |>
  filter(index != 8)

sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('CACPFV', rownames(sensi_mod$ctl$Q_options)),]
sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('CACPFV', rownames(sensi_mod$ctl$Q_parms)),]

<<<<<<< HEAD
# Need to remove length data, age data, and selectivities. If no catch or index, you can't have length or age data
sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(index != 8)
sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(index != 8)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[!grepl("8_", rownames(sensi_mod$ctl$size_selex_types)),]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[!grepl("(8)", rownames(sensi_mod$ctl$size_selex_parms)),]

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '04_no_CA_CPFV'), overwrite = TRUE)
=======
SS_write(sensi_mod, file.path(dir,model_directory, 'sensitivities', '04_no_CA_CPFV'), overwrite = TRUE)
>>>>>>> 00bc5e7e (writing sensitivity model files)

## remove OR onboard (OR_RECOB)

sensi_mod <- base_model

sensi_mod$dat$CPUE <- sensi_mod$dat$CPUE |>
  filter(index != 9)

sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('OR_RECOB', rownames(sensi_mod$ctl$Q_options)),]
sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('OR_RECOB', rownames(sensi_mod$ctl$Q_parms)),]

<<<<<<< HEAD

# Need to remove length data, age data, and selectivities. If no catch or index, you can't have length or age data
sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(index != 9)
sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(index != 9)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[!grepl("9_", rownames(sensi_mod$ctl$size_selex_types)),]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[!grepl("(9)", rownames(sensi_mod$ctl$size_selex_parms)),]

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '05_no_OR_onboard'), overwrite = TRUE)

## remove AFSC triennial
=======
SS_write(sensi_mod, file.path(dir,model_directory, 'sensitivities', '05_no_OR_onboard'), overwrite = TRUE)

## remove AFSC triennial 
>>>>>>> 00bc5e7e (writing sensitivity model files)

sensi_mod <- base_model

sensi_mod$dat$CPUE <- sensi_mod$dat$CPUE |>
  filter(index != 10)

sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('TRI_ORWA', rownames(sensi_mod$ctl$Q_options)),]
sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('TRI_ORWA', rownames(sensi_mod$ctl$Q_parms)),]

<<<<<<< HEAD
# Need to remove length data, age data, and selectivities. If no catch or index, you can't have length or age data
sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(index != 10)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[!grepl("10_", rownames(sensi_mod$ctl$size_selex_types)),]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[!grepl("(10)", rownames(sensi_mod$ctl$size_selex_parms)),]

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '06_no_AFSC_triennial'), overwrite = TRUE)

## remove NWFSC trawl
=======
SS_write(sensi_mod, file.path(dir,model_directory, 'sensitivities', '06_no_AFSC_triennial'), overwrite = TRUE)

## remove NWFSC trawl 
>>>>>>> 00bc5e7e (writing sensitivity model files)

sensi_mod <- base_model

sensi_mod$dat$CPUE <- sensi_mod$dat$CPUE |>
  filter(index != 11)

sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('NWFSC_ORWA', rownames(sensi_mod$ctl$Q_options)),]
sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('NWFSC_ORWA', rownames(sensi_mod$ctl$Q_parms)),]

<<<<<<< HEAD
# Need to remove length data, age data, and selectivities. If no catch or index, you can't have length or age data
sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(index != 11)
sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(index != 11)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[!grepl("11_", rownames(sensi_mod$ctl$size_selex_types)),]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[!grepl("(11)", rownames(sensi_mod$ctl$size_selex_parms)),]

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '07_no_NWFSC_trawl'), overwrite = TRUE)

## remove IPHC
=======
SS_write(sensi_mod, file.path(dir,model_directory, 'sensitivities', '07_no_NWFSC_trawl'), overwrite = TRUE)

## remove IPHC 
>>>>>>> 00bc5e7e (writing sensitivity model files)

sensi_mod <- base_model

sensi_mod$dat$CPUE <- sensi_mod$dat$CPUE |>
  filter(index != 12)

sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('IPHC_ORWA', rownames(sensi_mod$ctl$Q_options)),]
sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('IPHC_ORWA', rownames(sensi_mod$ctl$Q_parms)),]

<<<<<<< HEAD
# Need to remove length data, age data, and selectivities. If no catch or index, you can't have length or age data
sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(index != 12)
sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(index != 12)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[!grepl("12_", rownames(sensi_mod$ctl$size_selex_types)),]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[!grepl("(12)", rownames(sensi_mod$ctl$size_selex_parms)),] 

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '08_no_IPHC'), overwrite = TRUE)

## remove all indices

sensi_mod <- base_model

sensi_mod$dat$CPUE$year <- -1 * sensi_mod$dat$CPUE$year
sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_parms <- NULL
sensi_mod$ctl$Q_parms_tv <- NULL

# Need to remove length data, age data, and selectivities. If no catch or index, you can't have length or age data
indices_no_catches <- c(8, 9, 10, 11, 12)
indices_und <- paste0(indices_no_catches, "_")
indices_chr <- paste0("(", indices_no_catches, ")")

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(!fleet %in% indices_no_catches)
sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(!fleet %in% indices_no_catches)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[!grepl(paste(indices_und, collapse = "|"), rownames(sensi_mod$ctl$size_selex_types)),]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[!grepl(paste(indices_chr, collapse = "|"), rownames(sensi_mod$ctl$size_selex_parms)),]


SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '09_no_indices'), overwrite = TRUE)
=======
SS_write(sensi_mod, file.path(dir,model_directory, 'sensitivities', '08_no_IPHC'), overwrite = TRUE)

## remove all indices 

sensi_mod <- base_model

sensi_mod$dat$CPUE$year <- -1*sensi_mod$dat$CPUE$year
sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_parms <- NULL

SS_write(sensi_mod, file.path(dir,model_directory, 'sensitivities', '09_no_indices'),
         overwrite = TRUE)
>>>>>>> 00bc5e7e (writing sensitivity model files)


# Remove length comps -----------------------------------------------------

<<<<<<< HEAD
## remove CA trawl lengths
# We don't need to remove the selex params if we are removing length comps from 
# data that has catch
=======
## remove CA trawl lengths 
>>>>>>> 00bc5e7e (writing sensitivity model files)

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 1)

<<<<<<< HEAD
SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '10_no_CA_trawl_lengths'), overwrite = TRUE)
=======
sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[-grep('CA_TWL', rownames(sensi_mod$ctl$size_selex_types)),]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[-grep('CA_TWL', rownames(sensi_mod$ctl$size_selex_parms)),]

SS_write(sensi_mod, file.path(dir,model_directory, 'sensitivities', '10_no_CA_trawl_lengths'), overwrite = TRUE)
>>>>>>> 00bc5e7e (writing sensitivity model files)


## remove CA non-trawl lengths

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 2)

<<<<<<< HEAD
SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '11_no_CA_nontrawl_lengths'), overwrite = TRUE)


## remove CA dockside lengths
=======
sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[-grep('CA_NONTWL', rownames(sensi_mod$ctl$size_selex_types)),]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[-grep('CA_NONTWL', rownames(sensi_mod$ctl$size_selex_parms)),]

SS_write(sensi_mod, file.path(dir,model_directory, 'sensitivities', '11_no_CA_nontrawl_lengths'), overwrite = TRUE)


## remove CA dockside lengths ## REMOVE Q'S TOO?
>>>>>>> 00bc5e7e (writing sensitivity model files)

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 3)

<<<<<<< HEAD
SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '12_no_CA_dockside_lengths'), overwrite = TRUE)

## remove OR-WA trawl lengths
=======
sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[-grep('CA_TWL', rownames(sensi_mod$ctl$size_selex_types)),]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[-grep('CA_TWL', rownames(sensi_mod$ctl$size_selex_parms)),]

#sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_options)),]
#sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_parms)),]

# change CA-CPFV fleet mirror to OR rec (???)
sensi_mod$ctl$size_selex_types$Pattern[7]
sensi_mod$ctl$size_selex_types$Special[7]<-6

SS_write(sensi_mod, file.path(dir,model_directory, 'sensitivities', '12_no_CA_dockside_lengths'), overwrite = TRUE)

## remove OR-WA trawl lengths 
>>>>>>> 00bc5e7e (writing sensitivity model files)

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 4)

<<<<<<< HEAD
SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '13_no_ORWA_trawl_lengths'), overwrite = TRUE)


## remove OR-WA non-trawl lengths
=======
sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[-grep('ORWA_TWL', rownames(sensi_mod$ctl$size_selex_types)),]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[-grep('ORWA_TWL', rownames(sensi_mod$ctl$size_selex_parms)),]

SS_write(sensi_mod, file.path(dir,model_directory, 'sensitivities', '13_no_ORWA_trawl_lengths'), overwrite = TRUE)


## remove OR-WA non-trawl lengths 
>>>>>>> 00bc5e7e (writing sensitivity model files)

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 5)

<<<<<<< HEAD
SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '14_no_ORWA_non-trawl_lengths'), overwrite = TRUE)

# remove OR dockside lengths
=======
sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[-grep('ORWA_NONTWL', rownames(sensi_mod$ctl$size_selex_types)),]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[-grep('ORWA_NONTWL', rownames(sensi_mod$ctl$size_selex_parms)),]

SS_write(sensi_mod, file.path(dir,model_directory, 'sensitivities', '14_no_ORWA_non-trawl_lengths'), overwrite = TRUE)


## remove OR dockside lengths ## REMOVE Q'S ?? mirror CPUE to another fleet

>>>>>>> 00bc5e7e (writing sensitivity model files)
sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 6)

<<<<<<< HEAD
SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '15_no_OR_dockside_lengths'), overwrite = TRUE)

## remove WA dockside lengths
=======
sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[-grep('OR_REC', rownames(sensi_mod$ctl$size_selex_types)),]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[-grep('OR_REC', rownames(sensi_mod$ctl$size_selex_parms)),]

#sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_options)),]
#sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_parms)),]

# do I mirror the CPUE index to something? 

SS_write(sensi_mod, file.path(dir,model_directory, 'sensitivities', '15_no_OR_dockside_lengths'), overwrite = TRUE)

## remove WA dockside lengths 
>>>>>>> 00bc5e7e (writing sensitivity model files)

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 7)

<<<<<<< HEAD
SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '16_no_WA_dockside_lengths'), overwrite = TRUE)
=======
sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[-grep('WA_REC', rownames(sensi_mod$ctl$size_selex_types)),]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[-grep('WA_REC', rownames(sensi_mod$ctl$size_selex_parms)),]

#sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_options)),]
#sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_parms)),]

# do I mirror the CPUE index to something? 

SS_write(sensi_mod, file.path(dir,model_directory, 'sensitivities', '16_no_WA_dockside_lengths'), overwrite = TRUE)

>>>>>>> 00bc5e7e (writing sensitivity model files)

## remove CA CPFV lengths # note - mirrored to CA_REC

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 8)

<<<<<<< HEAD
# Ian said we shouldn't need to remove the mirroring selex type

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '17_no_CA_CPFV_lengths'), overwrite = TRUE)

## remove OR onboard lengths
=======
sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[-grep('CACPFV', rownames(sensi_mod$ctl$size_selex_types)),]
#sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[-grep('CACPFV', rownames(sensi_mod$ctl$size_selex_parms)),]

#sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_options)),]
#sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_parms)),]

# do I mirror the CPUE index to something? 

SS_write(sensi_mod, file.path(dir,model_directory, 'sensitivities', '17_no_CA_CPFV_lengths'), overwrite = TRUE)

## remove OR onboard lengths 
>>>>>>> 00bc5e7e (writing sensitivity model files)

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 9)

<<<<<<< HEAD
# Fix params by *-1 instead of removing them for indices - says Ian
sensi_mod$ctl$size_selex_parms[grepl('OR_RECOB', rownames(sensi_mod$ctl$size_selex_parms)),]$PHASE <- 
  abs(sensi_mod$ctl$size_selex_parms[grepl('OR_RECOB', rownames(sensi_mod$ctl$size_selex_parms)),]$PHASE)*-1

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '18_no_OR_onboard_lengths'), overwrite = TRUE)

## remove AFSC triennial lengths
=======
sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[-grep('OR_RECOB', rownames(sensi_mod$ctl$size_selex_types)),]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[-grep('OR_RECOB', rownames(sensi_mod$ctl$size_selex_parms)),]

#sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_options)),]
#sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_parms)),]

# do I mirror the CPUE index to something? 

SS_write(sensi_mod, file.path(dir,model_directory, 'sensitivities', '18_no_OR_onboard_lengths'), overwrite = TRUE)

## remove AFSC triennial lengths 
>>>>>>> 00bc5e7e (writing sensitivity model files)

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 10)

<<<<<<< HEAD
sensi_mod$ctl$size_selex_parms[grepl('TRI_ORWA', rownames(sensi_mod$ctl$size_selex_parms)),]$PHASE <- 
  abs(sensi_mod$ctl$size_selex_parms[grepl('TRI_ORWA', rownames(sensi_mod$ctl$size_selex_parms)),]$PHASE)*-1

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '19_no_AFSC_TRI_lengths'), overwrite = TRUE)

## remove NWFSC trawl lengths
=======
sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[-grep('TRI_ORWA', rownames(sensi_mod$ctl$size_selex_types)),]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[-grep('TRI_ORWA', rownames(sensi_mod$ctl$size_selex_parms)),]

#sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_options)),]
#sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_parms)),]

# do I mirror the CPUE index to something? 

SS_write(sensi_mod, file.path(dir,model_directory, 'sensitivities', '19_no_AFSC_TRI_lengths'), overwrite = TRUE)

## remove NWFSC trawl lengths 
>>>>>>> 00bc5e7e (writing sensitivity model files)

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 11)

<<<<<<< HEAD
sensi_mod$ctl$size_selex_parms[grepl('NWFSC_ORWA', rownames(sensi_mod$ctl$size_selex_parms)),]$PHASE <- 
  abs(sensi_mod$ctl$size_selex_parms[grepl('NWFSC_ORWA', rownames(sensi_mod$ctl$size_selex_parms)),]$PHASE)*-1

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '20_no_NWFSC_lengths'), overwrite = TRUE)

## remove IPHC lengths
=======
sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[-grep('NWFSC_ORWA', rownames(sensi_mod$ctl$size_selex_types)),]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[-grep('NWFSC_ORWA', rownames(sensi_mod$ctl$size_selex_parms)),]

#sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_options)),]
#sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_parms)),]

# do I mirror the CPUE index to something? 

SS_write(sensi_mod, file.path(dir,model_directory, 'sensitivities', '20_no_NWFSC_lengths'), overwrite = TRUE)

## remove IPHC lengths 
>>>>>>> 00bc5e7e (writing sensitivity model files)

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 12)

<<<<<<< HEAD
sensi_mod$ctl$size_selex_parms[grepl('IPHC_ORWA', rownames(sensi_mod$ctl$size_selex_parms)),]$PHASE <- 
  abs(sensi_mod$ctl$size_selex_parms[grepl('IPHC_ORWA', rownames(sensi_mod$ctl$size_selex_parms)),]$PHASE)*-1

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '21_no_IPHC_lengths'), overwrite = TRUE)

## remove all length comps

sensi_mod <- base_model

sensi_mod$ctl$lambdas <- sensi_mod$ctl$lambdas |> 
  bind_rows(data.frame(
    like_comp = 4,
    fleet = 1:12,
    phase = 1,
    value = 0,
    sizefreq_method = 0
  ))

sensi_mod$ctl$N_lambdas <- nrow(sensi_mod$ctl$lambdas)

# Turn size selex phase to -1 for indices that don't have catch or aren't mirroring catch selectivity
indices_list <- paste0("OR_RECOB", "TRI_ORWA", "NWFSC_ORWA", "IPHC_ORWA", collapse = "|")
sensi_mod$ctl$size_selex_parms[grepl(indices_list, rownames(sensi_mod$ctl$size_selex_parms)),]$PHASE <- 
  abs(sensi_mod$ctl$size_selex_parms[grepl(indices_list, rownames(sensi_mod$ctl$size_selex_parms)),]$PHASE)*-1

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '22_no_length_comps'), overwrite = TRUE)


# Remove age comps --------------------------------------------------------

## remove CA non-trawl

sensi_mod <- base_model

sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(fleet != 2)

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '23_no_CA_NONTWL_ages'), overwrite = TRUE)

## remove CA dockside ages

sensi_mod <- base_model

sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(fleet != 3)

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '24_no_CA_REC_ages'), overwrite = TRUE)

## remove OR-WA trawl ages

sensi_mod <- base_model

sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(fleet != 4)

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '25_no_ORWA_TWL_ages'), overwrite = TRUE)

## remove OR-WA non-trawl ages

sensi_mod <- base_model

sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(fleet != 5)

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '26_no_ORWA_NON-TWL_ages'), overwrite = TRUE)

## remove OR dockside ages

sensi_mod <- base_model

sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(fleet != 6)

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '27_no_OR_dockside_ages'), overwrite = TRUE)

## remove WA dockside ages

sensi_mod <- base_model

sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(fleet != 7)

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '28_no_WA_dockside_ages'), overwrite = TRUE)

## remove NWFSC trawl ages

sensi_mod <- base_model

sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(fleet != 11)

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '29_no_NWFSC_ages'), overwrite = TRUE)

## remove IPHC trawl ages

sensi_mod <- base_model

sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(fleet != 12)

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '30_no_IPHC_ages'), overwrite = TRUE)

## remove all ages
=======
sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[-grep('IPHC_ORWA', rownames(sensi_mod$ctl$size_selex_types)),]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[-grep('IPHC_ORWA', rownames(sensi_mod$ctl$size_selex_parms)),]

#sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_options)),]
#sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_parms)),]

# do I mirror the CPUE index to something? 

SS_write(sensi_mod, file.path(dir,model_directory, 'sensitivities', '21_no_IPHC_lengths'), overwrite = TRUE)


## remove all length comps 
>>>>>>> 00bc5e7e (writing sensitivity model files)

sensi_mod <- base_model

sensi_mod$ctl$lambdas <- sensi_mod$ctl$lambdas |>
  bind_rows(data.frame(
<<<<<<< HEAD
    like_comp = 5,
    fleet = c(2:7, 11, 12),
    phase = 1,
    value = 0,
    sizefreq_method = 0
=======
    like_comp = 4, fleet = 1:12, phase = 1, value = 0, sizefreq_method = 0
>>>>>>> 00bc5e7e (writing sensitivity model files)
  ))

sensi_mod$ctl$N_lambdas <- nrow(sensi_mod$ctl$lambdas)

<<<<<<< HEAD
SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'index_and_comp_data', '31_no_age_comps'), overwrite = TRUE)


# Change aging error  -----------------------------------------------------

# not sure if we need to do these if we don't have updated data
# plus we don't have the original data the aging errors were developed from?

# Natural Mortality -------------------------------------------------------

# Matheus signed up for these...

# Steepness ---------------------------------------------------------------

## estimate steepness

sensi_mod <- base_model

sensi_mod$ctl$SR_parms$PHASE[2] <- 3 # left it in phase 3

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'model_specs', '39_est_steepness'), overwrite = TRUE)


## use 2017 L-W relationship - not run yet

sensi_mod <- base_model

# they don't seem to be different!!

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'model_specs', '41_2017_LW'), overwrite = TRUE)

# Try do_recdev option 2

sensi_mod <- base_model

sensi_mod$ctl$do_recdev <- 2

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'model_specs', '42_do_redev2'), overwrite = TRUE)

# Try do_recdev option 
sensi_mod <- base_model

sensi_mod$ctl$do_recdev <- 3

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'model_specs', '43_do_redev3'), overwrite = TRUE)

# Change removal history --------------------------------------------------

## all years 50% less

## all years 50% more

## comm decreased

## comm increased

## rec decreased

## rec increased

# Others! -----------------------------------------------------------------

## no rec devs

## dome-shaped selex estimated

## M-I weighting - not sure if this one worked? got a warning "-nohess had status 1" ?

copy_SS_inputs(
  dir.old = file.path(dir, model_directory, base_model_name),
  dir.new = file.path(
    dir,
    model_directory,
    'sensitivities',
    'model_specs',
    '54_M_I_weighting'
  )
)
file.copy(
  from = file.path(
    dir,
    model_directory,
    base_model_name,
    c('Report.sso', 'CompReport.sso', 'warning.sso')
  ),
  to = file.path(
    dir,
    model_directory,
    'sensitivities',
    'model_specs',
    '54_M_I_weighting',
    c('Report.sso', 'CompReport.sso', 'warning.sso')
  ),
  overwrite = TRUE
)
tune_comps(
  option = 'MI',
  niters_tuning = 3,
  dir = file.path(
    dir,
    model_directory,
    'sensitivities',
    'model_specs',
    '54_M_I_weighting'
  ),
  exe = exe_loc,
  extras = '-nohess'
)

## one area

## two sex - ????

## rec selex dome-shaped

## rec-devs option 3

## Dirichlet weighting - ???

# below here not adapted for YEYE yet... but will be!!
=======
SS_write(sensi_mod, file.path(dir,model_directory, 'sensitivities', '22_no_length_comps'),
         overwrite = TRUE)






## M-I weighting -----------------------------------------------------------

copy_SS_inputs(dir.old = file.path(model_directory, base_model_name), 
               dir.new = file.path(model_directory, 'sensitivities', 'M_I_weighting'))
file.copy(from = file.path(model_directory, base_model_name,
                           c('Report.sso', 'CompReport.sso', 'warning.sso')), 
          to = file.path(model_directory, 'sensitivities', 'M_I_weighting', 
                         c('Report.sso', 'CompReport.sso', 'warning.sso')), 
          overwrite = TRUE)
tune_comps(option = 'MI', niters_tuning = 3, 
           dir = file.path(model_directory, 'sensitivities', 'M_I_weighting'),
           exe = exe_loc, extras = '-nohess')


## SMURFS ------------------------------------------------------------------

sensi_mod <- base_model

sensi_mod$dat$CPUE <- sensi_mod$dat$CPUE |>
  filter(index != 7)

sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('SMURF', rownames(sensi_mod$ctl$Q_options)),]
sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('SMURF', rownames(sensi_mod$ctl$Q_parms)),]

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'no_SMURF'), overwrite = TRUE)

# out <- SSgetoutput(dirvec = c(file.path(model_directory, base_model_name),
#                               file.path(model_directory, 'sensitivities', 'SMURF')))
# SSsummarize(out) |>
#   SSplotComparisons(subplots = c(1,3), endyrvec = 2037, new = FALSE)


## ORBS --------------------------------------------------------------------

sensi_mod <- base_model

orbs <- read.csv('Data/raw_not_confidential/ORBS index/index_forSS.csv') |>
  mutate(index = 3) |>
  rename(se_log = logse) |>
  select(-fleet)

sensi_mod$dat$CPUEinfo['Recreational','units'] <- 0 # numbers

sensi_mod$dat$CPUE <- bind_rows(sensi_mod$dat$CPUE,
                                orbs)

sensi_mod$ctl$Q_options <- rbind(sensi_mod$ctl$Q_options,
                                 Recreational = c(3,1,0,1,0,0)) |>
  slice(5,1,2,3,4) # reorder
sensi_mod$ctl$Q_parms <- bind_rows(sensi_mod$ctl$Q_parms[1:2,], # copy H&L Q setup for SMURF
                                   sensi_mod$ctl$Q_parms)
rownames(sensi_mod$ctl$Q_parms) <- rownames(sensi_mod$ctl$Q_parms) |>
  stringr::str_replace('H&L_survey\\(4\\)\\.\\.\\.[1|2]', 'Recreational(3)') |> # fix row names
  stringr::str_remove('\\.\\.\\.[:digit:]')

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'ORBS'), overwrite = TRUE)

sensi_mod$ctl$Q_parms['Q_extraSD_Recreational(3)', 'PHASE'] <- 3
SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'ORBS_SE'), overwrite = TRUE)

# 
# out <- SSgetoutput(dirvec = c(file.path(model_directory, base_model_name),
#                               file.path(model_directory, 'sensitivities', 'ORBS')))
# SSsummarize(out) |>
#   SSplotComparisons(subplots = c(1,3), endyrvec = 2037, new = FALSE)
# SSplotIndices(out[[2]])
# 

## Oceanographic index -----------------------------------------------------

sensi_mod <- base_model

flt <- base_model$dat$Nfleets + 1

ocean <- read.csv('Data/raw_not_confidential/OceanographicIndex/OceanographicIndexV1.csv') |>
  mutate(month = 7, 
         index = ifelse(year >= 2015, flt, -flt) # include 10 years of index
  ) |>
  select(year, month, index, obs = fit, se_log = se.p)

# data file updates
sensi_mod$dat$Nfleets <- flt
sensi_mod$dat$fleetnames[flt] <- 'ocean'
sensi_mod$dat$fleetinfo[flt,] <- c(3,1,1,2,0,'ocean')
sensi_mod$dat$CPUEinfo[flt,] <- c(flt,36,-1,0)
sensi_mod$dat$len_info[flt,] <- sensi_mod$dat$len_info[flt-1,]
sensi_mod$dat$age_info[flt,] <- sensi_mod$dat$age_info[flt-1,]
sensi_mod$dat$fleetinfo1$SMURF <- sensi_mod$dat$fleetinfo1$WCGBTS
sensi_mod$dat$fleetinfo2$SMURF <- sensi_mod$dat$fleetinfo2$WCGBTS
sensi_mod$dat$CPUE <- bind_rows(sensi_mod$dat$CPUE,
                          ocean)

# control file updates
sensi_mod$ctl$size_selex_types[flt,] <- rep(0, 4)
sensi_mod$ctl$age_selex_types[flt,] <- sensi_mod$ctl$age_selex_types[flt-1,]
sensi_mod$ctl$Q_options <- rbind(sensi_mod$ctl$Q_options,
                           ocean = c(flt,1,0,0,0,0))
sensi_mod$ctl$Q_parms <- bind_rows(sensi_mod$ctl$Q_parms,
                             sensi_mod$ctl$Q_parms[1,])

sensi_mod$ctl$Q_parms[nrow(sensi_mod$ctl$Q_parms), c('INIT', 'PHASE')] <- c(1, -99)

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'oceanographic_index'), overwrite = TRUE)
# 
# out <- SSgetoutput(dirvec = c(file.path(model_directory, base_model_name),
#                               file.path(model_directory, 'sensitivities', 'oceanographic_index')))

# miraculously, it is not bad.
# 
# out <- SS_output(file.path(model_directory, 'sensitivities', 'hook_and_line'))
# SS_plots(out)

# surveys_only <- SS_read(file.path(model_directory, 'sensitivities', 'hook_and_line'), 
#                         ss_new = TRUE)
# 
# surveys_only$ctl$MG_parms$PHASE <- -99
# surveys_only$ctl$SR_parms$PHASE <- -99
# surveys_only$ctl$Q_parms$PHASE <- -99
# surveys_only$ctl$size_selex_parms$PHASE <- -99
# surveys_only$ctl$size_selex_parms_tv$PHASE <- -99
# surveys_only$ctl$lambdas <- surveys_only$ctl$lambdas |>
#   slice(-(1:2)) |>
#   bind_rows(
#     data.frame(
#       like_comp = rep(4, 6),
#       fleet = 1:6, phase = 1, value = 0, sizefreq_method = 0
#     ),
#     data.frame(
#       like_comp = rep(5, 5),
#       fleet = c(1,2,3,5,6), phase = 1, value = 0, sizefreq_method = 0
#     )
#     
#   )
# surveys_only$ctl$N_lambdas <- nrow(surveys_only$ctl$lambdas)
# surveys_only$ctl$recdev_phase <- 1
# 
# SS_write(surveys_only, file.path(model_directory, 'sensitivities', 'surveys_only'),
#          overwrite = TRUE)
# out_surveys <- SS_output(file.path(model_directory, 'sensitivities', 'surveys_only'))
# SS_plots(out_surveys)

## RREAS -------------------------------------------------------------------

sensi_mod <- base_model

flt <- base_model$dat$Nfleets + 1

rreas <- read.csv('Data/raw_not_confidential/RREAS/ytail_coastwide_indices.csv') |>
  mutate(index = flt, month = 7) |>
  rename(se_log = logse, year = YEAR, obs = est)

sensi_mod$dat$Nfleets <- flt
sensi_mod$dat$fleetnames[flt] <- 'RREAS'
sensi_mod$dat$fleetinfo[flt,] <- c(3,1,1,2,0,'RREAS')
sensi_mod$dat$CPUEinfo[flt,] <- c(flt,33,0,0)
sensi_mod$dat$len_info[flt,] <- sensi_mod$dat$len_info[flt-1,]
sensi_mod$dat$age_info[flt,] <- sensi_mod$dat$age_info[flt-1,]
sensi_mod$dat$fleetinfo1$SMURF <- sensi_mod$dat$fleetinfo1$WCGBTS
sensi_mod$dat$fleetinfo2$SMURF <- sensi_mod$dat$fleetinfo2$WCGBTS
sensi_mod$dat$CPUE <- bind_rows(sensi_mod$dat$CPUE,
                                rreas)

# control file updates
sensi_mod$ctl$size_selex_types[flt,] <- rep(0, 4)
sensi_mod$ctl$age_selex_types[flt,] <- sensi_mod$ctl$age_selex_types[flt-1,]
sensi_mod$ctl$Q_options <- rbind(sensi_mod$ctl$Q_options,
                                 RREAS = c(flt,1,0,0,0,0))
sensi_mod$ctl$Q_parms <- bind_rows(sensi_mod$ctl$Q_parms,
                                   sensi_mod$ctl$Q_parms[1,])

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'RREAS'),
         overwrite = TRUE)

## remove indices ----------------------------------------------------

sensi_mod <- base_model

sensi_mod$dat$CPUE$year <- -1*sensi_mod$dat$CPUE$year
sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_parms <- NULL

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'no_indices'),
         overwrite = TRUE)


## upweight wcbts ----------------------------------------------------------

sensi_mod <- base_model

sensi_mod$dat$CPUE <- sensi_mod$dat$CPUE |>
  mutate(se_log = ifelse(index == 6, 0.05, se_log))

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'upweight_wcgbts'),
         overwrite = TRUE)

## observer index ----------------------------------------------------------

sensi_mod <- base_model

sensi_mod$dat$CPUEinfo
sensi_mod$dat$CPUE <- bind_rows(sensi_mod$dat$CPUE,
                                read.csv('data/processed/observer_index.csv'))

sensi_mod$ctl$Q_options <- rbind(sensi_mod$ctl$Q_options,
                                 Commercial = c(1,1,0,0,0,1)) |> # float Q, was not being well estimated (possibly bad start value)
  slice(5,1,2,3,4) # reorder
sensi_mod$ctl$Q_parms <- bind_rows(sensi_mod$ctl$Q_parms[1,], # copy H&L Q setup for observer index
                                   sensi_mod$ctl$Q_parms)
sensi_mod$ctl$Q_parms[1, 'PHASE'] <- -99

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'observer_index'),
         overwrite = TRUE)
# out <- SS_output(file.path(model_directory, 'sensitivities', 'observer_index'))
# SSplotIndices(out, fleets = 1)

## no fishery lengths ------------------------------------------------------

sensi_mod <- base_model
sensi_mod$ctl$lambdas <- sensi_mod$ctl$lambdas |>
  bind_rows(data.frame(
    like_comp = 4, fleet = 1:3, phase = 1, value = 0, sizefreq_method = 0
  ))
sensi_mod$ctl$N_lambdas <- nrow(sensi_mod$ctl$lambdas)

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'no_fishery_len'),
         overwrite = TRUE)

## non-linear WCGBTS catchability -------------------------------------------------

sensi_mod <- base_model
sensi_mod$ctl$Q_options['WCGBTS', 'link'] <- 3
# Triennial estimate of power parameters is pretty close to zero

power_row <- sensi_mod$ctl$Q_parms[1,] |>
  `rownames<-`('power_parameter')
power_row$INIT <- 0
power_row$PHASE <- 3

sensi_mod$ctl$Q_parms <- bind_rows(
  sensi_mod$ctl$Q_parms[1:5,],
  power_row,
  sensi_mod$ctl$Q_parms[6:8,]
)

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'nonlinear_q'),
         overwrite = TRUE)


## Add unsexed commercial lengths ------------------------------------------

sensi_mod <- base_model

unsexed_lengths <- read.csv('data/processed/pacfin_lcomps.csv') |>
  `names<-`(names(sensi_mod$dat$lencomp)) |>
  filter(sex == 0)
sensi_mod$dat$lencomp <- bind_rows(sensi_mod$dat$lencomp,
                                   unsexed_lengths)

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'unsexed_lengths'),
         overwrite = TRUE)


## sex-specific selectivity ------------------------------------------------

sensi_mod <- base_model

sensi_mod$ctl$size_selex_parms[grepl('Off_(1|2|5)', rownames(sensi_mod$ctl$size_selex_parms)) &
                                 !grepl('Rec|H&L', rownames(sensi_mod$ctl$size_selex_parms)), 
                               'PHASE'] <- 6

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'sex_selex'), 
         overwrite = TRUE)


## No sex specific selectivity ---------------------------------------------

sensi_mod <- base_model

sensi_mod$ctl$size_selex_parms[grepl('Off', rownames(sensi_mod$ctl$size_selex_parms)), 'PHASE'] <- -99

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'no_sex_selex'), 
         overwrite = TRUE)

8
## Breakpoint M --------------------------------------------------------------

sensi_mod <- base_model

sensi_mod$ctl$natM_type <- 1
sensi_mod$ctl$N_natM <- sensi_mod$ctl$N_natMparms <- 2
sensi_mod$ctl$M_ageBreakPoints <- 9:10 # age at 50% maturity is 10

nat_m_ind <- grep('NatM', rownames(sensi_mod$ctl$MG_parms))

mg_table <- SS_read(file.path(model_directory, '4.07_breakpoint_m'))$ctl$MG_parms
mg_table['CV_old_Fem_GP_1', 'LO'] <- -0.99
sensi_mod$ctl$MG_parms <- mg_table

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'breakpoint_m'),
         overwrite = TRUE)  


## Single M ----------------------------------------------------------------

sensi_mod <- base_model

sensi_mod$ctl$MG_parms['NatM_p_1_Mal_GP_1', c('INIT', 'PHASE')] <- c(0, -99)

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'single_m'),
         overwrite = TRUE)  


## Time varying W-L --------------------------------------------------------

source('Rscripts/add_time_varying_WL.R')

sensi_mod <- add_tv_wl(base_model)

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'tv_wl'))

## F method --base_model# F method ----------------------------------------------------------------

sensi_mod <- base_model

sensi_mod$ctl$F_Method <- 3
sensi_mod$ctl$F_iter <- 4

SS_write(sensi_mod, file.path(model_directory, 'sensitivities', 'hybrid_f'))
>>>>>>> 00bc5e7e (writing sensitivity model files)

# Run stuff ---------------------------------------------------------------

sensi_dirs <- list.files(file.path(model_directory, 'sensitivities'))

tuning_mods <- grep('weighting', sensi_mods)

<<<<<<< HEAD
future::plan(future::multisession(
  workers = parallelly::availableCores(omit = 1)
))

furrr::future_map(sensi_dirs[-tuning_mods], \(x)
                  run(file.path(model_directory, 'sensitivities', x),
                      exe = exe_loc, extras = '-nohess', skipfinished = FALSE)
)

# furrr::future_map(
#   c('nonlinear_q', 'oceanographic_index'),
#   \(x)
#     run(
#       file.path(model_directory, 'sensitivities', x),
#       exe = exe_loc,
#       extras = '-nohess',
#       skipfinished = FALSE
#     )
# )

=======
future::plan(future::multisession(workers = parallelly::availableCores(omit = 1)))

# furrr::future_map(sensi_dirs[-tuning_mods], \(x) 
#                   run(file.path(model_directory, 'sensitivities', x), 
#                       exe = exe_loc, extras = '-nohess', skipfinished = FALSE)
# )

furrr::future_map(c('nonlinear_q', 'oceanographic_index'), \(x) 
                  run(file.path(model_directory, 'sensitivities', x), 
                      exe = exe_loc, extras = '-nohess', skipfinished = FALSE)
)

>>>>>>> 00bc5e7e (writing sensitivity model files)
future::plan(future::sequential)


# Plot stuff --------------------------------------------------------------

<<<<<<< HEAD
## function ----------------------------------------------------------------

make_detailed_sensitivites <- function(biglist, mods, outdir, grp_name) {
  shortlist <- big_sensitivity_output[c('base', mods$dir)] |>
    r4ss::SSsummarize()

  r4ss::SSplotComparisons(
    shortlist,
    subplots = c(2, 4, 18),
    print = TRUE,
    plot = FALSE,
    plotdir = outdir,
    filenameprefix = grp_name,
    legendlabels = c('Base', mods$pretty),
    endyrvec = 2036
  )

  SStableComparisons(
    shortlist,
    modelnames = c('Base', mods$pretty),
    names = c(
      "Recr_Virgin",
      "R0",
      "NatM",
      "L_at_Amax",
      "VonBert_K",
      "SmryBio_unfished",
      "SSB_Virg",
      "SSB_2025",
      "Bratio_2025",
      "SPRratio_2024",
      "LnQ_base_WCGBTS"
    ),
    likenames = c(
      "TOTAL",
      "Survey",
      "Length_comp",
      "Age_comp",
      "Discard",
      "Mean_body_wt",
      "Recruitment",
      "priors"
    )
  ) |>
=======

## function ----------------------------------------------------------------

make_detailed_sensitivites <- function(biglist, mods, 
                                       outdir, grp_name) {
  
  shortlist <- big_sensitivity_output[c('base', mods$dir)] |>
    r4ss::SSsummarize() 
  
  r4ss::SSplotComparisons(shortlist,
                          subplots = c(2,4, 18), 
                          print = TRUE,  
                          plot = FALSE,
                          plotdir = outdir, 
                          filenameprefix = grp_name,
                          legendlabels = c('Base', mods$pretty), 
                          endyrvec = 2036)
  
  SStableComparisons(shortlist, 
                     modelnames = c('Base', mods$pretty),
                     names =c("Recr_Virgin", "R0", "NatM", "L_at_Amax", "VonBert_K", "SmryBio_unfished", "SSB_Virg",
                              "SSB_2025", "Bratio_2025", "SPRratio_2024", "LnQ_base_WCGBTS"),
                     likenames = c(
                              "TOTAL", "Survey", "Length_comp", "Age_comp",
                              "Discard", "Mean_body_wt", "Recruitment", "priors"
                            )
                          ) |>
>>>>>>> 00bc5e7e (writing sensitivity model files)
    # dplyr::filter(!(Label %in% c('NatM_break_1_Fem_GP_1',
    #                              'NatM_break_1_Mal_GP_1', 'NatM_break_2_Mal_GP_1')),
    #               Label != 'NatM_uniform_Mal_GP_1' | any(grep('break', Label)),
    #               Label != 'SR_BH_steep' | any(grep('break', Label))) |>
    # dplyr::mutate(dplyr::across(-Label, ~ sapply(., format, digits = 3, scientific = FALSE) |>
    #                               stringr::str_replace('NA', ''))) |>
    `names<-`(c('Label', 'Base', mods$pretty)) |>
<<<<<<< HEAD
    write.csv(
      file.path(outdir, paste0(grp_name, '_table.csv')),
      row.names = FALSE,
    )
}


## grouped plots -----------------------------------------------------------

modeling <- data.frame(
  dir = c(
    'breakpoint_m',
    'no_sex_selex',
    'sex_selex',
    'single_m',
    'tv_wl',
    'hybrid_f',
    'nonlinear_q'
  ),
  pretty = c(
    'Breakpoint M',
    'No sex selectivity',
    'Sex selectivity all fleets',
    'Single M',
    'Time-vary weight-length',
    'Hybrid F method',
    'Nonlinear WCGBTS Q'
  )
)

indices <- data.frame(
  dir = c(
    'no_indices',
    'no_smurf',
    'observer_index',
    'oceanographic_index',
    'ORBS',
    'ORBS_SE',
    'RREAS',
    'upweight_wcgbts'
  ),
  pretty = c(
    'No indices',
    '- SMURF index',
    '+ WCGOP index',
    '+ Oceanographic index',
    '+ ORBS index',
    '+ ORBS w/added SE',
    '+ RREAS index',
    'Decrease WCGBTS CV'
  )
)


comp_data <- data.frame(
  dir = c('M_I_weighting', 'no_fishery_len', 'unsexed_lengths'),
  pretty = c(
    'McAllister & Ianelli',
    '- Fishery lengths',
    '+ Unsexed commercial lengths'
  )
)

sens_names <- bind_rows(modeling, indices, comp_data)

big_sensitivity_output <- SSgetoutput(
  dirvec = file.path(
    model_directory,
    c(
      base_model_name,
      glue::glue("sensitivities/{subdir}", subdir = sens_names$dir)
    )
  )
) |>
  `names<-`(c('base', sens_names$dir))


# test to make sure they all read correctly:
which(sapply(big_sensitivity_output, length) < 180) # all lengths should be >180

sens_names_ls <- list(
  modeling = modeling,
  indices = indices,
  comp_data = comp_data
)

outdir <- 'report/figures/sensitivities'

purrr::imap(
  sens_names_ls,
  \(sens_df, grp_name)
    make_detailed_sensitivites(
      biglist = big_sensitivity_output,
      mods = sens_df,
      outdir = outdir,
      grp_name = grp_name
    )
)
=======
    write.csv(file.path(outdir, paste0(grp_name, '_table.csv')), 
              row.names = FALSE, )
  
}



## grouped plots -----------------------------------------------------------

modeling <- data.frame(dir = c('breakpoint_m', 
                               'no_sex_selex',
                               'sex_selex',
                               'single_m',
                               'tv_wl',
                               'hybrid_f',
                               'nonlinear_q'),
                       pretty = c('Breakpoint M',
                                  'No sex selectivity',
                                  'Sex selectivity all fleets',
                                  'Single M',
                                  'Time-vary weight-length',
                                  'Hybrid F method',
                                  'Nonlinear WCGBTS Q')
)

indices <- data.frame(dir = c('no_indices',
                              'no_smurf',
                              'observer_index',
                              'oceanographic_index',
                              'ORBS',
                              'ORBS_SE',
                              'RREAS',
                              'upweight_wcgbts'),
                      pretty = c('No indices',
                                 '- SMURF index',
                                 '+ WCGOP index',
                                 '+ Oceanographic index',
                                 '+ ORBS index',
                                 '+ ORBS w/added SE',
                                 '+ RREAS index',
                                 'Decrease WCGBTS CV')
)


comp_data <- data.frame(dir = c('M_I_weighting',
                                'no_fishery_len',
                                'unsexed_lengths'),
                        pretty = c('McAllister & Ianelli',
                                   '- Fishery lengths',
                                   '+ Unsexed commercial lengths')
)

sens_names <- bind_rows(modeling,
                        indices,
                        comp_data)

big_sensitivity_output <- SSgetoutput(dirvec = file.path(model_directory,
                                                         c(base_model_name,
                                                           glue::glue("sensitivities/{subdir}", 
                                                                      subdir = sens_names$dir)))) |>
  `names<-`(c('base', sens_names$dir))



# test to make sure they all read correctly:
which(sapply(big_sensitivity_output, length) < 180) # all lengths should be >180

sens_names_ls <- list(modeling = modeling,
                      indices = indices,
                      comp_data = comp_data)

outdir <- 'report/figures/sensitivities'

purrr::imap(sens_names_ls, \(sens_df, grp_name) 
            make_detailed_sensitivites(biglist = big_sensitivity_output, 
                                       mods = sens_df, 
                                       outdir = outdir, 
                                       grp_name = grp_name))

>>>>>>> 00bc5e7e (writing sensitivity model files)


## big plot ----------------------------------------------------------------

current.year <- 2025
CI <- 0.95

<<<<<<< HEAD
sensitivity_output <- SSsummarize(big_sensitivity_output)

lapply(
  big_sensitivity_output,
  function(.) .$warnings[grep('gradient', .$warnings)]
) # check gradients

dev.quants.SD <- c(
  sensitivity_output$quantsSD[
    sensitivity_output$quantsSD$Label == "SSB_Initial",
    1
  ],
  (sensitivity_output$quantsSD[
    sensitivity_output$quantsSD$Label == paste0("SSB_", current.year),
    1
  ]),
  sensitivity_output$quantsSD[
    sensitivity_output$quantsSD$Label == paste0("Bratio_", current.year),
    1
  ],
  sensitivity_output$quantsSD[
    sensitivity_output$quantsSD$Label == "Dead_Catch_SPR",
    1
  ],
  sensitivity_output$quantsSD[
    sensitivity_output$quantsSD$Label == "annF_SPR",
    1
  ]
)

dev.quants <- rbind(
  sensitivity_output$quants[
    sensitivity_output$quants$Label == "SSB_Initial",
    1:(dim(sensitivity_output$quants)[2] - 2)
  ],
  sensitivity_output$quants[
    sensitivity_output$quants$Label == paste0("SSB_", current.year),
    1:(dim(sensitivity_output$quants)[2] - 2)
  ],
  sensitivity_output$quants[
    sensitivity_output$quants$Label == paste0("Bratio_", current.year),
    1:(dim(sensitivity_output$quants)[2] - 2)
  ],
  sensitivity_output$quants[
    sensitivity_output$quants$Label == "Dead_Catch_SPR",
    1:(dim(sensitivity_output$quants)[2] - 2)
  ],
  sensitivity_output$quants[
    sensitivity_output$quants$Label == "annF_SPR",
    1:(dim(sensitivity_output$quants)[2] - 2)
  ]
) |>
  cbind(baseSD = dev.quants.SD) |>
  dplyr::mutate(
    Metric = c(
      "SB0",
      paste0("SSB_", current.year),
      paste0("Bratio_", current.year),
      "MSY_SPR",
      "F_SPR"
    )
  ) |>
  tidyr::pivot_longer(
    -c(base, Metric, baseSD),
    names_to = 'Model',
    values_to = 'Est'
  ) |>
  dplyr::mutate(
    relErr = (Est - base) / base,
    logRelErr = log(Est / base),
    mod_num = rep(1:nrow(sens_names), 5)
  )
=======
sensitivity_output <- SSsummarize(big_sensitivity_output) 

lapply(big_sensitivity_output, function(.)
  .$warnings[grep('gradient', .$warnings)]) # check gradients

dev.quants.SD <- c(
  sensitivity_output$quantsSD[sensitivity_output$quantsSD$Label == "SSB_Initial", 1],
  (sensitivity_output$quantsSD[sensitivity_output$quantsSD$Label == paste0("SSB_", current.year), 1]),
  sensitivity_output$quantsSD[sensitivity_output$quantsSD$Label == paste0("Bratio_", current.year), 1],
  sensitivity_output$quantsSD[sensitivity_output$quantsSD$Label == "Dead_Catch_SPR", 1],
  sensitivity_output$quantsSD[sensitivity_output$quantsSD$Label == "annF_SPR", 1]
)

dev.quants <- rbind(
  sensitivity_output$quants[sensitivity_output$quants$Label == "SSB_Initial", 
                            1:(dim(sensitivity_output$quants)[2] - 2)],
  sensitivity_output$quants[sensitivity_output$quants$Label == paste0("SSB_", current.year), 
                            1:(dim(sensitivity_output$quants)[2] - 2)],
  sensitivity_output$quants[sensitivity_output$quants$Label == paste0("Bratio_", current.year), 
                            1:(dim(sensitivity_output$quants)[2] - 2)],
  sensitivity_output$quants[sensitivity_output$quants$Label == "Dead_Catch_SPR", 
                            1:(dim(sensitivity_output$quants)[2] - 2)],
  sensitivity_output$quants[sensitivity_output$quants$Label == "annF_SPR", 
                            1:(dim(sensitivity_output$quants)[2] - 2)]
) |>
  cbind(baseSD = dev.quants.SD) |>
  dplyr::mutate(Metric = c("SB0", paste0("SSB_", current.year), paste0("Bratio_", current.year), "MSY_SPR", "F_SPR")) |>
  tidyr::pivot_longer(-c(base, Metric, baseSD), names_to = 'Model', values_to = 'Est') |>
  dplyr::mutate(relErr = (Est - base)/base,
                logRelErr = log(Est/base),
                mod_num = rep(1:nrow(sens_names), 5))
>>>>>>> 00bc5e7e (writing sensitivity model files)

metric.labs <- c(
  SB0 = expression(SB[0]),
  SSB_2023 = as.expression(bquote("SB"[.(current.year)])),
  Bratio_2023 = bquote(frac(SB[.(current.year)], SB[0])),
  MSY_SPR = expression(Yield['SPR=0.50']),
  F_SPR = expression(F['SPR=0.50'])
)

CI.quants <- dev.quants |>
  dplyr::filter(Model == unique(dev.quants$Model)[1]) |>
  dplyr::select(base, baseSD, Metric) |>
<<<<<<< HEAD
  dplyr::mutate(CI = qnorm((1 - CI) / 2, 0, baseSD) / base)
=======
  dplyr::mutate(CI = qnorm((1-CI)/2, 0, baseSD)/base)
>>>>>>> 00bc5e7e (writing sensitivity model files)

ggplot(dev.quants, aes(x = relErr, y = mod_num, col = Metric, pch = Metric)) +
  geom_vline(xintercept = 0, linetype = 'dotted') +
  geom_point() +
<<<<<<< HEAD
  geom_segment(
    aes(
      x = CI,
      xend = abs(CI),
      col = Metric,
      y = nrow(sens_names) +
        1.5 +
        seq(-0.5, 0.5, length.out = length(metric.labs)),
      yend = nrow(sens_names) +
        1.5 +
        seq(-0.5, 0.5, length.out = length(metric.labs))
    ),
    data = CI.quants,
    linewidth = 2,
    show.legend = FALSE,
    lineend = 'round'
  ) +
=======
  geom_segment(aes(x = CI, xend = abs(CI), col = Metric,
                   y = nrow(sens_names) + 1.5 + seq(-0.5, 0.5, length.out = length(metric.labs)),
                   yend = nrow(sens_names) + 1.5 + seq(-0.5, 0.5, length.out = length(metric.labs))), 
               data = CI.quants, linewidth = 2, show.legend = FALSE, lineend = 'round') +
>>>>>>> 00bc5e7e (writing sensitivity model files)
  theme_bw() +
  scale_shape_manual(
    values = c(15:18, 12),
    # name = "",
    labels = metric.labs
  ) +
  # scale_color_discrete(labels = metric.labs) +
<<<<<<< HEAD
  scale_y_continuous(
    breaks = 1:nrow(sens_names),
    name = '',
    labels = sens_names$pretty,
    limits = c(1, nrow(sens_names) + 2),
    minor_breaks = NULL
  ) +
  xlab("Relative change") +
  viridis::scale_color_viridis(discrete = TRUE, labels = metric.labs)
ggsave(
  file.path(outdir, 'sens_summary.png'),
  dpi = 300,
  width = 6,
  height = 6.5,
  units = "in"
)
=======
  scale_y_continuous(breaks = 1:nrow(sens_names), name = '', labels = sens_names$pretty, 
                     limits = c(1, nrow(sens_names) + 2), minor_breaks = NULL) +
  xlab("Relative change") +
  viridis::scale_color_viridis(discrete = TRUE, labels = metric.labs)
ggsave(file.path(outdir, 'sens_summary.png'),  dpi = 300,  
       width = 6, height = 6.5, units = "in")
>>>>>>> 00bc5e7e (writing sensitivity model files)
