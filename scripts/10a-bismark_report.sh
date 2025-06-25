#!/bin/bash
#SBATCH --error=output/report_output/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output/report_output/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=20:00:00
#SBATCH --job-name=bismark_report
#SBATCH --mem=40GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

module load bismark/0.22.2

# set paths 
out="/work/gmgi/Fisheries/epiage/haddock/methylation/summary2"
align_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/aligned2"
dedup_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/deduplicated2"
ext_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/meth_extracted2"

## set file names 
##### Alignment reports
mapfile -t ALIGN_REPORTS < ${align_dir}/report_alignfiles
a=${ALIGN_REPORTS[$SLURM_ARRAY_TASK_ID]}

##### Deduplicated reports
mapfile -t DEDUP_REPORTS < ${dedup_dir}/report_dedupfiles
d=${DEDUP_REPORTS[$SLURM_ARRAY_TASK_ID]}

##### Meth ext splitting report 
mapfile -t SPLIT_REPORTS < ${ext_dir}/report_splittingfiles
e1=${SPLIT_REPORTS[$SLURM_ARRAY_TASK_ID]}

##### Meth ext splitting report 
mapfile -t MBIAS_REPORTS < ${ext_dir}/report_mbiasfiles
e2=${MBIAS_REPORTS[$SLURM_ARRAY_TASK_ID]}

bismark2report --dir ${out} --alignment_report ${a} --dedup_report ${d} --splitting_report ${e1} --mbias_report ${e2}
