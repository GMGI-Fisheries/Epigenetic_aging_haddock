#!/bin/bash
#SBATCH --error=output/qualimap_output/"%x_error.%a" #if your job fails, the error report will be put in this file
#SBATCH --output=output/qualimap_output/"%x_output.%a" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --job-name=qualimap
#SBATCH --mem=100GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

## path to qualimap
qualimap_path="/work/gmgi/packages/qualimap_v2.3"

## set paths 
output_summary="/work/gmgi/Fisheries/epiage/haddock/methylation/summary/qualimap"
sorted_path="/work/gmgi/Fisheries/epiage/haddock/methylation/sorted"

## sample list 
mapfile -t FILENAMES < ${sorted_path}/sorted_bamfiles
i=${FILENAMES[$SLURM_ARRAY_TASK_ID]}less

${qualimap_path}/qualimap bamqc -bam ${i} -outdir ${output_summary}
