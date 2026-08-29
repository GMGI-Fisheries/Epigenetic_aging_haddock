#!/bin/bash
#SBATCH --error=2026_bootstrap_output/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=2026_bootstrap_output/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=48:00:00
#SBATCH --job-name=2026_bootstrap_output_v2
#SBATCH --mem=250GB
#SBATCH --ntasks=12
#SBATCH --cpus-per-task=2

source /projects/gmgi/miniconda3/etc/profile.d/conda.sh
conda activate /projects/gmgi/miniconda3/envs/R_env

Rscript /projects/gmgi/Fisheries/epiage/haddock/scripts/20-Age_prediction_bootstrap_2026_v2.R
