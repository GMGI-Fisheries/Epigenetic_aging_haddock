### 2026 20-Age_prediction_bootstrap

### Load libraries
# Load necessary libraries
library(readxl)   # read Excel files
#library(writexl)  # write Excel files
library(plyr)     # needs to be loaded before dplyr
library(dplyr)    # data manipulation
library(tidyverse) # includes dplyr, tidyr, readr, purrr, and more
library(ggplot2)  # plotting (included in tidyverse but listed explicitly for clarity)
#library(Rmisc)    # for summarySE()
#library(janitor)  # for clean_names()
library(glmnet)   # for generalized linear models
library(data.table) # for efficient data manipulation
library(lme4)     # for linear mixed effects models
library(car)      # for regression diagnostics
library(ggpubr)   # for ggplot2 extensions
library(tidymodels) # for modeling and machine learning
library(caret)    # for machine learning and regression
library(psych)    # for psychological statistics
library(bestNormalize) # for data normalization
library(emmeans)  # for estimated marginal means
library(rstanarm) # for Bayesian models
library(coda)     # for Markov chain Monte Carlo diagnostics
library(parallel) # for parallel processing
library(glmnetUtils)
library(parallelly)

# Note: tidyverse includes tidyr, readr, purrr, and other packages.
#       Loading tidyverse reduces the need to load these individually.

#### DEFINE PATHS AND VARIABLES
#### DEFINE PATHS AND VARIABLES
BASE_DIR <- "/projects/gmgi/Fisheries/epiage/haddock/modelplots_2026"
RUN_ID <- "6-22-2026_1"

sites <- 629
iterations <- 1000
ridge_rounds <- 6
corr_percent <- 0.5   # top 25% quantile value (0.25 means 25% quantile)
ridge_percent <- 0.5  # flipped; 0.25 means top 75%
sig_percent <- 0.5    # top 50%
alpha_value <- 0.01

CONFIG <- paste0(RUN_ID, "_Ridgex", ridge_rounds,
                 "_alpha", alpha_value, "x", sites, "x", iterations)

################################################

# Equivalent of: mkdir -p
dir.create(file.path(BASE_DIR, CONFIG), recursive = TRUE, showWarnings = FALSE)

COMMON_PATH <- file.path(BASE_DIR, CONFIG, RUN_ID)
EXPORT_PLOT_PATH <- paste0(COMMON_PATH, "_plot_")
EXPORT_LASSO_PATH <- paste0(COMMON_PATH, "_lasso_processed_sample_")
EXPORT_ELASTIC_PATH <- paste0(COMMON_PATH, "_elastic_results_")


############ Load data 
under96BC <- read_xlsx("/projects/gmgi/Fisheries/epiage/haddock/conversion_eff/under96.xlsx")

## adding metadata 
meta <- read_xlsx("/projects/gmgi/Fisheries/epiage/haddock/metadata/Haddock_labwork.xlsx", 
                  sheet = "Sample List") %>% 
  dplyr::select(GMGI_ID, Length, Sex, AgeRounded, Season) %>%
  filter(!GMGI_ID %in% under96BC$GMGI_ID) 

load("/projects/gmgi/Fisheries/epiage/haddock/GLM/df100_filtered4/seq2/df100_f4_agelength_final-3-24-2026.RData")

## 90% df4 age and age + length from 19-Missing values script 
load("/projects/gmgi/Fisheries/epiage/haddock/GLM/df_filtered4/df_f4_agelength_imputed_data-3-24-2026.RData")
df_f4_agelength_imputed <- results1 %>% rownames_to_column(var = "Loc") %>%
  gather("GMGI_ID", "percent.meth", 2:last_col()) %>%
  left_join(., meta, by = "GMGI_ID")

sig_values <- 
  read.csv("/projects/gmgi/Fisheries/epiage/haddock/GLM/df_filtered4/df_f4_AL_sig-3-24-2026.csv") %>%
  dplyr::select(-X) %>%
  arrange(p.value) %>%
  slice_head(prop = sig_percent) %>%
  
  ### below only needed for imputed values 
  mutate(Loc = gsub(" ", "_", Loc),
         Loc = gsub("\\|", "_", Loc))

############ Filter data
df <- 
  df_f4_agelength_imputed %>%
  dplyr::select(-Length, -Sex, -Season)  %>%
  filter(!GMGI_ID %in% under96BC$GMGI_ID) 

## FILTER TO MOST SIGNIFICANT SITES
## filter for top % most significant sites
# df <- df %>% filter(Loc %in% sig_values$Loc)

