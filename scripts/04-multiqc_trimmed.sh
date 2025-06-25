#!/bin/bash
#SBATCH --error=output/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=23:00:00
#SBATCH --job-name=multiqc_trimmed
#SBATCH --mem=10GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

source ~/../../work/gmgi/miniconda3/bin/activate
conda activate haddock_methylation

dir="/work/gmgi/Fisheries/epiage/haddock/QC/trimmed_fastqc/"
multiqc_dir="/work/gmgi/Fisheries/epiage/haddock/QC/multiqc"

multiqc --interactive ${dir} --filename ${multiqc_dir}/multiqc_trimmed_full.html
