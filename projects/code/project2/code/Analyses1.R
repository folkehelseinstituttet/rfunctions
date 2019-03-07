Analyses1 <- function(d){
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
}