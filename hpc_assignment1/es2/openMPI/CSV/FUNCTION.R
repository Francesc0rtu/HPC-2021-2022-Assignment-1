# read csv assignment 1 
library(ggplot2)
library(RColorBrewer)
library(patchwork)
library(cowplot)

setwd("/home/francesco/Documents/Repository/Francesc0rtu/hpc_assignment1/es2/IntelMPI/")
col_legend <-brewer.pal(n=8, name="Dark2")

file<-bysocket_ucx
df<-data.frame(file)

plot_times()
##############
plot_times <- function(file) {
  df1<- data.frame(read.csv(file))
  df1$X <- NULL
  df<-df1[1:24,]
  x <- df$X.bytes
  #model_linear<-lm(t.usec.[1:24,] ~ X.bytes[1:24,], df)
  model_poly <- loess(t.usec. ~ X.bytes, df)
  
  
  
  times <- ggplot() +
    # sperimental
    geom_point( aes(x = as.factor(x) , y = df$t.usec., color="experimental", group = 1))  + 
    geom_line( aes(x = as.factor(x) , y = df$t.usec., color="experimental", group = 1)) +
    
    # modello 1
    geom_line( aes(x = as.factor(x), y = min(df$t.usec.) + df$X.bytes/max(df$Mbytes.sec), color="comm. model", group=1)) +
    geom_point( aes(x = as.factor(x), y = min(df$t.usec.) + df$X.bytes/max(df$Mbytes.sec), color="comm. model", group=1)) +
    
    # fitted poly
    geom_point(aes(as.factor(x), model_poly$fitted, color="fit model", group=1))+
    geom_line(aes(as.factor(x), model_poly$fitted, color="fit model", group=1))+
    
    #fitted lm
    #geom_point(aes(as.factor(x), model_linear$coefficients[1]+model_linear$coefficients[2]*x, color="fit linear model", group=1))+
    #geom_line(aes(as.factor(x), model_linear$coefficients[1]+model_linear$coefficients[2]*x, color="fit linear model", group=1))+
    
    
    labs(x = "Message size (bytes)", y = "Time") +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
    theme(legend.title = element_blank()) +
    scale_color_manual(values=col_legend)+
    #scale_colour_manual(values = c("sperimental" = "#2bacbd", "comm. model" = "#cf5e25", "fit model" = "#297504")) +
    labs(title = gsub('_', ' ', gsub('.{4}$', '', file)))
  
  #if(!"t.usec.comp." %in% colnames(df)){
    df1$t.usec.comp.[1:24] <- round(loess(t.usec. ~ X.bytes, df1[1:24,])$fitted, 4)
    write.csv(df1[1:24,], file)
  #}
  
  
  return(times)
}


plot_bandwidth <- function(file) {
  df1 <- data.frame(read.csv(file))
  df1$X <- NULL
  df<-df1[1:24,]
  x <- df$X.bytes
  model_linear<-lm(Mbytes.sec ~ X.bytes, df)
  model_poly <- loess(Mbytes.sec ~ X.bytes, df, degree = 1)
  model_time <- loess(t.usec. ~ X.bytes, df)
  #bandwidth
  bandwidth <- ggplot() +
    # core ucx
    geom_line(data = df, aes(x = as.factor(X.bytes), group = 2, y = Mbytes.sec, color="experimental")) +
    geom_point(data = df, aes(x = as.factor(X.bytes), group = 2, y = Mbytes.sec, color="experimental"))  +
    
    # theoretical
    geom_line(data = df, aes(x = as.factor(X.bytes), y = X.bytes/(min(t.usec.) + X.bytes/max(Mbytes.sec)), color="comm. model", group=1)) +
    geom_point(data = df, aes(x = as.factor(X.bytes), y = X.bytes/(min(t.usec.) + X.bytes/max(Mbytes.sec)), color="comm. model", group=1)) +
    
    # fitted poly
    geom_point(aes(as.factor(x), df$X.bytes/loess(t.usec. ~X.bytes,df)$fitted, color="fit model", group=1))+
    geom_line(aes(as.factor(x), df$X.bytes/model_time$fitted, color="fit model", group=1))+
    
    labs(x = "Message size (bytes)", y = "MB/s") +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
    theme(legend.title = element_blank()) +
    scale_color_manual(values=col_legend)+
    #scale_colour_manual(values = c("sperimental" = "#2bacbd", "comm. model" = "#cf5e25", "fit model" = "#297504")) +
    labs(title = gsub('_', ' ', gsub('.{4}$', '', file)))

  #if(!"Mbytes.sec.comp." %in% colnames(df)){
  df1$Mbytes.sec.comp.[1:24] <- round(df1$X.bytes[1:24]/loess(t.usec. ~ X.bytes, df1[1:24,])$fitted, 4)
  write.csv(df1, file)
 # }
  
  
  return(bandwidth)
}

