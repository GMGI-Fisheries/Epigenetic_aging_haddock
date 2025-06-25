#!/bin/bash
#SBATCH --error=output/sorted_bam_output2/"%x_error.%a" #if your job fails, the error report will be put in this file
#SBATCH --output=output/sorted_bam_output2/"%x_output.%a" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --job-name=sort_bam
#SBATCH --mem=25GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2


# modules to load 
module load samtools/1.9
module load bedtools/2.29.0

## set paths 
output_sorted="/work/gmgi/Fisheries/epiage/haddock/methylation/sorted2"
dedup_path="/work/gmgi/Fisheries/epiage/haddock/methylation/deduplicated2"

## sample list 
mapfile -t FILENAMES < ${dedup_path}/deduplicated_bamfiles
i=${FILENAMES[$SLURM_ARRAY_TASK_ID]}

## SORT
samtools sort ${i} -o ${i}_sorted.bam
