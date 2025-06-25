#!/bin/bash
#SBATCH --error="%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output="%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --time=120:00:00
#SBATCH --job-name=10k_iteration_bootstrap
#SBATCH --mem=200GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

# module load R/4.4.0

module load anaconda3/2022.05
source activate /home/e.strand/.conda/envs/Env_R_v2

Rscript /work/gmgi/Fisheries/epiage/haddock/scripts/20-Age_prediction_bootstrap_10k.R
