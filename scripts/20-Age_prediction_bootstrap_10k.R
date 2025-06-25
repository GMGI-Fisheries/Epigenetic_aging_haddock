#!/bin/R

##### Slurm script version of 20-Age_prediction_bootstrap.Rmd
### But do this for 10k iterations of the best model 

## clear environment 
rm(list=ls())

#### Load libraries
# Load necessary libraries
library(readxl)   # read Excel files
library(tidyverse) # includes dplyr, tidyr, readr, purrr, and more
library(ggplot2)  # plotting (included in tidyverse but listed explicitly for clarity)
# library(janitor)  # for clean_names() (xxx)
library(glmnet)   # for generalized linear models
library(data.table) # for efficient data manipulation
# library(lme4)     # for linear mixed effects models
library(car)      # for regression diagnostics (xxx)
library(ggpubr)   # for ggplot2 extensions (xxx)
library(tidymodels) # for modeling and machine learning (xxx)
library(caret)    # for machine learning and regression 
library(psych)    # for psychological statistics (xxx)
library(bestNormalize) # for data normalization (xxx)
library(emmeans)  # for estimated marginal means (xxx)
library(rstanarm) # for Bayesian models (xxx)
library(coda)     # for Markov chain Monte Carlo diagnostics (xxx)
# library(parallel) # for parallel processing (xxx)
library(glmnetUtils) # (xxx)

# Note: tidyverse includes tidyr, readr, purrr, and other packages.
#       Loading tidyverse reduces the need to load these individually.
################


##### Load data 
under96BC <- read_xlsx("/work/gmgi/Fisheries/epiage/haddock/conversion_eff/under96.xlsx")

## adding metadata 
meta <- read_xlsx("/work/gmgi/Fisheries/epiage/haddock/metadata/Haddock_labwork.xlsx", 
                  sheet = "Sample List") %>% 
  dplyr::select(GMGI_ID, Length, Sex, AgeRounded, Season) %>%
  filter(!GMGI_ID %in% under96BC$GMGI_ID) # %>%

# filter(AgeRounded <8)

#  ## testing removing outliers 
# filter(!GMGI_ID=="Mae-285") %>%
# filter(!GMGI_ID=="Mae-424") %>%
# filter(!GMGI_ID=="Mae-422") %>%
# filter(!GMGI_ID=="Mae-500") %>%
# filter(!GMGI_ID=="Mae-299")

## 90% df4 age and age + length from 19-Missing values script 
load("/work/gmgi/Fisheries/epiage/haddock/GLM/df_filtered4/df_f4_agelength_imputed_data.RData")
df_f4_agelength_imputed <- results1 %>% rownames_to_column(var = "Loc") %>%
  gather("GMGI_ID", "percent.meth", 2:last_col()) %>%
  left_join(., meta, by = "GMGI_ID")

sig_values <- 
  # read.csv("/work/gmgi/Fisheries/epiage/haddock/GLM/df100_filtered4/seq2/df100_f4_AL_sig.csv") %>% 
  # read.csv("/work/gmgi/Fisheries/epiage/haddock/GLM/df100_filtered4/seq2/df100_f4_age_sig.csv") %>%
  # read.csv("/work/gmgi/Fisheries/epiage/haddock/GLM/df_filtered4/df_f4_age_sig.csv") %>%
  read.csv("/work/gmgi/Fisheries/epiage/haddock/GLM/df_filtered4/df_f4_AL_sig.csv") %>%
  dplyr::select(-X) %>%
  arrange(p.value) %>%
  slice_head(prop = 0.20) %>%
  
  ### below only needed for imputed values 
  mutate(Loc = gsub(" ", "_", Loc),
         Loc = gsub("\\|", "_", Loc))

############################

#### Filter data 

df <- df_f4_agelength_imputed %>%
  dplyr::select(-Length, -Sex, -Season)  %>%
  filter(!GMGI_ID %in% under96BC$GMGI_ID) # %>%

# filter(AgeRounded <8)

# filter(!GMGI_ID=="Mae-285") %>%
# filter(!GMGI_ID=="Mae-424") %>%
# filter(!GMGI_ID=="Mae-422") %>%
# filter(!GMGI_ID=="Mae-500") %>%
# filter(!GMGI_ID=="Mae-299")

## FILTER TO MOST SIGNIFICANT SITES
## filter for top % most significant sites
df <- df %>% filter(Loc %in% sig_values$Loc)
length(unique(df$Loc)) 
## 9,474 loci

## REMOVE OR SUBSET TO HIGHLY CORRELATED SITES
df_wide <- df %>% spread(Loc, percent.meth)
x_matrix <- as.matrix(df_wide[,-(1:2)])

