
#!/bin/bash
#PBS -l nodes=1:ppn=24
#PBS -l walltime=02:00:00
#PBS -q dssc

cd $PBS_O_WORKDIR
module load openmpi-4.1.1+gnu-9.3.0
mpicc sum3Dmatrix.c -o matrix.x
printf '%s,\t%s,\t%s,\t%s,\t%s\n' 'GRID' 'DIM' 'MIN TIME' 'SUM TIME' 'MEAN TIME' > results.csv

for y in {0..2}
do
  mpirun -np 24 --mca btl ^openib ./matrix.x 24 1 1 <input${y} >> results.csv
  mpirun -np 24 --mca btl ^openib ./matrix.x 12 2 1 <input${y} >> results.csv
  mpirun -np 24 --mca btl ^openib ./matrix.x 8 3 1 <input${y} >> results.csv
  mpirun -np 24 --mca btl ^openib ./matrix.x 6 2 2 <input${y} >> results.csv
  mpirun -np 24 --mca btl ^openib ./matrix.x 4 3 2 <input${y} >>  results.csv
  
done







##################### per prove locali #############################

# for y in {0..2}
# do
#   mpirun -np 4 --mca btl ^openib ./matrix.x 4 1 1 <input${y} >> results.csv
#   mpirun -np 4 --mca btl ^openib ./matrix.x 2 2 1 <input${y} >> results.csv
#
#
# done



exit
