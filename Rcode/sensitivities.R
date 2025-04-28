### RUN SENSITIVITIES FOR YELLOWEYE 2025 UPDATE ASSESSMENT
# CODE ADAPTED BY A. WHITMAN (ODFW) FROM K. OKEN (NWFSC)

# LAST UPDATE: 4/28/2025

library(here)
library(r4ss)
library(dplyr)

# dir<-"C:/Users/daubleal/OneDrive - Oregon/Desktop/Sebastes_ruberrimus_2025"

model_directory <- here::here('model')
base_model_name <- here::here('updated_alldata_tunecomps_20250427') # might need to update later?
exe_loc <- here::here('model/ss3_win.exe')
base_model <- SS_read(
  file.path(dir, model_directory, base_model_name),
  ss_new = TRUE
)
base_out <- SS_output(file.path(dir, model_directory, base_model_name))

# Write sensitivities -----------------------------------------------------

# Remove Indices ----------------------------------------------------------

## remove CA dockside (CA_REC)

sensi_mod <- base_model

sensi_mod$dat$CPUE <- sensi_mod$dat$CPUE |>
  filter(index != 3)

sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[
  -grep('CA_REC', rownames(sensi_mod$ctl$Q_options)),
]
sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[
  -grep('CA_REC', rownames(sensi_mod$ctl$Q_parms)),
]

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '01_no_CA_dockside'
  ),
  overwrite = TRUE
)

## remove OR dockside (OR_REC)

sensi_mod <- base_model

sensi_mod$dat$CPUE <- sensi_mod$dat$CPUE |>
  filter(index != 6)

sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[
  -grep('OR_REC', rownames(sensi_mod$ctl$Q_options)),
]
sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[
  -grep('OR_REC', rownames(sensi_mod$ctl$Q_parms)),
]
sensi_mod$ctl$Q_parms_tv <- NULL

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '02_no_OR_dockside'
  ),
  overwrite = TRUE
)

## remove WA dockside

sensi_mod <- base_model

sensi_mod$dat$CPUE <- sensi_mod$dat$CPUE |>
  filter(index != 7)

sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[
  -grep('WA_REC', rownames(sensi_mod$ctl$Q_options)),
]
sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[
  -grep('WA_REC', rownames(sensi_mod$ctl$Q_parms)),
]

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '03_no_WA_dockside'
  ),
  overwrite = TRUE
)

## remove CA CPFV

sensi_mod <- base_model

sensi_mod$dat$CPUE <- sensi_mod$dat$CPUE |>
  filter(index != 8)

sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[
  -grep('CACPFV', rownames(sensi_mod$ctl$Q_options)),
]
sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[
  -grep('CACPFV', rownames(sensi_mod$ctl$Q_parms)),
]

# Need to remove length data, age data, and selectivities. If no catch or index, you can't have length or age data
sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(index != 8)
sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(index != 8)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[
  !grepl("8_", rownames(sensi_mod$ctl$size_selex_types)),
]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[
  !grepl("(8)", rownames(sensi_mod$ctl$size_selex_parms)),
]
sensi_mod$ctl$age_selex_types <- sensi_mod$ctl$age_selex_types[
  !grepl("8_", rownames(sensi_mod$ctl$age_selex_types)),
]
sensi_mod$ctl$age_selex_parms <- sensi_mod$ctl$age_selex_parms[
  !grepl("(8)", rownames(sensi_mod$ctl$age_selex_parms)),
]


SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '04_no_CA_CPFV'
  ),
  overwrite = TRUE
)

## remove OR onboard (OR_RECOB)

sensi_mod <- base_model

sensi_mod$dat$CPUE <- sensi_mod$dat$CPUE |>
  filter(index != 9)

sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[
  -grep('OR_RECOB', rownames(sensi_mod$ctl$Q_options)),
]
sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[
  -grep('OR_RECOB', rownames(sensi_mod$ctl$Q_parms)),
]


