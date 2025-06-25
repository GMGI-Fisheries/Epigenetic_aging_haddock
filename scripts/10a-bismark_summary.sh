#!/bin/bash
#SBATCH --error=output/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=20:00:00
#SBATCH --job-name=bismark_summary2
#SBATCH --mem=40GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

module load bismark/0.22.2

out="/work/gmgi/Fisheries/epiage/haddock/methylation/summary2"
align_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/aligned2"
dedup_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/deduplicated2"
ext_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/meth_extracted2"

bismark2summary ${align_dir}/*bam -o ${out}/haddock_seqrun2_align
bismark2summary ${dedup_dir}/*bam -o ${out}/haddock_seqrun2_dedup
bismark2summary ${ext_dir}/*splitting_report.txt -o ${out}/haddock_seqrun2_ext
