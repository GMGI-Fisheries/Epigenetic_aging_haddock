#!/bin/bash
#SBATCH --error=output/preseq_output/"%x_error.%a" #if your job fails, the error report will be put in this file
#SBATCH --output=output/preseq_output/"%x_output.%a" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --job-name=preseq
#SBATCH --mem=25GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

# modules to load 
module load samtools/1.9
module load bedtools/2.29.0

## set paths 
output_summary="/work/gmgi/Fisheries/epiage/haddock/methylation/summary2"
sorted_path="/work/gmgi/Fisheries/epiage/haddock/methylation/sorted2"

## sample list 
mapfile -t FILENAMES < ${sorted_path}/sorted_bamfiles
i=${FILENAMES[$SLURM_ARRAY_TASK_ID]}

## PRESEQ 
preseq lc_extrap -bam -verbose -o ${i}
preseq c_curve -bam -verbose -o ${i}

#mv ${i}_future_yield.txt ${output_summary}/
#mv ${i}__complexity_output.txt ${output_summary}/
