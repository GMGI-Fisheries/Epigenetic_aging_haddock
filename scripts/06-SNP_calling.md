# Identifying SNPs from WGBS output data 

# Epidiverse SNP

I'm trying EpiDiverse's SNP pipeline: https://github.com/EpiDiverse/snp/tree/master. See schematic below for pipeline. 

![](https://github.com/EpiDiverse/snp/raw/master/docs/images/workflow.png)

I'm using aligned bam files from my Bismark workflow in `04-Methylation_calling`. EpiDiverse/SNP requires input files to be in their own folders.

### Prepping genome 

Using samtools to create an index file of the reference genome. Output is `Haddock_OLKM01.fasta.fai`. 

```
cd /work/gmgi/Fisheries/reference_genomes/Haddock
module load samtools/1.9
samtools faidx Haddock_OLKM01.fasta
```

Required: `--reference /work/gmgi/Fisheries/reference_genomes/Haddock`  
> Specify the path to the input reference genome file in fasta format. REQUIRED for the variant calling aspect of the pipeline, along with a corresponding fasta index *.fai file in the same location.

### Prepping sample input 

The pipeline needs the sample input to be '*/{sample_name}/{sample_name}.bam' format. I currently have one folder for all aligned files.

Required:  `--input /work/gmgi/Fisheries/epiage/haddock/SNP/bam_symlinks`
> Specify input path for the directory containing outputs from the WGBS pipeline. The pipeline searches for bam files in '*/{sample_name}/{sample_name}.bam' format.

Goal is to create sym link in folders to SNP that coordinate with each sample name.    
- 1.) Create file with list of sample IDs in R on Discovery Cluster.    
- 2.) Create folder for each entry in that list.  

`create_folders.sh`

```
#!/bin/bash

## CREATE FOLDERS 

## sample list 
mapfile -t FOLDER_NAMES < foldernames.txt
i=${FOLDER_NAMES[$SLURM_ARRAY_TASK_ID]}

mkdir ${i}
```

To run slurm array = `sbatch --array=0-67 create_folders.sh`.

- 3.) Create sym link for each file that matches the folder name: `ln -s [filename] /work/gmgi/Fisheries/epiage/haddock/SNP/bam_symlinks/[folder_name]/`

Use `bamfiles` in `methylation/aligned/` folder.


### Script 

`epidiverse_snp_test.sh`

```
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
module load nextflow/23.10.1

## set paths 
bam_folders="/work/gmgi/Fisheries/epiage/haddock/methylation/deduplicated"
ref="/work/gmgi/Fisheries/reference_genomes/Haddock/Haddock_OLKM01.fasta"
output="/work/gmgi/Fisheries/epiage/haddock/SNP/results"

NXF_VER=20.07.1 nextflow run epidiverse/snp -profile singularity -resume \
--input ${bam_folders} \
--reference ${ref} \
--output ${output} \
--variants \
--clusters \
--coverage 10 \
--take 68


```


# BS Snper 

Download BS Snper: `wget https://github.com/hellbelly/BS-Snper/archive/refs/heads/master.zip` and use `unzip` on the resulting `master.zip` file. I kept this in `/work/gmgi/packages` and the folder is automatically renamed `BS-Snper-master`. Then run `BS-Snper.sh` to fully download all commands and folders that belong in BS-Snper.

Sorted, deduplicated bam files as input (`/work/gmgi/Fisheries/epiage/haddock/methylation/sorted/*deduplicated.bam_sorted.bam`). 

Step 1: Merge bam files `BSSnper-01_mergefile.sh`

```
#!/bin/bash
#SBATCH --error=output_messages/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output_messages/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --job-name=BSSnper_merge
#SBATCH --mem=100GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

# load modules needed
module load samtools/1.19.2

# set paths 
sorted_dedup="/work/gmgi/Fisheries/epiage/haddock/methylation/sorted"
output="/work/gmgi/Fisheries/epiage/haddock/SNP"

# Merge Samples with SAMtools
samtools merge ${output}/BS_SNPer_merged.bam ${sorted_dedup}/*deduplicated.bam_sorted.bam
```

Step 2: `BSSnper-02_run.sh`

```
#!/bin/bash
#SBATCH --error=output_messages/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output_messages/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --job-name=BSSnper_run
#SBATCH --mem=100GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

## set paths 
snp_folder="/work/gmgi/Fisheries/epiage/haddock/SNP"
genome="/work/gmgi/Fisheries/reference_genomes/Haddock"

perl /work/gmgi/packages/BS-Snper-master/BS-Snper.pl ${snp_folder}/BS_SNPer_merged.bam \
--fa ${genome}/Haddock_OLKM01.fasta \
--output ${snp_folder}/SNP-candidates.out \
--methcg ${snp_folder}/CpG-meth-info.tab \
--methchg ${snp_folder}/CHG-meth-info.tab \
--methchh ${snp_folder}/CHH-meth-info.tab \
--minhetfreq 0.1 \
--minhomfreq 0.85 \
--minquali 15 \
--mincover 10 \
--maxcover 1000 \
--minread2 2 \
--errorate 0.02 \
--mapvalue 20 \
> ${snp_folder}/SNP-results.vcf 2>${snp_folder}/merged.ERR.log

```

