#!/bin/bash
#SBATCH --error=output/sort_cov2/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output/sort_cov2/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --time=120:00:00
#SBATCH --job-name=sort_cov2
#SBATCH --mem=100GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

# load BEDTools 
module load bismark/0.24.2
module load samtools/1.9
module load bedtools/2.29.0

## Set paths
merged_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/merged2"
sorted_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/sorted"

cd ${merged_dir}

for f in ${merged_dir}/*merged_CpG_evidence.cov
do
  STEM=$(basename "${f}" .CpG_report.merged_CpG_evidence.cov)
  bedtools sort -i "${f}" \
  > ${sorted_dir}/"${STEM}"_sorted.cov
done
