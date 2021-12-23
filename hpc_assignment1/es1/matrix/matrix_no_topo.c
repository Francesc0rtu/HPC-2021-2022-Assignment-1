#include "mpi.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>


#define TRUE 1
#define FALSE 0
#define MASTER 0

int main(int argc, char *argv[]){
  double start_time, end_time, res_time, min_time;
  MPI_Init(&argc,&argv);                                                           //MPI si inizializza
 



  int period[2] = {TRUE,FALSE};                                                    //dichiarazioni iniziali
  int reorder = TRUE;
  MPI_Comm comm;
  int rank,size;
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);


  int tot_size;
  int mat_size[3] = {atoi(argv[1]), atoi(argv[2]), atoi(argv[3])};
  int x_size,y_size,z_size;
  tot_size = mat_size[0]*mat_size[1]*mat_size[2];
  if(rank == MASTER){
    x_size = mat_size[0];
    y_size = mat_size[1];
    z_size = mat_size[2];
  }else{
    x_size = 1;
    y_size = 1;
    z_size = 1;
  }

  double A[x_size][y_size][z_size],                             // Dichiaro matrici ovunque, ma solo in MASTER sono allocate
         B[x_size][y_size][z_size],                            // con le dimensioni giuste
         C[x_size][y_size][z_size];
  double a[tot_size/size + tot_size%size],b[tot_size/size + tot_size%size],c[tot_size/size + tot_size%size];

  if(rank == MASTER){                                                             // Inizializza A,B con numeri casuali in MASTER
    srand(time(NULL));
    for(int i=0; i<mat_size[0]; i++){
      for(int j=0; j<mat_size[1]; j++){
        for(int h=0; h<mat_size[2]; h++){
          A[i][j][h] = (double)rand()/1000000;
          B[i][j][h] = (double)rand()/1000000;
        }
      }
    }
  }
	 MPI_Barrier(MPI_COMM_WORLD);                                                     // inizia il tempo
  start_time = MPI_Wtime();
  MPI_Scatter(&A[0][0][0], tot_size/size, MPI_DOUBLE, a, tot_size/size, MPI_DOUBLE, MASTER, MPI_COMM_WORLD );
  MPI_Scatter(&B[0][0][0], tot_size/size, MPI_DOUBLE, b, tot_size/size, MPI_DOUBLE, MASTER, MPI_COMM_WORLD );


  for(int i=0; i<(tot_size/size); i++){
    c[i] = a[i] + b[i];
  }
  MPI_Gather(c,  tot_size/size, MPI_DOUBLE, &C[0][0][0], tot_size/size, MPI_DOUBLE, MASTER, MPI_COMM_WORLD );


////////////////////////////////////// STAMPA LE MATRICI /////////////////////////////////////////////////////


  // if(rank == MASTER){
  //   for(int i=0; i<mat_size[0]; i++){
  //     for(int j=0; j<mat_size[1]; j++){
  //       for(int h=0; h<mat_size[2]; h++){
  //         printf("%f", A[i][j][h]);
  //       }
  //       printf("\n");
  //     }
  //     printf("-------------\n");
  //   }
  // }
  // if(rank == MASTER){
  //   for(int i=0; i<mat_size[0]; i++){
  //     for(int j=0; j<mat_size[1]; j++){
  //       for(int h=0; h<mat_size[2]; h++){
  //         printf("%f", B[i][j][h]);
  //       }
  //       printf("\n");
  //     }
  //     printf("-------------\n");
  //   }
  // }
  // if(rank == MASTER){
  //   for(int i=0; i<mat_size[0]; i++){
  //     for(int j=0; j<mat_size[1]; j++){
  //       for(int h=0; h<mat_size[2]; h++){
  //         printf("%f", C[i][j][h]);
  //       }
  //       printf("\n");
  //     }
  //     printf("-------------\n");
  //   }
  // }
  //////////////////////////////////////// OPERAZIONI PER PRENDERE I TEMPI //////////////////////////////////

  MPI_Barrier(MPI_COMM_WORLD);														// il tempo calcolato finisce qui
  end_time=MPI_Wtime();
  res_time = end_time-start_time;


  MPI_Reduce(&res_time, &min_time, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);    //prendo il tempo più lento



  

  if(rank == MASTER){
    printf("dim matrix: %dx%dx%d,mintime: %10.8f \n", mat_size[0], mat_size[1],mat_size[2], min_time);

  }

  MPI_Finalize();
  return 0;
}
