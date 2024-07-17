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

*After running these scripts, I'm not sure that I actually need the deduplicated or meth ext files? The summary script is run from the align output..* 



## Slurm script 

Within `scripts` folder. Error and output messages will output to `scripts/output_messages/` (make directory for this, `mkdir output_messages`). 

NU Discovery Cluster has a 5 day maximum for scripts so users can either 1.) create a slurm array or 2.) subset samples and run multiple scripts. Slurm is great for creating arrays and samples will run simultaneously. I opted to run multiple scripts with multiple `samplesheet_NU_subset.csv` files for the ease of nextflow nf-core outputs from this pipline rather than running each step individually would be harder to break up.

`methylseq_fullrun1.sh`: 

```
#!/bin/bash
#SBATCH --error=output_messages/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output_messages/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --time=120:00:00
#SBATCH --job-name=methylseq_full
#SBATCH --mem=800GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

cd /work/gmgi/Fisheries/epiage/haddock

# singularity module version 3.10.3
module load singularity/3.10.3

# nextflow module loaded on NU cluster is v23.10.1
module load nextflow/23.10.1

## nextflow pipeline
nextflow -log ./ run nf-core/methylseq -resume \
-profile singularity \
    --max_cpus 24 \
    --input metadata/samplesheet_NU_full.csv \
    --outdir ./results \
    --multiqc_title haddock_fullrun_1 \
    --fasta ./OLKM01.fasta \
    --igenomes_ignore \
    --save_reference \
    --clip_r1 10 \
    --clip_r2 10 \
    --three_prime_clip_r1 10 \
    --three_prime_clip_r2 10 \
    --save_trimmed \
    --cytosine_report \
    --non_directional \
    --relax_mismatches \
    --num_mismatches 0.6
```

`squeue --start -j 41381884` to see when the expected start time is.

#### Array of slurm jobs

Make a list of all sample names: `ls -d directory2/* >> samplename`

Example lines (from another project) to add to sbatch script -- 

```
mapfile -t FILENAMES < samplename

i=${FILENAMES[$SLURM_ARRAY_TASK_ID]}
echo ${i}

#used basename for ease in output file naming
base=$(basename $i .vcf.gz). 
echo ${base}

samtools view ${i} | samtools sort ${base}.vcf -out ${base}.g.vcf

```

Then run as slurm array: `sbatch --array=0-43 script.sh`


#### Notes

In between TrimGalore! and Bismark Align steps, I run into this error: 

```
xxx
```

I can get around this by copying the genome file directly to the `BismarkIndex` folder within the folder listed above. This isn't ideally because the script stops, but the `-resume` flag allows the script to pick up where it left off. 


### Parameters chosen 

#### Explanation 

- `--clip_r1`: (numeric value) Trim bases from the 5' end of read 1 (or single-end reads).  
- `--clip_r2`: (numeric value) Trim bases from the 5' end of read 2 (paired-end only).    
- `--three_prime_clip_r1`: (numeric value) Trim bases from the 3' end of read 1 AFTER adapter/quality trimming.     
- `--three_prime_clip_r2`: (numeric value) Trim bases from the 3' end of read 2 AFTER adapter/quality trimming.    
- `--multiqc_title`: (string) MultiQC report title. Printed as page header, used for filename if not otherwise specified.    
- `--cytosine_report`: (boolean) Output stranded cytosine report, following Bismark's bismark_methylation_extractor step.  
- `--non_directional`: (boolean) Run alignment against all four possible strands.  
- `--relax_mismatches`: (boolean) Turn on to relax stringency for alignment (set allowed penalty with --num_mismatches).    
- `--num_mismatches`: (numeric value) 0.6 will allow a penalty of bp * -0.6 - for 100bp reads (bismark default is 0.2). 

#### Reasoning

- `--clip_r1 10`, `--clip_r2 10`, `--three_prime_clip_r1 10`, and `--three_prime_clip_r2 10` were chosen based on fastqc results and reducing m-bias. I suggest running 3-4 samples through this pipeline with varying values for these flags and analyzing the m-bias output. Ideally, you get rid of the least amount of data while mainaining the highest quality.    
- `--max_cpus 24`: I worked with NU bioinformaticians to optimize the CPU and memory usage. This flag increases the max CPUs set by nextflow default.  
- `--num_mismatches 0.6`: Penalty set on the higher end (compared to 0.2) because the reference genome is from European sample rather than from our sample's geographic region. 


### Script execution details 

To check the efficiency of the script: `seff [insert jobid]`. Use this information to optimize the CPU usage and memory parameters of the script. Example output: 

```
Job ID: 41022943
Cluster: discovery
User/Group: e.strand/users
State: COMPLETED (exit code 0)
Nodes: 1
Cores per node: 48
CPU Utilized: 75-15:55:13
CPU Efficiency: 45.11% of 167-17:21:36 core-walltime
Job Wall-clock time: 3-11:51:42
Memory Utilized: 28.98 GB
Memory Efficiency: 96.58% of 30.00 GB
```

## Output files 

### FastQC 

Output directory: `results/trimgalore/fastqc/` 

FastQC gives general quality metrics about your sequenced reads. It provides information about the quality score distribution across your reads, per base sequence content (%A/T/G/C), adapter contamination and overrepresented sequences. For further reading and documentation see the FastQC help pages: http://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/. 

### TrimGalore!

The nf-core/methylseq pipeline uses TrimGalore! for removal of adapter contamination and trimming of low quality regions. TrimGalore is a wrapper around Cutadapt and runs FastQC after it finishes. http://www.bioinformatics.babraham.ac.uk/projects/trim_galore/

