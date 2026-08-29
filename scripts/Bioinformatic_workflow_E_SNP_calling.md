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
sorted_dedup="/work/gmgi/Fisheries/epiage/haddock/methylation/sorted/sorted_bam"
output="/work/gmgi/Fisheries/epiage/haddock/SNP"

# Merge Samples with SAMtools
samtools merge ${output}/BS_SNPer_merged2.bam ${sorted_dedup}/*deduplicated.bam_sorted.bam
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

Counting number of lines in vcf file: `wc -l SNP-results2.vcf` (version 1 = 3,681,270; version 2 = 3,880,864).
Counting number of lines in .out file: `wc -l SNP-candidates2.out` (version 1 = 6,918,915; version 2 = 7,140,723).

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
`grep $'C\tT' SNP-results2.vcf  >  CT-SNP2.vcf`  
`wc -l CT-SNP.vcf` 420,362. This file doesn't include the headers that vcf file does so 420,362 potential SNPs in this dataset. 
`wc -l CT-SNP2.vcf` 442,485.  

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
#SBATCH --job-name=bsnsper
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

#### re-doing with cov 500 

```
grep $'C\tT' SNP-results2_v2.vcf  >  CT-SNP_v2.vcf

```

Checking if the file contains one genotype column per individual. This does not so I need to call SNPs from each bam file:

Make file with paths for sorted bam files:

```
sorted_dedup="/projects/gmgi/Fisheries/epiage/haddock/methylation/sorted/sorted_bam"
SNP="/projects/gmgi/Fisheries/epiage/haddock/SNP"
ls -d ${sorted_dedup}/*.bam > ${SNP}/sorted_bam_list
```

#### slurm array for each bam file

`02-SNP_bssnper_individual.sh`

```
#!/bin/bash
#SBATCH --error=output_messages/%x_error.%A_%a
#SBATCH --output=output_messages/%x_output.%A_%a
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --mem=8G
#SBATCH --job-name=BSSNP_individual
#SBATCH --array=1-140

## load Perl
module load perl/5.40.0

## define paths
snp_folder="/projects/gmgi/Fisheries/epiage/haddock/SNP"
bam_list="${snp_folder}/sorted_bam_list"
genome="/projects/gmgi/Fisheries/reference_genomes/Haddock"
outdir="${snp_folder}/individual_vcfs"

mkdir -p "${outdir}"

## get BAM corresponding to this array task
bam=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${bam_list}")

## extract sample name from BAM filename
sample=$(basename "${bam}" .bam)

echo "Processing sample: ${sample}"
echo "BAM: ${bam}"

## run BS-Snper for individual sample
perl /projects/gmgi/packages/BS-Snper-master/BS-Snper.pl "${bam}" \
  --fa "${genome}/Haddock_OLKM01.fasta" \
  --output "${outdir}/${sample}_SNP-candidates.out" \
  --methcg "${outdir}/${sample}_CpG-meth-info.tab" \
  --methchg "${outdir}/${sample}_CHG-meth-info.tab" \
  --methchh "${outdir}/${sample}_CHH-meth-info.tab" \
  --minhetfreq 0.1 \
  --minhomfreq 0.85 \
  --minquali 15 \
  --mincover 10 \
  --maxcover 500 \
  --minread2 2 \
  --errorate 0.02 \
  --mapvalue 20 \
  > "${outdir}/${sample}.vcf" \
  2> "${outdir}/${sample}.BS-Snper.log"
```

```
ls *_sorted.vcf | wc
    140     140    9502 

ls -lh /projects/gmgi/Fisheries/epiage/haddock/SNP/individual_vcfs/*sorted.vcf | head
-rw-rw----+ 1 e.strand gmgi 420M Aug 26 10:33 /projects/gmgi/Fisheries/epiage/haddock/SNP/individual_vcfs/Mae-263_S1_R1_001_val_1_bismark_bt2_pe.deduplicated.bam_sorted.vcf
-rw-rw----+ 1 e.strand gmgi 419M Aug 26 10:32 /projects/gmgi/Fisheries/epiage/haddock/SNP/individual_vcfs/Mae-265_S1_R1_001_val_1_bismark_bt2_pe.deduplicated.bam_sorted.vcf
-rw-rw----+ 1 e.strand gmgi 418M Aug 26 10:33 /projects/gmgi/Fisheries/epiage/haddock/SNP/individual_vcfs/Mae-266_S2_R1_001_val_1_bismark_bt2_pe.deduplicated.bam_sorted.vcf
-rw-rw----+ 1 e.strand gmgi 384M Aug 26 10:29 /projects/gmgi/Fisheries/epiage/haddock/SNP/individual_vcfs/Mae-271_S2_R1_001_val_1_bismark_bt2_pe.deduplicated.bam_sorted.vcf
-rw-rw----+ 1 e.strand gmgi 394M Aug 26 10:30 /projects/gmgi/Fisheries/epiage/haddock/SNP/individual_vcfs/Mae-274_S3_R1_001_val_1_bismark_bt2_pe.deduplicated.bam_sorted.vcf


grep "^#CHROM" Mae-274_S3_R1_001_val_1_bismark_bt2_pe.deduplicated.bam_sorted.vcf | head -n 3
#CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO    FORMAT  /projects/gmgi/Fisheries/epiage/haddock/methylation/sorted/sorted_bam/Mae-274_S3_R1_001_val_1_bismark_bt2_pe.deduplicated.bam_sorted.bam

grep -v "^#" Mae-274_S3_R1_001_val_1_bismark_bt2_pe.deduplicated.bam_sorted.vcf | head -n 10
grep -v "^#" Mae-274_S3_R1_001_val_1_bismark_bt2_pe.deduplicated.bam_sorted.vcf | head -n 10
ENA|OLKM01000001|OLKM01000001.1 993     .       T       C       24      Low     DP=5;ADF=0,0;ADR=3,2;AD=3,2;    GT:DP:ADF:ADR:AD:BSD:BSQ:ALFR   0/1:5:0,0:3,2:3,2:0,4,0,0,0,3,2,0:0,37,0,0,0,37,37,0:0.600,0.400
ENA|OLKM01000001|OLKM01000001.1 1158    .       A       C       6       Low     DP=2;ADF=0,0;ADR=0,2;AD=0,2;    GT:DP:ADF:ADR:AD:BSD:BSQ:ALFR   1/1:2:0,0:0,2:0,2:0,0,0,0,0,0,2,0:0,0,0,0,0,0,37,0:0.000,1.000
ENA|OLKM01000001|OLKM01000001.1 1377    .       C       G       15      PASS    DP=10;ADF=6,2;ADR=2,0;AD=8,2;   GT:DP:ADF:ADR:AD:BSD:BSQ:ALFR   0/1:10:6,2:2,0:8,2:0,0,6,2,0,0,2,0:0,0,37,37,0,0,37,0:0.800,0.200
```


### Filtering SNPs 

Creating conda environment for bcftools that also had bedtools and samtools

```
srun --pty bash 
source /projects/gmgi/miniconda3/bin/activate
conda create -n bcftools -c bioconda -c conda-forge bcftools
conda activate bcftools
conda install -c bioconda -c conda-forge samtools bedtools

samtools --version 
bcftools --version
bedtools --version
### output all present 
```

`03-SNP_filter_biallelic.sh`

```
#!/bin/bash
#SBATCH --error=output_messages/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output_messages/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --job-name=eval_BSSNP
#SBATCH --mem=8GB
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=1

source /projects/gmgi/miniconda3/bin/activate
conda activate bcftools

snp_folder="/projects/gmgi/Fisheries/epiage/haddock/SNP"

vcf="${snp_folder}/v2/SNP-results2_v2.vcf"
biallelic="${snp_folder}/v2/SNP-biallelic_v2.vcf.gz"

## basic SNP count
echo "Total SNP records:"
grep -vc "^#" "${vcf}"

## retain biallelic SNPs only
bcftools view --threads 4 -v snps -m2 -M2 "${vcf}" -Oz -o "${biallelic}"

## index compressed VCF
bcftools index --threads 4 "${biallelic}"

## count retained SNPs
echo "Biallelic SNP records:"
bcftools view -H "${biallelic}" | wc -l
```

`04-SNP_filter_MAF.sh`

```
#!/bin/bash
#SBATCH --error=output_messages/%x_error.%j
#SBATCH --output=output_messages/%x_output.%j
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --time=01:00:00
#SBATCH --mem=4G
#SBATCH --job-name=filter_BSSNP_MAF

source /projects/gmgi/miniconda3/bin/activate
conda activate bcftools

snp_folder="/projects/gmgi/Fisheries/epiage/haddock/SNP"

input_vcf="${snp_folder}/v2/SNP-biallelic_v2.vcf.gz"
output_vcf="${snp_folder}/v2/SNP-biallelic_MAF05_missing10_v2.vcf.gz"

## filter SNPs by minor allele frequency and missingness
## retain SNPs with:
##   minor allele frequency >= 0.05
##   missing genotypes in <= 10% of individuals
bcftools view -q 0.05:minor -i 'F_MISSING<=0.10' "${input_vcf}" -Oz -o "${output_vcf}"

## index the filtered output
bcftools index "${output_vcf}"

## produce SNP count after MAF and missingness filtering
echo "Number of SNPs retained after MAF >= 0.05 and missingness <= 10%:"
bcftools view -H "${output_vcf}" | wc -l
```

`05-SNP_filter_genes.sh`

```
#!/bin/bash
#SBATCH --error=output_messages/%x_error.%j
#SBATCH --output=output_messages/%x_output.%j
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --time=01:00:00
#SBATCH --mem=4G
#SBATCH --job-name=neutral_BSSNP

snp_folder="/projects/gmgi/Fisheries/epiage/haddock/SNP"
genome="/projects/gmgi/Fisheries/reference_genomes/Haddock"
annotation="/projects/gmgi/Fisheries/reference_genomes/Haddock/melAeg_maker.putative_function.domain_added.gff"

input_vcf="${snp_folder}/v2/SNP-biallelic_MAF05_missing10_v2.vcf.gz"
neutral_vcf="${snp_folder}/v2/SNP-neutral_intergenic_v2.vcf.gz"

## create BED file of annotated genes
awk 'BEGIN{OFS="\t"} $3=="gene" {print $1,$4-1,$5}' "${annotation}" > "${snp_folder}/v2/genes.bed"

## create genome index if needed
samtools faidx "${genome}/Haddock_OLKM01.fasta"

## create genome sizes file 
cut -f1,2 "${genome}/Haddock_OLKM01.fasta.fai" > "${snp_folder}/v2/genome.sizes"

## expand gene regions by 5 kb on each side
bedtools slop -i "${snp_folder}/v2/genes.bed" -g "${snp_folder}/v2/genome.sizes" -b 5000 > "${snp_folder}/v2/genes_5kb.bed"

## create intergenic regions at least 5 kb away from genes
bedtools complement -i "${snp_folder}/v2/genes_5kb.bed" -g "${snp_folder}/v2/genome.sizes" > "${snp_folder}/v2/intergenic_5kb.bed"

## retain SNPs within putatively neutral intergenic regions
bcftools view -R "${snp_folder}/v2/intergenic_5kb.bed" "${input_vcf}" -Oz -o "${neutral_vcf}"

## index neutral SNP VCF
bcftools index "${neutral_vcf}"

## count retained SNPs
echo "Number of putatively neutral intergenic SNPs:"
bcftools view -H "${neutral_vcf}" | wc -l
```

### Create conda environment for PLINK 

```
srun --pty bash 
source /projects/gmgi/miniconda3/bin/activate
conda create -n plink -c bioconda -c conda-forge plink
conda activate plink
plink --version
PLINK v1.9.0-b.8 64-bit (22 Oct 2024)
```

`06-plink-pca.sh`

```
#!/bin/bash
#SBATCH --error=output_messages/%x_error.%j
#SBATCH --output=output_messages/%x_output.%j
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --time=01:00:00
#SBATCH --mem=4G
#SBATCH --job-name=PCA_BSSNP

## activate conda environment
source ~/miniforge3/etc/profile.d/conda.sh
conda activate plink

## define paths
snp_folder="/projects/gmgi/Fisheries/epiage/haddock/SNP"

input_vcf="${snp_folder}/v2/SNP-neutral_intergenic_v2.vcf.gz"
plink_prefix="${snp_folder}/v2/haddock_neutral"
pruned_prefix="${snp_folder}/v2/haddock_neutral_pruned"
pca_prefix="${snp_folder}/v2/haddock_neutral_PCA"

## check PLINK version
plink --version

## convert neutral SNP VCF to PLINK binary format
plink --vcf "${input_vcf}" --double-id --allow-extra-chr --make-bed --out "${plink_prefix}"

## LD prune SNPs
## 50 = window of 50 SNPs
## 5 = move window forward 5 SNPs at a time
## 0.2 = remove SNPs with pairwise LD r^2 > 0.2
plink --bfile "${plink_prefix}" --allow-extra-chr --indep-pairwise 50 5 0.2 --out "${plink_prefix}"

## create dataset containing only LD-pruned SNPs
plink --bfile "${plink_prefix}" --allow-extra-chr --extract "${plink_prefix}.prune.in" --make-bed --out "${pruned_prefix}"

## run PCA using LD-pruned putatively neutral SNPs
## calculate first 10 principal components
plink --bfile "${pruned_prefix}" --allow-extra-chr --pca 10 --out "${pca_prefix}"

## report number of SNPs before and after LD pruning
echo "Number of neutral SNPs before LD pruning:"
wc -l < "${plink_prefix}.bim"

echo "Number of neutral SNPs retained after LD pruning:"
wc -l < "${pruned_prefix}.bim"

## report PCA output locations
echo "PCA complete."
echo "Eigenvectors: ${pca_prefix}.eigenvec"
echo "Eigenvalues: ${pca_prefix}.eigenval"
```

Take eigenvec and eigenval to create ggplot PCA 

