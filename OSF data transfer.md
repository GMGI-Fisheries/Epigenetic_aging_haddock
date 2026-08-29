# Transferring large file to OSF and NCBI from HPCC 

I'm working on NU's Explorer cluster and want to transfer data to OSF: https://osf.io/jy2pb/overview and NCBI BioProject PRJNA1345711

## OSF transfer 

https://osfclient.readthedocs.io/en/latest/cli-usage.html

#### Create conda environment for osf client 

What worked:

```
$ srun --pty bash

$ conda create -n env_osf python=3.10
$ conda activate env_osf
$ conda install -c conda-forge osfclient
$ osf --version

osf 0.0.5
```

Troubleshooting:

```
########## ATTEMPT 1
$ srun --pty bash

$ module load anaconda3/2024.06
$ conda create -n osfenv -c conda-forge osfclient
$ conda activate osfenv
## conda init error 

source ~/.bashrc
conda activate osfenv

## conda had an old version so trying to download from github instead 
conda deactivate
conda remove -n osfenv osfclient

conda activate osfenv
pip install git+https://github.com/osfclient/osfclient.git --user


############ ATTEMPT 2
$ conda create -n osfclient-env conda-forge::osfclient -y
$ conda activate osfclient-env

$ osf --help
bash: /home/e.strand/.local/bin/osf: /home/e.strand/.conda/envs/osfenv/bin/python3.14: bad interpreter: No such file or directory

$ pip install --force-reinstall osfclient

$ osf --help
bash: /home/e.strand/.local/bin/osf: No such file or directory

$ conda env remove -n osfclient-env

############ ATTEMPT 3
$ conda create -n env_osf python=3.10
$ conda activate env_osf
$ conda install -c conda-forge osfclient
$ osf --version

osf 0.0.5
```

#### Log in and transfer

What worked:

```
## Set login
export OSF_USERNAME='emma_strand@uri.edu'
export OSF_PASSWORD='##Firenze2016!!!'
export OSF_TOKEN='0aJrUCgMk55n6goGtsLeV0CNxCxbeS4c3ox0e3slXFaM0VB2qDINfDcX0zgqmYDF8xk6PS'

$ osf init 
## fill out prompts

## 50 GB max 
for f in /projects/gmgi/Fisheries/epiage/haddock/methylation/deduplicated/Mae-537*txt; do
    osf -p jy2pb upload "$f" remote/deduplicated_bam/$(basename "$f")
done

## alternate IDs b/c it times out otherwise
for f in /projects/gmgi/Fisheries/epiage/haddock/methylation/deduplicated2/Mae-5*txt; do
    osf -p jy2pb upload "$f" remote/deduplicated_bam/$(basename "$f")
done

for f in /projects/gmgi/Fisheries/epiage/haddock/methylation/filtered/*; do
    osf -p jy2pb upload "$f" remote/$(basename "$f")
done

for f in /projects/gmgi/Fisheries/epiage/haddock/SNP/*.vcf; do
    osf -p jy2pb upload "$f" remote/$(basename "$f")
done


### gzipping these
for f in /projects/gmgi/Fisheries/epiage/haddock/methylation/filtered/10X_files/Mae-38*; do
    osf -p jy2pb upload "$f" remote/10X_files/$(basename "$f")
done

for f in /projects/gmgi/Fisheries/epiage/haddock/*.csv; do
    osf -p jy2pb upload "$f" remote/csv_files/$(basename "$f")
done
```

Troubleshooting:

```
# using same interactive node as above

## temp path
$ export PATH=$HOME/.local/bin:$PATH

## confirming osf works
$ osf --version
osf 0.0.5

$ osf login
usage: osf [-h] [-u USERNAME] [-p PROJECT] [-v] {clone,init,fetch,geturl,list,ls,upload,remove,rm} ...
osf: error: argument command: invalid choice: 'login' (choose from clone, init, fetch, geturl, list, ls, upload, remove, rm)

## still running into osf login issue.. 

mkdir -p ~/.config/osfclient
nano ~/.config/osfclient/config

## paste below information into config file (with tokens filled in)
[osf]
token=<YOUR_PERSONAL_ACCESS_TOKEN>
project=<YOUR_PROJECT_ID>

## can also try
export OSF_USERNAME=tokenuser
export OSF_TOKEN=<YOUR_PERSONAL_ACCESS_TOKEN>
export OSF_PROJECT=jy2pb

## This didn't work so deleting everything and starting fresh 
rm -rf ~/.config/osfclient
unset OSF_TOKEN
unset OSF_PROJECT
unset OSF_USERNAME
conda env remove -n osfenv

## testing one file 
$ osf -p jy2pb upload /projects/gmgi/Fisheries/epiage/haddock/methylation/deduplicated/Mae-263_S1_R1_001_val_1_bismark_bt2_pe.deduplicated.bam.genozip remote/Mae-263_S1_R1_001_val_1_bismark_bt2_pe.deduplicated.bam.genozip

## Sending group; too much at once so I did different number groups (Mae-27*)
######## deduplicated bams were too large
for f in /projects/gmgi/Fisheries/epiage/haddock/methylation/deduplicated/Mae-43*; do
    osf -p jy2pb upload "$f" remote/deduplicated_bam/$(basename "$f")
done

## this didn't work
osf -p jy2pb rm '*.bam.genozip'
```

```
## Set login
export OSF_USERNAME='emma_strand@uri.edu'
export OSF_PASSWORD='##Firenze2016!!!'
export OSF_TOKEN='vpktoMBK7bwFdI4GyBKI9mp6hHYWUqhyvlZA7VdUuYTvYiLN6ZgrERDxWtdoNUn4IupaZn'

# list all files for a public project
$ osf -p jy2pb list

$ osf init ## fill out username and project ID
$ osf -p jy2pb -u emma_strand@uri.edu list

$ osf -p jy2pb upload /projects/gmgi/Fisheries/epiage/haddock/methylation/deduplicated/Mae-263_S1_R1_001_val_1_bismark_bt2_pe.deduplicated.bam.genozip remote/Mae-263_S1_R1_001_val_1_bismark_bt2_pe.deduplicated.bam.genozip
```

## NCBI transfer 

8-29-2026 SRA upload:

```
ssh e.strand@xfer.discovery.neu.edu

tmux new -s ncbi_upload

## I originally tried to do this on a node but it wouldn't connect
srun --partition=long --nodes=1 --ntasks=1 --cpus-per-task=1 --mem=40G --time=4-00:00:00 --pty bash

cd /projects/gmgi/Fisheries/epiage/haddock/SRA_upload
ncftp -u subftp ftp-private.ncbi.nlm.nih.gov
## put password from NCBI SRA page here

cd uploads/emstrand96_gmail.com_gEPegZK9
mkdir Haddock_epiage_upload
cd Haddock_epiage_upload

## detach: Ctrl+b then d
## reattach: tmux attach -t ncbi_upload

## the * below only works b/c we used cd to be in the SRA_upload folder already
mput *
```

