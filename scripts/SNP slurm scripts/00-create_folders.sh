#!/bin/bash
## sample list 
mapfile -t FOLDER_NAMES < foldernames.txt
i=${FOLDER_NAMES[$SLURM_ARRAY_TASK_ID]}

mkdir ${i}