MultiQC reports the percentage of bases removed by Cutadapt in the General Statistics table, along with a line plot showing where reads were trimmed.

Output directory: `results/trim_galore`. Contains FastQ files with quality and adapter trimmed reads for each sample, along with a log file describing the trimming.  
- `sample_val_1.fq.gz`, `sample_val_2.fq.gz`: Trimmed FastQ data, reads 1 and 2. Only saved if `--save_trimmed` has been specified.    
- `logs/sample_val_1.fq.gz_trimming_report.txt`: Trimming report (describes which parameters that were used).  
- `FastQC/sample_val_1_fastqc.zip`: FastQC report for trimmed reads. 

### Alignment 

Bismark and bwa-meth convert all Cytosines contained within the sequenced reads to Thymine in-silico and then align against a three-letter reference genome. This method avoids methylation-specific alignment bias. The alignment produces a BAM file of genomic alignments.

Bismark output directory: `results/bismark_alignments/` Note that bismark can use either use Bowtie2 (default) or HISAT2 as alignment tool and the output file names will not differ between the options.
- `sample.bam`: Aligned reads in BAM format. NB: Only saved if `--save_align_intermeds`, `--skip_deduplication` or `--rrbs` is specified when running the pipeline.    
- `logs/sample_PE_report.txt`: Log file giving summary statistics about alignment.     
- `unmapped/unmapped_reads_1.fq.gz`, `unmapped/unmapped_reads_2.fq.gz`: Unmapped reads in FastQ format. Only saved if `--unmapped` specified when running the pipeline.  

### Deduplication 

This step removes alignments with identical mapping position to avoid technical duplication in the results. Note that it is skipped if `--save_align_intermeds`, `--skip_deduplication` or `--rrbs` is specified when running the pipeline.

Bismark output directory: `results/bismark_deduplicated/`  
- `deduplicated.bam`: BAM file with only unique alignments.  
- `logs/deduplication_report.txt`: Log file giving summary statistics about deduplication. 

### Methylation Extraction

The methylation extractor step takes a BAM file with aligned reads and generates files containing cytosine methylation calls. It produces a few different output formats, described below. Note that the output may vary a little depending on whether you specify `--comprehensive` or `--non_directional` when running the pipeline.

Filename abbreviations stand for the following reference alignment strands:  
- `OT` - original top strand  
- `OB` - original bottom strand  
- `CTOT` - complementary to original top strand  
- `CTOB` - complementary to original bottom strand  

Bismark output directory: `results/bismark_methylation_calls/`:  
- `methylation_calls/XXX_context_sample.txt.gz`: Individual methylation calls, sorted into files according to cytosine context.   
- `methylation_coverage/sample.bismark.cov.gz`: Coverage text file summarising cytosine methylation values.    
- `bedGraph/sample.bedGraph.gz`: Methylation statuses in bedGraph format, with 0-based genomic start and 1- based end coordinates.  
- `m-bias/sample.M-bias.txt`: QC data showing methylation bias across read lengths. See the bismark documentation for more information.  
- `logs/sample_splitting_report.txt`: Log file giving summary statistics about methylation extraction.  

### Bismark Reports

Bismark generates a HTML reports describing results for each sample, as well as a summary report for the whole run.

Output directory: `results/bismark_reports`  
Output directory: `results/bismark_summary`

### Qualimap

Qualimap BamQC is a general-use quality-control tool that generates a number of statistics about aligned BAM files. It’s not specific to bisulfite data, but it produces several useful stats - for example, insert size and coverage statistics. http://qualimap.bioinfo.cipf.es/doc_html/analysis.html#bam-qc 

Output directory: `results/qualimap`  
- `sample/qualimapReport.html`: Qualimap HTML report  
- `sample/genome_results.txt`, `sample/raw_data_qualimapReport/*.txt`: Text-based statistics that can be loaded into downstream programs. 

### Preseq

Preseq estimates the complexity of a library, showing how many additional unique reads are sequenced for increasing the total read count. A shallow curve indicates that the library has reached complexity saturation and further sequencing would likely not add further unique reads. The dashed line shows a perfectly complex library where total reads = unique reads. http://smithlabresearch.org/software/preseq/. Note that these are predictive numbers only, not absolute. The MultiQC plot can sometimes give extreme sequencing depth on the X axis - click and drag from the left side of the plot to zoom in on more realistic numbers.

Output directory: `results/preseq`:
- `sample_ccurve.txt`: This file contains plot values for the complexity curve, plotted in the MultiQC report. 

### Multiqc 

`multiqc/`:  
- `multiqc_report.html`: a standalone HTML file that can be viewed in your web browser.  
- `multiqc_data/`: directory containing parsed statistics from the different tools used in the pipeline.  
- `multiqc_plots/`: directory containing static images from the report in various formats.   

### Pipeline Information

`pipeline_info/`:  
- Reports generated by Nextflow: `execution_report.html`, `execution_timeline.html`, `execution_trace.txt` and `pipeline_dag.dot/pipeline_dag.svg`.  
- Reports generated by the pipeline: `pipeline_report.html`, `pipeline_report.txt` and `software_versions.yml`. The pipeline_report* files will only be present if the `--email` / `--email_on_fail` parameter’s are used when running the pipeline.  
- Reformatted samplesheet files used as input to the pipeline: `samplesheet.valid.csv`.  
- Parameters used by the pipeline run: `params.json`.




