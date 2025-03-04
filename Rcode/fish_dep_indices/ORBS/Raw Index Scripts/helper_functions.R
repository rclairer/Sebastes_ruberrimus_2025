
# manually pulled functions for sdmTMB index work 

# emailed to me by Melissa Monk on 4/26/2023


get_diag_tables <- function(fit, dir){
  
  run_diagnostics <- list()
  run_diagnostics$model <- fit$family$clean_name
  run_diagnostics$formula <- fit$formula[[1]]
  run_diagnostics$loglike <- logLik(fit)
  run_diagnostics$aic <- AIC(fit)
  write.csv(
    rbind(c("AIC", run_diagnostics$aic), c("NLL", run_diagnostics$loglike)), 
    file = file.path(dir, "aic_nll.csv"),
    row.names = FALSE
  )
  
  if (length(grepl("delta", run_diagnostics$model)) > 0) {
    run_diagnostics$model1_fixed_effects <- tidy(
      fit, 
      model = 1, 
      effects = 'fixed',
      conf.int = TRUE
    )
    run_diagnostics$model2_fixed_effects <- tidy(
      fit, 
      model = 2, 
      effects = 'fixed',
      conf.int = TRUE
    )
    run_diagnostics$model1_random_effects <- tidy(
      fit, 
      model = 1, 
      effects = 'ran_pars',
      conf.int = TRUE
    )
    run_diagnostics$model2_random_effects <- tidy(
      fit, 
      model = 2, 
      effects = 'ran_pars',
      conf.int = TRUE
    )
    
    model_fixed_effects <- run_diagnostics$model1_fixed_effects
    model_fixed_effects[, 2:ncol(model_fixed_effects)] <- round(model_fixed_effects[, 2:ncol(model_fixed_effects)], 2)
    colnames(model_fixed_effects) <- c("Term", "Estimate", "SD Error", "Low CI", "High CI")
    write.csv(model_fixed_effects, 
              file = file.path(dir, "model1_fixed_effects_parameters.csv"), row.names = FALSE)
    
    model_fixed_effects <- run_diagnostics$model2_fixed_effects
    model_fixed_effects[, 2:ncol(model_fixed_effects)] <- round(model_fixed_effects[, 2:ncol(model_fixed_effects)], 2)
    colnames(model_fixed_effects) <- c("Term", "Estimate", "SD Error", "Low CI", "High CI")
    write.csv(model_fixed_effects, 
              file = file.path(dir, "model2_fixed_effects_parameters.csv"), row.names = FALSE)
    
    model_random_effects <- run_diagnostics$model1_random_effects
    model_random_effects[, 2:ncol(model_random_effects)] <- round(model_random_effects[, 2:ncol(model_random_effects)], 2)
    colnames(model_random_effects) <- c("Term", "Estimate", "SD Error", "Low CI", "High CI")
    write.csv(model_random_effects, 
              file = file.path(dir, "model1_random_effects_parameters.csv"), row.names = FALSE)
    
    model_random_effects <- run_diagnostics$model2_random_effects
    model_random_effects[, 2:ncol(model_random_effects)] <- round(model_random_effects[, 2:ncol(model_random_effects)], 2)
    colnames(model_random_effects) <- c("Term", "Estimate", "SD Error", "Low CI", "High CI")
    write.csv(model_random_effects, 
              file = file.path(dir, "model2_random_effects_parameters.csv"), row.names = FALSE)
    
  } else {
    run_diagnostics$model_fixed_effects <- tidy(
      fit, 
      effects = 'fixed',
      conf.int = TRUE
    )
    run_diagnostics$model_random_effects <- tidy(
      fit, 
      effects = 'ran_pars',
      conf.int = TRUE
    )
    
    model_fixed_effects <- run_diagnostics$model_fixed_effects
    model_fixed_effects[, 2:ncol(model_fixed_effects)] <- round(model_fixed_effects[, 2:ncol(model_fixed_effects)], 2)
    colnames(model_fixed_effects) <- c("Term", "Estimate", "SD Error", "Low CI", "High CI")
    write.csv(model_fixed_effects, 
              file = file.path(dir, "fixed_effects_parameters.csv"), row.names = FALSE)
    
    model_random_effects <- run_diagnostics$model_random_effects
    model_random_effects[, 2:ncol(model_random_effects)] <- round(model_random_effects[, 2:ncol(model_random_effects)], 2)
    colnames(model_random_effects) <- c("Term", "Estimate", "SD Error", "Low CI", "High CI")
    write.csv(model_random_effects, 
              file = file.path(dir, "random_effects_parameters.csv"), row.names = FALSE)
  }
  
  s <- sanity(fit, big_sd_log10 = 2, gradient_thresh = 0.001)
  write.csv(s, file = file.path(dir, "sanity.csv"), row.names = FALSE)
  
  sink(file = file.path(dir, "fit.txt"))
  fit
  sink()
  
  save(
    run_diagnostics, 
    file = file.path(dir, "run_diagnostics_and_estimates.rdata")
  )
  
}

