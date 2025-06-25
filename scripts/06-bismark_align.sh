#!/bin/bash
#SBATCH --error=align_output2/"%x_error.%a" #if your job fails, the error report will be put in this file
#SBATCH --output=align_output2/"%x_output.%a" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --time=120:00:00
#SBATCH --job-name=align
#SBATCH --mem=50GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

module load bismark/0.22.2
module load bowtie/2.5.2
module load samtools/1.9

## Set paths
genome_folder="/work/gmgi/Fisheries/reference_genomes/Haddock"
trimmed_path="/work/gmgi/Fisheries/epiage/haddock/trimmed_data2"
out_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/aligned2/"

## File name based on R1 list
mapfile -t FILENAMES < ${trimmed_path}/trimmed_R1_files
FQ1=${FILENAMES[$SLURM_ARRAY_TASK_ID]}
FQ2=$(echo $FQ1 | sed 's/R1/R2/' | sed 's/val_1/val_2/')

cd /work/gmgi/Fisheries/epiage/haddock/methylation/aligned2/

## Bismark align
bismark \
-o ${out_dir} \
--bowtie2 \
-genome ${genome_folder} \
-score_min L,0,-0.6 \
--non_directional \
-1 ${FQ1} \
-2 ${FQ2}
