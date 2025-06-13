#' Convert some parameters
#'
#' Convert log Q to standard space, likelihoods to difference from base,
#' and summary biomass into 1000s of mt
#' @param tab a table with a `Label` column containing parameter labels
table_convert_vals <- function(tab) {
  tab[grep("LnQ", tab$Label), -1] <-
    exp(tab[grep("LnQ", tab$Label), -1])
  tab[grep("SmryBio_unfished", tab$Label), -1] <-
    tab[grep("SmryBio_unfished", tab$Label), -1] / 1e3
  #   tab[grep("SSB", tab$Label), -1] <-
  #     tab[grep("SSB", tab$Label), -1]*1e3
  
  # convert likelihoods to difference from base (assumed to be in column 2)
  like_rows <- grep("_like", tab$Label)
  for (icol in ncol(tab):2) {
    tab[like_rows, icol] <- tab[like_rows, icol] - tab[like_rows, 2]
  }
  
  # round length values to 1 decimal place
  tab[grep("L_at", tab$Label), -1] <-
    round(tab[grep("L_at", tab$Label), -1], 1)
  
  # merge rows with separate parameter labels for NatM
  if (any(grepl("NatM_break_1", tab$Label)) & any(grepl("NatM_uniform_Fem", tab$Label))) {
    for (icol in 2:ncol(tab)) {
      if (is.na(tab[grep("NatM_uniform_Fem", tab$Label), icol])) {
        tab[grep("NatM_uniform_Fem", tab$Label), icol] <- tab[grep("NatM_break_1_Fem", tab$Label), icol]
        tab[grep("NatM_uniform_Mal", tab$Label), icol] <- tab[grep("NatM_break_1_Mal", tab$Label), icol]
      }
    }
    tab <- tab[-grep("NatM_break_1", tab$Label), ]
  }
  
  return(tab)
}



#' create a nicer label for model output tables
#'
#' adds a new column of english language labels
#' for parameters and quantities of interest
#' @param tab a table with a `Label` column containing parameter labels
#' @author Ian G. Taylor
#' @export
table_clean_labels <- function(tab) {
  newlabel <- tab$Label
  newlabel <- gsub("TOTAL", "Total", newlabel)
  newlabel <- gsub("Survey", "Index", newlabel)
  newlabel <- gsub("like", "", newlabel)
  newlabel <- gsub("wt", "weight", newlabel)
  newlabel <- gsub("Ret", "Retained", newlabel)
  newlabel <- gsub("p_1_", "", newlabel)
  newlabel <- gsub("GP_1", "", newlabel)
  newlabel <- gsub("SR_LN", "log", newlabel)
  newlabel <- gsub("SR_BH_steep", "Stock-recruit steepness (h)", newlabel)
  # convert things like "LnQ_base_Triennial(3)" to "catchability for Triennial"
  newlabel <- gsub("LnQ_base_([A-Za-z]+)\\((\\d+)\\)", "Catchability for \\1", newlabel)
  newlabel <- gsub("NatM_break_1", "M", newlabel)
  newlabel <- gsub("Fem", "Female", newlabel)
  newlabel <- gsub("Mal", "Male", newlabel)
  newlabel <- gsub("Recr_Virgin", "Recruitment unfished", newlabel)
  newlabel <- gsub("SSB_Virgin", "B0", newlabel)
  newlabel <- gsub("SSB_(\\d{4})", "B\\1", newlabel) # convert SSB_YYYY to BYYYY
  newlabel <- gsub("Bratio", "Fraction unfished", newlabel)
  newlabel <- gsub("OFLCatch", "OFL mt", newlabel)
  newlabel <- gsub("MSY", "MSY mt", newlabel)
  newlabel <- gsub("SPRratio", "Fishing intensity", newlabel)
  newlabel <- gsub("_", " ", newlabel)
  # not generalized, depends on fecundity parameters and summary biomass age
  newlabel <- gsub("SmryBio unfished", "Unfished age 8+ bio 1000 mt", newlabel)
  # newlabel <- gsub("thousand", "1000", newlabel)
  newlabel <- gsub("B(\\d+)", "B\\1 millions of eggs", newlabel) # should work for B0 and B2025
  tab$Label <- newlabel
  return(tab)
}



