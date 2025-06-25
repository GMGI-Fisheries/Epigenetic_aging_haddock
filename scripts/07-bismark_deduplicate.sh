#!/bin/bash
#SBATCH --error=dedup_output2/"%x_error.%a" #if your job fails, the error report will be put in this file
#SBATCH --output=dedup_output2/"%x_output.%a" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --time=120:00:00
#SBATCH --job-name=deduplicate
#SBATCH --mem=30GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

module load bismark/0.24.2
module load samtools/1.9

## Set paths
align_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/aligned2"

## File name based on align_list list
mapfile -t FILENAMES < ${align_dir}/bamfiles
i=${FILENAMES[$SLURM_ARRAY_TASK_ID]}

## Bismark Deduplicate
cd /work/gmgi/Fisheries/epiage/haddock/methylation/deduplicated2

deduplicate_bismark --bam --paired ${i}
