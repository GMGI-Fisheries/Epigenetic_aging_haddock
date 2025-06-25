#!/bin/bash
#SBATCH --error=output/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=23:00:00
#SBATCH --job-name=genomeprep_ecoli
#SBATCH --mem=100GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

module load bismark/0.22.2
module load bowtie/2.5.2

bismark_genome_preparation /work/gmgi/Fisheries/reference_genomes/ecoli --verbose --bowtie2
