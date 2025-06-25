#!/bin/bash
#SBATCH --error=extract_output/"%x_error.%a" #if your job fails, the error report will be put in this file
#SBATCH --output=extract_output/"%x_output.%a" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=20:00:00
#SBATCH --job-name=methylation_extractor
#SBATCH --mem=80GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

module load bismark/0.24.2
module load samtools/1.9

## Set paths
dedup_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/deduplicated"

## File name based on rawdata list
#mapfile -t FILENAMES < ${dedup_dir}/deduplicated_bamfiles
#i=${FILENAMES[$SLURM_ARRAY_TASK_ID]}

cd /work/gmgi/Fisheries/epiage/haddock/methylation/meth_extracted/

bismark_methylation_extractor --bedGraph --paired --counts --scaffolds --report ${dedup_dir}/Mae-533*
