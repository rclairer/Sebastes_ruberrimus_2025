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