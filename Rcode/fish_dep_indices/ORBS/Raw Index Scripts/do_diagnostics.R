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