length(unique(df$Loc)) 
### 90% set 3-25-2026
### pre filter: 40,251 CpGs
### post sig filter: 8,050 CpGs 

## REMOVE OR SUBSET TO HIGHLY CORRELATED SITES
df_wide <- df %>% spread(Loc, percent.meth)
x_matrix <- as.matrix(df_wide[,-(1:2)])

corr_matrix <- corr.test(x = as.matrix(x_matrix), y = df_wide[, 2],
                          use="pairwise", method="pearson", adjust="BH", alpha=0.05)
corr_results <- data.frame(corr_matrix$r, corr_matrix$p.adj)
corr_results <- tibble::rownames_to_column(corr_results, "Loc")
colnames(corr_results) <- c("Loc", "r", "padj")
corr_results$absr <- abs(corr_results$r) ## r = correlation coefficients

quant <- quantile(corr_results$absr, corr_percent, na.rm = TRUE)
loc_highr <- corr_results %>% filter(absr > quant)

# df <- df %>% filter(Loc %in% loc_highr$Loc)

length(unique(df$Loc)) 
### Sig filtering + corr filtering: 40,251 -> 8,050 -> 4,025 (top 50% correlated with age) -- filter to one direction in the future? 
### No sig filtering + corr filtering: 40,251 -> 20,125 (0.5, top 50%) or 10,063 (0.75, top 25%)


############ Training Testing Split Bootstrap 
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

### 4K LOCI ~ 5 min
### 8K LOCI ~ 


############ LASSO FUNCTION FOR X TIMES 

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
    filter(AbsWeight > quantile(AbsWeight, ridge_percent))
  
  list(
    n_sites = loc_highweights,
    training = training_matrix[, loc_highweights$Loc],
    testing = testing_matrix[, loc_highweights$Loc],
    age_vector = age_training_vector
  )
}

# Function to process all rounds for a single bootstrap sample
### CHANGE THE NUMBER OF ITERATIONS AS DESIRED
lasso_process_bootstrap_sample <- function(bootstrap_sample, num_rounds = ridge_rounds) {
  filtered_matrices <- bootstrap_sample
  
  for (i in 1:num_rounds) {
    filtered_matrices <- perform_lasso(filtered_matrices, i)
  }
  
  return(filtered_matrices)
} 

# Process all bootstrap samples
# lasso_processed_samples <- lapply(bootstrap_samples_df, lasso_process_bootstrap_sample)
lasso_processed_samples <- mclapply(bootstrap_samples_df, lasso_process_bootstrap_sample, mc.cores = detectCores() - 1)

# If you want to see the results for a specific bootstrap sample (e.g., the first one):
filtered_result_sample_1 <- lasso_processed_samples[[1]]
filtered_result_sample_1$n_sites

### 4,025 loci 
### 1 round = 3,018
### 2 round = 2,264
### 3 round = 1,698
### 4 round = 1,273
### 5 round = 955 loci 

############ SELECT BEST ELASTIC NET FROM LASSO OUTPUT 
###### Selected from lowest testing MAE rather than training + testing 


