## IntelMPI

I ran this command on `ct1pt-tnode007` for map by core:

```bash
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,2  ./IMB-MPI1_intel PingPong
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,2 -genv I_MPI_OFI_PROVIDER tcp ./IMB-MPI1_intel PingPong
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,2 -genv I_MPI_OFI_PROVIDER shm ./IMB-MPI1_intel PingPong
```

this on `ct1pt-tnode007` for map by socket:
```bash
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,1  ./IMB-MPI1_intel PingPong
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,1 -genv I_MPI_OFI_PROVIDER tcp ./IMB-MPI1_intel PingPong
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,1 -genv I_MPI_OFI_PROVIDER shm ./IMB-MPI1_intel PingPong
```

this on `ct1pt-tnode007` and `ct1pt-tnode009` for map by node:

```bash
mpiexec -n 2 -ppn 1 ./IMB-MPI1_intel  PingPong
mpiexec -n 2 -ppn 1 -genv I_MPI_OFI_PROVIDER tcp ./IMB-MPI1_intel PingPong

```
