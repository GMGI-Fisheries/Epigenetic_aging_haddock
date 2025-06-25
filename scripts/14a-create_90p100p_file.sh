#!/bin/bash
#SBATCH --error=output/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --job-name=create_90p100p_file2
#SBATCH --mem=50GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

# load modules
module load bedtools/2.29.0

cd /work/gmgi/Fisheries/epiage/haddock/methylation/filtered/10X_files

multiIntersectBed -i *.tab > CpG.all.samps.10x_sorted2.bed

cat CpG.all.samps.10x_sorted2.bed | awk '$4 > 125' > CpG.filt90.all.samps.10x_sorted2.bed
cat CpG.all.samps.10x_sorted2.bed | awk '$4 == 140' > CpG.filt100.all.samps.10x_sorted2.bed
