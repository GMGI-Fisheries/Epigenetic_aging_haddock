# DNA methylation calling

I'm using the nf-core methylseq pipeline (https://nf-co.re/methylseq/2.6.0) on Northeastern's Discovery Cluster (https://rc-docs.northeastern.edu/en/latest/welcome/index.html). Nf-core methylseq pipeline has great documentation for parameter usage. See `03a-Methylation_calling_samples` for details and sample sheet. 
 
## Download E. coli genome 

Escherichia coli str. K_12 substr. MG1655 (Genome assembly ASM584v2) from Riley et al., 2006: https://academic.oup.com/nar/article/34/1/1/2401490#38767936. GenBank: https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000005845.2/. 

`wget https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/GCF_000005845.2`. 

## Methylseq slurm script  

Within `scripts` folder. Error and output messages will output to `scripts/output_messages/` (make directory for this, `mkdir output_messages`).  

`methylseq_ecoli.sh`: 

```
#!/bin/bash
#SBATCH --error=output_messages/"%x_error.%j" #if your job fails, the error report will be put in this file
#SBATCH --output=output_messages/"%x_output.%j" #once your job is completed, any final job report comments will be put in this file
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --time=120:00:00
#SBATCH --job-name=methylseq_ecoli
#SBATCH --mem=60GB
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2

cd /work/gmgi/Fisheries/epiage/haddock

# singularity module version 3.10.3
module load singularity/3.10.3

# nextflow module loaded on NU cluster is v23.10.1
module load nextflow/23.10.1

nextflow -log ./ run nf-core/methylseq -resume \
-profile singularity \
    --max_cpus 24 \
    --input metadata/samplesheet_NU_full.csv \
    --outdir ./ecoli_results \
    --multiqc_title ecoli \
    --fasta /work/gmgi/Fisheries/epiage/ecoli_genome/GCF_000005845.2_ASM584v2_genomic.fna \
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

## Extract conversion efficiency 

`results/bismark/summary/bismark_summary_report.txt` will have methylated CHH and unmethylated CHH information. Export this file to data folder. 

#### Notes

In between TrimGalore! and Bismark Align steps, I run into this error: 

```
ERROR ~ Error executing process > 'NFCORE_METHYLSEQ:METHYLSEQ:PREPARE_GENOME:BISMARK_GENOMEPREPARATION (BismarkIndex/GCF_000005845.2_ASM584v2_genomic.fna)'
Caused by:
  Process `NFCORE_METHYLSEQ:METHYLSEQ:PREPARE_GENOME:BISMARK_GENOMEPREPARATION (BismarkIndex/GCF_000005845.2_ASM584v2_genomic.fna)` terminated with an error exit status (255)

Command error:
  Writing bisulfite genomes out into a single MFA (multi FastA) file
  
  The specified genome folder BismarkIndex/ does not contain any sequence files in FastA format (with .fa, .fa.gz, .fasta or .fasta.gz file extensions)
Work dir:
  /work/gmgi/Fisheries/epiage/haddock/work/6a/64c5be29277b4dfafb1e46521f4458
```

I can get around this by copying the genome file directly to the `BismarkIndex` folder within the folder listed above. This isn't ideally because the script stops, but the `-resume` flag allows the script to pick up where it left off. 


