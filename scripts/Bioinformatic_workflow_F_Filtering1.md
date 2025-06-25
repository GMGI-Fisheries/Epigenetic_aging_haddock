# Filtering Steps #1 

First iteration of filtering steps include filtering for coverage (e.g., 5X, 10X, 20X) and filtering for CpG sites found in all samples. 

## 01. Filter for a specific coverage (10X)

This script is running a loop to filter CpGs for a specified coverage and creating tab files.

Essentially, the loop in this script will take columns 5 (Methylated) and 6 (Unmethylated) positions and keeps that row if it is greater than or equal to 5. This means that we have 5x coverage for this position. This limits our interpretation to 0%, 20%, 40%, 60%, 80%, 100% methylation resolution per position.

Input File: `*_sorted.cov`  
Output File: `10x_sorted.tab`

`13-filter_coverage.sh`: 

```
#!/bin/bash
#SBATCH --error=output/filter_output/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output/filter_output/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --job-name=filter_coverage
#SBATCH --mem=50GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

## set paths 
sorted_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/sorted/sorted_cov"
out="/work/gmgi/Fisheries/epiage/haddock/methylation/filtered/10X_files"

## Filtering for 10X coverage 

for f in ${sorted_dir}/*_sorted.cov
do
  STEM=$(basename "${f}" _sorted.cov)
  cat "${f}" | awk -F $'\t' 'BEGIN {OFS = FS} {if ($5+$6 >= 10) {print $1, $2, $3, $4, $5, $6}}' \
  > ${out}/"${STEM}"_10x_sorted.tab
done

```

`wc -l /work/gmgi/Fisheries/epiage/haddock/methylation/filtered/10X_files/*10x_sorted.tab > 10X_sample_depth2.txt` 

`head 10X_sample_depth2.txt` (with all 140 samples): 

```
   8106281 /work/gmgi/Fisheries/epiage/haddock/methylation/filtered/10X_files/Mae-263_S1_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab
    6772426 /work/gmgi/Fisheries/epiage/haddock/methylation/filtered/10X_files/Mae-265_S1_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab
    7750784 /work/gmgi/Fisheries/epiage/haddock/methylation/filtered/10X_files/Mae-266_S2_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab
    4809095 /work/gmgi/Fisheries/epiage/haddock/methylation/filtered/10X_files/Mae-271_S2_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab
    5480154 /work/gmgi/Fisheries/epiage/haddock/methylation/filtered/10X_files/Mae-274_S3_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab
    2837964 /work/gmgi/Fisheries/epiage/haddock/methylation/filtered/10X_files/Mae-275_S3_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab
    5564938 /work/gmgi/Fisheries/epiage/haddock/methylation/filtered/10X_files/Mae-278_S4_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab
    7364620 /work/gmgi/Fisheries/epiage/haddock/methylation/filtered/10X_files/Mae-281_S5_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab
    8723102 /work/gmgi/Fisheries/epiage/haddock/methylation/filtered/10X_files/Mae-282_S4_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab
    5640348 /work/gmgi/Fisheries/epiage/haddock/methylation/filtered/10X_files/Mae-284_S5_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab
```

## 02. Filter for positions found in 90% of samples

90% of 68 samples = 61.2 so column 4 should be greater than 61 samples.

### Create file that has the list of C's found in 90% of samples

`14a-create_90p_file.sh` 

I used >125 because 90% is right at 126.

```
#!/bin/bash
#SBATCH --error=output/filter_output/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output/filter_output/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --job-name=create_90p_file
#SBATCH --mem=50GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

# load modules
module load bedtools/2.29.0

cd /work/gmgi/Fisheries/epiage/haddock/methylation/filtered

multiIntersectBed -i *.tab > CpG.all.samps.10x_sorted.bed

#cat CpG.all.samps.10x_sorted.bed | awk '$4 > 61' > CpG.filt90.all.samps.10x_sorted.bed 
#cat CpG.all.samps.10x_sorted.bed | awk '$4 == 68' > CpG.filt100.all.samps.10x_sorted.bed 

cat CpG.all.samps.10x_sorted2.bed | awk '$4 > 125' > CpG.filt90.all.samps.10x_sorted2.bed 
cat CpG.all.samps.10x_sorted2.bed | awk '$4 == 140' > CpG.filt100.all.samps.10x_sorted2.bed 
```

