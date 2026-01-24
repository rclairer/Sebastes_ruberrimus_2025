###############################################################################
#Automated alt text generation for asar documents. Because as of December 2025 
#they cant assign alt text. 

#Input is a list of user-specified files from your report.
#Output is a csv with this format (https://github.com/nmfs-ost/stockplotr/blob/main/inst/resources/captions_alt_text_template.csv)

#This code takes the input files, identifies where alt text is specified for 
#figures, and then reads the alt text and saves it to a csv

#By Brian Langseth, Dec 2025
###############################################################################

library(here)
library(dplyr)

input_files <- c("01_executive_summary",
                 "09_figures")

output_name <- "fig_labels_captions"

alt_text_to_csv(input_files, output_name)


alt_text_to_csv <- function(input, output_file){
  
  ##Read input
  
  input_rename <- here("report", paste0(input, ".qmd"))
  
  read_input <- lapply(input_rename, function(x) {
    readLines(x)
  })
  
  
  ##Extract lines
  
  #Extract the alt text labels in each file that are not commented out
  lab_lines <- lapply(read_input, function(x) {
    x[grepl("label:", x) & !grepl("<!--", x) & !grepl("tbl", x)]
  })
    
  #Extract the alt text captions in each file that are not commented out
  cap_lines <- lapply(read_input, function(x) {
    x[grepl("fig-cap", x) & !grepl("<!--", x)]
  })
  
  #Check to ensure caption and label lists are the same length
  if(!identical(lengths(lab_lines), lengths(cap_lines))) {
     warning(paste("Label and captions list are of unequal length. Check file(s): \n",
                   paste(input_files[which(lengths(lab_lines) != lengths(cap_lines))], collapse = "\n "))
             )
  }
  
  
  ##Extract parts of the lines that are needed
  labs <- lapply(lab_lines, function(x) {
    sub(".*fig-", "", x) #everything after the 'fig-'
  })
  caps <- lapply(cap_lines, function(x) {
    sub(".*:[^\\]{2}", "", x) %>%
    sub("(.{1})$", "", .)
    #everything after the colon '.*:', and then 
    #remove the first two character other than the '\' [^\\]{2}. 
    #Then from that remove the last character '(.{1})$'
  })
  
  
  ##Save the file as a csv
  out <- data.frame("label" = unlist(labs), 
                    "cap_text" = unlist(caps))
  file_name <- here("report", paste0(output_name, ".csv"))
  
  write.csv(out, file = file_name, row.names = F)
  writeLines(paste("Alt text saved to file:\n", file_name))
  
  return(out)
  
}