#' Summarize the configuration of the SS output
#'
#' Copied from https://github.com/pfmc-assessments/lingcod/blob/main/R/table_sens.R
#' and then from the petrale sole assessment repository.
#' @param file_csv A file path to the csv file.
#' @param caption Text you want in the caption.
#' @param caption_extra Additional text to add after the default
#' caption.
#' @param sens_group Optional description of the group of sensitivities
#' which will be used to change "alternative models" in the caption
#' (if present) to "alternative models related to \[sens_group\]"
#' @param dir Directory where the table should go (relative to "doc")
#' @template format
#' @author Kelli F. Johnson, Ian G. Taylor
#' @export
#' @examples
#' \dontrun{
#' table_sens("tables/sens_table_s_bio_rec.csv")
#' }
#'
table_sens <- function(dat,
                       #  caption = "Differences in negative log-likelihood, estimates of key parameters, and estimates of derived quantities between the base model and several alternative models (columns). See main text for details on each sensitivity analysis. Red values indicate negative log-likelihoods that were lower (fit better to that component) than the base model.",
                       #  caption_extra = "",
                       # label = "tbl-sens",
                       sens_group = NULL,
                       dir = file.path("..", "tables"),
                       format = "latex") {
  # # Revise caption if sens_group is provided
  # if (!is.null(sens_group)) {
  #   caption <- gsub(
  #     pattern = "alternative models",
  #     replacement = paste(
  #       "alternative models related to",
  #       sens_group
  #     ),
  #     x = caption
  #   )
  #   caption <- gsub(
  #     pattern = "Differences",
  #     replacement = paste(
  #       stringr::str_replace(sens_group, "^\\w{1}", toupper), # capitalize first word
  #       "sensitivity analyses: differences"
  #     ),
  #     x = caption
  #   )
  # }
  # # add any additional text to caption
  # caption <- paste(caption, caption_extra)
  
  conditional_color <- function(x) {
    kableExtra::cell_spec(x,
                          color = ifelse(is.na(x) | x >= 0, "black", "red"),
                          format = "latex"
    )
  }
  data <- dat |>
    dplyr::filter(!grepl("VonBert", Label)) |> # remove VonBert K to fit on page
    dplyr::filter(!grepl("Forecast", Label)) |> # remove VonBert K to fit on page
    dplyr::rename_with(~ gsub(" & ", "-", .x)) |>
    table_convert_vals() |>
    # table_convert_offsets() |>
    table_clean_labels()
  
  tt <- kableExtra::kbl(
    data |>
      dplyr::mutate_if(is.numeric, round, 3) |>
      dplyr::mutate_if(is.numeric, conditional_color),
    booktabs = TRUE, longtable = TRUE,
    format = format, escape = FALSE,
    digits = 3 # ,
    # caption = caption,
    # label = label
  ) |> 
    kableExtra::kable_styling(font_size = 9)
  
  # decrease column width for tables with lots of columns
  if (NCOL(data) <= 7) {
    tt <- tt |>
      kableExtra::column_spec(3:NCOL(data), width = "5em")
  }
  if (NCOL(data) > 7) {
    tt <- tt |>
      kableExtra::column_spec(3:NCOL(data), width = "4em")
  }
  
  # add subsection to improve readability
  # needs to be customized for the quantities chosen
  switch1 <- grep("Recruitment unfished", data[, 1])[1] # age X+ summary biomass is first derived quantity
  switch2 <- grep("+ bio", data[, 1])[1] # age X+ summary biomass is first derived quantity
  tt <- tt |>
    kableExtra::pack_rows("Diff. in likelihood from base model", 1, switch1 - 1) |>
    kableExtra::pack_rows("Estimates of key parameters", switch1, switch2 - 1) |>
    kableExtra::pack_rows("Estimates of derived quantities", switch2, NROW(data))
  return(tt)
}