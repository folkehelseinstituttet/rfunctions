# you will need to install the following packages:
# data.table -> install.packages("data.table")
# lubridate -> install.packages("lubridate")
# ggplot2 -> install.packages("ggplot2")
# glue -> install.packages("glue")
# org -> install.packages("org")
# 
# run: 
options(repos=structure(c(
  FHI="https://folkehelseinstituttet.github.io/drat/",
  CRAN="https://cran.rstudio.com"
)))
#
# now install:
# fhidata -> install.packages("fhidata")

##############################
# CODE STARTS HERE
##############################

org::AllowFileManipulationFromInitialiseProject()
org::InitialiseProject(
  HOME="/git/rfunctions/projects/code/merging",
  SHARED="/git/rfunctions/projects/results/merging",
  DATA_RAW="/git/rfunctions/projects/data_raw/merging"
)

# Load some packages
library(data.table)
library(ggplot2)

##############################
# START DATA CLEANING
##############################

d <- fread(file.path(org::PROJ$DATA_RAW,"data.csv"))
d$year <- lubridate::year(d$date)
d <- d[d$age == "0-4",]

population <- fhidata::norway_population_current
population <- population[population$age==0,]

d_merged <- merge(d, population,
            by.x = c("municip", "year"),
            by.y = c("location_code", "year"))

# Always check the number of rows after merging!!!
nrow(d)
nrow(d_merged)

# Why are we missing so many people??
unique(d$year)
unique(d_merged$year)

xtabs(~d$year)
xtabs(~d_merged$year)

unique(d$municip)
unique(d_merged$municip)

# Another way to check if particular values are missing:
# which municipalities are in 'd' but not in 'd_merged'?
unique(d$municip)[!unique(d$municip) %in% unique(d_merged$municip)]

# which municipalities are in 'd_merged' but not in 'd'?
unique(d_merged$municip)[!unique(d_merged$municip) %in% unique(d$municip)]

# Lets remerge

d_merged <- merge(d, population,
            by.x = c("municip", "year"),
            by.y = c("location_code", "year"),
            all.x = TRUE)

nrow(d)
nrow(d_merged)

d_merged[d_merged$municip=="municip9999",]

# Lets keep all data points from both datasets!
# (This doesn't make much sense in this context)

d_merged <- merge(d, population,
            by.x = c("municip", "year"),
            by.y = c("location_code", "year"),
            all.x = TRUE,
            all.y = TRUE)

nrow(d)
nrow(d_merged)

xtabs(~d_merged$municip)

