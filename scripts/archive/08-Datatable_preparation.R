#!/bin/R

#Set up workspace
getwd() #Display the current working directory
#workingDir = "C:/Users/emmastrand/MyProjects/Epigenetic_aging/"
# working directory will be on RHEL.

#Loading libraries
library(writexl) ## read excel file 
library(readxl) ## read excel file 
library(plyr) ## needs to be loaded before dplyr 
library(dplyr)
library(readr)  # for read_csv()
library(tidyr)  # for unnest()
library(purrr)  # for map(), reduce()
library(janitor) # for clean_names()

## Importing data
## desktop path = data/WGBS/
## RHEL server path = /data/prj/Fisheries/epiage/haddock/methylseq/subset/bismark/merged_cov/10x/
df <- list.files(path="/data/prj/Fisheries/epiage/haddock/methylseq/full/bismark/merged/10x/enriched", 
                 pattern = ".bed", full.names=TRUE) %>% 
  set_names(.) %>% map_dfr(read.table, .id = "sample", header=F)

# removing everything after the first _
## _S for subset
## desktop below 
df$sample <- gsub(pattern = "_.*", replacement = "\\1", df$sample)

# removing the first part of the file path
## desktop path = data/WGBS/
## RHEL server path = /data/prj/Fisheries/epiage/haddock/methylseq/subset/bismark/merged_cov/10x/
df$sample <- gsub(pattern = "/data/prj/Fisheries/epiage/haddock/methylseq/full/bismark/merged/10x/enriched/", 
                  replacement = "\\1", df$sample)

# changing column names
colnames(df) <- c("sample", "scaffold", "start", "stop", "percent.meth", "meth", "unmeth")

# loading metadata
## desktop path = data/WGBS/
## RHEL path = /data/prj/Fisheries/epiage/haddock/metadata/full_finclips_sampling.xlsx
metadata <- read_xlsx("/data/prj/Fisheries/epiage/haddock/metadata/full_finclips_sampling.xlsx") %>% 
  dplyr::select(GMGI_ID, `Length Cm`, `Ind Sex`, AgeRounded, sampling_season) %>%
  dplyr::rename(sample = GMGI_ID)

df <- left_join(df, metadata, by = "sample")

## adds one column for 21994932 x 12
df <- df %>% unite(Loc, c("scaffold", "start"), sep=" ", remove=F)

#Save as R data file / read in R data file for future running
## desktop path = data/WGBS/
## RHEL path = /data/prj/Fisheries/epiage/haddock
save(df, file = "/data/prj/Fisheries/epiage/haddock/df_all_20231220.RData")
