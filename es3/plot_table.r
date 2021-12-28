
library(gridExtra)
library(grid)
library(ggplot2)
library(tidyverse)
library(RColorBrewer)

########################################################################################à
performance_test <- function(N,L,band,latency,T_s,k){
  C <- (L^2)*k*16
  T_c <- C/(band*8)  + k*latency*10^(-6)
  P <- N*L^3/(T_c+T_s)
  return (data.frame(C,T_c,P))
  
}



C <-function(table){}

fill <- function(table){
  data <-data.frame()
  A<-rep(11)
  B<-rep(11)
  C<-rep(11)
  for(i in c(1:11)){
    x<-performance_test(table$NProc[i],table$L[i], table$Bandwidth[i], table$Latency.tusec[i], table$T_s[i], table$k[i])
    A[i]<-x[,1]
    B[i]<-x[,2]
    C[i]<-x[,3]
  }
 return(A,B,C)
  
}




######################################################################################

table$L <- 1200/(table$NProc^(1/3))
table$T_s <- table$Total.Time[1]/table$NProc
#Importo dataset e le colonne dei tempi di comunicazione
setwd("~/Documents/Repository/Francesc0rtu/hpc_assignment1/es3/Jacobi3D-code")
res <- data.frame(read.csv("Results_Jacobi.csv"))
res <- data.frame(read.csv("Results_Jacobi_GPU.csv"))
res$MaxComTime <- res$MaxTime-res$JacobiMAX
res$MinComTime <- res$MinTime-res$JacobiMIN


table<- NULL
table <-res[,1:2]
table$Total.Time <- (res$MaxTime+res$MinTime)/2
table$Jacobi.Time <- (res$JacobiMAX+res$JacobiMIN)/2
table$Comm.Time <- (res$MaxComTime+res$MaxComTime)/2
table$MLUPs <- res$MLUPs
table$k <- c(0,4,6,6,4,6,6,6,6,12,12)
latency <- c(0.0, 0.2731,0.2731,0.2731, 0.6697,0.6697,0.6697,0.6697,0.6697,0.6697,0.6697)   #GPU
bandwidth <- c(0.0, 20175.0, 20175.0, 20175.0, 9217.67,9217.67,9217.67, 9217.67,9217.67,9217.67,9217.67) #GPU
latency <- c(0.0, 0.2469 , 0.2469 , 0.2469 , 0.6231 , 0.6231 , 0.6231 , 1.1328 , 1.1328 , 1.1328 , 1.1328)
bandwidth <- c(0,20845.5,20845.5,20845.5,9217.67,9217.67,9217.67,11914.97,11914.97,11914.97,11914.97)
table$Latency.tusec <- round(latency,4)
table$Bandwidth <- round(bandwidth, 4)
table$L <- (1200/(table$NProc)^(1/3))
table$C <- (table$L^2)*table$k*2*8/1000000
table$T_s <- table$Total.Time[1]/table$NProc
table$T_c <- table$C/(table$Bandwidth*8) 
table$T_c <- table$T_c
table$P <- (table$NProc*table$L^3 )/(table$T_s + table$T_c)
table$P <- table$P/1000000


data<-table
table$L<-NULL
names(table)[names(table) == "C"] = "C(L,N)[Mb]"
names(table)[names(table) == "NProc"] = "N"
names(table)[names(table) == "T_c"] = "Tc(L,N)[s]"
names(table)[names(table) == "T_s"] = "T_s[s]"
names(table)[names(table) == "P"] = "P(L,N)[MLUPs]"
names(table)[names(table) == "Latency.tusec"] = "Latency[usec]"
names(table)[names(table) == "Bandwidth"] = "Band[MB/s]"



mod_mlup_table<- function(){
  x<-rep(11)
  x[1] <- 1200^3/table$Total.Time[1]
   for(i in c(2:11)){
     x[i] <- (1200^3 * table$NProc[i] )/(table$Total.Time[1]+table$Model.C.Time[i])
   }
  return(x/1000000)
    }

write.csv(table, "table.csv")
  
  
mod_time_table <- function(){
  x<-rep(11)
  x[1]<-0
for(i in c(2:11)){
  x[i]<-model_comm_time(table$NProc[i], table$Bandwidth[i], table$Latency.tusec[i])
}
  return(x)
}
#Print table sperimental

tt3 <- ttheme_default( core = list(bg_params = list(fill =blues9[1:2])))

grid.table( table,  rows=NULL, theme = tt3 )
res[1:3,]




plot <- ggplot(data = table)+
      geom_point(aes(x= as.factor(NProc), y= MLUPs, color = "sperimental", shape = MAP))+
  geom_point(aes(x= as.factor(NProc), y= Model.MLUPs, color = "model", shape = MAP))

plot
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





