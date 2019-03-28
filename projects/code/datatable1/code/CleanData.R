CleanData <- function(){
  # Read in the data
  d <- data.table::fread(file.path(org::PROJ$DATA_RAW,"data.csv"))

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
  
  return(d)
}