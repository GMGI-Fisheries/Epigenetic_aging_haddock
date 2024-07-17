# Quality assessment of raw WGBS data 

Whole Genome Bisulfite Sequencing data from NovaSeq S4 300 cycle platform (NovaSeq 6000 S4 Reagent Kit v1.5 (300 cycles), catalog number 20028312 from Illumina). DNA Extraction and library preparation laboratory methods can be found in this repository in the 'Epigenetic_aging\protocols and lab work' folder. 

# TrimGalore!, FastQC, and MultiQC on all raw files 

FastQC: https://www.bioinformatics.babraham.ac.uk/projects/fastqc/ (fastqc/0.11.9 on NU)  
MultiQC: https://multiqc.info/ (v1.16)  
TrimGalore!: https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/ 

### List of R1 files 

`ls -d /work/gmgi/Fisheries/epiage/haddock/raw_data/*R1*.gz > R1_files` to create a list of files with R1 in the name to be used in the TrimGalore script below.

### Installing packages on conda 

Cutadapt requires python 2.7 so we need to create a different conda environment than `haddock_methylation` (3.11). If already in `haddock_methylation`, use `conda deactivate` to exit out of that environment. 

Create a new environment: `conda create --name trimgalore python=2.7`  
Activate that environment: `conda activate trimgalore`

Install cutadapt: `conda install cutadapt`.

## TrimGalore! Slurm script 

TrimGalore and fastqc are modules on NU Discovery Cluster and cutadapt is downloaded in the conda environment created above (thus, does not need to be loaded as a module). Running in parallel is not supported on Python 2 which is the miniconda version that supports cutadapt.

`03-TrimGalore.sh` (path = /work/gmgi/Fisheries/epiage/haddock/scripts)

```
#!/bin/bash
#SBATCH --error=output/trimgalore/"%x_error.%a" #if your job fails, the error report will be put in this file
#SBATCH --output=output/trimgalore/"%x_output.%a" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --job-name=trimgalore
#SBATCH --mem=1GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

module load OpenJDK/19.0.1 ## dependency on NU Discovery cluster 
module load fastqc/0.11.9
module load trimgalore/0.6.5

## Set paths
raw_path="/work/gmgi/Fisheries/epiage/haddock/raw_data"
out="/work/gmgi/Fisheries/epiage/haddock/trimmed_data/"

## File name based on R1 list
mapfile -t FILENAMES < ${raw_path}/R1_files
FQ1=${FILENAMES[$SLURM_ARRAY_TASK_ID]}
FQ2=$(echo $FQ1 | sed 's/R1/R2/')

## TrimGalore! program
trim_galore \
    --output_dir ${out} \
    --fastqc \
    --clip_r1 10 --clip_r2 10 \
    --three_prime_clip_r1 10 --three_prime_clip_r2 10 \
    --paired \
    --gzip \
    --illumina \
    ${FQ1} ${FQ2}
```

To run slurm array = `sbatch --array=0-68 03-TrimGalore.sh`.

This is going to output *many* error and output files. After job completes, use `cat *output.* > ../TrimGalore_output.txt` to create one file with all the output and `cat *error.* > ../TrimGalore_error.txt` to create one file with all of the error message outputs. Use `rm *output.*` and `rm *error.*` to remove all individual files once happy with the output and error txt files. Make sure to keep the periods to distinguish between the created .txt file and individual error/output files. 

Within the `dir` output folder, use `ls *html | wc` to count the number of html output files (1st/2nd column values). This should be equal to the --array range used and the number of raw data files. If not, the script missed some input files so address this before moving on. Can also use `wc -l TrimGalore_output.txt` and the output should be 136 for this project. 

Alternate method: I made a directory within the output folder for the trimgalore outputs.

For 136 files (~1.9TB total). Each sample takes about ~1-2 hours (but these are run simultaneously so this will take well under 24 hours to finish all 70 samples, maybe ~8-10 hours depending on the jobs running on NU). 

Move fastq files to proper directory: `mv trimmed_data/*html /work/gmgi/Fisheries/epiage/haddock/QC/trimmed_fastqc` and `mv trimmed_data/*zip /work/gmgi/Fisheries/epiage/haddock/QC/trimmed_fastqc`. This is my preference for repository organization. 

`seff [jobid]` to see efficiency of job (to then decide the # GB allocated, time, etc.). 

## MULTIQC Slurm script 

Activate conda package: `source ~/../../work/gmgi/miniconda3/bin/activate`

Deactivate `trimgalore` conda environment: `conda deactivate` and re-enter haddock methylation environment: `conda activate haddock_methylation`. MultiQC is already downloaded on this environment and the python version is more updated. 

Moving data to QC/trimmed_fastqc (my organizational preference).   
- `mv *fastqc.zip ../QC/trimmed_fastqc/`  
- `mv *html ../QC/trimmed_fastqc/`  
- `mv *txt ../QC/trimmed_fastqc/` 

`04-multiqc_trimmed.sh` (path = /work/gmgi/Fisheries/epiage/haddock/scripts)

```
#!/bin/bash
#SBATCH --error=output/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=23:00:00
#SBATCH --job-name=multiqc_trimmed
#SBATCH --mem=10GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

dir="/work/gmgi/Fisheries/epiage/haddock/QC/trimmed_fastqc/"
multiqc_dir="/work/gmgi/Fisheries/epiage/haddock/QC/multiqc"

multiqc --interactive ${dir} --filename ${multiqc_dir}/multiqc_trimmed.html
```

**Check output of multiqc for any red flags from sequencing. Address these prior to moving onto 03-methylation_calling.**

