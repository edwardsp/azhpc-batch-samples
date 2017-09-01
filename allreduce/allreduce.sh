#!/bin/sh

NPROCS_LIST=$1
PPN_LIST=$2
NITER=$3
NAME_TAG=$4
MPI_FLAGS=$5

if [ "$NAME_TAG" != "" ]; then
	NAME_TAG=_$NAME_TAG
fi

echo "NPROCS_LIST = $NPROCS_LIST"
echo "PPN_LIST    = $PPN_LIST"
echo "NITER       = $NITER"
echo "NAME_TAG    = $NAME_TAG"
echo "MPI_FLAGS   = $MPI_FLAGS"

source /opt/intel/impi/*/bin64/mpivars.sh
AZURE_MPI_FLAGS="-genv I_MPI_FABRICS shm:dapl -genv I_MPI_DAPL_PROVIDER ofa-v2-ib0 -genv I_MPI_DYNAMIC_CONNECTION 0 -genv I_MPI_FALLBACK_DEVICE 0"

for NPROCS in $NPROCS_LIST; do
	for PPN in $PPN_LIST; do
		NP=$(bc <<< "$NPROCS * $PPN")
		mpirun -np $NP -ppn $PPN -hostfile $HOME/bin/hostlisti $AZURE_MPI_FLAGS $MPI_FLAGS IMB-MPI1 Allreduce -iter ${NITER} -npmin $NP -msglog 3:4 -time 1000000 2>&1 | tee IMB_Allreduce_${NITER}_${NP}_${NPROCS}x${PPN}${NAME_TAG}.log
	done
done

OUTFILE=allreduce${NAME_TAG}_$(date +"%Y-%m-%d_%H-%M-%S").csv
for MSG_SZ in 8 16; do
	echo "MSG_SZ=${MSG_SZ}"
	echo -n "NPROCS/PPN"
	for PPN in $PPN_LIST; do
		echo -n " ${PPN}"
	done
	echo
	for NPROCS in $NPROCS_LIST; do
		echo -n "${NPROCS}"
		for PPN in $PPN_LIST; do
			NP=$(bc <<< "$NPROCS * $PPN")
			echo -n " $(grep -E " $MSG_SZ[ ]+$NITER " IMB_Allreduce_${NITER}_${NP}_${NPROCS}x${PPN}${NAME_TAG}.log | sed 's/  */ /g' | cut -d' ' -f 6)"
		done
		echo
	done
done