# Need to remove length data, age data, and selectivities. If no catch or index, you can't have length or age data
sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(index != 9)
sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(index != 9)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[
  !grepl("9_", rownames(sensi_mod$ctl$size_selex_types)),
]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[
  !grepl("(9)", rownames(sensi_mod$ctl$size_selex_parms)),
]
sensi_mod$ctl$age_selex_types <- sensi_mod$ctl$age_selex_types[
  !grepl("9_", rownames(sensi_mod$ctl$age_selex_types)),
]
sensi_mod$ctl$age_selex_parms <- sensi_mod$ctl$age_selex_parms[
  !grepl("(9)", rownames(sensi_mod$ctl$age_selex_parms)),
]

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '05_no_OR_onboard'
  ),
  overwrite = TRUE
)

## remove AFSC triennial

sensi_mod <- base_model

sensi_mod$dat$CPUE <- sensi_mod$dat$CPUE |>
  filter(index != 10)

sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[
  -grep('TRI_ORWA', rownames(sensi_mod$ctl$Q_options)),
]
sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[
  -grep('TRI_ORWA', rownames(sensi_mod$ctl$Q_parms)),
]


# Need to remove length data, age data, and selectivities. If no catch or index, you can't have length or age data
sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(index != 10)
sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(index != 10)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[
  !grepl("10_", rownames(sensi_mod$ctl$size_selex_types)),
]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[
  !grepl("(10)", rownames(sensi_mod$ctl$size_selex_parms)),
]
sensi_mod$ctl$age_selex_types <- sensi_mod$ctl$age_selex_types[
  !grepl("10_", rownames(sensi_mod$ctl$age_selex_types)),
]
sensi_mod$ctl$age_selex_parms <- sensi_mod$ctl$age_selex_parms[
  !grepl("(10)", rownames(sensi_mod$ctl$age_selex_parms)),
]

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '06_no_AFSC_triennial'
  ),
  overwrite = TRUE
)

## remove NWFSC trawl

sensi_mod <- base_model

sensi_mod$dat$CPUE <- sensi_mod$dat$CPUE |>
  filter(index != 11)

sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[
  -grep('NWFSC_ORWA', rownames(sensi_mod$ctl$Q_options)),
]
sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[
  -grep('NWFSC_ORWA', rownames(sensi_mod$ctl$Q_parms)),
]

# Need to remove length data, age data, and selectivities. If no catch or index, you can't have length or age data
sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(index != 11)
sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(index != 11)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[
  !grepl("11_", rownames(sensi_mod$ctl$size_selex_types)),
]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[
  !grepl("(11)", rownames(sensi_mod$ctl$size_selex_parms)),
]
sensi_mod$ctl$age_selex_types <- sensi_mod$ctl$age_selex_types[
  !grepl("11_", rownames(sensi_mod$ctl$age_selex_types)),
]
sensi_mod$ctl$age_selex_parms <- sensi_mod$ctl$age_selex_parms[
  !grepl("(11)", rownames(sensi_mod$ctl$age_selex_parms)),
]

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '07_no_NWFSC_trawl'
  ),
  overwrite = TRUE
)

## remove IPHC

sensi_mod <- base_model

sensi_mod$dat$CPUE <- sensi_mod$dat$CPUE |>
  filter(index != 12)

sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[
  -grep('IPHC_ORWA', rownames(sensi_mod$ctl$Q_options)),
]
sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[
  -grep('IPHC_ORWA', rownames(sensi_mod$ctl$Q_parms)),
]