run_random_subsets <- function(filtered_sample, num_iterations = iterations, num_sites = sites) {
  # Initialize storage
  mae_train <- numeric(num_iterations)
  mae_test <- numeric(num_iterations)
  r2_train <- numeric(num_iterations)
  r2_test <- numeric(num_iterations)
  num_sites_chosen <- numeric(num_iterations)
  cv_models <- list()
  subset_columns <- list()
  
  # For best model selection
  best_r2_test <- -Inf
  best_iteration <- NA
  
  # Extract matrices
  filtered_training_matrix <- filtered_sample$training
  filtered_testing_matrix <- filtered_sample$testing
  age_training_vector <- filtered_sample$age_vector
  #age_testing_vector <- filtered_sample$age_vector_test # Ensure this exists
  
  # Validation check
  if(num_sites > ncol(filtered_training_matrix)) {
    stop("Requested number of sites exceeds available features in filtered matrix")
  }
  
  for (i in 1:num_iterations) {
    subset_cols <- sample(ncol(filtered_training_matrix), num_sites)
    train_subset <- filtered_training_matrix[, subset_cols]
    test_subset <- filtered_testing_matrix[, subset_cols]
    
    cv_model <- cv.glmnet(x = train_subset, 
                          y = age_training_vector,
                          alpha = alpha_value,
                          nfolds = 10,
                          type.measure = "mae",
                          standardize = FALSE)
    
    # Predictions
    #pred_train <- predict(cv_model, newx = train_subset, s = "lambda.min")
    #pred_test <- predict(cv_model, newx = test_subset, s = "lambda.min")
    
    pred_train <- as.data.frame(predict(cv_model, newx = train_subset, s = "lambda.min")) %>% 
      rownames_to_column(var = "GMGI_ID") %>% 
      dplyr::rename(epi.age = lambda.min) %>%
      left_join(., meta, by = "GMGI_ID") %>%
      mutate(epi.age = pmax(epi.age, 0))
    
    pred_test <- as.data.frame(predict(cv_model, newx = test_subset, s = "lambda.min")) %>% 
      rownames_to_column(var = "GMGI_ID") %>% 
      dplyr::rename(epi.age = lambda.min) %>%
      left_join(., meta, by = "GMGI_ID") %>%
      mutate(epi.age = pmax(epi.age, 0))
    
    # Metrics
    mae_train[i] <- mean(abs(pred_train$epi.age - pred_train$AgeRounded))
    mae_test[i] <- mean(abs(pred_test$epi.age - pred_test$AgeRounded))
    
    r2_train[i] <- 1 - (sum((pred_train$AgeRounded - pred_train$epi.age)^2) / 
                          sum((pred_train$AgeRounded - mean(pred_train$AgeRounded))^2))
    
    r2_test[i] <- 1 - (sum((pred_test$AgeRounded - pred_test$epi.age)^2) / 
                         sum((pred_test$AgeRounded - mean(pred_test$AgeRounded))^2))
    
    # Non-zero coefficients at optimal lambda
    coef_list <- coef(cv_model, s = "lambda.min")
    non_zero_indices <- which(coef_list != 0)[-1] # Exclude intercept
    selected_sites <- subset_cols[non_zero_indices]
    num_sites_chosen[i] <- length(selected_sites)
    
    # Store model and sites
    cv_models[[i]] <- cv_model
    subset_columns[[i]] <- list(
      input_sites = subset_cols,
      selected_sites = selected_sites
    )
    
    # Track best model by R2_test
    if (r2_test[i] > best_r2_test ||
        (r2_test[i] == best_r2_test && mae_test[i] < mae_test[best_iteration])) {
      best_r2_test <- r2_test[i]
      best_iteration <- i
    }
  }
  
  # Output structure (same as before, but now best model is by R2_test)
  return(list(
    all_mae_train = mae_train,
    all_mae_test = mae_test,
    all_r2_train = r2_train,
    all_r2_test = r2_test,
    all_sites_chosen = num_sites_chosen,
    all_models = cv_models,
    all_subsets = subset_columns,
    
    best_model = cv_models[[best_iteration]],
    best_selected = subset_columns[[best_iteration]]$selected_sites,
    best_input = subset_columns[[best_iteration]]$input_sites,
    best_r2_test = r2_test[best_iteration],
    best_mae_test = mae_test[best_iteration],
    best_iteration = best_iteration
  ))
}


## Process all bootstrap samples (parallelized)
elastic_results <- mclapply(lasso_processed_samples, function(sample) {
  run_random_subsets(
    filtered_sample = sample,
    num_iterations = iterations,  # Adjust as needed
    num_sites = sites      # Adjust as needed
  )
}, mc.cores = detectCores() - 1)


############ PLOTTING THAT BEST MODEL AND EXPORT TO FOLDER 

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
    
    annotate(geom="label",x=0,y=8.5,label=paste0("MAE: ",round(elastic_results[[i]]$best_mae_test,2)), #lowest_mae
             hjust=0,vjust=1,label.size=NA,color="black",size=6,fill=NA)
  
  ## Save plot (optional)
  ggsave(filename=paste0(EXPORT_PLOT_PATH, i, "_plot.png"), create.dir = TRUE, plot=plot, width=7, height=5.5)
}


############ EXPORTING THE DATA ASSOCIATED WITH EACH MODEL

for (i in 1:100) {
  # Extract the ith sample
  sample_obj <- lasso_processed_samples[[i]]
  
  # Create a filename with the current index
  save_filename <- paste0(EXPORT_LASSO_PATH, i, ".RData")
  
  # Save the object
  save(sample_obj, file = save_filename)
}

## To analyze results for first bootstrap sample:
for (i in 1:100) {
  # Extract the ith sample
  sample_obj_elastic <- elastic_results[[i]]
  
  # Create a filename with the current index
  save_filename_elastic <- paste0(EXPORT_ELASTIC_PATH, i, ".RData")
  
  # Save the object
  save(sample_obj_elastic, file = save_filename_elastic)
}












