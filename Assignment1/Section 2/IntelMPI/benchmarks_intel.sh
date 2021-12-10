#!/bin/bash
#PBS -l nodes=2:ppn=24
#PBS -l walltime=01:00:00
#PBS -q dssc


module load intel/20.4
cd $PBS_O_WORKDIR





mpiexec.hydra -n 2 -iface ib0
mpiexec.hydra -n 2 -iface em1

#map by node
mpiexec -n 2 -ppn 1 ./IMB-MPI1_intel  PingPong -msglog 28 2> /dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' >bynode_infiniband.csv
mpiexec -n 2 -ppn 1 -genv I_MPI_OFI_PROVIDER tcp ./IMB-MPI1_intel PingPong -msglog 28 2> /dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' >bynode_tcp.csv
#map by socket
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,1  ./IMB-MPI1_intel PingPong -msglog 28 2> /dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' >bysocket.csv
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,1 -genv I_MPI_OFI_PROVIDER tcp ./IMB-MPI1_intel PingPong -msglog 28 2> /dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' >bysocket_tcp.csv
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,1 -genv I_MPI_OFI_PROVIDER shm ./IMB-MPI1_intel PingPong -msglog 28 2> /dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' >bysocket_shm.csv

#map by core
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,2  ./IMB-MPI1_intel PingPong -msglog 28 2> /dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' >bycore.csv
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,2 -genv I_MPI_OFI_PROVIDER tcp ./IMB-MPI1_intel PingPong -msglog 28 2> /dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' >bycore_tcp.csv
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,2 -genv I_MPI_OFI_PROVIDER shm ./IMB-MPI1_intel PingPong -msglog 28 2> /dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' >bycore_shm.csv


git rm benchmarks_intel.sh.*
git add *
git commit -m "new benchmarks"
git push
exit
