#!/bin/sh

OUTPUT_STORAGE=$1
NPROCS=$2
PPN_LIST=$3
NITER=$4
NAME_TAG=$5
MPI_FLAGS=$6

cat << EOF
{
	"id":"$(uuidgen)",
	"commandLine": "sudo -E -u _azbatch bash \$AZ_BATCH_TASK_WORKING_DIR/allreduce.sh '$2' '$3' '$4' '$5' '$6'",
	"resourceFiles": [ 
		{
		  "blobSource":"https://raw.githubusercontent.com/edwardsp/azhpc-batch-samples/master/allreduce/allreduce.sh",
		  "filePath":"allreduce.sh"
		}  
	],
	"outputFiles" : [
		{
		"filePattern" : "\$AZ_BATCH_TASK_WORKING_DIR/*.csv",
		"destination" : {
			"container" : {
				"path" : "allreduce-results",
				"containerUrl": "$1"
			}
		},
		"uploadOptions" : {
			"uploadCondition" : "taskCompletion"
			}
		}
	],	
	"multiInstanceSettings":
	{
		"numberOfInstances" : $NPROCS,
		"coordinationCommandLine" : "hostname",
		"commonResourceFiles": [ ]
	},
	"userIdentity": {
		"autoUser": {
			"scope":"pool",
			"elevationLevel":"admin"
		}
	}
}
EOF
