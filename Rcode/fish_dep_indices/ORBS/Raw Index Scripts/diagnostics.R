
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