#### output 

- `SNP-results.vcf`      
- `SNP-candidates.out`  
- `merged.ERR.log`  

Counting number of lines in vcf file: `wc -l SNP-results.vcf` (3,681,270).
Counting number of lines in .out file: `wc -l SNP-candidates.out` (6,918,915).

`.tab` file outputs:  
	1. CHROM: Chromosome.
	2. POS: Sequence context most 5’ position on the Watson strand (1-based).
	3. CONTEXT: Sequence contexts with the SNVs annotated using the IUPAC nucleotide ambiguity code (referred to the Watson strand).
	4. Watson METH: The number of methyl-cytosines (referred to the Watson strand).
	5. Watson COVERAGE: The number of reads covering the cytosine in this sequence context (referred to the Watson strand).
	6. Watson QUAL: Average PHRED score for the reads covering the cytosine (referred to the Watson strand).
	7. Crick METH: The number of methyl-cytosines (referred to the Watson strand).
	8. Crick COVERAGE: The number of reads covering the guanine in this context (referred to the Watson strand).
	9. Crick QUAL: Average PHRED score for the reads covering the guanine (referred to the Watson strand).

Filter for CT SNPs 

`grep $'C\tT' SNP-results.vcf  >  CT-SNP.vcf`  
`wc -l CT-SNP.vcf` 420,362. This file doesn't include the headers that vcf file does so 420,362 potential SNPs in this dataset. 


### old notes 

BS-Snper (https://github.com/hellbelly/BS-Snper) takes deduplciated.bam files from WGBS pipeline (03a-Methylation_calling_samples.md) to identify Single Nucleotide Polymorphisms (SNPs). We want to exclude any potential SNPs from our list of sites used in epigenetic aging models so that we're confident the methylation % change is due to age not population structure. 

## Data preparation

Sort and merge deduplicated bam files with SAMtools (https://www.htslib.org/). 

`SNP_dataprep.sh`

```
#!/bin/bash
#SBATCH --error=output_messages/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output_messages/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --time=40:00:00
#SBATCH --job-name=methylseq_ecoli
#SBATCH --mem=20GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

# load modules needed
module load samtools/1.9

# set paths 
deduplicated_folder="/work/gmgi/Fisheries/epiage/haddock/results/bismark/deduplicated"
sorted_folder="/work/gmgi/Fisheries/epiage/haddock/results/sorted"
SNP_folder="/work/gmgi/Fisheries/epiage/haddock/SNP"

# create for loop for sorting function
for f in ${deduplicated_folder}/*.deduplicated.bam
do
  STEM=$(basename "${f}" _R1_001_val_1_bismark_bt2_pe.deduplicated.bam)
  samtools sort "${f}" \
  -o ${sorted_folder}/"${STEM}".deduplicated_sorted.bam
done

# merging all sorted bams into one file
samtools merge \
    ${SNP_folder}/BS_SNPer_merged.bam \
    ${sorted_folder}/*sorted.bam
```

## BS-Snper

Parameter choices found here: https://github.com/hellbelly/BS-Snper/blob/master/README.txt. 

`SNP_bssnper.sh`:

```
#!/bin/bash
#SBATCH --error=output_messages/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output_messages/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --time=40:00:00
#SBATCH --job-name=methylseq_ecoli
#SBATCH --mem=20GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

# load modules 
module load BS-Snper/xxx

# set paths 
cd /work/gmgi/Fisheries/epiage/haddock/SNP
genome_folder="/work/gmgi/Fisheries/epiage/haddock/"

perl /opt/software/BS-Snper/1.0-foss-2021b/bin/BS-Snper.pl \
    BS_SNPer_merged.bam \
    --fa ${genome_folder}/OLKM01.fasta \ 
    --output SNP-candidates.out \
    --methcg CpG-meth-info.tab \
    --methchg CHG-meth-info.tab \
    --methchh CHH-meth-info.tab \
    --minhetfreq 0.1 \
    --minhomfreq 0.85 \
    --minquali 15 \
    --mincover 10 \
    --maxcover 1000 \
    --minread2 2 \
    --errorate 0.02 \
    --mapvalue 20 \
    >SNP-results.vcf 2>SNP.log
```

This vcf file can go on to answer some population genomics questions as well.



