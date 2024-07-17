# File preparation 

Output files from nf-core methylseq. 

## 01. Bismark: Merge Strands with coverage2cytosine

The file output from the methylseq pipeline that is used for the following steps: `meth_extracted/*deduplicated.bismark.cov.gz`.  

`ls -d /work/gmgi/Fisheries/epiage/haddock/methylation/meth_extracted/*deduplicated.bismark.cov.gz > cov_bamfiles`

The Bismark coverage2cytosine command re-reads the genome-wide report and merges methylation evidence of both top and bottom strand to create one file.

Input: `*deduplicated.bismark.cov.gz`.
Output: `*merged_CpG_evidence.cov`.

### Make a new directory for this output 

`mkdir methylation/merged`

### Create shell script  

`11-merge_strands.sh`

```
#!/bin/bash
#SBATCH --error=output/merge_strands_output/"%x_error.%a" #if your job fails, the error report will be put in this file
#SBATCH --output=output/merge_strands_output/"%x_output.%a" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=20:00:00
#SBATCH --job-name=merge_strands
#SBATCH --mem=50GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

module load bismark/0.24.2
module load samtools/1.9

## Set paths
cov_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/meth_extracted"
genome_folder="/work/gmgi/Fisheries/reference_genomes/Haddock"
output="/work/gmgi/Fisheries/epiage/haddock/methylation/merged"

## File name based on rawdata list
mapfile -t FILENAMES < ${cov_dir}/cov_bamfiles
i=${FILENAMES[$SLURM_ARRAY_TASK_ID]}

cd /work/gmgi/Fisheries/epiage/haddock/methylation/merged

coverage2cytosine --genome_folder ${genome_folder} --merge_CpG --zero_based -o ${i}_merged.cov ${i}
```

To run slurm array = `sbatch --array=0-67 11-merge_strands.sh`.

This worked but the naming got messed and produced extra annotations than I originally intended.. e.g. `Mae-378_S29_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz_merged.cov.CpG_report.merged_CpG_evidence.cov`. 


### Overview 

The script is saying:  
- for every file in `methylation_coverage` repo that ends with `deduplicated.bismark.cov.gz` (there should be 140 for this project),  
- and has basename of `_S0_L001_R1_001_val_1_bismark_bt2_pe.deduplicated.bismark.cov.gz` (everything that comes after the sample ID)    
- perform the function `coverage2cytosine` within the Bismark module  
- identifies where the output genome is located (folder reference_genome/BismarkIndex within methylseq output folder)  
- `--zero_based`: uses 0-based genomic coordinates instead of 1-based coordinates. Default is OFF  
- `-o`: output file names; {} identifies these remain the same  
- `merge_CpG`: write out additional coverage files that has the top and bottom strand methylation evidence pooled into a single CpG dinucleotide entity.  

Help on merge_CpG function: https://github.com/FelixKrueger/Bismark/issues/86.

The output files will look like (without the headers):

| **Scaffold** | **Start Position** | **Stop Position** | **% Methylated** | **Methylated** | **Unmethylated** |
|--------------|--------------------|-------------------|------------------|----------------|------------------|
| 000000F      | 29076              | 29078             | 0.000000         | 0              | 5                |
| 000000F      | 29158              | 29160             | 0.000000         | 0              | 12               |
| 000000F      | 29185              | 29187             | 0.000000         | 0              | 8                |
| 000000F      | 29215              | 29217             | 0.000000         | 0              | 4                |
| 000000F      | 29232              | 29234             | 0.000000         | 0              | 3                |
| 000000F      | 29241              | 29243             | 11.111111        | 1              | 8                |
| 000000F      | 29277              | 29279             | 0.000000         | 0              | 11               |
| 000000F      | 29282              | 29284             | 0.000000         | 0              | 12               |
| 000000F      | 29313              | 29315             | 0.000000         | 0              | 11               |
| 29335        | 29335              | 29337             | 0.000000         | 0              | 10               |

Each CpG dinucleotide will have data for % methylation, and how many times that CpG was methylated or unmethylated.

## 02. Bedtools: Sort files  

This function sorts all the merged files so that all scaffolds are in the same order. This needs to be done for multiIntersectBed to run correctly. This sets up a loop to do this for every sample (file). 

`mkdir methylation/sorted`    

`nano 12-sort_cov.sh`:

```
#!/bin/bash
#SBATCH --error=output/sort_cov/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output/sort_cov/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --time=120:00:00
#SBATCH --job-name=sort_cov
#SBATCH --mem=100GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

# load BEDTools 
module load bismark/0.24.2
module load samtools/1.9
module load bedtools/2.29.0

## Set paths
merged_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/merged"
sorted_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/sorted"

cd ${merged_dir}

for f in ${merged_dir}/*merged_CpG_evidence.cov
do
  STEM=$(basename "${f}" .CpG_report.merged_CpG_evidence.cov)
  bedtools sort -i "${f}" \
  > ${sorted_dir}/"${STEM}"_sorted.cov
done

```

### Overview 

The script is saying:
- For every sample's `.cov` file in the output folder `merged`, use bedtools function to sort and then output a file with the same name plus `_sorted.cov`.

`$ head -2 Mae-298_S10_R1_001_val_1_bismark_bt2_pe._sorted.cov`

```
ENA|OLKM01000001|OLKM01000001.1 795     797     0.000000        0       1
ENA|OLKM01000001|OLKM01000001.1 804     806     0.000000        0       2
```