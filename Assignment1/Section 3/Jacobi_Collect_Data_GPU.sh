#!/bin/bash
#PBS -l nodes=1:ppn=48
#PBS -l walltime=02:00:00
#PBS -q dssc_gpu

cd $PBS_O_WORKDIR
module load openmpi-4.1.1+gnu-9.3.0



printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' 'MAP' 'NProc' 'MaxTime' 'MinTime' 'JacobiMIN' 'JacobiMAX' 'MLUPs' >> Results_Jacobi_GPU.csv

printf 'core,\t1,\t%s\t%s\t%s\t%s\n'  `mpirun -np 1 --mca btl ^openib  -map-by core ./jacoby3D.x  <input.1200  | tail -1 | cut -c 46- | cut --complement -c 84-122  | sed 's/ \{1,\}/,/g'` >> Results_Jacobi_GPU.csv

for i in  {1..3}
do
  ((j=4*i))
  printf 'core,\t%d,\t%s\t%s\t%s\t%s\n' ${j} `mpirun -np ${j} --mca btl ^openib  -map-by core ./jacoby3D.x  <input.1200  | tail -1 | cut -c 46- | cut --complement -c 84-122  | sed 's/ \{1,\}/,/g'` >> Results_Jacobi_GPU.csv
done

for i in  {1..3}
do
  ((j=4*i))
  printf 'socket,\t%d,\t%s\t%s\t%s\t%s\n' ${j} `mpirun -np ${j} --mca btl ^openib  -map-by socket ./jacoby3D.x  <input.1200  | tail -1 | cut -c 46- | cut --complement -c 84-122 | sed 's/ \{1,\}/,/g'` >> Results_Jacobi_GPU.csv
done

for i in  {1..4}
do
  ((j=12*i))
  printf 'node,\t%d,\t%s\t%s\t%s\t%s\n' ${j} `mpirun -np ${j} --mca btl ^openib  -map-by node ./jacoby3D.x  <input.1200  | tail -1 | cut -c 46- | cut --complement -c 84-122  | sed 's/ \{1,\}/,/g'` >> Results_Jacobi_GPU.csv
done





rm Jacobi_Collect_Data.sh.*
rm task.*
exit
