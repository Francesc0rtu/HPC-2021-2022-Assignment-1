## OpenMPI

I ran this command on `ct1pt-tnode008` for map by core:
```bash
mpirun -mca pml ob1 --mca btl self,vader  -np 2 --map-by core ./IMB-MPI1 PingPong
mpirun -mca pml ob1 --mca btl self,tcp  -np 2 --map-by core
mpirun -mca pml ucx  -np 2 --map-by core ./IMB-MPI1 PingPong
```

this on `ct1pt-tnode008` for map by socket:
```bash
mpirun -mca pml ob1 --mca btl self,vader  -np 2 --map-by socket ./IMB-MPI1 PingPong
mpirun -mca pml ob1 --mca btl self,tcp  -np 2 --map-by socket ./IMB-MPI1 PingPong
mpirun -mca pml ucx  -np 2 --map-by socket ./IMB-MPI1 PingPong
```

this on `ct1pt-tnode008` and `ct1pt-tnode009` for mab by node:
```bash
mpirun -mca pml ob1 --mca btl tcp  -np 2 --map-by node ./IMB-MPI1 PingPong
mpirun -mca pml ucx   -np 2 --map-by node ./IMB-MPI1 PingPong
```
