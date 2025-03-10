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
