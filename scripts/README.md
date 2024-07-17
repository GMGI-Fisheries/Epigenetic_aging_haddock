# Scripts 

**Contents** 
- `.md` files are in markdown format (easier to read on github.com) either produced from Rmd files or are bioinformatic scripts.    
- `.Rmd` files are the R markdown format (download to use).   
- `.R` files are raw R script files (will not have a corresponding markdown file).  
- Folders are images produced in the .Rmd file that are visualized in the .md file.  

**Scripts used for this project:**   

01. `Metadata` - analyzing sample ID, length, otolith age, consolidating metadata files (Rmarkdown). 
02.  `QC` - Using FastQC and MultiQC to quality control check raw WGBS data (Linux).  
03. `Methylation_calling` - Using nf-core/methylseq to call methylation data for each sample. (3a) fish samples analysis (3b) E.coli spike-in to calculate bisulfite conversion efficiency (Linux).    
04. `File_preparation` - Includes merging R1 and R2 reads and sorting that merged output file (Linux).     
05. `SNP_calling` - Identifying positions that are potential SNPs to be used in filtering later (Linux).   
06. `Filtering1` - Filtering for 10X coverage and removing potential SNPs (Linux).   
07. `Bisulfite_conversion_efficiency` - Calculating bisulfite conversion efficiency based on E.coli genome and spike-in. 

