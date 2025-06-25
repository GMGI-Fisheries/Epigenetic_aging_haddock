#!/bin/bash
#SBATCH --error=output/trimgalore2/"%x_error.%a" #if your job fails, the error report will be put in this file
#SBATCH --output=output/trimgalore2/"%x_output.%a" #once your job is completed, any final job report comments will be put in this file
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

source ~/../../work/gmgi/miniconda3/bin/activate
conda activate trimgalore

## Set paths
raw_path="/work/gmgi/Fisheries/epiage/haddock/raw_data2"
out="/work/gmgi/Fisheries/epiage/haddock/trimmed_data2/"

#ls -d ${raw_path}/*R1*.gz > ${raw_path}/R1_files

## File name based on R1 list
mapfile -t FILENAMES < ${raw_path}/R1_files
FQ1=${FILENAMES[$SLURM_ARRAY_TASK_ID]}
FQ2=$(echo $FQ1 | sed 's/R1/R2/')

## TrimGalore! program
trim_galore \
    --output_dir ${out} \
    --fastqc \
    --clip_r1 10 --clip_r2 10 \
    --three_prime_clip_r1 10 --three_prime_clip_r2 10 \
    --paired \
    --gzip \
    --illumina \
    ${FQ1} ${FQ2}
