#include <stdio.h>
#include "mpi.h"
#include <stdlib.h>

#define TRUE 1
#define FALSE 0





int main(int argc, char *argv[]){
  MPI_Init(&argc,&argv);   //MPI si inizializza
  double start_time, end_time,res_time, final_time=0, tmp ;
  int rank,size,np=0;
  MPI_Comm_rank(MPI_COMM_WORLD,&rank);



  int period[2] = {TRUE,FALSE};
  int reorder = TRUE;
  MPI_Comm comm_ring;
  MPI_Request request[4];
  MPI_Status status[4];
  int tag_to_sx, tag_to_dx;
  int msg_to_left = rank, msg_to_right = -rank;
  int msg_from_left, msg_from_right;
  int sx,dx;                                									                       		//rank dei vicini


  MPI_Comm_size(MPI_COMM_WORLD,&size);
  MPI_Cart_create(MPI_COMM_WORLD, 1, &size, period, reorder, &comm_ring);				     		//crea la topologia ring
  MPI_Comm_size(comm_ring,&size);
  MPI_Comm_rank(comm_ring,&rank);

  MPI_Cart_shift(comm_ring,1,1,&sx,&dx);     										                         	//sx e dx prendono i rank dei vicini
  tag_to_sx=10*rank;
  tag_to_dx=10*rank;



      //////////////////////////////////// INVIO E RICEZIONE DEI MESSAGGI CON 10000 DI RIPETIZIONI   /////////////////////////////////////////////////
      /////// I processori mandano a dx e sx e ricevono con operazioni non blocking. Dopo aspettano che tutti i messaggi siano arrivati       ////////
      //////  e aggiornano i messagi da rimandare. In realtà quindi nonostante l'uso di op non-blocking vi e' un blocking tramite MPI_Barrier ////////
      ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




    for(int i=0; i<10000; i++){
      MPI_Barrier(comm_ring);
      start_time = MPI_Wtime();

      do{							 // Mi fermo quando ricevo il messaggio inviato da destra e da sinistra
        MPI_Isend( &msg_to_right, 1, MPI_INT, dx, tag_to_dx , comm_ring, &request[0] );    //invio a destra
        MPI_Isend( &msg_to_left, 1, MPI_INT, sx, tag_to_sx, comm_ring, &request[1]);    	 //invio a sinistra
        MPI_Irecv( &msg_from_left, 1, MPI_INT, sx, MPI_ANY_TAG, comm_ring, &request[2]);   //ricevo da sinistra
        MPI_Irecv( &msg_from_right, 1, MPI_INT, dx, MPI_ANY_TAG, comm_ring, &request[3] ); //ricevo da destra

        MPI_Waitall(4,request, status);                        													//Aspetto di aver inviato e sopratutto ricevuto
        np = np + 2;
        msg_to_left = msg_from_right - rank;											                      	// Invio a sinistra il messagio ricevuto da destra
        tag_to_sx = status[3].MPI_TAG;
        msg_to_right = msg_from_left + rank;												                    	// Invio a dx il msg ricevuto da sx
        tag_to_dx = status[2].MPI_TAG;

      }while (status[2].MPI_TAG != rank*10 &&  status[3].MPI_TAG != rank*10);
      MPI_Barrier(comm_ring);														// il tempo calcolato finisce qui
      end_time=MPI_Wtime();
      res_time = end_time-start_time;
      MPI_Reduce(&res_time, &tmp, 1, MPI_DOUBLE, MPI_MAX, 0, comm_ring );    //prendo il tempo più lento
      final_time = final_time + tmp;
    }

  final_time = final_time/10000;

		                                  ////////////////////////////// OPERAZIONI DI STAMPA//////////////////////////////////////
  FILE *out;
  if(rank == 0){
    out=fopen("output_ring_non_blocking", "w");
    fprintf(out,"----NON BLOCKING EXECUTION-----\n");
    fclose(out);
  }

  MPI_Barrier(comm_ring);												          //Tutti i proc aspettano che il proc 0 abbia creato il file prima di appendere la propria stampa


  out=fopen("output_ring_non_blocking", "a");
  fprintf(out,"I am process %d and i have received %d messages. My final messages have tag %d and value %d,%d\n", rank, np, status[2].MPI_TAG, msg_from_left,msg_from_right);
  fclose(out);

  MPI_Barrier(comm_ring);   //time va stampato per ultimo per essere estratto dallo script bash

  if(rank == 0){														// Il proc 0 stampa il tempo impiegato
  out=fopen("output_ring_non_blocking", "a");
  fprintf(out,"time: %10.8f\n", final_time);
  fclose(out);
  }

  MPI_Finalize();



}