corr_matrix <- corr.test(x = as.matrix(x_matrix), y = df_wide[, 2], 
                         use="pairwise", method="pearson", adjust="BH", alpha=0.05)
corr_results <- data.frame(corr_matrix$r, corr_matrix$p.adj)
corr_results <- tibble::rownames_to_column(corr_results, "Loc")
colnames(corr_results) <- c("Loc", "r", "padj")
corr_results$absr <- abs(corr_results$r) ## r = correlation coefficients
quant <- quantile(corr_results$absr, 0.5, na.rm = TRUE)
loc_highr <- corr_results %>%
  filter(absr > quant)

# df <- df %>% filter(Loc %in% loc_highr$Loc)

length(unique(df$Loc)) 
## 9,474 loci
## 2,369 loci w/ 0.75 corr filtering
## 4,737 loci w/ 0.5 corr filtering

##########################

## Create lapply function for 100 iterations of 70/30 split or 80/20 split 
# Define function
bootstrap_sample_splits <- function(data, iterations = 100) {
  split_samples_df <- list()
  
  for (i in 1:iterations) {
    # Create a 70/30 split
    splits <- initial_split(data, strata = AgeRounded, prop = 0.7)
    age_training <- training(splits)
    age_test <- testing(splits)
    
    # Create training and test lists
    age_training_list <- age_training %>% dplyr::select(GMGI_ID)
    age_test_list <- age_test %>% dplyr::select(GMGI_ID)
    
    # Join with df
    df_significant_train <- left_join(age_training_list, df, by = "GMGI_ID")
    df_significant_test <- left_join(age_test_list, df, by = "GMGI_ID")
    
    ## Chosing what data to use
    column_to_use <- "percent.meth"
    #column_to_use <- "normalized_meth"
    
    # Create training matrix 
    training_matrix <- df_significant_train %>% dplyr::select(GMGI_ID, Loc, column_to_use) %>% 
      spread(Loc, column_to_use) %>% arrange(GMGI_ID) %>% column_to_rownames(var="GMGI_ID")
    training_matrix <- as.matrix(training_matrix)
    
    # Create testing matrix
    testing_matrix <- df_significant_test %>% dplyr::select(GMGI_ID, Loc, column_to_use) %>% 
      spread(Loc, column_to_use) %>%  arrange(GMGI_ID) %>% column_to_rownames(var="GMGI_ID")
    testing_matrix <- as.matrix(testing_matrix)
    
    # Creating age vector from training set
    age_training <- df_significant_train %>% dplyr::select(GMGI_ID, AgeRounded) %>% distinct() %>% 
      arrange(GMGI_ID) %>% dplyr::select(AgeRounded)
    age_training_vector <- age_training$AgeRounded
    
    # Store split_samples_df
    split_samples_df[[i]] <- list(
      training = training_matrix,
      testing = testing_matrix,
      age_vector = age_training_vector
    )
  }
  
  return(split_samples_df)
}

# Run bootstrap 
bootstrap_samples_df <- bootstrap_sample_splits(meta, iterations = 100)

## View example of one output that has 2 dataframes: training and testing that are df_significant_train
# bootstrap_samples_df[1]

##########################

## Create an lapply function for iterative lasso models for each sample set

perform_lasso <- function(bootstrap_sample, round_num) {
  cat(sprintf("\n### Round %d\n", round_num))
  
  training_matrix <- bootstrap_sample$training
  testing_matrix <- bootstrap_sample$testing
  age_training_vector <- bootstrap_sample$age_vector
  
  CVGLM <- cv.glmnet(x = training_matrix,
                     y = age_training_vector,
                     nfolds = nrow(training_matrix),
                     alpha = 0,
                     type.measure = "mae",
                     family = "gaussian",
                     grouped = FALSE)
  
  cat("Minimum MAE:", min(CVGLM$cvm), "\n")
  
  coefList <- coef(CVGLM, s = CVGLM$lambda.min)
  coefList <- data.frame(Loc = coefList@Dimnames[[1]][coefList@i + 1],
                         Weight = coefList@x)[-1, ]
  coefList$AbsWeight <- abs(coefList$Weight)
  
  loc_highweights <- coefList %>%
    filter(AbsWeight > quantile(AbsWeight, 0.25))
  
  list(
    n_sites = loc_highweights,
    training = training_matrix[, loc_highweights$Loc],
    testing = testing_matrix[, loc_highweights$Loc],
    age_vector = age_training_vector
  )
}

