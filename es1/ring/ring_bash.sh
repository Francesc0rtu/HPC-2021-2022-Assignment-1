#!/bin/bash

#PBS -l nodes=2:ppn=24
#PBS -l walltime=02:00:00
#PBS -q dssc

cd $PBS_O_WORKDIR

module load openmpi-4.1.1+gnu-9.3.0
mpicc ring_non_blocking.c -o ring_non_blocking.x
mpicc ring_blocking.c -o ring_blocking.x

# establish the maximum number of processor on which you want to test the code
N=48
#store time taken by first and second implementation

time_nb=[]
time_b=[]



printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' 'n_procs,' 'MIN NB,' 'MIN B,' 'SUM NB,' 'SUM B,' 'MEAN NB,' 'MEAN B,' 'MIN NB ob1,' 'MIN B ob1' > results.csv

for i in  $( seq 2 $N )
do


 mpirun -np $i --mca pml ucx --map-by core ./ring_non_blocking.x
 mpirun -np $i --mca pml ucx --map-by core ./ring_blocking.x

 str=$(cat output_ring_non_blocking | grep time | cut -f2 -d ':')
 str1=$(cat output_ring_blocking | grep time | cut -f2 -d ':')
 time_nb[j]=$(echo ${str} | cut -d ' ' -f1)
 time_b[j]=$(echo ${str1} | cut -f2 -d ' ')




 printf '%d,\t%s,\t%s\n' ${i} ${time_nb[0]} ${time_b[0]} >> results.csv

done

exit