plot_nshm <- function(core, socket, node, type) {
  core_times <- plot_times(core)
  socket_times <- plot_times(socket)
  node_times <- plot_times(node)
  
  
  core_times + socket_times + node_times
  ggsave(paste0( "time_", type, ".png"), width = 20, height = 8, dpi = 150)
  
   core_bandwidth <- plot_bandwidth(core)
    socket_bandwidth <- plot_bandwidth(socket)
    node_badnwidth <- plot_bandwidth(node)
   core_bandwidth + socket_bandwidth + node_badnwidth
   ggsave(paste0( "bandwidth_", type, ".png"), width = 20, height = 8, dpi = 150)
  
}


plot_shm <- function(core, socket, type) {
  core_times <- plot_times(core)
  socket_times <- plot_times(socket)
  core_times + socket_times
  ggsave(paste0( "time_", type, ".png"), width = 20, height = 8, dpi = 150)
  core_bandwidth <- plot_bandwidth(core)
  socket_bandwidth <- plot_bandwidth(socket)
  core_bandwidth + socket_bandwidth
  ggsave(paste0( "bandwidth_", type, ".png"), width = 20, height = 8, dpi = 150)
}





#openmpi - cpu
##############
setwd("/home/francesco/Documents/Repository/Francesc0rtu/hpc_assignment1/es2/openMPI/CSV")
#ucx
plot_nshm("bycore_ucx.csv", "bysocket_ucx.csv", "bynode_ucx.csv", "ucx_OPMPI")

#tcp
plot_nshm("bycore_tcp.csv", "bysocket_tcp.csv", "bynode_tcp.csv", "tcp_OPMPI")
#vader
plot_shm("bycore_vader.csv", "by_socket_vader.csv", "vader_OPMPI")

#openmpi - gpu
##############
#ucx
plot_nshm("bycore_ucx_GPU.csv", "bysocket_ucx_GPU.csv", "bynode_ucx_GPU.csv", "ucx_OPMPI_GPU")
#tcp
plot_nshm("bycore_tcp_GPU.csv", "bysocket_tcp_GPU.csv", "bynode_tcp_GPU.csv", "tcp_OPMPI_GPU")
#vader
plot_shm("bycore_vader_GPU.csv", "by_socket_vader_GPU.csv", "vader_OPMPI_GPU")

############## INTEL ##############################
setwd("/home/francesco/Documents/Repository/Francesc0rtu/hpc_assignment1/es2/IntelMPI/")
#ucx
plot_nshm("bycore_infiniband.csv", "bysocket_infiniband.csv", "bynode_infiniband.csv", "infiniband_INTEL")

#tcp
plot_nshm("bycore_tcp.csv", "bysocket_tcp.csv", "bynode_tcp.csv", "tcp_INTEL")
#vader
plot_shm("bycore_shm.csv", "bysocket_shm.csv", "shm_INTEL")

#
##############
#ucx
#ucx
plot_nshm("bycore_infiniband_GPU.csv", "bysocket_infiniband_GPU.csv", "bynode_infiniband_GPU.csv", "infiniband_INTEL_GPU")

#tcp
plot_nshm("bycore_tcp_GPU.csv", "bysocket_tcp_GPU.csv", "bynode_tcp_GPU.csv", "tcp_INTEL_GPU")
#vader
plot_shm("bycore_shm_GPU.csv", "bysocket_shm_GPU.csv", "shm_INTEL_GPU")

################### Openmpi vs openmpi no cache ####################
setwd("/home/francesco/Documents/Repository/Francesc0rtu/hpc_assignment1/es2/openMPI/CSV")
#ucx
plot_shm("bycore_ucx.csv", "bycore_ucx_NOCACHE.csv", "core_ucx_OPMPI_no_cache")
plot_shm("bysocket_ucx.csv", "")
#tcp
plot_shm("bycore_tcp.csv", "bycore_tcp_NOCACHE.csv",  "core_tcp_OPMPI_no_cache")
#vader
plot_shm("bycore_vader.csv", "bycore_vader_NOCACHE.csv", "core_vader_OPMPI_no_cache")
#ucx
plot_shm("bysocket_ucx.csv", "bysocket_ucx_NOCACHE.csv", "socket_ucx_OPMPI_no_cache")

#tcp
plot_shm("bysocket_tcp.csv", "bysocket_tcp_NOCACHE.csv",  "socket_tcp_OPMPI_no_cache")
#vader
plot_shm("by_socket_vader.csv", "by_socket_vader_NOCACHE.csv", "socket_vader_OPMPI_no_cache")

