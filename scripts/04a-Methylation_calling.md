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

`05-genomeprep.sh` (path = /work/gmgi/Fisheries/epiage/haddock/scripts)

```
#!/bin/bash
#SBATCH --error=output/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=23:00:00
#SBATCH --job-name=genomeprep
#SBATCH --mem=100GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

module load bismark/0.22.2
module load bowtie/2.5.2

bismark_genome_preparation /work/gmgi/Fisheries/reference_genomes/Haddock --verbose --bowtie2 
```

## Bismark Align

Creating filename of trimmed fastqc files using `ls -d /work/gmgi/Fisheries/epiage/haddock/trimmed_data/*R1*.gz > trimmed_R1_files`. This will be used for filename inputs.

Zymo Pico Methyl-Seq Library Kit is `non-directional`.

`06-bismark_align.sh` (path = /work/gmgi/Fisheries/epiage/haddock/scripts)

```
#!/bin/bash
#SBATCH --error=align_output2/"%x_error.%a" #if your job fails, the error report will be put in this file
#SBATCH --output=align_output2/"%x_output.%a" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --time=120:00:00
#SBATCH --job-name=align
#SBATCH --mem=50GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

module load bismark/0.22.2
module load bowtie/2.5.2
module load samtools/1.9

## Set paths
genome_folder="/work/gmgi/Fisheries/reference_genomes/Haddock"
trimmed_path="/work/gmgi/Fisheries/epiage/haddock/trimmed_data2"
out_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/aligned2/"

## File name based on R1 list
mapfile -t FILENAMES < ${trimmed_path}/trimmed_R1_files
FQ1=${FILENAMES[$SLURM_ARRAY_TASK_ID]}
FQ2=$(echo $FQ1 | sed 's/R1/R2/' | sed 's/val_1/val_2/')

cd /work/gmgi/Fisheries/epiage/haddock/methylation/aligned2/

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

To run slurm array = `sbatch --array=0-68 06-bismark_align.sh` and `sbatch --array=0-71 06-bismark_align.sh`

Check error file of each sample to confirm the align function worked. The bottom of the report will have the total processing time and will say completed.

## Bismark Deduplicate

Creating filename of bam files using `ls -d /work/gmgi/Fisheries/epiage/haddock/methylation/aligned/*.bam > bamfiles`. This will be used for filename inputs.

`07-bismark_deduplicate.sh`: 

```
#!/bin/bash
#SBATCH --error=dedup_output/"%x_error.%a" #if your job fails, the error report will be put in this file
#SBATCH --output=dedup_output/"%x_output.%a" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --time=120:00:00
#SBATCH --job-name=deduplicate
#SBATCH --mem=30GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

module load bismark/0.24.2
module load samtools/1.9

## Set paths
align_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/aligned"

## File name based on align_list list
mapfile -t FILENAMES < ${align_dir}/bamfiles
i=${FILENAMES[$SLURM_ARRAY_TASK_ID]}

## Bismark Deduplicate
cd /work/gmgi/Fisheries/epiage/haddock/methylation/deduplicated

deduplicate_bismark --bam --paired ${i}

```

To run slurm array = `sbatch --array=0-67 07-bismark_deduplicate.sh` and `sbatch --array=0-71 07-bismark_deduplicate.sh`

Notes:  
- Check output of FILESNAMES list: `echo ${FILENAMES[0]}` for individual file, `echo ${FILENAMES[@]}` for list of files

## Methylation Extractor 

Creating filename of bam files using `ls -d /work/gmgi/Fisheries/epiage/haddock/methylation/deduplicated/*deduplicated.bam > deduplicated_bamfiles`. This will be used for filename inputs. *After running this, I could have increased GB to make this go faster.* 

`08-bismark_extractor.sh`: 

```
#!/bin/bash
#SBATCH --error=extract_output/"%x_error.%a" #if your job fails, the error report will be put in this file
#SBATCH --output=extract_output/"%x_output.%a" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --time=120:00:00
#SBATCH --job-name=methylation_extractor
#SBATCH --mem=40GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

module load bismark/0.24.2
module load samtools/1.9

## Set paths
dedup_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/deduplicated"

## File name based on rawdata list
mapfile -t FILENAMES < ${dedup_dir}/deduplicated_bamfiles
i=${FILENAMES[$SLURM_ARRAY_TASK_ID]}

cd /work/gmgi/Fisheries/epiage/haddock/methylation/meth_extracted/

bismark_methylation_extractor --comprehensive --bedGraph --paired --counts --scaffolds --gzip --report ${i}
```

To run slurm array = `sbatch --array=0-67 08-bismark_extractor.sh` and `sbatch --array=0-71 08-bismark_extractor.sh`

## Sort Bam 

Creating filename of bam files using `ls -d /work/gmgi/Fisheries/epiage/haddock/methylation/deduplicated/*deduplicated.bam > deduplicated_bamfiles`. This will be used for filename inputs.

`09-sort_bam.sh`:

```
#!/bin/bash
#SBATCH --error=output/sorted_bam_output/"%x_error.%a" #if your job fails, the error report will be put in this file
#SBATCH --output=output/sorted_bam_output/"%x_output.%a" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --job-name=sort_bam
#SBATCH --mem=25GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

# modules to load 
module load samtools/1.9
module load bedtools/2.29.0

## set paths 
output_sorted="/work/gmgi/Fisheries/epiage/haddock/methylation/sorted"
dedup_path="/work/gmgi/Fisheries/epiage/haddock/methylation/deduplicated"

## sample list 
mapfile -t FILENAMES < ${dedup_path}/deduplicated_bamfiles
i=${FILENAMES[$SLURM_ARRAY_TASK_ID]}

## SORT
samtools sort ${i} -o ${i}_sorted.bam
```

To run slurm array = `sbatch --array=0-67 09-sort_bam.sh` and `sbatch --array=0-71 09-sort_bam.sh`

Move output files to sorted folder. I was having trouble getting the sort function to recognize this. `mv *sorted.bam ../sorted/`. 

## Bismark Reports 

Create list of files from each directory:
- `ls -d /work/gmgi/Fisheries/epiage/haddock/methylation/deduplicated/*report.txt > report_dedupfiles`  (deduplicated)  
- `ls -d /work/gmgi/Fisheries/epiage/haddock/methylation/aligned/*report.txt > report_alignfiles` (aligned)    
- `ls -d /work/gmgi/Fisheries/epiage/haddock/methylation/meth_extracted/*splitting_report.txt > report_splittingfiles` (meth ext)
- `ls -d /work/gmgi/Fisheries/epiage/haddock/methylation/meth_extracted/*M-bias.txt > report_mbiasfiles` (meth ext)  

`10a-bismark_report.sh`

```
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
out="/work/gmgi/Fisheries/epiage/haddock/methylation/summary"
align_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/aligned"
dedup_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/deduplicated"
ext_dir="/work/gmgi/Fisheries/epiage/haddock/methylation/meth_extracted"

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
```

To run slurm array = `sbatch --array=0-67 10a-bismark_report.sh`.

`10a-bismark_summary.sh`

```
#!/bin/bash
#SBATCH --error=output/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=20:00:00
#SBATCH --job-name=bismark_summary
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
```

## PreSeq Reports 

Creating filename of sorted bam files using `ls -d /work/gmgi/Fisheries/epiage/haddock/methylation/sorted/*sorted.bam > sorted_bamfiles`. This will be used for filename inputs.

Preseq is downloaded in conda environment. 

- `source ~/../../work/gmgi/miniconda3/bin/activate`  
- `conda activate haddock_methylation`  

`10b-preseq_report.sh`:

```
#!/bin/bash
#SBATCH --error=output/preseq_output/"%x_error.%a" #if your job fails, the error report will be put in this file
#SBATCH --output=output/preseq_output/"%x_output.%a" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --job-name=preseq
#SBATCH --mem=25GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

# modules to load 
module load samtools/1.9
module load bedtools/2.29.0

## set paths 
output_summary="/work/gmgi/Fisheries/epiage/haddock/methylation/summary"
sorted_path="/work/gmgi/Fisheries/epiage/haddock/methylation/sorted"

## sample list 
mapfile -t FILENAMES < ${sorted_path}/sorted_bamfiles
i=${FILENAMES[$SLURM_ARRAY_TASK_ID]}

## PRESEQ 
preseq lc_extrap -bam -verbose -o ${i}
preseq c_curve -bam -verbose -o ${i}

#mv ${i}_future_yield.txt ${output_summary}/
#mv ${i}__complexity_output.txt ${output_summary}/
```

To run slurm array = `sbatch --array=0-67 10b-preseq_report.sh`.


## Qualimap Reports 

`10c-qualimap_report.sh`:

```
#!/bin/bash
#SBATCH --error=output/qualimap_output/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output/qualimap_output/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --job-name=qualimap
#SBATCH --mem=100GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

## path to qualimap
qualimap_path="/work/gmgi/packages/qualimap_v2.3"

## set paths 
output_summary="/work/gmgi/Fisheries/epiage/haddock/methylation/summary/qualimap"
sorted_path="/work/gmgi/Fisheries/epiage/haddock/methylation/sorted"

## sample list 
mapfile -t FILENAMES < ${sorted_path}/sorted_bamfiles
i=${FILENAMES[$SLURM_ARRAY_TASK_ID]}less

${qualimap_path}/qualimap bamqc -bam ${i} -outdir ${output_summary} 

#${qualimap_path}/qualimap multi-bamqc -d ${i}/*bam -outdir ${output_summary}/

```

To run slurm array = `sbatch --array=0-67 10c-qualimap_report.sh`.


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

The one we care about the most includes m-bias and methylation calling (meth extract). 

# Using genozip .bam files to reduce storage space 

Within conda environment `haddock_methylation`, install `genozip`: `conda install genozip`. 

https://www.genozip.com/installing

Create a genozip reference file for the haddock genome: `$ genozip --make-reference Haddock_OLKM01.fasta`

`$ genozip --threads 4 --reference ../../Haddock_OLKM01.ref.genozip myfile.bam`: To zip file.  
`$ ls -lha myfile.bam*`: To check storage space of all files including hidden files.  
`$ genounzip --threads 4 myfile.bam.genozip`: To uncompress a file.    

This function can be used for .vcf files too. 
