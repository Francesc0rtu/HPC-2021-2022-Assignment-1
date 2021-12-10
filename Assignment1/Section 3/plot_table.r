
library(gridExtra)
library(grid)
library(ggplot2)
library(tidyverse)
library(RColorBrewer)

#Importo dataset e le colonne dei tempi di comunicazione
setwd("~/Documents/Repository/Francesc0rtu/hpc_assignment1/es3/Jacobi3D-code")
res <- data.frame(read.csv("Results_Jacobi.csv"))
res_gpu <- data.frame(read.csv("Results_Jacobi_GPU.csv"))
res$MaxComTime <- res$MaxTime-res$JacobiMAX
res$MinComTime <- res$MinTime-res$JacobiMIN
res_gpu$MaxComTime <- res_gpu$MaxTime-res_gpu$JacobiMAX
res_gpu$MinComTime <- res_gpu$MinTime-res_gpu$JacobiMIN
res_gpu

table<- NULL
table <-res[,1:2]
table$Total.Time <- (res$MaxTime+res$MinTime)/2
table$Jacobi.Time <- (res$JacobiMAX+res$JacobiMIN)/2
table$Comm.Time <- (res$MaxComTime+res$MaxComTime)/2
table$MLUPs <- res$MLUPs
table$k <- c(0,4,6,6,4,6,6,6,6,6,6)
latency <- c(0.0, 0.2469 , 0.2469 , 0.2469 , 0.6231 , 0.6231 , 0.6231 , 1.1328 , 1.1328 , 1.1328 , 1.1328)
bandwidth <- c(0,20845.5,20845.5,20845.5,22748.6,22748.6,22748.6,11914.97,11914.97,11914.97,11914.97)
table$Latency.tusec <- round(latency,4)
table$Bandwidth <- round(bandwidth, 4)
table$Model.C.Time <- round(as.numeric(mod_time_table()),4)
table$Model.MLUPs <- round(as.numeric(mod_mlup_table()),4)

mod_mlup_table<- function(){
  x[1] <- 1200^3/table$Total.Time[1]
   for(i in c(2:11)){
     x[i] <- (1200^3 * table$NProc[i] )/(table$Total.Time[1]+table$Model.C.Time[i])
   }
  return(x/1000000)
    }

write.csv(table, "table.csv")
  
  
mod_time_table <- function(){
  x[1]<-0
for(i in c(2:11)){
  x[i]<-model_comm_time(table$NProc[i], table$Bandwidth[i], table$Latency.tusec[i])
}
  return(x)
}
#Print table sperimental

tt3 <- ttheme_default( core = list(bg_params = list(fill =blues9[1:2])))

grid.arrange( tableGrob(res_gpu, theme = tt3 ))
res[1:3,]



#Performance model
c_ <- function(N){
  if(N==1){
    return(1200*1200*16)
  }
  if(N==2){
    return(1200*1200*16*2)
  }
  if(N==4){
    return(1200*1200*16*4)
  }
  else{
    return(1200*1200*16*6)
  }
}


model_comm_time <- function(N,band,lambda){
  if(N==2){
    return((c_(N)/1000)/(band*8) + 2*lambda*10^(-6))
  }else if(N==4){
    return((c_(N)/1000)/(band*8) + 2*lambda*10^(-6))
  }else{
  return((c_(N)/1000)/(band*8) + 2*lambda*10^(-6))
  }
}

perfromance_model <- function(N, band, lambda,seq){
  return(1200*1200*1200*N/(model_comm_time(N,band,lambda)+seq))
}


N<- 12
band <-20845.5986*8
lambda <-0.2469*10^(-6)
seq <-15.2349


#
perf <- ggplot()+
    geom_point(data = res, aes(x=as.factor(NProc), y=MLUPs, shape = MAP, color = "thin")) +
    geom_point(data = res_gpu, aes(x=as.factor(NProc), y=MLUPs, shape = MAP, color = "gpu")) +
    scale_shape_manual(values = c(20,4,17))+
    labs(x="Proc Num", y = "MLUPs")
perf


time <- ggplot()+
 geom_point(data = res, aes(x=as.factor(NProc), y=MaxTime, shape = MAP, color = "thin")) +
  geom_point(data = res_gpu, aes(x=as.factor(NProc), y=MaxTime, shape = MAP, color = "gpu")) +
  geom_line(data = res, aes(x=as.factor(NProc),group = 1, y=MaxTime, color = "thin")) +
  geom_line(data = res_gpu, aes(x=as.factor(NProc), group=2, y=MaxTime, color = "gpu")) +
  scale_shape_manual(values = c(20,4,17))+
  labs(x="Proc Num", y = "second")
time

## PLOT DEI TEMPI DI COMUNICAZIONE###
# ha poco senso, infatti diminuisce all'aumentare del numero dei processori(ovviamente  più sono i proc e meno grandi sono
# gli offset) quindi non si capisce bene la relazione. Meglio lasciare solo la tabella


comm_time <- ggplot()+
  geom_point(data = res[2:8,], aes(x=as.factor(NProc), y=MaxComTime, shape = MAP, color = "thin")) +
  geom_point(data = res_gpu[2:8,], aes(x=as.factor(NProc), y=MaxComTime, shape = MAP, color = "gpu")) +
  #geom_line(data = res, aes(x=as.factor(NProc),group = 1, y=MaxComTime, color = "thin")) +
  #geom_line(data = res_gpu, aes(x=as.factor(NProc), group=2, y=MaxComTime, color = "gpu")) +
  scale_shape_manual(values = c(20,4,17))+
  labs(x="Proc Num", y = "second")
comm_time