plot_qq <- function(fit, dir){
  
  resids <- fit$data$residuals
  # Switch to generating the Q:Q plot based on MCMC samples
  # samps <- sdmTMBextra::predict_mle_mcmc(fit, mcmc_iter = 201, mcmc_warmup = 200)
  # mcmc_res <- residuals(fit, type = "mle-mcmc", mcmc_samples = samps)
  
  grDevices::png(
    filename = file.path(dir, "qq.png"),
    width = 7, 
    height = 7, 
    units = "in", 
    res = 300, 
    pointsize = 12
  )
  stats::qqnorm(resids) 
  stats::qqline(resids)
  dev.off()
  
}

plot_qq_sdm <- function(fit, dir){
  
  resids <- residuals(fit)
  
  grDevices::png(
    filename = file.path(dir, "qq.png"),
    width = 7,
    height = 7,
    units = "in",
    res = 300,
    pointsize = 12
  )
  stats::qqnorm(resids)
  stats::qqline(resids)
  dev.off()
  
}



plot_residuals<- function(fit, dir, nrow = 3, ncol = 4){
  
  year <- fit$time
  df <- fit$data
  num_years <- sort(unlist(unique(df[, year])))
  g <- split(
    num_years, 
    ceiling(seq_along(num_years) / (ncol * nrow))
  )
  if (min(df$lon) > 0){
    lon_range <- -1 * c(min(df$lon), max(df$lon))
    df$lon <- -1 * df$lon
  } else {
    lon_range <- c(min(df$lon), max(df$lon))
  }
  lat_range <- c(min(df$lat), max(df$lat))
  
  for(page in 1:length(g)) {
    
    ggplot2::ggplot(df[df$year %in% g[[page]], ], 
                    aes(lon, lat, colour = residuals)) + 
      geom_point() + 
      scale_colour_viridis_c(option = "A") +
      nwfscSurvey::draw_theme() +
      nwfscSurvey::draw_land() +
      nwfscSurvey::draw_projection() +
      nwfscSurvey::draw_USEEZ(lon_range, lat_range)  + 
      facet_wrap(~year, ncol = ncol, nrow = nrow) +
      labs(x = "Longitude", y = "Latitude", colour = "Residuals") 
    
    height <- ifelse(
      length(g[[page]]) == nrow * ncol, 10, 7)
    ggsave(
      filename = file.path(dir, paste0("residuals_page", page, ".png")), 
      width = 14, height = height, units = 'in')
  }
}


