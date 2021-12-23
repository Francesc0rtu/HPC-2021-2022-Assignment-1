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


  int dims[3] = {atoi(argv[1]), atoi(argv[2]), atoi(argv[3])};
  MPI_Cart_create(MPI_COMM_WORLD, 3, dims, period, reorder, &comm);               //crea la topologia
  int mycoord[3];
  MPI_Comm_rank(comm, &rank);
  MPI_Cart_coords(comm, rank, 3, mycoord);                                        //Ogni proc salva in mycoord le proprie coordinate



  int mat_sizes[3] = {1,1,1};
  int tot_size;
  if(rank == MASTER){
    scanf("%d %d %d", &mat_sizes[0], &mat_sizes[1], &mat_sizes[2]);                                 // prende in input le dimesioni delle matrici
    tot_size = mat_sizes[0]*mat_sizes[1]*mat_sizes[2];
  }

  double A[mat_sizes[0]][mat_sizes[1]][mat_sizes[2]],                             // Dichiaro matrici ovunque, ma solo in MASTER sono allocate
         B[mat_sizes[0]][mat_sizes[1]][mat_sizes[2]],                             // con le dimensioni giuste
         C[mat_sizes[0]][mat_sizes[1]][mat_sizes[2]];

  if(rank == MASTER){                                                             // Inizializza A,B con numeri casuali in MASTER
    srand(time(NULL));
    for(int i=0; i<mat_sizes[0]; i++){
      for(int j=0; j<mat_sizes[1]; j++){
        for(int h=0; h<mat_sizes[2]; h++){
          A[i][j][h] = rand() % 100;
          B[i][j][h] = rand() % 100;
        }
      }
    }
    // printf("A[2][4][1] =  %f \n", A[2][4][1]);
  }

  MPI_Bcast(mat_sizes, 3, MPI_INT, MASTER, comm );                             //MASTER manda a tutti le dimensioni delle matrici in input

  int local_sizes[3] = {mat_sizes[0]/dims[0] + mat_sizes[0]%dims[0],mat_sizes[1]/dims[1]+ mat_sizes[1]%dims[1],mat_sizes[2]/dims[2]+ mat_sizes[2]%dims[2]};    // Calcola le dimensioni dei cubetti
  int tot_local_size = local_sizes[0]*local_sizes[1]*local_sizes[2];
  double A_local[local_sizes[0]][local_sizes[1]][local_sizes[2]];         //Ogni proc alloca i propri cubetti
  double B_local[local_sizes[0]][local_sizes[1]][local_sizes[2]];
  double C_local[local_sizes[0]][local_sizes[1]][local_sizes[2]];
  // printf("proc %d, micoord %d %d %d e %d\n", rank, mycoord[0], mycoord[1], mycoord[2], mat_sizes[0]);
  MPI_Barrier(MPI_COMM_WORLD);                                                     // inizia il tempo
  start_time = MPI_Wtime();

  MPI_Scatter(&A[0][0][0], tot_local_size, MPI_DOUBLE, &A_local[0][0][0], tot_local_size, MPI_DOUBLE, MASTER, comm );
  MPI_Scatter(&B[0][0][0], tot_local_size, MPI_DOUBLE, &B_local[0][0][0], tot_local_size, MPI_DOUBLE, MASTER, comm );

  for(int i=0; i<local_sizes[0]; i++){                                          // Ogni proc fa la sua parte di somma
    for(int j=0; j<local_sizes[1]; j++){
      for(int h=0; h<local_sizes[2]; h++){
        C_local[i][j][h] = A_local[i][j][h] + B_local[i][j][h];
      }
    }
  }

  MPI_Gather(&C_local[0][0][0],  tot_local_size, MPI_DOUBLE, &C[0][0][0], tot_local_size, MPI_DOUBLE, MASTER, comm );


    //////////////////////////////////////// OPERAZIONI PER PRENDERE I TEMPI //////////////////////////////////


  MPI_Barrier(MPI_COMM_WORLD);														// il tempo calcolato finisce qui
  end_time=MPI_Wtime();
  res_time = end_time-start_time;


  MPI_Reduce(&res_time, &min_time, 1, MPI_DOUBLE, MPI_MAX, 0, comm );    //prendo il tempo più lento

  

  if(rank == MASTER){
    printf("grid: (%d %d %d),matrix sizes: %dx%dx%d, mintime: %10.8f \n",dims[0],dims[1],dims[2], mat_sizes[0], mat_sizes[1],mat_sizes[2], min_time);
  }
  MPI_Finalize();

}
