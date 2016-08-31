#!/bin/sh

# args:
# $1: mpi_pingpong executable
# $2: number of iterations
# $3: number of tasks
# $4: allow concurrent messages?

module load R

MPI_PINGPONG=$1
ITER=$2
N=$3
CONCURRENT=$4

shift 4

for SIZE in $*
do
	./run_all.sh $MPI_PINGPONG $ITER $N $CONCURRENT $SIZE
done

