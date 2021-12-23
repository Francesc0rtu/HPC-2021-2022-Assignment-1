
__Assignment 1-Francesco Ortu__

To compile all files on orfeo do:
```bash
module load openmpi-4.1.1+gnu-9.3.0
make
```


---

# Ring
The file `ring.c` contain two implementation of the exercise: one that use full-blocking operations while the other one use non blocking operations.


To run with `N` processors do :
``` bash
mpirun -np N --mca btl ^openib ./ring.x
```
This execution will produce two files, one per implementation:
`output_ring_blocking`
`output_ring_non_blocking`

---
# Matrix-Matrix sum

As before there are two implementation of the exercise in `sum3Dmatrix.c`, one with virtual topology and one without.

To run with `N` processors do:
```bash
mpirun -np N --mca btl ^openib sum3Dmatrix.x X Y Z < input
```

where `X Y Z` are the grid of the virtual topology while in the `input` files there are the sizes of the matrixes.
This execution will print the dimension of the input matrices and the walltime in two files, one per implementation:
`output_matrix_topo`
`output_matrix_no_topo`