# Function to process all rounds for a single bootstrap sample
### CHANGE THE NUMBER OF ITERATIONS AS DESIRED
lasso_process_bootstrap_sample <- function(bootstrap_sample, num_rounds = 7) {
  filtered_matrices <- bootstrap_sample
  
  for (i in 1:num_rounds) {
    filtered_matrices <- perform_lasso(filtered_matrices, i)
  }
  
  return(filtered_matrices)
} 

# Process all bootstrap samples
# lasso_processed_samples <- lapply(bootstrap_samples_df, lasso_process_bootstrap_sample)
lasso_processed_samples <- mclapply(bootstrap_samples_df, lasso_process_bootstrap_sample, mc.cores = detectCores() - 1)

for (i in 1:100) {
  # Extract the ith sample
  sample_obj <- lasso_processed_samples[[i]]
  
  # Create a filename with the current index
  save_filename <- paste0("/work/gmgi/Fisheries/epiage/haddock/modelplots/10k/4-16-2025_1_lasso_processed_sample_", i, ".RData")
  
  # Save the object
  save(sample_obj, file = save_filename)
}

# If you want to see the results for a specific bootstrap sample (e.g., the first one):
# filtered_result_sample_1 <- lasso_processed_samples[[1]]
# filtered_result_sample_1$n_sites 

## 2,997 loci included from 9,474 after lasso x4
## 749 loci included from 2,369 after lasso x4 from corr=0.75
## 1,498 loci included from 4,737 loci after lasso x4 from corr=0.5
## 2,247 loci included from 9,474 after lasso x5
## 1,685 loci included from 9,474 after lasso x6
## 1,263 loci included from 9,474 after lasso x7
## 947 loci included from 9,474 after lasso x8
## 710 loci included from 9,474 after lasso x9

##########################

## Create function to take the filtered matrix from lasso x4 to elastic net function 

## Define function to perform random subset analysis on processed samples
run_random_subsets <- function(filtered_sample, num_iterations = 10000, num_sites = 150) {
  # Initialize storage
  mae_results <- numeric(num_iterations)
  num_sites_chosen <- numeric(num_iterations)
  cv_models <- list()
  subset_columns <- list()
  lowest_mae <- Inf
  best_model <- NULL
  best_subset <- NULL
  
  # Extract matrices from processed sample
  filtered_training_matrix <- filtered_sample$training
  age_training_vector <- filtered_sample$age_vector
  
  # Validation check
  if(num_sites > ncol(filtered_training_matrix)) {
    stop("Requested number of sites exceeds available features in filtered matrix")
  }
  
  for (i in 1:num_iterations) {
    subset_cols <- sample(ncol(filtered_training_matrix), num_sites)
    subset_matrix <- filtered_training_matrix[, subset_cols]
    
    cv_model <- cv.glmnet(x = subset_matrix, 
                          y = age_training_vector, 
                          alpha = 0, 
                          nfolds = 10,
                          type.measure = "mae",
                          family = "gaussian",
                          standardize = FALSE)
    
    # Store results
    current_mae <- min(cv_model$cvm)
    mae_results[i] <- current_mae
    
    # Extract non-zero coefficients at optimal lambda
    coef_list <- coef(cv_model, s = "lambda.min")
    non_zero_indices <- which(coef_list != 0)[-1] # Exclude intercept (first coefficient)
    
    # Get actual column names or indices for selected sites
    selected_sites <- subset_cols[non_zero_indices]
    
    num_sites_chosen[i] <- length(selected_sites)
    
    # Store both input and selected sites
    cv_models[[i]] <- cv_model
    subset_columns[[i]] <- list(
      input_sites = subset_cols,
      selected_sites = selected_sites
    )
  }
  
  # Identify the best model based on the lowest MAE
  best_iteration <- which.min(mae_results)
  
  return(list(
    all_mae = mae_results,
    all_sites_chosen = num_sites_chosen,
    all_models = cv_models,
    all_subsets = subset_columns,
    
    best_model = cv_models[[best_iteration]],
    best_selected = subset_columns[[best_iteration]]$selected_sites,
    best_input = subset_columns[[best_iteration]]$input_sites,
    lowest_mae = mae_results[best_iteration],
    best_iteration = best_iteration
  ))
}

## Process all bootstrap samples (parallelized)
elastic_results <- mclapply(lasso_processed_samples, function(sample) {
  run_random_subsets(
    filtered_sample = sample,
    num_iterations = 10000,  # Adjust as needed
    num_sites = 150      # Adjust as needed
  )
}, mc.cores = detectCores() - 1)

