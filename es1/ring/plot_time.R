library(ggplot2)
library(gridExtra)
setwd("~/Desktop/Francesc0rtu/hpc_assignment1/es1/ring/Ring")

result <- data.frame(read.csv("results_diecimila.csv"))


plot_result_B <- ggplot()+
  #geom_smooth(data = result, aes(x =as.factor(n_procs), y=MIN.B, group=1, color = "blocking"))+
  #geom_smooth(data = result, aes(x =as.factor(n_procs), y=MIN.NB, group=1, color="non blocking"))+
  geom_line(data = result, aes(x = n_procs, y=MIN.NB, group=1, color = "non blocking"))+
  geom_point(data = result, aes(x =n_procs, y=MIN.NB, group=1, color="non blocking"))+
  geom_point(data = result, aes(x =n_procs, y=MIN.B, group=1, color = "blocking"))+
  geom_line(data = result, aes(x =n_procs, y=MIN.B, group=1, color="blocking"))+
 geom_line(aes(x=x, y=3*y, color="model"))+
  labs(x="processors number", y="seconds", colour = "Implementation")+
  geom_vline(aes(xintercept=12), linetype="dotted")+geom_vline(aes(xintercept=24), linetype="dotted")+geom_vline(aes(xintercept=36), linetype="dotted")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), axis.text=element_text(size=8))

plot_result_B



y<-c(x[1:12]*(0.24*10^(-6)+(18*10^(-6))/20845),x[13:23]*(0.63*10^(-6)+(8*10^(-6))/20845),x[24:47]*(1.20*10^(-6)+(8*10^(-6))/11900))
y<-c(x[1:11]*0.2471*10^(-6),x[12:23]*0.66*10^(-6),2*(x[24:47])*1.33*10^(-6))
plot(result$MIN.NB)
result$y <- y
plot_RESULT_B <- ggplot()+
  geom_line(aes(x=as.factor(x), y=y, color="network"))
plot_RESULT_B

grid.arrange(plot_resut_B, plot_result_NB)



plot_result_NB <- ggplot()+
  geom_smooth(data = result, aes(x = n_procs, y = MIN.NB , color = " min"))+
 geom_smooth(data = result, aes(x = n_procs, y=SUM.NB, color = "sum"))+
  geom_smooth(data = result, aes(x = n_procs, y=MEAN.NB, color = "mean"))+
  geom_smooth(data = result, aes(x = n_procs, y=MIN.NB.ob1, color = "min ob1"))








