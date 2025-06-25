### Data pruning and filtering 

## restart R under 'Sesson' to clear packages and start fresh

## clear environment 
rm(list=ls())
## unloading packages
# invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE,unload=TRUE))

## load packages
library(purrr)
library(cli) ##dependency for following packages; load to get the correct version
library(vctrs) ##dependency for following packages;  load to get the correct version
library(plyr) ## for data transformation
library(dplyr) ## for data transformation
library(stringi)
library(caret) #loads ggplot2 and lattice; needed for nearZeroVar() and findCorrelation()
library(tidyverse) ## for data transformation

## Load data 
load("/work/gmgi/Fisheries/epiage/haddock/RData_Round2/df_all2.RData")
load("/work/gmgi/Fisheries/epiage/haddock/RData_Round2/df100_all2.RData")

##### 1. Removing sites with low variance
df_spread <- df %>% dplyr::select(sample, AgeRounded, Loc, percent.meth) %>% spread(Loc, percent.meth)
df100_spread <- df100 %>% dplyr::select(sample, AgeRounded, Loc, percent.meth) %>% spread(Loc, percent.meth)

nzv.cpg.list <- nearZeroVar(df_spread, freqCut = 85/15, uniqueCut = 50, allowParallel = TRUE) 
df_spread_filteredDescr <- df_spread[, -nzv.cpg.list]

nzv.cpg.list100 <- nearZeroVar(df100_spread, freqCut = 85/15, uniqueCut = 50, allowParallel = TRUE) 
df100_spread_filteredDescr <- df100_spread[, -nzv.cpg.list100]

df_filtered1 <- df_spread_filteredDescr %>% gather("Loc", "percent.meth", 3:643793)
df100_filtered1 <- df100_spread_filteredDescr %>% gather("Loc", "percent.meth", 3:106772)

length(unique(df_filtered1$Loc))
length(unique(df100_filtered1$Loc))

### Results for 68 samples round 1
# 100% presence = 137,694 loci filtered to 130,904 loci (6,788 loci removed)
# 90% presence = 755,564 loci filtered to 600,248 loci (155,314 loci removed)

### Results for 140 samples round 2
# 100% presence = 108,411 loci filtered to 106,770 loci (  loci removed)
# 90% presence = 813,743 loci filtered to 643,791 loci (175,952 loci removed)

##### 2. Removing potential SNPs 
## currently based on BS Snper 
## https://gatk.broadinstitute.org/hc/en-us/articles/360035531692-VCF-Variant-Call-Format

SNP_list <- read.delim2("/work/gmgi/Fisheries/epiage/haddock/SNP/CT-SNP2.vcf", header=FALSE, 
                        col.names = c("chrom", "position", "ID", "REF", "ALT", "QUAL", "FILT", "SITE_INFO", "FORMAT", "SAMPLE_INFO")) %>%
  unite(Loc, chrom, position, sep = " ", remove=F)

df_filtered2 <- df_filtered1 %>% anti_join(SNP_list, by = "Loc")
df100_filtered2 <- df100_filtered1 %>% anti_join(SNP_list, by = "Loc")

#Save as R data file / read in R data file for future running
save(df_filtered2, file = "/work/gmgi/Fisheries/epiage/haddock/RData_Round2/seq2_df_filtered2.RData")
save(df100_filtered2, file = "/work/gmgi/Fisheries/epiage/haddock/RData_Round2/seq2_df100_filtered2.RData")

length(unique(df_filtered2$Loc))
length(unique(df100_filtered2$Loc))

### Results for 68 samples round 1
# 100% presence = 130,904 loci filtered to 130,843 loci
# 90% presence = 600,248 loci filtered to 599,952 loci

### Results for 140 samples round 2
# 100% presence = 106,770 loci filtered to 106,718 loci
# 90% presence = 643,791 loci filtered to 643,483 loci

##### 3. Filtering out loci that are <10% in all samples 

## Load data 
load("/work/gmgi/Fisheries/epiage/haddock/RData_Round2/seq2_df_filtered2.RData")
load("/work/gmgi/Fisheries/epiage/haddock/RData_Round2/seq2_df100_filtered2.RData")

df_filtered3 <- df_filtered2 %>% group_by(Loc) %>%
  filter(!all(percent.meth < 10)) %>% ungroup()

df100_filtered3 <- df100_filtered2 %>% group_by(Loc) %>%
  filter(!all(percent.meth < 10)) %>% ungroup()

length(unique(df_filtered3$Loc))
length(unique(df100_filtered3$Loc))

### Results after taking out loci where all samples <10% for 68 samples round 1 
# 100% presence = 130,843 loci filtered to 130,230 loci
# 90% presence = 599,952 loci filtered to 599,320 loci

