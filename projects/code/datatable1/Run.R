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
  HOME="/git/rfunctions/projects/code/datatable1",
  SHARED="/git/rfunctions/projects/results/datatable1",
  DATA_RAW="/git/rfunctions/projects/data_raw/datatable1"
)

# Load some packages
library(data.table)
library(ggplot2)

##############################
# START DATA CLEANING
##############################

d <- fread(file.path(org::PROJ$DATA_RAW,"data.csv"))

##############################
# data.table vs data.frame
##############################
# old (data.frame) way
# d$year <- lubridate::year(d$date)
# new (data.table) way
d[,year := lubridate::isoyear(date)]

##############################
# PRINCIPLES OF DATA.TABLE
##############################
# datatable[rows, columns, groups]

##############################
# ROW SELECTION
##############################
d[year==2006]

##############################
# ROW SELECTION AND VARIABLE CREATION
##############################
d[year==2006, consult := consult * 1000]
d[year==2006]
d[year==2007]

d <- d[year >= 2006]

##############################
# CREATION OF NEW VARIABLE
##############################
d[, name := "hello"]
d

##############################
# DELETION OF VARIABLE
##############################
d[, name := NULL]
d

##############################
# CREATION OF NEW VARIABLE USING GROUPS
##############################
d[, num_consults_per_year_age := sum(consult), by = .(year,age)]
d

##############################
# SUMMARIZING/AGGREGATING DATA
##############################

## COLLAPSING TO WEEKLY DATA, ONLY CONTAINING 'Legekontakt'
# first attempt to create a "year-week" variable
d[,year_week:=glue::glue("{year}-{week}",
                         year=lubridate::isoyear(date),
                         week=lubridate::isoweek(date))]
d
# putting a leading '0' in front of the week
d[,year_week:=glue::glue("{year}-{week}",
                         year=lubridate::isoyear(date),
                         week=formatC(lubridate::isoweek(date),width=2,flag=0))]
d
# Remember: [rows, columns, groups]
d_weekly <- d[
  Kontaktype=="Legekontakt",
  .(
    influensa = sum(influensa),
    consult = sum(consult)
  ),
  keyby=.(
    municip,
    age,
    week_year
  )
  ]
d_weekly

# creating summary statistics
ugly_table <- d[,
  .(
    num_influensa=sum(influensa),
    num_consults=sum(consult),
    mean_weekly_influensa_consults = mean(influensa)
  ),
  keyby=.(
    age,
    year
  )]
ugly_table

##############################
# MAKING A MAP
##############################

pd <- fhidata::norway_map_counties

q <- ggplot()
q <- q + geom_polygon(data = pd, aes( x = long, y = lat, group = group, fill=location_code), color="black")
q <- q + theme_void()
q <- q + coord_quickmap()
q
ggsave(
  file.path(org::PROJ$SHARED_TODAY,"map_1.png"),
  plot = q,
  width = 297,
  height = 210,
  units = "mm"
  )

# looking at the map data
pd

# looking at the population data
population <- fhidata::norway_population_current

# creating population for 0-105 year olds (aggregating)
total_pop <- population[
  year==2019,
  .(
    pop_2019=sum(pop)
  ),
  keyby=.(
    location_code
  )]
total_pop

# merging map data 'pd' with population data
pd2 <- merge(
  pd,
  total_pop,
  by.x=c("location_code"),
  by.y=c("location_code"))

# check to see if we lost any data
nrow(pd)
nrow(pd2)

# plot, coloring by pop_2019
q <- ggplot()
q <- q + geom_polygon(data = pd2, aes( x = long, y = lat, group = group, fill=pop_2019), color="black")
q <- q + theme_void()
q <- q + coord_quickmap()
q
ggsave(
  file.path(org::PROJ$SHARED_TODAY,"map_2.png"),
  plot = q,
  width = 297,
  height = 210,
  units = "mm"
)

##############################
# create annual incidence of influensa per 
# 100.000 people in 2018 per municipality
##############################
d <- readRDS(file.path(org::PROJ$DATA_RAW,"data_2018.rds"))
res <- d[,
  .(influensa=sum(influensa)),
  keyby=.(municip)
  ]

# creating population for 0-105 year olds (aggregating)
total_pop <- fhidata::norway_population_current[
  year==2018,
  .(pop_2018=sum(pop)),
  keyby=.(location_code)
  ]
total_pop

# merge
res2 <- merge(
  res,
  total_pop,
  by.x=c("municip"),
  by.y=c("location_code")
)

# check if we lost any data
nrow(res)
nrow(res2)

# look at our new data
res2

# create incidence
res2[,incidence := 10000*influensa/pop_2018]

# categorize incidence
res2[, incidence_cat := cut(incidence, breaks = c(0, 50000, 100000, 200000, 9999999))]
levels(res2$incidence_cat)
levels(res2$incidence_cat) <- c("0-50.000","50.001-100.000","100.001-200.000","200.001+")

# merge with map dataset

pd2 <- merge(
  fhidata::norway_map_municips,
  res2,
  by.x=c("location_code"),
  by.y=c("municip"))

# check to see if we lost any data
nrow(fhidata::norway_map_municips)
nrow(pd2)

# looks like we are missing something!
unique(fhidata::norway_map_municips$location_code)[!unique(fhidata::norway_map_municips$location_code) %in% unique(pd2$location_code)]
# looks like we do NOT have data for 'municip5061'!!

