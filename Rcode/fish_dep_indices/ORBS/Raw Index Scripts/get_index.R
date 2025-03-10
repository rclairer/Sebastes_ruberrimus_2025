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