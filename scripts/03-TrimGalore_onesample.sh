#!/bin/bash
#SBATCH --error=output/trimgalore/"%x_error.%a" #if your job fails, the error report will be put in this file
#SBATCH --output=output/trimgalore/"%x_output.%a" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --job-name=trimgalore
#SBATCH --mem=1GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

module load OpenJDK/19.0.1 ## dependency on NU Discovery cluster 
module load fastqc/0.11.9
module load trimgalore/0.6.5

## Set paths
raw_path="/work/gmgi/Fisheries/epiage/haddock/raw_data"
out="/work/gmgi/Fisheries/epiage/haddock/trimmed_data/"

## File name based on R1 list
#mapfile -t FILENAMES < ${raw_path}/R1_files
#FQ1=${FILENAMES[$SLURM_ARRAY_TASK_ID]}
#FQ2=$(echo $FQ1 | sed 's/R1/R2/')

cd /work/gmgi/Fisheries/epiage/haddock/raw_data

## TrimGalore! program
trim_galore \
    --output_dir ${out} \
    --fastqc \
    --clip_r1 10 --clip_r2 10 \
    --three_prime_clip_r1 10 --three_prime_clip_r2 10 \
    --paired \
    --gzip \
    --illumina \
    Mae-274_S3_R1_001.fastq.gz Mae-274_S3_R2_001.fastq.gz
