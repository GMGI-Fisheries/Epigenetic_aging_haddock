#!/bin/bash
#SBATCH --error=output/bismark_summary_ecoli/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output/bismark_summary_ecoli/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=20:00:00
#SBATCH --job-name=bismark_summary_ecoli
#SBATCH --mem=40GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

module load bismark/0.22.2

out="/work/gmgi/Fisheries/epiage/haddock/methylation/conversion_eff/summary"
align_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/conversion_eff/aligned"

bismark2summary ${align_dir}/*bam -o ${out}/ecoli_seqrun1_align
