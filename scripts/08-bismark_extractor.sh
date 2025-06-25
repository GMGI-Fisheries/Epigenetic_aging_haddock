#!/bin/bash
#SBATCH --error=extract_output2/"%x_error.%a" #if your job fails, the error report will be put in this file
#SBATCH --output=extract_output2/"%x_output.%a" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --time=120:00:00
#SBATCH --job-name=methylation_extractor
#SBATCH --mem=75GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

module load bismark/0.24.2
module load samtools/1.9

## Set paths
dedup_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/deduplicated2"

## File name based on rawdata list
mapfile -t FILENAMES < ${dedup_dir}/deduplicated_bamfiles
i=${FILENAMES[$SLURM_ARRAY_TASK_ID]}

cd /work/gmgi/Fisheries/epiage/haddock/methylation/meth_extracted2/

bismark_methylation_extractor --comprehensive --bedGraph --paired --counts --scaffolds --gzip --report ${i}
