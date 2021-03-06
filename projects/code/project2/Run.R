# you will need to install the following packages:
# data.table -> install.packages("data.table")
# lubridate -> install.packages("lubridate")
# ggplot2 -> install.packages("ggplot2")
# org -> install.packages("org")

# Here we use a very useful function that lets us
# define the location of all of our necessary folders
# at the start of the project. There are many ways
# to do this, but this is how I choose to do it.
org::AllowFileManipulationFromInitialiseProject()
org::InitialiseProject(
  HOME="/git/rfunctions/projects/code/project2",
  SHARED="/git/rfunctions/projects/results/project2",
  DATA_RAW="/git/rfunctions/projects/data_raw/project2"
)

# We have just set the following folders:
org::PROJ$HOME
org::PROJ$DATA_RAW
org::PROJ$SHARED_TODAY

# We can then use 'file.path' to link to
# files/folders inside these base folders
file.path(org::PROJ$DATA_RAW,"data.csv")

# Load some packages
library(data.table)
library(ggplot2)

##############################
# START DATA CLEANING
##############################

d <- CleanData()

##############################
# END DATA CLEANING
##############################

##############################
# START ANALYSES
##############################

Analyses1(d)

##############################
# END ANALYSES
##############################



