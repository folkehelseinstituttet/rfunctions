# Simple analysis of 1 illness
Analyses1_version1 <- function(d){
  # Lets do some analyses!
  q <- ggplot(d,aes_string(x="dayOfWeek",y="consult",group="dayOfWeek"))
  q <- q + geom_boxplot()
  q
  
  # And now we save our analyses into today's results folder
  ggsave(filename=file.path(org::PROJ$SHARED_TODAY,"consult.png"),
         width=297,
         height=210,
         units="mm",
         plot=q)
}

# Analysing 3 illnesses (without loops)
Analyses1_version2 <- function(d){
  # analyse bronkitt
  q <- ggplot(d,aes_string(x="dayOfWeek",y="bronkitt",group="dayOfWeek"))
  q <- q + geom_boxplot()
  q
  
  ggsave(filename=file.path(org::PROJ$SHARED_TODAY,"bronkitt.png"),
         width=297,
         height=210,
         units="mm",
         plot=q)
  
  # analyse influensa
  q <- ggplot(d,aes_string(x="dayOfWeek",y="influensa",group="dayOfWeek"))
  q <- q + geom_boxplot()
  q
  
  ggsave(filename=file.path(org::PROJ$SHARED_TODAY,"influensa.png"),
         width=297,
         height=210,
         units="mm",
         plot=q)
  
  # analyse gastro
  q <- ggplot(d,aes_string(x="dayOfWeek",y="gastro",group="dayOfWeek"))
  q <- q + geom_boxplot()
  q
  
  ggsave(filename=file.path(org::PROJ$SHARED_TODAY,"gastro.png"),
         width=297,
         height=210,
         units="mm",
         plot=q)
}

# Analysing 3 illnesses (without loops, but getting closer)
Analyses1_version3 <- function(d){
  # analyse bronkitt
  illness <- "bronkitt"
  q <- ggplot(d,aes_string(x="dayOfWeek",y=illness,group="dayOfWeek"))
  q <- q + geom_boxplot()
  q
  
  file <- glue::glue("{illness}.png")
  ggsave(filename=file.path(org::PROJ$SHARED_TODAY,file),
         width=297,
         height=210,
         units="mm",
         plot=q)
  
  # analyse influensa
  illness <- "influensa"
  q <- ggplot(d,aes_string(x="dayOfWeek",y=illness,group="dayOfWeek"))
  q <- q + geom_boxplot()
  q
  
  file <- glue::glue("{illness}.png")
  ggsave(filename=file.path(org::PROJ$SHARED_TODAY,file),
         width=297,
         height=210,
         units="mm",
         plot=q)
  
  # analyse gastro
  illness <- "gastro"
  q <- ggplot(d,aes_string(x="dayOfWeek",y=illness,group="dayOfWeek"))
  q <- q + geom_boxplot()
  q
  
  file <- glue::glue("{illness}.png")
  ggsave(filename=file.path(org::PROJ$SHARED_TODAY,file),
         width=297,
         height=210,
         units="mm",
         plot=q)
}


# Analysing 3 illnesses (with loops)
Analyses1_version4 <- function(d){
  
  for(illness in c("bronkitt","influensa","gastro")){
    q <- ggplot(d,aes_string(x="dayOfWeek",y=illness,group="dayOfWeek"))
    q <- q + geom_boxplot()
    q
    
    file <- glue::glue("{illness}.png")
    ggsave(filename=file.path(org::PROJ$SHARED_TODAY,file),
           width=297,
           height=210,
           units="mm",
           plot=q)
  }
}

