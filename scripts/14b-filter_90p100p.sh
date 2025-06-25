#!/bin/bash
#SBATCH --error=output/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --job-name=filter_90p100p2
#SBATCH --mem=50GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

# load modules
module load bedtools/2.29.0

cd /work/gmgi/Fisheries/epiage/haddock/methylation/filtered/10X_files

for i in *tab
do
  intersectBed \
  -a ${i} \
  -b CpG.filt90.all.samps.10x_sorted2.bed \
  > ${i}_CpG_10x_90p_enrichment2.bed
done

for i in *tab
do
  intersectBed \
  -a ${i} \
  -b CpG.filt100.all.samps.10x_sorted2.bed \
  > ${i}_CpG_10x_100p_enrichment2.bed
done