plot_fixed_effects_para <- function(fit, dir, name = "") {
  
  est <- as.list(fit$sd_report, "Estimate", report = FALSE)
  sd  <- as.list(fit$sd_report, "Std. Error", report = FALSE)
  years <- sort(unlist(unique(fit$data[, fit$time])))
  
  n_plot <- ifelse(
    "b_j2" %in% names(est),
    ifelse(length(est$b_j2) > 0, 2, 
           1), 1
  )
  
  n_var <- length(fit$xlevels[[1]])
  
  png(
    filename = file.path(dir, "fixed_effects_parameters.png"),
    height = ifelse(n_var > 2, 20, 10),
    width = 10,
    units = "in",
    res = 300
  )
  on.exit(dev.off(), add = TRUE)
  
  par(mfrow = c(n_var, n_plot))
  
  td <- tidy(fit, model = 1)
  yr_i <- grep("year", td$term, ignore.case = TRUE)
  upr <- est$b_j[yr_i] + 2 * sd$b_j[yr_i]
  lwr <- est$b_j[yr_i] - 2 * sd$b_j[yr_i]
  
  main_text <- ifelse(
    n_plot == 2, 
    "Fixed Effects: Presence Model",
    "Fixed Effects: Catch Rate Model"
  )
  
  plot(years, est$b_j[yr_i], ylim = range(c(lwr, upr)),
       ylab = "Parameter Estimates", xlab = "Year", 
       main = main_text)
  segments(x0 = as.numeric(years), y0 = lwr, 
           x1 = as.numeric(years), y1 = upr,
           col = "black")
  
  if(n_var > 1){
    ind <- length(yr_i) + 1
    for(aa in 2:n_var){
      main_text <- names(fit$xlevels[[1]][aa])
      x_val <- as.numeric(unlist(fit$xlevels[[1]][aa]))[-1]
      y_i <- ind:(ind + length(x_val) - 1)
      upr <- est$b_j[y_i] + 2 * sd$b_j[y_i]
      lwr <- est$b_j[y_i] - 2 * sd$b_j[y_i]
      plot(x_val, est$b_j[y_i], ylim = range(c(lwr, upr)),
           ylab = "Parameter Estimates", xlab = main_text, axes = FALSE)
      segments(x0 = x_val, y0 = lwr, 
               x1 = x_val, y1 = upr,
               col = "black")
      box()
      axis(side = 2)
      if(length(x_val) > 25) {
        text(x = x_val[seq(1,length(x_val),5)], y = par("usr")[3] - 0.5, xpd = NA, labels = as.factor(x_val)[seq(1,length(x_val),5)], cex = 0.5, srt = 45)
      } else {
        mtext(side = 1, at = x_val, text = x_val)
      }
      
      ind <- ind + length(x_val) 
    }
    
  }
  
  if (n_plot > 1) {
    td <- tidy(fit, model = 2)
    upr <- est$b_j2[yr_i] + 2 * sd$b_j2[yr_i]
    lwr <- est$b_j2[yr_i] - 2 * sd$b_j2[yr_i]
    yr_i <- grep("year", td$term, ignore.case = TRUE)
    plot(years, est$b_j2[yr_i], ylim = range(c(lwr, upr)),
         ylab = "Parmater Estimates", xlab = "Year", 
         main = "Fixed Effects: Catch Rate Model")
    segments(
      years, lwr,
      years, upr,
      col = 'black'
    )    
  }
  
  
}

plot_map <- function(data, column) {
  
  lon_range <- c(min(data$lon), max(data$lon))
  lat_range <- c(min(data$lat), max(data$lat))
  
  ggplot2::ggplot(data, aes(lon, lat, fill = {{ column }})) +
    geom_raster() +
    coord_fixed() +
    nwfscSurvey::draw_theme() +
    nwfscSurvey::draw_land() +
    nwfscSurvey::draw_USEEZ(lon_range, lat_range) 
}


