# Quality assessment of raw WGBS data 

Whole Genome Bisulfite Sequencing data from NovaSeq S4 300 cycle platform (NovaSeq 6000 S4 Reagent Kit v1.5 (300 cycles), catalog number 20028312 from Illumina). DNA Extraction and library preparation laboratory methods can be found in this repository in the 'Epigenetic_aging\protocols and lab work' folder. 

# Create conda environment for all analyses conducted for this project 

**Conda installation for GMGI (only need to complete once)** 

Documentation on using conda on NU Discovery Cluster: https://rc-docs.northeastern.edu/en/latest/software/packagemanagers/conda.html#conda. 

Request node on short partition: `srun --partition=short --nodes=1 --cpus-per-task=1 --pty /bin/bash`
Install miniconda3 module for gmgi/ directory: 

```
wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
sha256sum Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p ../../../../gmgi/miniconda3 
## in command above, miniconda3 can't be created yet, this signals new directory

conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict
```

**Create and activating a conda environment** 

Activate base Miniconda environment: `source ~/../../work/gmgi/miniconda3/bin/activate` (path will be depend on current location)

Create conda environment: `conda create --name haddock_methylation python=3.11`. Type `y` if asked to proceed with the installation. This step takes awhile. Only need to do this once at the start of the project. I'll use this environment for the remainder of my scripts.    
Activate that environment: `conda activate haddock_methylation`

The command line prompt will then include the path and name of environment: `(/<path>/<environment-name>) [<username>@c2001 dirname]$` (e.g., `(haddock_methylation) [e.strand@login-00 scripts]$`) 

**Using conda environment** 

Install packages needed for the following scripts: `conda install multiqc` (takes awhile)   
To list the software packages within a specific environment, use: `conda list --name haddock_methylation`

To deactivate an environment after done running scripts: `conda deactivate`  
To delete a Conda environment and all of its related packages, run: `conda remove -n haddock_methylation --all`  
You can view the environments you’ve created in your home directory by using the following command: `conda env list`


# FastQC and MultiQC on all raw files 

FastQC: https://www.bioinformatics.babraham.ac.uk/projects/fastqc/ (fastqc/0.11.9 on NU)  
MultiQC: https://multiqc.info/ (v1.16)  

### Adding Haddock genome to my folder 

Melanogrammus aeglefinus (haddock): https://www.ebi.ac.uk/ena/browser/view/GCA_900291075 and https://link.springer.com/article/10.1186/s12864-018-4616-y. 

```
## WGS contig information
$ cd /work/gmgi/Fisheries/epiage/haddock
$ wget hftp://ftp.ebi.ac.uk/pub/databases/ena/wgs/public/olk/OLKM01.fasta.gz
```

### Create list of samples 

`ls -d /work/gmgi/Fisheries/epiage/haddock/raw_data/*.gz > rawdata`


## FASTQC Slurm script 

`01-fastqc.sh` (path = /work/gmgi/Fisheries/epiage/haddock/scripts)

*Note from after running - I could have probably decreased the mem GB limit* 

```
#!/bin/bash
#SBATCH --error=fastqc_output/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output_messages/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=23:00:00
#SBATCH --job-name=fastqc
#SBATCH --mem=30GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

module load OpenJDK/19.0.1 ## dependency on NU Discovery cluster 
module load fastqc/0.11.9

raw_path="/work/gmgi/Fisheries/epiage/haddock/raw_data"
dir="/work/gmgi/Fisheries/epiage/haddock/QC/raw_fastqc"

## File name based on rawdata list
mapfile -t FILENAMES < ${raw_path}/rawdata
i=${FILENAMES[$SLURM_ARRAY_TASK_ID]}

## FastQC program
fastqc ${i} --outdir ${dir}
```

To run slurm array = `sbatch --array=0-136 01-fastqc.sh`.

This is going to output *many* error and output files. After job completes, use `cat *output.* > ../fastqc_output.txt` to create one file with all the output and `cat *error.* > ../fastqc_error.txt` to create one file with all of the error message outputs. Use `rm *output.*` and `rm *error.*` to remove all individual files once happy with the output and error txt files. Make sure to keep the periods to distinguish between the created .txt file and individual error/output files. 

Within the `dir` output folder, use `ls *html | wc` to count the number of html output files (1st/2nd column values). This should be equal to the --array range used and the number of raw data files. If not, the script missed some input files so address this before moving on. 

For 136 files (~1.9TB total), this took a couple hours. 

## MULTIQC Slurm script 

`02-multiqc_raw.sh` (path = /work/gmgi/Fisheries/epiage/haddock/scripts)

*Make sure conda environment has been activated and multiqc has been installed in that environment prior to running this script.* 

```
#!/bin/bash
#SBATCH --error=output/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --time=23:00:00
#SBATCH --job-name=multiqc
#SBATCH --mem=30GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

dir="/work/gmgi/Fisheries/epiage/haddock/QC/raw_fastqc/"
multiqc_dir="/work/gmgi/Fisheries/epiage/haddock/QC/multiqc/"

multiqc --interactive ${dir} -o ${multiqc_dir} --filename multiqc_raw.html
```

**Check output of multiqc for any red flags from sequencing. Address these prior to moving onto 03-methylation_calling.**
