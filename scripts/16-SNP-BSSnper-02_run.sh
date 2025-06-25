#!/bin/bash
#SBATCH --error=output_messages/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output_messages/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --time=120:00:00
#SBATCH --job-name=BSSnper_run
#SBATCH --mem=100GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

## set paths 
snp_folder="/work/gmgi/Fisheries/epiage/haddock/SNP"
genome="/work/gmgi/Fisheries/reference_genomes/Haddock"

perl /work/gmgi/packages/BS-Snper-master/BS-Snper.pl ${snp_folder}/BS_SNPer_merged2.bam \
--fa ${genome}/Haddock_OLKM01.fasta \
--output ${snp_folder}/SNP-candidates2.out \
--methcg ${snp_folder}/CpG-meth-info2.tab \
--methchg ${snp_folder}/CHG-meth-info2.tab \
--methchh ${snp_folder}/CHH-meth-info2.tab \
--minhetfreq 0.1 \
--minhomfreq 0.85 \
--minquali 15 \
--mincover 10 \
--maxcover 1000 \
--minread2 2 \
--errorate 0.02 \
--mapvalue 20 \
> ${snp_folder}/SNP-results2.vcf 2>${snp_folder}/scripts/merged.ERR2.log