plot_map_density <- function(predictions, dir, ncol = 4, nrow = 3, verbose = FALSE){
  
  column <- ifelse(
    "est2" %in% colnames(predictions),
    "est2",
    ifelse("est" %in% colnames(predictions),
           "est", 
           "skip")
  )
  
  if(column != 'skip'){
    num_years <- sort(unique(predictions$year))
    g <- split(
      num_years, 
      ceiling(seq_along(num_years) / (ncol * nrow))
    )
    for(page in 1:length(g)) {
      
      plot_map(predictions[predictions$year %in% g[[page]], ], 
               exp(predictions[predictions$year %in% g[[page]], column]) ) +
        geom_tile() + 
        labs(x = "Longitude", y = "Latitude") +
        scale_fill_viridis_c(
          name = "exp(pred)",
          trans = "sqrt",
          # trim extreme high values to make spatial variation more visible
          na.value = "yellow", 
          limits = c(0, quantile(exp(predictions[, column]), 0.995))
        ) +
        facet_wrap(~year, ncol = ncol, nrow = nrow) +
        ggtitle("Density Predictions: Fixed Effects + Random Effects")
      
      height <- ifelse(
        length(g[[page]]) == nrow * ncol, 10, 7)
      
      ggsave(
        filename = file.path(dir, paste0("prediction_density_", page, ".png")), 
        width = 10, 
        height = height, 
        units = 'in'
      )
    }
  } else {
    if(verbose){
      message('The est column not found in the predictions. Prediction density map not created.')
    }
  }
  
  
}

do_diagnostics <- function(dir, fit, plot_resids = TRUE){
  
  write.csv(rbind(c("pos_def_hessian", fit$pos_def_hessian),
                  c("bad_eig", fit$bad_eig)), 
            file = file.path(dir, paste0("pos_def_hessian_", fit$pos_def_hessian, ".csv")))
  
  get_diag_tables(
    fit = fit, 
    dir = dir
  )
  
  fit$data$residuals <- residuals(fit)
  
  plot_qq(fit = fit, 
          dir = dir)
  
  if(plot_resids == TRUE){
    plot_residuals(
      fit = fit, 
      dir = dir, 
      nrow = 3, ncol = 4)    
  }
  
  #plot_fixed_effects_para(
  #  fit = fit, 
  #  dir = dir) 
  
}

#' 
#' @param common_name species names as given in the hook and line data set
#' @param data raw hook and line data
#'
format_hkl_data <- function(
    common_name = "Bocaccio", 
    data) {
  
  data$vermilion <- data$bocaccio <- 0
  data$vermilion[data$common_name == "Vermilion Rockfish"] <- 1
  data$bocaccio[data$common_name == "Bocaccio"] <- 1
  
  data$number_caught <- as.numeric(data$common_name %in% common_name)  
  data$common_name <- common_name  
  data$crew <- paste0(data$angler_first_name, data$angler_last_name)
  # Change Phillip Ebert's name to 'AAAPhillipEbert'
  # so that the Aggressor also has the crew name that gets set to zero
  data$crew[data$crew %in% "PhillipEbert"] <- "AAAPhillipEbert"  
  
  total_sample_by_site <- 
    data.frame(
      site_number  = dimnames(table(data$site_number, data$year))[[1]], 
      samples_across_years = apply(matrix(as.numeric(as.logical(table(data$site_number, data$year))), 
                                          ncol = ncol(table(data$site_number, data$year))), 1, sum))
  
  # need to find way to do this without JWToolBox
  data <- match.f(data, total_sample_by_site, "site_number", "site_number", "samples_across_years")
  
  data$cca <- data$cowcod_conservation_area_indicator
  
  samples_across_years <- aggregate(
    list(total_caught_by_site = data$number_caught), 
    list(site_number = data$site_number), sum)
  
  data <- data[data$site_number %in% 
                 samples_across_years[samples_across_years$total_caught_by_site != 0, "site_number"] & 
                 data$samples_across_years >= 2, 
               c("common_name", "number_caught", "year", "site_number", "vessel",
                 "cca", "vermilion", "bocaccio",
                 "drop_latitude_degrees", "drop_longitude_degrees",
                 "drop_number", "hook_number", "angler_number", "sex", "crew", 
                 "fishing_time_seconds",
                 "drop_depth_meters", "swell_height_m", "wave_height_m", 
                 "fishing_time_seconds",
                 "moon_phase_r", 
                 "moon_proportion_fullness_r", 
                 "drop_time_proportion_of_solar_day", 
                 "weight_kg", "length_cm")]
  
  data$hook_number <- as.character(data$hook_number)
  data$hook_number[data$hook_number %in% "1"] <- "1_Bottom"
  data$hook_number[data$hook_number %in% "5"] <- "5_Top"
  
  data$angler_number <- as.character(data$angler_number)
  data$angler_number[data$angler_number %in% "1"] <- "1_Bow"
  data$angler_number[data$angler_number %in% "2"] <- "2_Midship"
  data$angler_number[data$angler_number %in% "3"] <- "3_Stern"
  
  data$year <- as.factor(as.character(data$year))
  data$site_number <- as.factor(as.character(data$site_number))
  data$vessel <- as.factor(as.character(data$vessel))
  data$drop_number <- as.factor(as.character(data$drop_number))
  data$angler_number <- as.factor(as.character(data$angler_number))
  data$crew <- as.factor(as.character(data$crew))
  data$hook_number <- as.factor(as.character(data$hook_number))
  data$sex <- as.factor(as.character(data$sex))
  data$moon_phase <- as.factor(data$moon_phase_r)
  data$cca <- as.factor(data$cca)
  
  # Create Minor Angler Groups
  #if(area == "Orig121") {
  #  data <- data[as.numeric(as.character(data$site_number)) < 500, ]  }
  #if(area == "CCA") {
  #   data <- data[as.numeric(as.character(data$site_number)) > 500, ] }  
  
  mean_crew <- aggregate(list(Mean = data$number_caught), list(crew = data$crew), mean)   
  data <- refactor(data[!data$crew %in% mean_crew[mean_crew$Mean %in% 0, 'crew'], ])    
  data$crew <- as.character(data$crew)  
  data$crew <- as.factor(data$crew)
  
  data[,'crew'] = as.numeric(data[,'crew'], as.is = FALSE) - 1
  data[,'hook'] = as.numeric(data[,'hook_number'], as.is = FALSE) 
  data[,'drop'] = as.numeric(data[,'drop_number'], as.is = FALSE) 
  data[,'angler'] = as.numeric(data[,'angler_number'], as.is = FALSE) 
  data[, "moon_phase"] = as.numeric(data[,"moon_phase"], as.is = FALSE) 
  return(data)
  
}

