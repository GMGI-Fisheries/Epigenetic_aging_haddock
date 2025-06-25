#!/bin/bash
#SBATCH --error=output/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=23:00:00
#SBATCH --job-name=multiqc
#SBATCH --mem=30GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

source ~/../../work/gmgi/miniconda3/bin/activate
conda activate haddock_methylation

dir="/work/gmgi/Fisheries/epiage/haddock/QC/raw_fastqc/"
multiqc_dir="/work/gmgi/Fisheries/epiage/haddock/QC/multiqc/"

multiqc --interactive ${dir} -o ${multiqc_dir} --filename raw_multiqc_full.html
