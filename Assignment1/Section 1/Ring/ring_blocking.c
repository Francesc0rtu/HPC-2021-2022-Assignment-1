#include <stdio.h>
#include "mpi.h"
#include <stdlib.h>



#define TRUE 1
#define FALSE 0
int main(int argc, char *argv[]){
  double start_time, end_time, res_time, final_time=0, tmp ;
  MPI_Init(&argc,&argv);   //MPI si inizializza


  int rank,size,np=0;
  int period = TRUE;
  int reorder = TRUE;
  MPI_Comm comm_ring;
  MPI_Status status_from_dx,status_from_sx;


  MPI_Comm_size(MPI_COMM_WORLD,&size);

  MPI_Cart_create(MPI_COMM_WORLD, 1, &size, &period, reorder, &comm_ring); //crea la topologia ring
  MPI_Comm_size(comm_ring,&size);
  MPI_Comm_rank(comm_ring,&rank);           //rank nella nuova topologia


  int sx,dx;                                //rank dei vicini i
  MPI_Cart_shift(comm_ring,1,1,&sx,&dx);     //sx e dx sono i rank dei vicini
  int msg_to_left = rank, msg_to_right = -rank;
  int msg_from_left, msg_from_right;
  int tag_to_sx = rank*10, tag_to_dx = rank*10;



  int n=0;




          //////////////////////////////////// INVIO E RICEZIONE DEI MESSAGGI CON 10000 DI RIPETIZIONI   ////////////////////////////////////////////
          /////// I processori pari e dispari si alternano a mandare messaggi e a riceverli per evitare deadlock. Nel caso in cui il numero ////////
          //////  totale di processori è dispari il proc 0 ha un comportamento leggermente divero: invece di ricevere a dx e sx come i proc ////////
          //////  pari manda a sx e riceve da dx e poi manda a dx e riceve da sx.                                                           /////////
          ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


  for(int i=0; i<100000; i++){
    MPI_Barrier(comm_ring);                                                     //Per prendere i tempi tutti i proc partano insieme
    start_time = MPI_Wtime();

                                           // Ripetizioni per osservare differenze di tempo
    while(n<size){                                                            // Dopo #{num proc} volte ogni proc ha ricevuto indietro il messagio inviato all'inizio
      int tmp1, tmp2;

      if(rank%2 == 1){
        MPI_Ssend( &msg_to_right, 1, MPI_INT, dx, tag_to_dx, comm_ring );    //invio a destra
        MPI_Ssend( &msg_to_left, 1, MPI_INT, sx, tag_to_sx, comm_ring );    //invio a sinistra
        //printf("proc=%d, ho inviato a dx e a sx\n", rank);
        MPI_Recv( &msg_from_left, 1, MPI_INT, sx, MPI_ANY_TAG, comm_ring, &status_from_sx ); //ricevo da sinistra
        MPI_Recv( &msg_from_right, 1, MPI_INT, dx, MPI_ANY_TAG, comm_ring, &status_from_dx ); //ricevo da destra
        np = np + 2;
      }
      else if((rank%2 == 0 && size%2 == 0) || (rank%2 == 0 && rank != 0) ){
        MPI_Recv( &msg_from_left, 1, MPI_INT, sx, MPI_ANY_TAG, comm_ring, &status_from_sx ); //ricevo da sinistra
        MPI_Recv( &msg_from_right, 1, MPI_INT, dx, MPI_ANY_TAG, comm_ring, &status_from_dx  ); //ricevo da destra
        np = np + 2;

        MPI_Ssend( &msg_to_right, 1, MPI_INT, dx, tag_to_dx, comm_ring );    //invio a destra
        MPI_Ssend( &msg_to_left, 1, MPI_INT, sx, tag_to_sx, comm_ring );    //invio a sinistra
      }
      else{
        MPI_Ssend( &msg_to_left, 1, MPI_INT, sx, tag_to_sx, comm_ring );    //invio a sinistra
        MPI_Recv( &msg_from_right, 1, MPI_INT, dx, MPI_ANY_TAG, comm_ring, &status_from_dx  ); //ricevo da destra
        np+=1;

        MPI_Ssend( &msg_to_right, 1, MPI_INT, dx, tag_to_dx, comm_ring );    //invio a destra
        MPI_Recv( &msg_from_left, 1, MPI_INT, sx, MPI_ANY_TAG, comm_ring, &status_from_sx ); //ricevo da sinistra
        np+=1;
      }

      tag_to_sx = status_from_dx.MPI_TAG;
      tag_to_dx = status_from_sx.MPI_TAG;
      msg_to_left = msg_from_right - rank;
      msg_to_right = msg_from_left + rank;

      n++;

    }

    MPI_Barrier(comm_ring);														// il tempo calcolato finisce qui
    end_time=MPI_Wtime();
    res_time = end_time-start_time;
    MPI_Reduce(&res_time, &tmp, 1, MPI_DOUBLE, MPI_MAX, 0, comm_ring );    //prendo il tempo più lento
    final_time=final_time+tmp;
  }
  
  final_time = final_time/100000;


		                            ////////////////////////////// OPERAZIONI DI STAMPA//////////////////////////////////////
  FILE *out;
  if(rank == 0){
    out=fopen("output_ring_blocking", "w");
    fprintf(out,"----BLOCKING EXECUTION-----\n");
    fclose(out);
  }

  MPI_Barrier(comm_ring);												     //Tutti i proc aspettano che il proc 0 abbia creato il file prima di appendere la propria stampa


  out=fopen("output_ring_blocking", "a");
  fprintf(out,"I am process %d and i have received %d messages. My final messages have tag %d and value %d,%d\n", rank, np, status_from_dx.MPI_TAG, msg_from_left,msg_from_right);
  fclose(out);

  if(rank == 0){														    // Il proc 0 stampa il tempo impiegato
  out=fopen("output_ring_blocking", "a");
  fprintf(out,"time: %10.8f\n", final_time);
  fclose(out);
  }

  MPI_Finalize();





}
