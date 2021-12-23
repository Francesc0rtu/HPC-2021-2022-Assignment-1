#include "mpi.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>


#define TRUE 1
#define FALSE 0
#define MASTER 0

void matrix_topo(int dims[3], int sizes[3]);
void matrix_no_topo(int mat_size[3]);


int main(int argc, char *argv[]){
  int grid[3]={atoi(argv[1]), atoi(argv[2]), atoi(argv[3])};
  int size[3];
  int rank;
  MPI_Init(&argc,&argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  if(rank==0){
    scanf("%d %d %d", &size[0], &size[1], &size[2]);
  }
  MPI_Bcast(size, 3, MPI_INT, MASTER, MPI_COMM_WORLD );
  matrix_topo(grid, size);
  matrix_no_topo(size);

  MPI_Finalize();
}

//////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////// IMPLEMENTAZIONE CON TOPOLOGIA ///////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

void matrix_topo(int dims[3], int mat_sizes[3]){
  double start_time, end_time, res_time, min_time;

  int period[2] = {TRUE,FALSE};                                                    //dichiarazioni iniziali
  int reorder = TRUE;
  MPI_Comm comm;
  int rank,size;
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);

  MPI_Cart_create(MPI_COMM_WORLD, 3, dims, period, reorder, &comm);               //crea la topologia
  int mycoord[3];
  MPI_Comm_rank(comm, &rank);
  MPI_Cart_coords(comm, rank, 3, mycoord);                                        //Ogni proc salva in mycoord le proprie coordinate

  int x_size,y_size,z_size;
  int tot_size;
  if(rank == MASTER){
    x_size = mat_sizes[0];
    y_size = mat_sizes[1];
    z_size = mat_sizes[2];
  }else{
    x_size = 1;
    y_size = 1;
    z_size = 1;
  }
  tot_size = x_size*y_size*z_size;

  double A[x_size][y_size][z_size],                             // Dichiaro matrici ovunque, ma solo in MASTER sono allocate
         B[x_size][y_size][z_size],                             // con le dimensioni giuste
         C[x_size][y_size][z_size];

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
  }


  int tot_local_size = (mat_sizes[0]*mat_sizes[1]*mat_sizes[2])/size;
  double A_local[tot_local_size], B_local[tot_local_size], C_local[tot_local_size];

  MPI_Barrier(MPI_COMM_WORLD);                                                     // inizia il tempo
  start_time = MPI_Wtime();

  MPI_Scatter(&A[0][0][0], tot_local_size, MPI_DOUBLE, &A_local[0], tot_local_size, MPI_DOUBLE, MASTER, comm );
  MPI_Scatter(&B[0][0][0], tot_local_size, MPI_DOUBLE, &B_local[0], tot_local_size, MPI_DOUBLE, MASTER, comm );


  for(int i = 0; i< tot_local_size; i++){
    C_local[i] = A_local[i] + B_local[i];
  }

  MPI_Gather(&C_local[0],  tot_local_size, MPI_DOUBLE, &C[0][0][0], tot_local_size, MPI_DOUBLE, MASTER, comm );



  //////////////////////////////////////// OPERAZIONI PER PRENDERE I TEMPI //////////////////////////////////

  MPI_Barrier(MPI_COMM_WORLD);														// il tempo calcolato finisce qui
  end_time=MPI_Wtime();
  res_time = end_time-start_time;

  MPI_Reduce(&res_time, &min_time, 1, MPI_DOUBLE, MPI_MAX, 0, comm );    //prendo il tempo più lento

  if(rank == MASTER){
    printf("grid: (%d %d %d),matrix sizes: %dx%dx%d, mintime: %10.8f \n",dims[0],dims[1],dims[2], mat_sizes[0], mat_sizes[1],mat_sizes[2], min_time);
  }
}


//////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////// IMPLEMENTAZIONE SENZA TOPOLOGIA //////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////

void matrix_no_topo(int mat_size[3]){
  double start_time, end_time, res_time, min_time;

  int period[2] = {TRUE,FALSE};                                                    //dichiarazioni iniziali
  int reorder = TRUE;
  MPI_Comm comm;
  int rank,size;
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);

  int tot_size, partial_size;
  int x_size,y_size,z_size;
  tot_size = mat_size[0]*mat_size[1]*mat_size[2];
  partial_size = tot_size/size ;
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
  double a[partial_size],b[partial_size],c[partial_size];

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

  MPI_Scatter(&A[0][0][0], partial_size, MPI_DOUBLE, a, partial_size, MPI_DOUBLE, MASTER, MPI_COMM_WORLD );
  MPI_Scatter(&B[0][0][0], partial_size, MPI_DOUBLE, b, partial_size, MPI_DOUBLE, MASTER, MPI_COMM_WORLD );

  for(int i=0; i<partial_size; i++){
    c[i] = a[i] + b[i];
  }
  MPI_Gather(c,  partial_size, MPI_DOUBLE, &C[0][0][0], partial_size, MPI_DOUBLE, MASTER, MPI_COMM_WORLD );

  MPI_Barrier(MPI_COMM_WORLD);														// il tempo calcolato finisce qui
  end_time=MPI_Wtime();
  res_time = end_time-start_time;
  MPI_Reduce(&res_time, &min_time, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);    //prendo il tempo più lento

  if(rank == MASTER){
    printf("dim matrix: %dx%dx%d,mintime: %10.8f \n", mat_size[0], mat_size[1],mat_size[2], min_time);
  }
}
