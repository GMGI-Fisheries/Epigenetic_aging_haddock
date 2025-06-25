#!/bin/bash
#SBATCH --error=output/merge_strands_output2/"%x_error.%a" #if your job fails, the error report will be put in this file
#SBATCH --output=output/merge_strands_output2/"%x_output.%a" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=20:00:00
#SBATCH --job-name=merge_strands2
#SBATCH --mem=50GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

module load bismark/0.24.2
module load samtools/1.9

## Set paths
cov_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/meth_extracted2"
genome_folder="/work/gmgi/Fisheries/reference_genomes/Haddock"
output="/work/gmgi/Fisheries/epiage/haddock/methylation/merged2"

## File name based on rawdata list
mapfile -t FILENAMES < ${cov_dir}/cov_bamfiles
i=${FILENAMES[$SLURM_ARRAY_TASK_ID]}

cd /work/gmgi/Fisheries/epiage/haddock/methylation/merged2

coverage2cytosine --genome_folder ${genome_folder} --merge_CpG --zero_based -o ${i}_merged.cov ${i}