### Results after taking out loci where all samples <10% for 140 samples round 2
# 100% presence = 106,718 loci filtered to 106,342 loci
# 90% presence = 643,483 loci filtered to 643,090 loci

##### 4. Filtering out loci that have a range of <10% change 

df_filtered4 <- df_filtered3 %>% group_by(Loc) %>%
  filter(max(percent.meth, na.rm = TRUE) - min(percent.meth, na.rm = TRUE) > 10) %>% ungroup()

df100_filtered4 <- df100_filtered3 %>% group_by(Loc) %>%
  filter(max(percent.meth, na.rm = TRUE) - min(percent.meth, na.rm = TRUE) > 10) %>% ungroup()

length(unique(df_filtered4$Loc))
length(unique(df100_filtered4$Loc))
 
### Results for 68 samples round 1 
# 100% presence = 130,230 loci filtered to 128,981 loci
# 90% presence = 599,320 loci filtered to 598,064 loci

### Results for 140 samples round 2
# 100% presence = 106,342 loci filtered to 105,602 loci
# 90% presence = 643,090 loci filtered to 642,346 loci

##### 5. Removing sites that are highly correlated to each other

df_filtered4_matrix <- df_filtered4 %>% 
  ## replace NAs with mean value 
  group_by(Loc) %>%
  mutate(across(where(is.numeric), ~ ifelse(is.na(.), mean(., na.rm = TRUE), .))) %>% ungroup() %>%
  ## create matrix 
  spread(Loc, percent.meth) %>%
  column_to_rownames(var = "sample") %>% dplyr::select(-AgeRounded)

df100_filtered4_matrix <- df100_filtered4 %>% spread(Loc, percent.meth) %>%
  column_to_rownames(var = "sample") %>% dplyr::select(-AgeRounded)

# library(foreach)
# library(doParallel)
# 
# cores <- detectCores()
# registerDoParallel(cores)
# 
# n <- ncol(df_filtered4_matrix)
# chunk_size <- 1000  # Adjust based on your system's memory
# 
# correlation_matrix <- foreach(i = 1:ceiling(n/chunk_size), .combine = rbind) %dopar% {
#   start <- (i-1)*chunk_size + 1
#   end <- min(i*chunk_size, n)
#   cor(df_filtered4_matrix[,start:end], df_filtered4_matrix)
# }


library(propagate)
correlation_matrix <- bigcor(df_filtered4_matrix, size = 1000)


highlyCorDescr <- findCorrelation(df_filtered4_matrix, cutoff = 0.95, verbose=TRUE)  
highlyCorDescr100 <- findCorrelation(df100_filtered4_matrix, cutoff = 0.95, exact = TRUE) 

df_filtered4_spread <- df_filtered4 %>% spread(Loc, percent.meth) %>% 
  column_to_rownames(var = "sample") %>% dplyr::select(-AgeRounded)
df100_filtered4_spread <- df100_filtered4 %>% spread(Loc, percent.meth) %>% 
  column_to_rownames(var = "sample") %>% dplyr::select(-AgeRounded)

df_filtered5 <- df_filtered4_spread[,-highlyCorDescr]
df_filtered5 <- df_filtered5 %>% gather("Loc", "percent.meth", 1:11388) %>% dplyr::select(Loc) %>% distinct() %>%
  left_join(., df_filtered4, by = "Loc")

df100_filtered5 <- df100_filtered4_spread[,-highlyCorDescr100]
df100_filtered5 <- df100_filtered5 %>% gather("Loc", "percent.meth", 1:1260) %>% dplyr::select(Loc) %>% distinct() %>%
  left_join(., df100_filtered4, by = "Loc")

### Results after taking out loci that are highly correlated with each other  
# 100% presence = 128,981 loci filtered to  loci
# 90% presence = 598,064 loci filtered to 11,388 loci

## Export Rdata
#Save as R data file / read in R data file for future running

### df filtered 4 without removing highly correlated - feed into elastic net model
### 90% present = 598,064 loci 
### 100% present = 128,981 loci 
save(df_filtered4, file = "../../work/gmgi/Fisheries/epiage/haddock/RData_Round2/seq2_df_filtered4.RData")
save(df100_filtered4, file = "../../work/gmgi/Fisheries/epiage/haddock/RData_Round2/seq2_df100_filtered4.RData")

### df filtered 5 removing highly correlated - feed into GLM then elastic net model
save(df_filtered5, file = "../../work/gmgi/Fisheries/epiage/haddock/df_filtered5.RData")
save(df100_filtered5, file = "../../work/gmgi/Fisheries/epiage/haddock/df100_filtered5.RData")








