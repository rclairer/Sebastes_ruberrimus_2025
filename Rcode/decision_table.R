#' function modiifed from r4ss::SS_decision_table_stuff
#' to aggregate across areas and modernize to dplyr
SS_decision_table_stuff2 <- function(replist, yrs = 2025:2036, digits = c(0, 0, 3)) {
  unfished <- replist[["derived_quants"]]["SSB_Virgin", "Value"]
  replist[["timeseries"]] |>
    dplyr::filter(Yr %in% yrs) |>
    dplyr::group_by(Yr) |>
    dplyr::summarise(
      catch = sum(rowSums(dplyr::across(dplyr::starts_with("dead(B)")), na.rm = TRUE)),
      spawn_bio = sum(SpawnBio, na.rm = TRUE)
    ) |>
    dplyr::mutate(
      # calculation of fraction_unfished is independent of Bratio definition
      # which could have a different denominator
      fraction_unfished = spawn_bio / unfished
    ) |>
    dplyr::mutate(
      catch = round(catch, digits[1]),
      spawn_bio = round(spawn_bio, digits[2]),
      fraction_unfished = round(fraction_unfished, digits[3])
    ) |>
    dplyr::rename(
      # matching names in earlier version of the function for backwards compatibility
      yr = Yr,
      SpawnBio = spawn_bio,
      dep = fraction_unfished
    )
}

#' Format a decision table
#'
#' Format a decision table for its inclusion in a document.
#'
#' @param ... Each element provided in the call to this function that is not
#' assigned to a particular input argument should be a vector of file paths
#' to the models you want to read for a given column of your decision table.
#' For example, if a single column has results from three models and
#' if your decision table has a low and high state of nature, then
#' there should be two vectors passed via `...` and each vector would contain
#' paths to three different models.
#' The order of the vectors will be the column order from left to right.
#' The order of the models within a vector will be the row order.
#' @param years A vector of years you want catches for.
#' @template format
#' @param caption A character string that
#' will be passed to the `caption` parameter of [kableExtra::kbl].
#' The default value is `NULL`.
#' @param label A character string without underscores that
#' will be passed to the `label` parameter of [kableExtra::kbl].
#' The default value is `NULL`.
#' @param digits A vector of digits for catch, spawning output, and fraction,
#' unfished. It gets passed to `r4ss::SS_decision_table_stuff()`.
#' @param tex TRUE/FALSE controlling whether to apply latex formatting.
#' @export
#' @author Kelli F. Johnson, Ian G. Taylor, Chantel R. Wetzel
#' @examples
#' table_decision(
#'   list(mod.low.A, mod.base.A, mod.high.A),
#'   list(mod.low.B, mod.base.B, mod.high.B),
#'   list(mod.low.C, mod.base.C, mod.high.C)
#' )
table_decision <- function(
    ...,
    years = 2025:2036,
    format = c("latex", "html"),
    caption = formals(kableExtra::kbl)$caption,
    label = formals(kableExtra::kbl)$label,
    digits = c(0, 2, 3),
    tex = TRUE) {
  mods <- list(...)
  # make sure that the format input is good
  # chooses first option by default
  format <- match.arg(format)
  
  # hardwired to prevent users from adding too-long inputs
  rowgroup <- c("A", "B", "C")
  
  # process output
  results <- purrr::modify_depth(
    mods,
    .depth = 2,
    .f = SS_decision_table_stuff2,
    yrs = years,
    digits = digits
  ) |>
    purrr::modify_depth(1, dplyr::bind_cols) |>
    dplyr::bind_rows(.id = "Mgmt") |>
    dplyr::mutate(
      Mgmt = rowgroup[as.numeric(Mgmt)],
      # Catch = pmax(na.rm = TRUE, !!!rlang::syms(grep(value = TRUE, "catch", names(.))))
    ) |>
    dplyr::rename(Year = "yr...1") |>
    dplyr::select(-dplyr::starts_with("yr"))
  
  # get the catch columns and warn if they aren't all equal
  # (simpler than trying to automatically italicize values associated
  # with mismatched catch which had issues for lingcod)
  catch_cols <- results |> dplyr::select(dplyr::starts_with("catch"))
  if (max(abs(apply(catch_cols, 1, sd))) > 0.01) {
    warning("Catch differs among columns, perhaps due to a crashed model without enough biomass.")
  }
  
  # clean up column names and remove extra catch columns
  # first rename the first catch column
  results <- results |>
    dplyr::rename(Catch = "catch...2") |>
    dplyr::select(-dplyr::starts_with("catch", ignore.case = FALSE))
  
  # remove repeated lables in Mgmt column
  results <- results |>
    dplyr::mutate(Mgmt = ifelse(duplicated(Mgmt), "", Mgmt))
  
  # add column names
  rownames(results) <- NULL
  # note: column names could be modified to include informative descriptions
  colnames(results) <- c(
    "Mgmt", "Year", "Catch", "Low Spawn", "Low Frac",
    "Base Spawn", "Base Frac", "High Spawn", "High Frac"
  )
  
  if (tex) {
    results <- results |>
      kableExtra::kbl(
        format = format,
        escape = FALSE,
        booktabs = TRUE,
        linesep = rep(c(rep("", length(years) - 1), "\\addlinespace"), 2),
        align = c("l", "l", "r", rep(c("r", "r"), 3)),
        caption = caption,
        label = label
      ) |>
      kableExtra::column_spec(c(1), bold = TRUE) # first column bold
    
    results <- results |>
      kableExtra::column_spec(4:9, width = "3.5em") |>
      kableExtra::kable_classic(full_width = FALSE) |>
      kableExtra::kable_styling(font_size = 9)
  }
  return(results)
}
