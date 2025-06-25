#!/bin/bash
#SBATCH --error="%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output="%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --job-name=Impute_missing_values
#SBATCH --mem=50GB
#SBATCH --ntasks=10
#SBATCH --cpus-per-task=2

# module load R/4.4.0

module load anaconda3/2022.05
source activate /home/e.strand/.conda/envs/Env_R_v2

Rscript /work/gmgi/Fisheries/epiage/haddock/scripts/19-Missing_values.R
