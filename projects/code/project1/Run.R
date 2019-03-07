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
  HOME="/git/rfunctions/projects/code/project1",
  SHARED="/git/rfunctions/projects/results/project1",
  DATA_RAW="/git/rfunctions/projects/data_raw/project1"
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

# Read in the data
d <- data.table::fread(file.path(org::PROJ$DATA_RAW,"data.csv"))

##############################
# START DATA CLEANING
##############################

# look at our data
xtabs(~d$age)
xtabs(~d$Kontaktype)
xtabs(~d$Praksis)
xtabs(~d$municip)

# extract data between 2010 and 2018
d <- d[d$date>="2010-01-01" & d$date<="2018-01-01",]

# extract Praksis=='Fastlege' and Kontakttype=='Legekontakt'
d <- d[d$Praksis=="Fastlege" & d$Kontaktype=="Legekontakt",]

# extract age=='65+'
d <- d[d$age=="65+"]

# create a new variable that says "day of week"
d$dayOfWeek <- lubridate::wday(d$date)

# check how many days bronkitt>influensa
sum(d$bronkitt>d$influensa)
mean(d$bronkitt>d$influensa)

# in our world, bronkitt must always be less than or equal to influensa
rows <- d$bronkitt>=d$influensa
d[rows,]$bronkitt <- d[rows,]$influensa

# on sundays, there should be no consultations at all:
rows <- d$dayOfWeek==1
d[rows,]$influensa <- 0
d[rows,]$gastro <- 0
d[rows,]$respiratoryinternal <- 0
d[rows,]$respiratoryexternal <- 0
d[rows,]$lungebetennelse <- 0
d[rows,]$bronkitt <- 0
d[rows,]$consult <- 0

##############################
# END DATA CLEANING
##############################

##############################
# START ANALYSES
##############################

# Lets do some analyses!
q <- ggplot(d,aes(x=dayOfWeek,y=consult,group=dayOfWeek))
q <- q + geom_boxplot()
q

# And now we save our analyses into today's results folder
ggsave(filename=file.path(org::PROJ$SHARED_TODAY,"consult.png"),
       width=297,
       height=210,
       units="mm",
       plot=q)

##############################
# END ANALYSES
##############################