format_index <- function(dir, index, month = 7, fleet = NA){
  
  format_index <- data.frame(
    year = index[,1],
    month = month,
    fleet = fleet,
    obs = index$est,
    logse = index$se
  )
  write.csv(format_index, 
            file = file.path(dir, "index_forSS.csv"),
            row.names = FALSE)
}

calc_index <- function(dir, fit, grid, ymax = NULL, bias_correct = TRUE){
  
  save(fit, file = file.path(dir, "fit.rdata"))
  
  pred <- predict(fit, newdata = grid, return_tmb_object = TRUE)
  
  index <- get_index(pred, bias_correct = bias_correct)
  
  save(index, file = file.path(dir, "index.rdata"))
  
  format_index(
    dir = dir, 
    index = index)
  
  plot_indices(
    data = index, 
    dir = dir, 
    ymax = ymax)
  
  return(index)
}

match.f <- function (file, table, findex = 1, tindex = findex, tcol = NULL, round. = T, digits = 0) {
  ''
  '  #   DATE WRITTEN:  Circa 1995      LAST REVISED:   Circa 2005  '
  '  #   AUTHOR:  John R. Wallace (John.Wallace@noaa.gov)  '
  ''
  paste.col <- function(x) {
    if (is.null(dim(x)))
      return(paste(as.character(x)))
    out <- paste(as.character(x[, 1]))
    for (i in 2:ncol(x)) {
      out <- paste(out, as.character(x[, i]))
    }
    out
  }
  if (is.null(dim(file))) {
    dim(file) <- c(length(file), 1)
  }
  if (round.) {
    for (i in findex) {
      if (is.numeric(file[, i]))
        file[, i] <- round(file[, i], digits)
    }
    for (i in tindex) {
      if (is.numeric(table[, i]))
        table[, i] <- round(table[, i], digits)
    }
  }
  if (is.null(tcol))
    tcol <- dimnames(table)[[2]][!(dimnames(table)[[2]] %in%
                                     tindex)]
  cbind(file, table[match(paste.col(file[, findex]), paste.col(table[,
                                                                     tindex])), tcol, drop = F])
}