# Need to remove length data, age data, and selectivities. If no catch or index, you can't have length or age data
sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(index != 12)
sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(index != 12)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[
  !grepl("12_", rownames(sensi_mod$ctl$size_selex_types)),
]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[
  !grepl("(12)", rownames(sensi_mod$ctl$size_selex_parms)),
]
sensi_mod$ctl$age_selex_types <- sensi_mod$ctl$age_selex_types[
  !grepl("12_", rownames(sensi_mod$ctl$age_selex_types)),
]
sensi_mod$ctl$age_selex_parms <- sensi_mod$ctl$age_selex_parms[
  !grepl("(12)", rownames(sensi_mod$ctl$age_selex_parms)),
]

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '08_no_IPHC'
  ),
  overwrite = TRUE
)

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

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[
  !grepl(
    paste0(indices_und, collapse = "|"),
    rownames(sensi_mod$ctl$size_selex_types)
  ),
]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[
  !grepl(
    paste0(indices_chr, collapse = "|"),
    rownames(sensi_mod$ctl$size_selex_parms)
  ),
]
sensi_mod$ctl$age_selex_types <- sensi_mod$ctl$age_selex_types[
  !grepl(
    paste0(indices_und, collapse = "|"),
    rownames(sensi_mod$ctl$age_selex_types)
  ),
]
sensi_mod$ctl$age_selex_parms <- sensi_mod$ctl$age_selex_parms[
  !grepl(
    paste0(indices_chr, collapse = "|"),
    rownames(sensi_mod$ctl$age_selex_parms)
  ),
]


SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '09_no_indices'
  ),
  overwrite = TRUE
)


# Remove length comps -----------------------------------------------------

## remove CA trawl lengths

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 1)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[
  -grep('CA_TWL', rownames(sensi_mod$ctl$size_selex_types)),
]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[
  -grep('CA_TWL', rownames(sensi_mod$ctl$size_selex_parms)),
]

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '10_no_CA_trawl_lengths'
  ),
  overwrite = TRUE
)


## remove CA non-trawl lengths

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 2)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[
  -grep('CA_NONTWL', rownames(sensi_mod$ctl$size_selex_types)),
]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[
  -grep('CA_NONTWL', rownames(sensi_mod$ctl$size_selex_parms)),
]

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '11_no_CA_nontrawl_lengths'
  ),
  overwrite = TRUE
)


## remove CA dockside lengths

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 3)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[
  -grep('CA_TWL', rownames(sensi_mod$ctl$size_selex_types)),
]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[
  -grep('CA_TWL', rownames(sensi_mod$ctl$size_selex_parms)),
]

#sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_options)),]
#sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_parms)),]

# change CA-CPFV fleet mirror to OR rec (???)
# I think this is a question for Vlada, did they mirror it to another fleet or did they remove both length comps?
sensi_mod$ctl$size_selex_types$Pattern[7]
sensi_mod$ctl$size_selex_types$Special[7] <- 6

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '12_no_CA_dockside_lengths'
  ),
  overwrite = TRUE
)

## remove OR-WA trawl lengths

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 4)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[
  -grep('ORWA_TWL', rownames(sensi_mod$ctl$size_selex_types)),
]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[
  -grep('ORWA_TWL', rownames(sensi_mod$ctl$size_selex_parms)),
]

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '13_no_ORWA_trawl_lengths'
  ),
  overwrite = TRUE
)


## remove OR-WA non-trawl lengths

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 5)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[
  -grep('ORWA_NONTWL', rownames(sensi_mod$ctl$size_selex_types)),
]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[
  -grep('ORWA_NONTWL', rownames(sensi_mod$ctl$size_selex_parms)),
]

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '14_no_ORWA_non-trawl_lengths'
  ),
  overwrite = TRUE
)


## remove OR dockside lengths ## REMOVE Q'S ?? mirror CPUE to another fleet
# I don't see Q's mirrored, I do see selectivity mirrored to fleet 8

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 6)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[
  -grep('OR_REC', rownames(sensi_mod$ctl$size_selex_types)),
]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[
  -grep('OR_REC', rownames(sensi_mod$ctl$size_selex_parms)),
]

#sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_options)),]
#sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_parms)),]

# do I mirror the CPUE index to something?

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '15_no_OR_dockside_lengths'
  ),
  overwrite = TRUE
)

## remove WA dockside lengths

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 7)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[
  -grep('WA_REC', rownames(sensi_mod$ctl$size_selex_types)),
]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[
  -grep('WA_REC', rownames(sensi_mod$ctl$size_selex_parms)),
]

#sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_options)),]
#sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_parms)),]

