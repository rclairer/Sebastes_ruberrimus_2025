#install.packages("remotes")
#remotes::install_github("nmfs-ost/asar")
#remotes::install_github("nmfs-ost/satf")

library(asar)
library(here)

here::here()

#once we have a Report.sso file
#output_file <- here::here("Report.sso")

#asar::convert_output(
#  output_file = output_file,
#  outdir = here::here(), # or wherever you saved the example output file
#  model = "SS3",
#  file_save = TRUE,
#  savedir = here::here(),
#  save_name = "yelloweye_std_output"
#)

#output <- asar::convert_output(
#  output_file = "Report.sso",
#  outdir = getwd(),
#  model = "SS3"
#)

list.files(system.file("templates", "skeleton", package = "asar"))

asar::create_template(
  format = "pdf",
  office = "NWFSC",
  region = "U.S. West Coast",
  species = "Yelloweye Rockfish",
  spp_latin = "Sebastes ruberrimus",
  year = 2025,
  author = c("R. Claire Rosemond"),
  include_affiliation = TRUE,
  simple_affiliation = FALSE,
  #param_names = c("nf","sf"),
  #param_values = c("North fleet", "South fleet"),
  #resdir = here::here(), # indicate where the model output is located
  #model_results = "petrale_sole_std_output.csv", # converted model output
  #rda_dir = here::here() # directory where the rda files were made in previous step
  ###custom = TRUE, #use if only need certain sections
  ###custom_sections = c("executive_summary") #specify needed sections here
  )
