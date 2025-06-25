# DNA methylation calling

This script is modeled after the nf-core methylseq pipeline (https://nf-co.re/methylseq/2.6.0). Northeastern's Discovery Cluster (https://rc-docs.northeastern.edu/en/latest/welcome/index.html) works with a 5-day limit for slurm scripts so it's most efficient to run steps in slurm arrays, which nextflow/nf-core pipeline is not compatible with. I prefer nf-core/methylseq because of the organization, reproducibility, and reports that are produced from the pipeline. Compared to running each step individually.

### Pipeline overview 

The pipeline is built using Nextflow and processes data using the following steps. The most recent version of each step's corresponding package dependency is loaded by nf-core methylseq pipeline. Within the script, the only modules to call are Singularity and Nextflow.   
- FastQC - Raw read QC (also in script 02-FastQC.md)   
- TrimGalore - Adapter trimming  
- Bismark Genome Preparation - Bisulfite converting reference genome  
- Bismark Alignment - Aligning reads to reference genome  
- Bismark Deduplication - Deduplicating reads  
- Bismark Methylation Extraction - Calling cytosine methylation steps  
- Bismark Merge - Merging R1 and R2 strands for each sample  
- Bismark Reports - Single-sample and summary analysis reports  
- Qualimap - Tool for genome alignments QC  
- Preseq - Tool for estimating sample complexity   
- MultiQC - Aggregate report describing results and QC from the whole pipeline  
- Pipeline information - Report metrics generated during the workflow execution   

### Installing packages on conda 

No packages to install in conda environment, bismark and bowtie are loaded as modules on Northeastern's Discovery Cluster. 

## Bismark Genome Preparation 

The Haddock genome needs to be bisulfite converted and will live in this directory - `/work/gmgi/Fisheries/reference_genomes/Haddock`. `bismark_genome_preparation` expects a .fasta (Haddock_OLKM01.fasta) file to be within that folder. So path is to a folder not file. The following parameters and script took 7 minutes. 

`05-genomeprep_ecoli.sh` (path = /work/gmgi/Fisheries/epiage/haddock/scripts)

```
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
```

## Bismark Align

Creating filename of trimmed fastqc files using `ls -d /work/gmgi/Fisheries/epiage/haddock/trimmed_data/*R1*.gz > trimmed_R1_files`. This will be used for filename inputs.

`06-bismark_align_ecoli.sh` (path = /work/gmgi/Fisheries/epiage/haddock/scripts)

```
#!/bin/bash
#SBATCH --error=align_output_ecoli/"%x_error.%a" #if your job fails, the error report will be put in this file
#SBATCH --output=align_output_ecoli/"%x_output.%a" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --time=120:00:00
#SBATCH --job-name=align_ecoli
#SBATCH --mem=75GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

module load bismark/0.22.2
module load bowtie/2.5.2
module load samtools/1.9

## Set paths
genome_folder="/work/gmgi/Fisheries/reference_genomes/ecoli"
trimmed_path="/work/gmgi/Fisheries/epiage/haddock/trimmed_data"
out_dir="/work/gmgi/Fisheries/epiage/haddock/conversion_eff/aligned"

## File name based on R1 list
mapfile -t FILENAMES < ${trimmed_path}/trimmed_R1_files
FQ1=${FILENAMES[$SLURM_ARRAY_TASK_ID]}
FQ2=$(echo $FQ1 | sed 's/R1/R2/' | sed 's/val_1/val_2/')

cd /work/gmgi/Fisheries/epiage/haddock/conversion_eff/aligned

## Bismark align
bismark \
-o ${out_dir} \
--bowtie2 \
-genome ${genome_folder} \
-score_min L,0,-0.6 \
--non_directional \
-1 ${FQ1} \
-2 ${FQ2}

```

To run slurm array = `sbatch --array=0-67 06-bismark_align_ecoli.sh`.

## Bismark Deduplicate

Creating filename of bam files using `ls -d /work/gmgi/Fisheries/epiage/haddock/conversion_eff/aligned/*.bam > bamfiles_ecoli`. This will be used for filename inputs.

`07-bismark_deduplicate_ecoli.sh`: 

```
#!/bin/bash
#SBATCH --error=dedup_output_ecoli/"%x_error.%a" #if your job fails, the error report will be put in this file
#SBATCH --output=dedup_output_ecoli/"%x_output.%a" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --time=40:00:00
#SBATCH --job-name=deduplicate_ecoli
#SBATCH --mem=30GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

module load bismark/0.24.2
module load samtools/1.9

## Set paths
align_dir="/work/gmgi/Fisheries/epiage/haddock/conversion_eff/aligned"

## File name based on align_list list
mapfile -t FILENAMES < ${align_dir}/bamfiles
i=${FILENAMES[$SLURM_ARRAY_TASK_ID]}

## Bismark Deduplicate
cd /work/gmgi/Fisheries/epiage/haddock/conversion_eff/deduplicated

deduplicate_bismark --bam --paired ${i}

```

To run slurm array = `sbatch --array=0-67 07-bismark_deduplicate_ecoli.sh`.

Notes:  
- Check output of FILESNAMES list: `echo ${FILENAMES[0]}` for individual file, `echo ${FILENAMES[@]}` for list of files

## Methylation Extractor 

Creating filename of bam files using `ls -d /work/gmgi/Fisheries/epiage/haddock/conversion_eff/deduplicated/*deduplicated.bam > deduplicated_bamfiles_ecoli`. This will be used for filename inputs.

`08-bismark_extractor_ecoli.sh`: 

```
#!/bin/bash
#SBATCH --error=output/extract_output_ecoli/"%x_error.%a" #if your job fails, the error report will be put in this file
#SBATCH --output=output/extract_output_ecoli/"%x_output.%a" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=20:00:00
#SBATCH --job-name=methylation_extractor_ecoli
#SBATCH --mem=10GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

module load bismark/0.24.2
module load samtools/1.9

## Set paths
dedup_dir="/work/gmgi/Fisheries/epiage/haddock/conversion_eff/deduplicated"

## File name based on rawdata list
mapfile -t FILENAMES < ${dedup_dir}/deduplicated_bamfiles_ecoli
i=${FILENAMES[$SLURM_ARRAY_TASK_ID]}

cd /work/gmgi/Fisheries/epiage/haddock/conversion_eff/meth_extracted/

bismark_methylation_extractor --bedGraph --paired --counts --scaffolds --report ${i}
```

To run slurm array = `sbatch --array=0-67 08-bismark_extractor_ecoli.sh`.


## Bismark summary 

`10a-bismark_summary_ecoli.sh`

```
cd /work/gmgi/Fisheries/epiage/haddock/methylation/conversion_eff/aligned"

bismark2summary ./*bam -o ecoli_seqrun1_align

mv ecoli_seqrun1_align* ../summary
```

## MultiQC Bismark Reports, Qualimap, and Preseq 

Load conda environment with multiqc package.

- `source ~/../../work/gmgi/miniconda3/bin/activate`  
- `conda activate haddock_methylation`

```
cd /work/gmgi/Fisheries/epiage/haddock/methylation/meth_extracted/ 

multiqc . --interactive --filename meth_extract_multiqc_report2.html

cd /work/gmgi/Fisheries/epiage/haddock/methylation/deduplicated/ 

multiqc . --interactive --filename deduplicated_multiqc_report2.html

cd /work/gmgi/Fisheries/epiage/haddock/methylation/aligned/ 

multiqc . --interactive --filename aligned_multiqc_report2.html
```