## Prepping df for GLM analyses 

#Loading libraries
library(writexl) ## read excel file 
library(readxl) ## read excel file 
library(plyr) ## needs to be loaded before dplyr 
library(dplyr)
library(readr)  # for read_csv()
library(tidyr)  # for unnest()
library(purrr)  # for map(), reduce()
library(janitor) # for clean_names()
library(stringr)
library(strex)

## Importing data
## Round 1 (68 samples): 49,005,759 rows
## Round 2 (140 samples): 108,754,911 rows
df <- list.files(path="/work/gmgi/Fisheries/epiage/haddock/methylation/filtered/90p_bedfiles", 
                 pattern = "90p_enrichment2.bed", full.names=TRUE) %>% 
  set_names(.) %>% map_dfr(read.table, .id = "sample", header=F)

# changing column names
colnames(df) <- c("sample", "scaffold", "start", "stop", "percent.meth", "meth", "unmeth")

## Editing sample name 
df <- df %>%
  mutate(sample = str_after_nth(sample, "filtered/90p_bedfiles/", 1),
         sample = str_before_nth(sample, "_", 1))

## adding metadata 
metadata <- read_xlsx("../../work/gmgi/Fisheries/epiage/haddock/metadata/full_finclips_sampling.xlsx") %>% 
  dplyr::select(GMGI_ID, `Length Cm`, `Ind Sex`, AgeRounded, sampling_season) %>%
  dplyr::rename(sample = GMGI_ID)

# number of rows should not increase after this left_join
df <- left_join(df, metadata, by = "sample")

## adds a Loci specific column 
df <- df %>% unite(Loc, c("scaffold", "start"), sep=" ", remove=F)

## confirm format is correct
head(df)

#Save as R data file / read in R data file for future running
save(df, file = "/work/gmgi/Fisheries/epiage/haddock/RData_Round2/df_all2.RData")

### Do this same .Rdata with 100% loci 
## Round 2 (140 samples): 15,177,540 rows
df100 <- list.files(path="../../work/gmgi/Fisheries/epiage/haddock/methylation/filtered/100p_bedfiles", 
                 pattern = "100p_enrichment2.bed", full.names=TRUE) %>% 
  set_names(.) %>% map_dfr(read.table, .id = "sample", header=F)

# changing column names
colnames(df100) <- c("sample", "scaffold", "start", "stop", "percent.meth", "meth", "unmeth")

## Editing sample name 
df100 <- df100 %>%
  mutate(sample = str_after_nth(sample, "filtered/100p_bedfiles/", 1),
         sample = str_before_nth(sample, "_", 1))

## adding metadata
df100 <- left_join(df100, metadata, by = "sample")

## adds a Loci specific column 
df100 <- df100 %>% unite(Loc, c("scaffold", "start"), sep=" ", remove=F)

## confirm format is correct
head(df100)

#Save as R data file / read in R data file for future running
save(df100, file = "/work/gmgi/Fisheries/epiage/haddock/RData_Round2/df100_all2.RData")
