#!/bin/bash
#SBATCH --error=output/fastqc_output2/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output/fastqc_output2/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=23:00:00
#SBATCH --job-name=fastqc
#SBATCH --mem=5GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

module load OpenJDK/19.0.1
module load fastqc/0.11.9
module load bismark/0.22.2

raw_path="/work/gmgi/Fisheries/epiage/haddock/raw_data2"
dir="/work/gmgi/Fisheries/epiage/haddock/QC/raw_fastqc"

# ls -d ${raw_path}/*.gz > rawdata

## File name based on rawdata list
mapfile -t FILENAMES < ${raw_path}/rawdata
i=${FILENAMES[$SLURM_ARRAY_TASK_ID]}

## FastQC program
fastqc ${i} --outdir ${dir}
