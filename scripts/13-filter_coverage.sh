#!/bin/bash
#SBATCH --error=output/filter_output2/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output/filter_output2/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --job-name=filter_coverage2
#SBATCH --mem=50GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

## set paths 
sorted_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/sorted/sorted_cov"
out="/work/gmgi/Fisheries/epiage/haddock/methylation/filtered/10X_files"

## Filtering for 10X coverage 

for f in ${sorted_dir}/*_sorted.cov
do
  STEM=$(basename "${f}" _sorted.cov)
  cat "${f}" | awk -F $'\t' 'BEGIN {OFS = FS} {if ($5+$6 >= 10) {print $1, $2, $3, $4, $5, $6}}' \
  > ${out}/"${STEM}"_10x_sorted.tab
done
