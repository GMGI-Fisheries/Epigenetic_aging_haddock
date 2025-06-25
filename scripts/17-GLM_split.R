### 17-GLM_split.R 

### Splitting the larger df into smaller chunks to process with the GLM
### General Linear Model to find loci significantly differentially methylated with age 
getwd()

## clear environment 
rm(list=ls())
## unloading packages
# invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE,unload=TRUE))

## load packages
library(tidyverse)
library(emmeans)
library(rstanarm)
library(coda)
library(tidymodels)
library(caret)
library(readxl)
library(parallel)

## load full dataset 
load("/work/gmgi/Fisheries/epiage/haddock/RData_Round2/df_all2.RData")

#### EDIT WHICH TABLE TO USE ### 
## 642,346 loci df
## 105,602 loci df100
load(file = "/work/gmgi/Fisheries/epiage/haddock/RData_Round2/seq2_df_filtered4.RData")
load(file = "/work/gmgi/Fisheries/epiage/haddock/RData_Round2/seq2_df100_filtered4.RData")

df_filtered4 <- df_filtered4 %>% dplyr::select(Loc) %>% distinct() %>% left_join(., df, by = "Loc")
df100_filtered4 <- df100_filtered4 %>% dplyr::select(Loc) %>% distinct() %>% left_join(., df, by = "Loc")

## splitting by Loc
split_dfs <- split(df_filtered4, df_filtered4$Loc)

## splitting into 10+ dfs 
df_f4_split1 <- split_dfs[1:min(50000, length(split_dfs))]
df_f4_split2 <- split_dfs[50001:min(100000, length(split_dfs))]
df_f4_split3 <- split_dfs[100001:min(150000, length(split_dfs))]
df_f4_split4 <- split_dfs[150001:min(200000, length(split_dfs))]
df_f4_split5 <- split_dfs[200001:min(250000, length(split_dfs))]
df_f4_split6 <- split_dfs[250001:min(300000, length(split_dfs))]
df_f4_split7 <- split_dfs[300001:min(350000, length(split_dfs))]
df_f4_split8 <- split_dfs[350001:min(400000, length(split_dfs))]
df_f4_split9 <- split_dfs[400001:min(450000, length(split_dfs))]
df_f4_split10 <- split_dfs[450001:min(500000, length(split_dfs))]
df_f4_split11 <- split_dfs[500001:min(550000, length(split_dfs))]
df_f4_split12 <- split_dfs[550001:min(600000, length(split_dfs))]
df_f4_split13 <- split_dfs[600001:min(650000, length(split_dfs))]

save(df_f4_split1, file = "/work/gmgi/Fisheries/epiage/haddock/RData_Round2/df_f4_split/df_f4_split1.RData")
save(df_f4_split2, file = "/work/gmgi/Fisheries/epiage/haddock/RData_Round2/df_f4_split/df_f4_split2.RData")
save(df_f4_split3, file = "/work/gmgi/Fisheries/epiage/haddock/RData_Round2/df_f4_split/df_f4_split3.RData")
save(df_f4_split4, file = "/work/gmgi/Fisheries/epiage/haddock/RData_Round2/df_f4_split/df_f4_split4.RData")
save(df_f4_split5, file = "/work/gmgi/Fisheries/epiage/haddock/RData_Round2/df_f4_split/df_f4_split5.RData")
save(df_f4_split6, file = "/work/gmgi/Fisheries/epiage/haddock/RData_Round2/df_f4_split/df_f4_split6.RData")
save(df_f4_split7, file = "/work/gmgi/Fisheries/epiage/haddock/RData_Round2/df_f4_split/df_f4_split7.RData")
save(df_f4_split8, file = "/work/gmgi/Fisheries/epiage/haddock/RData_Round2/df_f4_split/df_f4_split8.RData")
save(df_f4_split9, file = "/work/gmgi/Fisheries/epiage/haddock/RData_Round2/df_f4_split/df_f4_split9.RData")
save(df_f4_split10, file = "/work/gmgi/Fisheries/epiage/haddock/RData_Round2/df_f4_split/df_f4_split10.RData")
save(df_f4_split11, file = "/work/gmgi/Fisheries/epiage/haddock/RData_Round2/df_f4_split/df_f4_split11.RData")
save(df_f4_split12, file = "/work/gmgi/Fisheries/epiage/haddock/RData_Round2/df_f4_split/df_f4_split12.RData")
save(df_f4_split13, file = "/work/gmgi/Fisheries/epiage/haddock/RData_Round2/df_f4_split/df_f4_split13.RData")


## splitting by Loc for df100
split100_dfs <- split(df100_filtered4, df100_filtered4$Loc)

## splitting into 10+ dfs 
df100_f4_split1 <- split100_dfs[1:min(55000, length(split100_dfs))]
df100_f4_split2 <- split100_dfs[55001:min(110000, length(split100_dfs))]

save(df100_f4_split1, file = "/work/gmgi/Fisheries/epiage/haddock/RData_Round2/df100_f4_split/df100_f4_split1.RData")
save(df100_f4_split2, file = "/work/gmgi/Fisheries/epiage/haddock/RData_Round2/df100_f4_split/df100_f4_split2.RData")



