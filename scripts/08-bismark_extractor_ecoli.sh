#!/bin/bash
#SBATCH --error=output/extract_output_ecoli2/"%x_error.%a" #if your job fails, the error report will be put in this file
#SBATCH --output=output/extract_output_ecoli2/"%x_output.%a" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=20:00:00
#SBATCH --job-name=methylation_extractor_ecoli2
#SBATCH --mem=10GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

module load bismark/0.24.2
module load samtools/1.9

## Set paths
dedup_dir="/work/gmgi/Fisheries/epiage/haddock/conversion_eff/deduplicated2"

## File name based on rawdata list
mapfile -t FILENAMES < ${dedup_dir}/deduplicated_bamfiles_ecoli
i=${FILENAMES[$SLURM_ARRAY_TASK_ID]}

cd /work/gmgi/Fisheries/epiage/haddock/conversion_eff/meth_extracted2/

bismark_methylation_extractor --bedGraph --paired --counts --scaffolds --report ${i}
