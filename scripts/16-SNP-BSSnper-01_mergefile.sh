#!/bin/bash
#SBATCH --error=output_messages/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output_messages/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --time=100:00:00
#SBATCH --job-name=BSSnper_merge
#SBATCH --mem=10GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

# load modules needed
module load samtools/1.19.2

# set paths 
sorted_dedup="/work/gmgi/Fisheries/epiage/haddock/methylation/sorted/sorted_bam"
output="/work/gmgi/Fisheries/epiage/haddock/SNP"

# Merge Samples with SAMtools
samtools merge ${output}/BS_SNPer_merged2.bam ${sorted_dedup}/*deduplicated.bam_sorted.bam
