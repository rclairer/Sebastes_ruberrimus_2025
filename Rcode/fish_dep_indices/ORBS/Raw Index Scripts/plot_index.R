
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