# do I mirror the CPUE index to something?

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '16_no_WA_dockside_lengths'
  ),
  overwrite = TRUE
)


## remove CA CPFV lengths # note - mirrored to CA_REC

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 8)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[
  -grep('CACPFV', rownames(sensi_mod$ctl$size_selex_types)),
]
#sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[-grep('CACPFV', rownames(sensi_mod$ctl$size_selex_parms)),]

#sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_options)),]
#sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_parms)),]

# do I mirror the CPUE index to something?

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '17_no_CA_CPFV_lengths'
  ),
  overwrite = TRUE
)

## remove OR onboard lengths

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 9)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[
  -grep('OR_RECOB', rownames(sensi_mod$ctl$size_selex_types)),
]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[
  -grep('OR_RECOB', rownames(sensi_mod$ctl$size_selex_parms)),
]

#sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_options)),]
#sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_parms)),]

# do I mirror the CPUE index to something?

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '18_no_OR_onboard_lengths'
  ),
  overwrite = TRUE
)

## remove AFSC triennial lengths

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 10)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[
  -grep('TRI_ORWA', rownames(sensi_mod$ctl$size_selex_types)),
]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[
  -grep('TRI_ORWA', rownames(sensi_mod$ctl$size_selex_parms)),
]

#sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_options)),]
#sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_parms)),]

# do I mirror the CPUE index to something?

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '19_no_AFSC_TRI_lengths'
  ),
  overwrite = TRUE
)

## remove NWFSC trawl lengths

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 11)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[
  -grep('NWFSC_ORWA', rownames(sensi_mod$ctl$size_selex_types)),
]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[
  -grep('NWFSC_ORWA', rownames(sensi_mod$ctl$size_selex_parms)),
]

#sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_options)),]
#sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_parms)),]

# do I mirror the CPUE index to something?

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '20_no_NWFSC_lengths'
  ),
  overwrite = TRUE
)

## remove IPHC lengths

sensi_mod <- base_model

sensi_mod$dat$lencomp <- sensi_mod$dat$lencomp |>
  filter(fleet != 12)

sensi_mod$ctl$size_selex_types <- sensi_mod$ctl$size_selex_types[
  -grep('IPHC_ORWA', rownames(sensi_mod$ctl$size_selex_types)),
]
sensi_mod$ctl$size_selex_parms <- sensi_mod$ctl$size_selex_parms[
  -grep('IPHC_ORWA', rownames(sensi_mod$ctl$size_selex_parms)),
]

#sensi_mod$ctl$Q_options <- sensi_mod$ctl$Q_options[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_options)),]
#sensi_mod$ctl$Q_parms <- sensi_mod$ctl$Q_parms[-grep('CA_TWL', rownames(sensi_mod$ctl$Q_parms)),]

# do I mirror the CPUE index to something?

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '21_no_IPHC_lengths'
  ),
  overwrite = TRUE
)


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

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '22_no_length_comps'
  ),
  overwrite = TRUE
)


# Remove age comps --------------------------------------------------------

## remove CA non-trawl

sensi_mod <- base_model

sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(fleet != 2)

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '23_no_CA_NONTWL_ages'
  ),
  overwrite = TRUE
)

## remove CA dockside ages

sensi_mod <- base_model

sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(fleet != 3)

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '24_no_CA_REC_ages'
  ),
  overwrite = TRUE
)

## remove OR-WA trawl ages

sensi_mod <- base_model

sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(fleet != 4)

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '25_no_ORWA_TWL_ages'
  ),
  overwrite = TRUE
)

## remove OR-WA non-trawl ages

sensi_mod <- base_model

sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(fleet != 5)

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '26_no_ORWA_NON-TWL_ages'
  ),
  overwrite = TRUE
)

## remove OR dockside ages

sensi_mod <- base_model

sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(fleet != 6)

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '27_no_OR_dockside_ages'
  ),
  overwrite = TRUE
)

## remove WA dockside ages

sensi_mod <- base_model

sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(fleet != 7)

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '28_no_WA_dockside_ages'
  ),
  overwrite = TRUE
)

## remove NWFSC trawl ages

sensi_mod <- base_model

sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(fleet != 11)

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '29_no_NWFSC_ages'
  ),
  overwrite = TRUE
)

## remove IPHC trawl ages

sensi_mod <- base_model

sensi_mod$dat$agecomp <- sensi_mod$dat$agecomp |>
  filter(fleet != 12)

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '30_no_IPHC_ages'
  ),
  overwrite = TRUE
)

## remove all ages

sensi_mod <- base_model

sensi_mod$ctl$lambdas <- sensi_mod$ctl$lambdas |>
  bind_rows(data.frame(
    like_comp = 5,
    fleet = c(2:7, 11, 12),
    phase = 1,
    value = 0,
    sizefreq_method = 0
  ))

sensi_mod$ctl$N_lambdas <- nrow(sensi_mod$ctl$lambdas)

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'index_and_comp_data',
    '31_no_age_comps'
  ),
  overwrite = TRUE
)


# Change aging error  -----------------------------------------------------

# not sure if we need to do these if we don't have updated data
# plus we don't have the original data the aging errors were developed from?

# Natural Mortality -------------------------------------------------------

# Matheus signed up for these...

# Steepness ---------------------------------------------------------------

## estimate steepness

sensi_mod <- base_model

sensi_mod$ctl$SR_parms$PHASE[2] <- 3 # left it in phase 3

SS_write(
  sensi_mod,
  file.path(
    dir,
    model_directory,
    'sensitivities',
    'model_specs',
    '39_est_steepness'
  ),
  overwrite = TRUE
)


## use 2017 L-W relationship - not run yet

sensi_mod <- base_model

# they don't seem to be different!!

SS_write(
  sensi_mod,
  file.path(dir, model_directory, 'sensitivities', 'model_specs', '41_2017_LW'),
  overwrite = TRUE
)


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

# Run stuff ---------------------------------------------------------------

sensi_dirs <- list.files(file.path(model_directory, 'sensitivities'))

tuning_mods <- grep('weighting', sensi_mods)

future::plan(future::multisession(
  workers = parallelly::availableCores(omit = 1)
))

# furrr::future_map(sensi_dirs[-tuning_mods], \(x)
#                   run(file.path(model_directory, 'sensitivities', x),
#                       exe = exe_loc, extras = '-nohess', skipfinished = FALSE)
# )

furrr::future_map(
  c('nonlinear_q', 'oceanographic_index'),
  \(x)
    run(
      file.path(model_directory, 'sensitivities', x),
      exe = exe_loc,
      extras = '-nohess',
      skipfinished = FALSE
    )
)

future::plan(future::sequential)


# Plot stuff --------------------------------------------------------------

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
    # dplyr::filter(!(Label %in% c('NatM_break_1_Fem_GP_1',
    #                              'NatM_break_1_Mal_GP_1', 'NatM_break_2_Mal_GP_1')),
    #               Label != 'NatM_uniform_Mal_GP_1' | any(grep('break', Label)),
    #               Label != 'SR_BH_steep' | any(grep('break', Label))) |>
    # dplyr::mutate(dplyr::across(-Label, ~ sapply(., format, digits = 3, scientific = FALSE) |>
    #                               stringr::str_replace('NA', ''))) |>
    `names<-`(c('Label', 'Base', mods$pretty)) |>
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


## big plot ----------------------------------------------------------------

current.year <- 2025
CI <- 0.95

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
  dplyr::mutate(CI = qnorm((1 - CI) / 2, 0, baseSD) / base)

ggplot(dev.quants, aes(x = relErr, y = mod_num, col = Metric, pch = Metric)) +
  geom_vline(xintercept = 0, linetype = 'dotted') +
  geom_point() +
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
  theme_bw() +
  scale_shape_manual(
    values = c(15:18, 12),
    # name = "",
    labels = metric.labs
  ) +
  # scale_color_discrete(labels = metric.labs) +
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