plot_betas_delta <- function(sdmTMB_model, model = 1, out_file) {
  
  years = as.numeric(sort(unique(sdmTMB_model$data[[sdmTMB_model$time]]))) 
  
  sdmTMB_est <- as.list(sdmTMB_model$sd_report, "Estimate", report = FALSE)
  sdmTMB_sd <- as.list(sdmTMB_model$sd_report, "Std. Error", report = FALSE)
  ymax = max(sdmTMB_est$b_j)
  
  grDevices::png(filename = out_file,
                 width = 10, height = 7, units = "in", res = 300, pointsize = 12)
  par(mfrow = c(1, 1), cex = 0.8, mar = c(4, 4, 2, 2), oma = c(2, 3, 1, 1))
  
  if (model == 1) {
    td <- tidy(sdmTMB_model, model = model)
    yr_i <- grep("year", td$term, ignore.case = TRUE)
    plot(years, sdmTMB_est$b_j, ylim = c(-2*ymax, 2*ymax),
         xlab = "Year", ylab = "Parameter Estimates")
    segments(years, sdmTMB_est$b_j - 2 * sdmTMB_sd$b_j,
             years, sdmTMB_est$b_j+ 2 * sdmTMB_sd$b_j,
             col = "red")
  } else {
    td <- tidy(sdmTMB_model, model = model)
    plot(years, sdmTMB_est$b_j2, ylim = c(-2*ymax, 2*ymax),
         xlab = "Year", ylab = "Parameter Estimates")
    segments(years, sdmTMB_est$b_j2 - 2 * sdmTMB_sd$b_j2,
             years, sdmTMB_est$b_j2 + 2 * sdmTMB_sd$b_j,
             col = "red")
  }
  dev.off()
}


plot_indices <- function(data, dir, ymax = NULL) {
  
  years =   as.numeric(as.character(data$year))
  sdmtmb_est <- data[,'est']
  hi_sdmtmb <- data[, "upr"]
  lo_sdmtmb <- data[, "lwr"]
  
  out_file = file.path(dir, "Index.png")
  grDevices::png(filename = out_file,
                 width = 10, height = 7, units = "in", res = 300, pointsize = 12)
  
  cex.axis = 1.25
  cex.lab = 1.20
  if (is.null(ymax)) {
    ymax = max(hi_sdmtmb) + 0.10 * max(hi_sdmtmb)
    if(ymax > 3 * max(sdmtmb_est)){
      ymax =  3 * max(sdmtmb_est)
    }
  }
  x <- 0.04
  
  plot(0, type = "n",
       xlim = range(years),
       ylim = c(0, ymax),
       xlab = "", ylab = "", yaxs = "i",
       main = "", cex.axis = cex.axis)
  
  graphics::mtext(side = 1, "Year", cex = cex.lab, line = 3)
  graphics::mtext(side = 2, "Relative Index", cex = cex.lab, line = 2.5)
  
  graphics::arrows(x0 = years + x, y0 = lo_sdmtmb, x1 = years + x, y1 = hi_sdmtmb, 
                   angle = 90, code = 3, length = 0.01, col = "blue",
                   lty = 2)
  graphics::points(years + x, sdmtmb_est, pch = 16, bg = 1, cex = 1.6, col = 'blue')
  graphics::lines(years + x,  sdmtmb_est, cex = 1, col = 'blue', lty = 2)
  
  dev.off()
  
}

refactor <- function(df, exclude = c(NA, ""))
{
  if(is.null(dim(df)))
    if(is.factor(df))
      factor(as.character(df), exclude = exclude)
  else df
  else {
    data.frame(lapply(df, function(x)
      if(is.factor(x)) factor(as.character(x), exclude = exclude) else x))
  }
}


