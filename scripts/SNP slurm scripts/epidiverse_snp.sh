#!/bin/bash
#SBATCH --error=output_messages/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output_messages/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --job-name=epidiverse_snp
#SBATCH --mem=100GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

## load modules
module load singularity/3.10.3

# nextflow module loaded on NU cluster is v23.10.1
module load nextflow/20.07.1

## set paths 
bam_folders="/work/gmgi/Fisheries/epiage/haddock/methylation/deduplicated"
ref="/work/gmgi/Fisheries/reference_genomes/Haddock/Haddock_OLKM01.fasta"
output="/work/gmgi/Fisheries/epiage/haddock/SNP/results"

NXF_VER=20.07.1 nextflow run epidiverse/snp \
-profile singularity -resume \
--input ${bam_folders} \
--reference ${ref} \
--output ${output} \
--variants \
--clusters \
--coverage 10 \
--take 68