Number of sites at each filer (90% and 100%)

68 samples:  
`wc -l CpG.filt90.all.samps.10x_sorted.bed`: 738,562   
`wc -l CpG.filt100.all.samps.10x_sorted.bed`: 132,839   

140 samples:  
`wc -l CpG.filt90.all.samps.10x_sorted2.bed`: 808,924 
`wc -l CpG.filt100.all.samps.10x_sorted2.bed`: 104,685 


### Filter each sample's file to the list found in 90% of samples 

`14b-filter_90p.sh`: 

```
#!/bin/bash
#SBATCH --error=output/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --job-name=filter_90p
#SBATCH --mem=50GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

# load modules
module load bedtools/2.29.0

cd /work/gmgi/Fisheries/epiage/haddock/methylation/filtered

for i in *tab
do
  intersectBed \
  -a ${i} \
  -b CpG.filt90.all.samps.10x_sorted.bed \
  > ${i}_CpG_10x_90p_enrichment.bed
done

for i in *tab
do
  intersectBed \
  -a ${i} \
  -b CpG.filt100.all.samps.10x_sorted.bed \
  > ${i}_CpG_10x_100p_enrichment.bed
done

```

#### confirm this filtering worked 

The output of the command below should have each sample with the same number of sites.

```
wc -l 100p_bedfiles/*100p_enrichment2.bed > 100p_enrichment_sample_size2.txt 
wc -l 90p_bedfiles/*90p_enrichment2.bed > 90p_enrichment_sample_size2.txt
```

`head 100p_enrichment_sample_size2.txt`: 

```
   108411 100p_bedfiles/Mae-263_S1_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab_CpG_10x_100p_enrichment2.bed
   108411 100p_bedfiles/Mae-265_S1_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab_CpG_10x_100p_enrichment2.bed
   108411 100p_bedfiles/Mae-266_S2_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab_CpG_10x_100p_enrichment2.bed
   108411 100p_bedfiles/Mae-271_S2_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab_CpG_10x_100p_enrichment2.bed
   108411 100p_bedfiles/Mae-274_S3_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab_CpG_10x_100p_enrichment2.bed
   108411 100p_bedfiles/Mae-275_S3_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab_CpG_10x_100p_enrichment2.bed
   108411 100p_bedfiles/Mae-278_S4_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab_CpG_10x_100p_enrichment2.bed
   108411 100p_bedfiles/Mae-281_S5_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab_CpG_10x_100p_enrichment2.bed
   108411 100p_bedfiles/Mae-282_S4_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab_CpG_10x_100p_enrichment2.bed
   108411 100p_bedfiles/Mae-284_S5_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab_CpG_10x_100p_enrichment2.bed
```

`head 90p_enrichment_sample_size2.txt`:

```
    813743 90p_bedfiles/Mae-263_S1_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab_CpG_10x_90p_enrichment2.bed
    806298 90p_bedfiles/Mae-265_S1_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab_CpG_10x_90p_enrichment2.bed
    810093 90p_bedfiles/Mae-266_S2_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab_CpG_10x_90p_enrichment2.bed
    771553 90p_bedfiles/Mae-271_S2_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab_CpG_10x_90p_enrichment2.bed
    806551 90p_bedfiles/Mae-274_S3_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab_CpG_10x_90p_enrichment2.bed
    690469 90p_bedfiles/Mae-275_S3_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab_CpG_10x_90p_enrichment2.bed
    804723 90p_bedfiles/Mae-278_S4_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab_CpG_10x_90p_enrichment2.bed
    816508 90p_bedfiles/Mae-281_S5_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab_CpG_10x_90p_enrichment2.bed
    817538 90p_bedfiles/Mae-282_S4_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab_CpG_10x_90p_enrichment2.bed
    786136 90p_bedfiles/Mae-284_S5_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov_10x_sorted.tab_CpG_10x_90p_enrichment2.bed
```
