library(ggplot2)
library(gridExtra)
setwd("~/Desktop/Francesc0rtu/hpc_assignment1/es1/matrix")
matrix <- data.frame(read.csv("results.csv"))
matrix_notopo <- data.frame(read.csv("results_notopo.csv"))
tt3 <- ttheme_default( core = list(bg_params = list(fill =blues9[1:2])))
grid.table( matrix,  rows=NULL, theme = tt3 )


matrix[18,]<-c("no topo", "800x300x100",1.049590)
