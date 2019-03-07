### OLD
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


### NEW/FINAL/MOST ADVANCED

MakeBoxPlot <- function(d, illness){
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

Analyses1_version5 <- function(d){
  for(illness in c("bronkitt","influensa","gastro")){
    MakeBoxPlot(d=d, illness=illness)
  }
}

