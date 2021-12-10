library(ggplot2)
library(gridExtra)
setwd("~/Desktop/Francesc0rtu/hpc_assignment1/es1/ring/Ring")

result <- data.frame(results)
RESULT <- data.frame(RESULTS)
plot_result_B <- ggplot()+
  #geom_smooth(data = result, aes(x =as.factor(n_procs), y=MIN.B, group=1, color = "blocking"))+
  #geom_smooth(data = result, aes(x =as.factor(n_procs), y=MIN.NB, group=1, color="non blocking"))+
  geom_line(data = result, aes(x = as.factor(n_procs), y=MIN.NB, group=1, color = "non blocking"))+
  geom_point(data = result, aes(x = as.factor(n_procs), y=MIN.NB, group=1, color="non blocking"))+
  geom_point(data = result, aes(x =as.factor(n_procs), y=MIN.B, group=1, color = "blocking"))+
  geom_line(data = result, aes(x =as.factor(n_procs), y=MIN.B, group=1, color="blocking"))+
  labs(x="processors number", y="seconds", colour = "Implementation")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), axis.text=element_text(size=8))

plot_result_B

plot(result$MIN.NB)

plot_RESULT_B <- ggplot()+
  #geom_line(data = result, aes(x = n_procs, y=SUM.B, color = "sum"))+
  geom_line(data = RESULT, aes(x = as.factor(n_procs), y=MEAN.B, color = "mean"))
plot_RESULT_B

grid.arrange(plot_resut_B, plot_result_NB)



plot_result_NB <- ggplot()+
  geom_smooth(data = result, aes(x = n_procs, y = MIN.NB , color = " min"))+
 geom_smooth(data = result, aes(x = n_procs, y=SUM.NB, color = "sum"))+
  geom_smooth(data = result, aes(x = n_procs, y=MEAN.NB, color = "mean"))+
  geom_smooth(data = result, aes(x = n_procs, y=MIN.NB.ob1, color = "min ob1"))








