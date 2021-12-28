library(tidyverse)
library(RColorBrewer)
wes_band<-brewer.pal(n=8, name="Set1")
wes_latency<-brewer.pal(n=8, name="Set2")

plot_bench_2<- function(d_inf,d_tcp){
  realdata<-realdata()
    data1<-d_inf
    data2<-d_tcp
    bandwidth <- ggplot() + 
      geom_point(data = data1, aes(x=as.factor(X.bytes), group=2,y=Mbytes.sec, color="tcp"))+
      geom_line(data = data1, aes(x=as.factor(X.bytes), group=2, y=Mbytes.sec, color="tcp")) +
      geom_point(data = data2, aes(x=as.factor(X.bytes), group=3,y=Mbytes.sec,color="infiniband"))+
      geom_line(data = data2, aes(x=as.factor(X.bytes), group=3, y=Mbytes.sec,color="infiniband")) +
      geom_line(data=realdata, aes(x=as.factor(x),y=z, group=1, color="infiniband", linetype="theoretical"))+
      geom_line(data=realdata, aes(x=as.factor(x),y=v, group=1, color="tcp", linetype="theoretical"))+
      # geom_hline(aes(yintercept= 12500, color="Infiniband"), linetype="twodash",size=1) +
      #  geom_hline( aes(yintercept=3125, color="tcp"), linetype="twodash",size=1)+
      geom_smooth(method = "lm") +
      labs(x = "Bytes", y = "MB/s", colour = "Networks", ) +
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
      scale_color_manual(values= wes_band)+
      scale_linetype_manual(values="dashed")
    #  latency <- ggplot() + 
    #    geom_point(data = data1, aes(x=as.factor(X.bytes), group=2,y=t.usec., color="Infiniband"))+
    #    geom_line(data = data1, aes(x=as.factor(X.bytes), group=2, y=t.usec., color="Infiniband")) +
    #    geom_point(data = data2, aes(x=as.factor(X.bytes), group=3,y=t.usec.,color="tcp"))+
    #    geom_line(data = data2, aes(x=as.factor(X.bytes), group=3, y=t.usec.,color="tcp")) +
    #    geom_line(data=realdata, aes(x=as.factor(x),y=v, group=4, color="Theoretical"), linetype="twodash",size=1)+
    #    geom_smooth(method = "lm") +
    #    labs(x = "Bytes", y = expression(paste(mu, "s"))) +
    #    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
    #    scale_color_manual(values= wes_latency)
    #  plot_grid(bandwidth, latency, ncol=1, align = "v")
    bandwidth  
  }

plot_bench_3 <- function(d_inf,d_tcp,d_vader){
 realdata<-realdata()
    data1<-d_inf
    data2<-d_tcp
    data3<-d_vader
    bandwidth <- ggplot() + 
      geom_point(data = data1, aes(x=as.factor(X.bytes), group=2,y=Mbytes.sec, color="infiniband"))+
      geom_line(data = data1, aes(x=as.factor(X.bytes), group=2, y=Mbytes.sec, color="infiniband")) +
      geom_point(data = data2, aes(x=as.factor(X.bytes), group=3,y=Mbytes.sec,color="tcp"))+
      geom_line(data = data2, aes(x=as.factor(X.bytes), group=3, y=Mbytes.sec,color="tcp")) +
      geom_point(data = data3, aes(x=as.factor(X.bytes), group=2,y=Mbytes.sec, color="shr"))+
      geom_line(data = data3, aes(x=as.factor(X.bytes), group=2, y=Mbytes.sec, color="shr")) +
  #   geom_hline(aes(yintercept= 12500, color="Infiniband"), linetype="twodash",size=1) +
  #   geom_hline( aes(yintercept=3125, color="tcp"), linetype="twodash",size=1)+
  #    geom_line(data=realdata, aes(x=as.factor(x),y=z, group=1, linetype="theoretical HS/IB"), color="black")+
  #    geom_line(data=realdata, aes(x=as.factor(x),y=v, group=1, linetype="theoretical HS/IB"), color="black")+
   #   geom_smooth(method = "lm") +
      labs(x = "Bytes", y = "MB/s") +
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
      scale_color_manual(values= wes_band)
  #   scale_linetype_manual(values="dashed")
  #  latency <- ggplot() + 
 #   geom_point(data = data1, aes(x=as.factor(X.bytes), group=2,y=t.usec., color="Infiniband"))+
   #  geom_line(data = data1, aes(x=as.factor(X.bytes), group=2, y=t.usec., color="Infiniband")) +
 # geom_point(data = data2, aes(x=as.factor(X.bytes), group=3,y=t.usec.,color="tcp"))+
    #geom_line(data = data2, aes(x=as.factor(X.bytes), group=3, y=t.usec.,color="tcp")) +
  #    geom_point(data = data3, aes(x=as.factor(X.bytes), group=2,y=t.usec., color="Vader"))+
  #    geom_line(data = data3, aes(x=as.factor(X.bytes), group=2, y=t.usec., color="Vader")) +
  #    geom_line(data=realdata, aes(x=as.factor(x),y=v, group=1, color="Theoretical"), linetype="twodash", size=1)+
  #    geom_smooth(method = "lm") +
  #    labs(x = "Bytes", y = expression(paste(mu,"s"))) +
  #    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  #    scale_color_manual(values= wes_latency)
  #  plot_grid(bandwidth, latency, ncol=1, align = "v")
  bandwidth

}

comm_tim_infiniband<- function(size){
  return (1.35+(size/12500))
}

comm_tim_tcp<- function(size){
  return (1.35+(size/3125))
}
comm_band_infiniband<-function(size){
  return (size/comm_tim_infiniband(size))
}

comm_band_tcp<-function(size){
  
  return (size/comm_tim_tcp(size))
}
realdata <- function(){
  n<-28
  x<-rep(n,0)
  v<-rep(n,0)
  z<-rep(n,0)
  for(i in c(1:n)){
    x[i]<- 2^(i-1)
    v[i]<-comm_band_tcp(x[i])
    z[i]<-comm_band_infiniband(x[i])
  } 
  return (data.frame(x,v,z))
}