## To analyze results for first bootstrap sample:
for (i in 1:100) {
  # Extract the ith sample
  sample_obj_elastic <- elastic_results[[i]]
  
  # Create a filename with the current index
  save_filename_elastic <- paste0("/work/gmgi/Fisheries/epiage/haddock/modelplots/10k/4-16-2025_1_elastic_results_", i, ".RData")
  
  # Save the object
  save(sample_obj_elastic, file = save_filename_elastic)
}

##########################

## Create df with each row as iteration and the output of MAE

# Extract MAE values and their indices
mae_values <- sapply(elastic_results, function(res) res$lowest_mae)
sorted_indices <- order(mae_values)  # Sort indices by MAE values

# Select the top 20 results
top_20_indices <- sorted_indices[1:20]
top_20_results <- elastic_results[top_20_indices]

# Optional: Create a summary of the top 20 results
top_20_summary <- data.frame(
  Index = top_20_indices,
  Lowest_MAE = mae_values[top_20_indices]
)

##########################

## Plot the models from those top 20 

## Loop to process each best model in elastic_results
all_predictions <- list()  # Initialize list to store predictions for each bootstrap sample

for (i in seq_along(elastic_results)) {
  # Extract best model and subset from current bootstrap sample
  best_model <- elastic_results[[i]]$best_model
  best_subset <- elastic_results[[i]]$best_input
  
  # Extract filtered matrices
  filtered_training_matrix <- lasso_processed_samples[[i]]$training
  filtered_testing_matrix <- lasso_processed_samples[[i]]$testing
  
  # Subset matrices based on best subset
  best_training_subset <- filtered_training_matrix[, best_subset]
  best_testing_subset <- filtered_testing_matrix[, best_subset]
  
  ## Training models
  predicted_age <- as.data.frame(predict(best_model, newx = best_training_subset, s = "lambda.min")) %>% 
    rownames_to_column(var = "GMGI_ID") %>% 
    dplyr::rename(epi.age = lambda.min)
  
  predicted_age_testing <- as.data.frame(predict(best_model, newx = best_testing_subset, s = "lambda.min")) %>% 
    rownames_to_column(var = "GMGI_ID") %>% 
    dplyr::rename(epi.age = lambda.min)
  
  ## Train and testing group labels
  predicted_age$group <- "training"
  predicted_age_testing$group <- "testing"
  
  predictions <- full_join(predicted_age, predicted_age_testing, by = join_by(GMGI_ID, epi.age, group)) %>%
    left_join(., meta, by = "GMGI_ID") %>%
    mutate(epi.age = pmax(epi.age, 0))
  
  ## Store predictions in the list for later use
  all_predictions[[i]] <- predictions
  
  ## Visualization (optional: save plots for each iteration)
  plot <- predictions %>%
    ggplot(aes(x = AgeRounded, y = epi.age)) + 
    theme_classic() + 
    geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "grey70") +
    geom_smooth(method = 'lm', se = FALSE, color = "grey", alpha = 0.8) +
    geom_point(aes(fill = group), size = 3, alpha = 0.8, color = "black", shape = 21) + 
    scale_fill_manual(values = c("#588157", "grey90")) +
    xlim(0,12) + ylim(0,12) +
    labs(fill = "Set",
         y = "Epigenetic Age",
         x = "Otolith Age") +
    theme(
      legend.position="right",
      legend.title = element_text(face="bold", size=18),
      legend.text = element_text(size=16),
      strip.text = element_text(face="bold", size=16),
      axis.title.y = element_text(margin=margin(t=0,r=15,b=0,l=0),size=20,face="bold"),
      axis.title.x = element_text(margin=margin(t=10,r=0,b=0,l=0),size=20,face="bold"),
      axis.text.x=element_text(color="black",size=16),
      axis.text.y=element_text(color="black",size=16),
      plot.caption=element_text(hjust=0.75,size=16,face="italic")
    ) +
    stat_regline_equation(label.x=0.2,label.y=11,size=6,aes(label=after_stat(rr.label))) +
    
    annotate(geom="label",x=0,y=10,label=paste0("# Sites: ",length(elastic_results[[i]]$best_selected)),
             hjust=0,vjust=1,label.size=NA,color="black",size=6,fill=NA) +
    
    annotate(geom="label",x=0,y=8.5,label=paste0("MAE: ",round(elastic_results[[i]]$lowest_mae,2)),
             hjust=0,vjust=1,label.size=NA,color="black",size=6,fill=NA)
  
  ## Save plot (optional)
  ggsave(filename=paste0("/work/gmgi/Fisheries/epiage/haddock/modelplots/10k/4-16-2025_1_Lassox7_lasso150by10000_bootstrap_",
                         i, "_plot.png"), plot=plot, width=7, height=5.5)
}












