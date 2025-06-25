#### 19 Impute missing values 

### Load packages 

library(tidyverse)
library(mice)
require(lattice)
library(emmeans)
library(rstanarm)
library(coda)
library(tidymodels)
library(caret)
library(readxl)
library(parallel)

set.seed(123)

num_cores <- detectCores() - 1

######### Load data 
load("/work/gmgi/Fisheries/epiage/haddock/GLM/df_filtered4/df_f4_agelength_final.RData")
load("/work/gmgi/Fisheries/epiage/haddock/GLM/df_filtered4/df_f4_age_final.RData")

length(unique(df_f4_agelength_final$Loc)) ## 47,373
length(unique(df_f4_age_final$Loc)) ## 124,836
######### 


######### Transform df to matrix 
df1 <- df_f4_agelength_final
df2 <- df_f4_age_final

df1_matrix <- df1 %>% 
  dplyr::select(sample, Loc, percent.meth, AgeRounded) %>% #, `Length Cm`, `Ind Sex`, AgeRounded, sampling_season) 
  mutate(Loc = gsub(" ", "_", Loc),
         Loc = gsub("\\|", "_", Loc)) %>%
  spread(Loc, percent.meth) %>%
  column_to_rownames(var = "sample")

df2_matrix <- df2 %>% 
  dplyr::select(sample, Loc, percent.meth, AgeRounded) %>% #, `Length Cm`, `Ind Sex`, AgeRounded, sampling_season) 
  mutate(Loc = gsub(" ", "_", Loc),
         Loc = gsub("\\|", "_", Loc)) %>%
  spread(Loc, percent.meth) %>%
  column_to_rownames(var = "sample")

#test_df <- df1_matrix %>% dplyr::select(1:2)

# age_matrix <- df1 %>% dplyr::select(sample, AgeRounded) %>% distinct() %>%
#   column_to_rownames(var = "sample")
# age_matrix <- as.matrix(age_matrix)
######### 


######### Running MICE for missing data based on age matrix
## Create function
# Make a list of methods for "" (age) and then the remaining loci 
## this assumes Age is the first column from df_matrix 
meth <- c("", "norm")

run_MICE_model <- function(data){
  # Remove existing row names if any
  data <- data %>% remove_rownames()
  
  # Prep df 
  data <- data %>% column_to_rownames(var = "sample")
  colnames(data)[colnames(data) == "percent.meth"] <- data$Loc[1]
  data <- data %>% dplyr::select(-Loc)
  
  # Perform multiple imputation
  imp <- mice(data, method = "pmm", m = 10, seed = 123, maxit = 10)
  
  # Fit a model with each dataset
  col_name <- colnames(data)[2]
  fit <- with(imp, lm(as.formula(paste0(col_name, " ~ AgeRounded"))))
  
  # Pool results 
  pooled_fit <- pool(fit)
  
  # Print summary of pooled fit (optional)
  print(summary(pooled_fit))
  
  # Complete data 
  complete_data <- complete(imp, 1)
  complete_data <- as.data.frame(t(complete_data %>% dplyr::select(-AgeRounded)))
  
  # Return complete data
  return(complete_data)
}
######### 

#########  Run df_f4_agelength_final 
## Estimate is ~ 4 hours 
df1_long <- df1_matrix %>% rownames_to_column(var = "sample") %>%
  gather("Loc", "percent.meth", 3:last_col())

split_dfs1 <- split(df1_long, df1_long$Loc)
# split_test <- df_long %>% subset(Loc=="ENA_OLKM01000001_OLKM01000001.1_1001454")

# Initialize results
results1 <- data.frame()

# Assuming split_dfs is a list of data frames
complete_datas_1 <- mclapply(split_dfs1, run_MICE_model, mc.cores = num_cores)

# Combine the results
results1 <- do.call(rbind, complete_datas_1)

save(results1, file = "/work/gmgi/Fisheries/epiage/haddock/GLM/df_filtered4/df_f4_agelength_imputed_data.RData")
#########  


#########  Run df_f4_age_final 
## Estimate is ~ 10 hours
df2_long <- df2_matrix %>% rownames_to_column(var = "sample") %>%
  gather("Loc", "percent.meth", 3:last_col())

split_dfs2 <- split(df2_long, df2_long$Loc)
# split_test <- df_long %>% subset(Loc=="ENA_OLKM01000001_OLKM01000001.1_1001454")

# Initialize results
results2 <- data.frame()

# Assuming split_dfs is a list of data frames
complete_datas_2 <- mclapply(split_dfs2, run_MICE_model, mc.cores = num_cores)

# Combine the results
results2 <- do.call(rbind, complete_datas_2)

save(results2, file = "/work/gmgi/Fisheries/epiage/haddock/GLM/df_filtered4/df_f4_age_imputed_data.RData")
#########  






