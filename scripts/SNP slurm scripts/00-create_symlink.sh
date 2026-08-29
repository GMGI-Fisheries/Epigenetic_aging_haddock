#!/bin/bash


## sample list 
mapfile -t FILENAMES < /work/gmgi/Fisheries/epiage/haddock/methylation/aligned/bamfiles
i=${FOLDER_NAMES[$SLURM_ARRAY_TASK_ID]}

## folder list
mapfile -t FOLDER_NAMES < /work/gmgi/Fisheries/epiage/haddock/SNP/scripts/foldernames.txt
f=${FOLDER_NAMES[$SLURM_ARRAY_TASK_ID]}

## create sym link

ln -s ${i} /work/gmgi/Fisheries/epiage/haddock/SNP/bam_symlinks/${f}/${i}
