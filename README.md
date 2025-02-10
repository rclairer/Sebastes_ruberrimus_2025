# Sebastes_ruberrimus_2025
Update assessment for Yelloweye Rockfish (*Sebastes ruberrimus*)

## File Structure 
`Data/` - This directory holds any and all data that is direct requested from state/federal agencies or pulled from NOAA servers (ie. survey data).

`Data/raw/` - Completely raw, unedited, data from various data sources. This folder is untracked and is safe to place confidential data in.

`Data/processed/` - Processed data from available data sources. This folder IS tracked, so no confidential data, only cleaned datasets ready for analysis. Every file in this directory should have an equivalent "raw" data file in data/raw.

`Data/for_ss/` - SS data files. These files should be able to be read directly into SS without further modification.
  
`Rcode/` - This directory should hold R scripts and analyses. These can take the form of either runnable .R scripts or .Rmd Rmarkdown documents/notebooks. This directory is further broken down into subdirectories based on data type ('removals/', 'fish_ind_indices/', 'fish_dep_indices/', 'length_age_comps/', 'model_parms/', and 'survey_length_age/'). Data type specific analyses and scripts should live in their relevant subdirectories rather than the root Rcode/ directory.

`model/` - This directory holds the stock synthesis model code.

`model/2017_base_model/` - This directory holds the executable and files for the 2017 assessment. 

## Useful Packages / Resources

* [PFMC assessments org](https://github.com/pfmc-assessments)
* [Pacific Fishery Management Council](https://www.pcouncil.org)

### Packages
repository | use 
-- | -- 
[nwfscSurvey](http://pfmc-assessments.github.io/nwfscSurvey/) | Analysis of the NWFSC trawl surveys 
[PacFIN.Utilities](https://pfmc-assessments.github.io/PacFIN.Utilities/) | Manipulate data from the PacFIN database for assessments 
