#!/bin/sh

# args:
# $1: mpi_pingpong executable
# $2: number of iterations
# $3: number of tasks
# $4: allow concurrent messages?
# $5: message size in bytes


MPI_PINGPONG=$1
ITER=$2
N=$3
CONCURRENT=$4
#SIZE=$5
HEAD=`echo "$N*$N" | bc`
job_id=$LSB_JOBID
#sizes=(488 1952 2440 2928 4880 5368 5856 7808 8296 10248)
sizes=(4 40 5200 52000 5408 54080 8 80 840 8400)
mkdir $job_id

for SIZE in "${sizes[@]}"
	do

if [ $MPI_PINGPONG == mpi_pingpong_intel* ]; then
	if [ -z $I_MPI_EAGER_THRESHOLD ]; then
		export I_MPI_EAGER_THRESHOLD=262144
		export I_MPI_INTRANODE_EAGER_THRESHOLD=$I_MPI_EAGER_THRESHOLD
	fi

	# assign processors in a RR fashion by core
	export I_MPI_PIN_PROCESSOR_LIST=`seq -s',' 0 $((N - 1))`

	T="$N-$SIZE-$ITER-$I_MPI_EAGER_THRESHOLD-$I_MPI_INTRANODE_EAGER_THRESHOLD-${LSB_JOBID}-`date '+%Y%m%d%H%M%S'`"
	LEGEND="No. of Tasks: $N
	Iterations: $ITER
	Msg. Size: `echo "$SIZE/1024" | bc`KB
	Eager Limit: `echo "$I_MPI_EAGER_THRESHOLD/1024" | bc`KB
	Eager Limit (Local): `echo "$I_MPI_INTRANODE_EAGER_THRESHOLD/1024" | bc`KB
	$MPI_PINGPONG"

else
	T="$N-$SIZE-$ITER-$MP_EAGER_LIMIT-$MP_EAGER_LIMIT_LOCAL-${LSB_JOBID}-`date '+%Y%m%d%H%M%S'`"
	LEGEND="No. of Tasks: $N
	Iterations: $ITER
	Msg. Size: `echo "$SIZE/1024" | bc`KB
	Eager Limit: `echo "$MP_EAGER_LIMIT/1024" | bc`KB
	Eager Limit (Local): `echo "$MP_EAGER_LIMIT_LOCAL/1024" | bc`KB
	$MPI_PINGPONG"
fi

echo "ping_size,from,to,from_host,to_host,from_cpu,to_cpu,mean" > $job_id/mpi_ping_latency_$T.csv

if [ $MPI_PINGPONG == mpi_pingpong_intel* ]; then
	module load impi
	mpirun -machinefile $LSB_DJOB_HOSTFILE ./$MPI_PINGPONG $ITER $SIZE $CONCURRENT | head -n $HEAD >> $job_id/mpi_ping_latency_$T.csv
	
elif [ $MPI_PINGPONG == mpi_pingpong_openmpi* ]; then
	module use ~/modules
	module load openmpi
	mpirun --bind-to-core -machinefile $LSB_DJOB_HOSTFILE ./$MPI_PINGPONG $ITER $SIZE $CONCURRENT | head -n $HEAD >> mpi_ping_latency_$T.csv
else
	mpirun.lsf ./$MPI_PINGPONG $ITER $SIZE $CONCURRENT | head -n $HEAD >> $job_id/mpi_ping_latency_$T.csv
fi

done