# plot, coloring by incidence_cat
q <- ggplot()
q <- q + geom_polygon(data = pd2, aes( x = long, y = lat, group = group, fill=incidence_cat), color="black", lwd=0.1)
q <- q + theme_void()
q <- q + coord_quickmap()
q <- q + scale_fill_brewer("Incidence",palette="OrRd")
q
ggsave(
  file.path(org::PROJ$SHARED_TODAY,"map_3.png"),
  plot = q,
  width = 297,
  height = 210,
  units = "mm"
)

##############################
# HOW TO CREATE A SKELETON DATASET
##############################
# In the previous section we learned that our base dataset was missing 
# data on 'municip5061'.
#
# If we want to create a summary dataset that includes zeros (when no data exists)
# then we need to create a 'skeleton' and merge our data into the skeleton

# let us take a simple dataset:
d <- data.table(
  location_code = "municip0301",
  date = as.Date("2018-01-03"),
  num_influensa = 4
)

d

# I want to have a dataset that contains:
# - daily values from 2018-01-01 to 2018-01-31
# - for all municipalities in Norway
# 
# we achieve this by creating a skeleton using 'expand.grid':

skeleton <- data.table(expand.grid(
  location_code = fhidata::norway_locations_current$municip_code,
  date = seq.Date(
    from=as.Date("2018-01-01"),
    to=as.Date("2018-01-31"),
    by=1),
  stringsAsFactors = FALSE
))

# now we merge our dataset with the skeleton:
d2 <- merge(
  skeleton,
  d,
  by.x=c("location_code","date"),
  by.y=c("location_code","date"),
  all.x=T
)

# check number of rows of data
nrow(skeleton)
nrow(d2)

# look at dataset
d2

# fill in the 'missing' with 0s
d2[is.na(num_influensa), num_influensa:=0]

# now you have a complete dataset of daily data
# from all of norway!
d2
d2[num_influensa>0]
d2[location_code=="municip0301"]
d2[location_code=="municip0101"]

##############################
# CREATING AN *ADVANCED* 
# DESCRIPTIVE TABLE
# BY COUNTY/FYLKE
##############################

d <- readRDS(file.path(org::PROJ$DATA_RAW,"data_2018.rds"))
norway_locations_current <- fhidata::norway_locations_current

# look at the two datasets
d
norway_locations_current

d2 <- merge(
  d, 
  norway_locations_current,
  by.x="municip",
  by.y="municip_code"
  )

# check number of rows in datasets
nrow(d)
nrow(d2)

# look at new dataset
d2

# create month and year variable
d2[,month:=lubridate::month(date)]
d2[,year:=lubridate::year(date)]

# aggregate down to year/month data for each fylke
county_data <- d2[,
  .(
    influensa = sum(influensa),
    gastro = sum(gastro),
    respiratoryinternal = sum(respiratoryinternal),
    respiratoryexternal = sum(respiratoryexternal),
    lungebetennelse = sum(lungebetennelse),
    bronkitt = sum(bronkitt),
    skabb = sum(skabb),
    consult = sum(consult)
  ),
  keyby=.(
    county_code,
    county_name,
    year,
    month
  )
]

# take a look at our data
county_data

# reshape from wide to long
d2 <- melt.data.table(
  county_data, 
  id.vars = c(
    "county_code",
    "county_name",
    "year",
    "month"
    ))

# look at the long format data
d2

# collapse further to get monthly summary statistics
results <- d2[,
  .(
    value_median = quantile(value, probs = 0.5),
    value_25p = quantile(value, probs = 0.25),
    value_75p = quantile(value, probs = 0.75)
  ),
  keyby = .(
    county_code,
    county_name,
    variable
  )
]

# look at results
results

# gen population data
norway_population_current <- fhidata::norway_population_current

norway_population_current <- norway_population_current[
  year==2018,
  .(
    pop = sum(pop)
  ),
  keyby=.(location_code)
]

# merge in population data
results2 <- merge(
  results,
  norway_population_current,
  by.x="county_code",
  by.y="location_code"
)

# check number of rows
nrow(results)
nrow(results2)

# create 'pretty' variables
results2[, pretty_var := glue::glue(
  "{value_median} ({value_25p}, {value_75p})",
  value_median = round(10000*value_median/pop),
  value_25p = round(10000*value_25p/pop),
  value_75p = round(10000*value_75p/pop)
  )]

# look at results2
results2

# delete the 'ugly' variables
results2[, value_median:=NULL]
results2[, value_25p:=NULL]
results2[, value_75p:=NULL]
results2[, pop:=NULL]

# look at results2
results2

# reshape to wide
results2 <- dcast.data.table(results2, county_name + county_code ~ variable)

# look at results2
results2

# results2 is sorted incorrectly. 
# We now reorder the rows:
setorder(results2, county_code)

# nicely reordered!
results2

# delete county_code
results2[,county_code := NULL]

# save to excel file
xlsx::write.xlsx(
  results2,
  file.path(org::PROJ$SHARED_TODAY,"results.xlsx"),
  row.names = FALSE)

##############################
# EXERCISE
##############################
# Look at these two datasets
norway_population_current <- fhidata::norway_population_current[level=="municipality"]
norway_locations_current <- fhidata::norway_locations_current

# Merge the two datasets together

# aggregate/collapse this dataset and calculate the total population in each county per year

