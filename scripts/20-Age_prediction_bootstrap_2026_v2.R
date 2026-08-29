### 2026 20-Age_prediction_bootstrap - safer parallel version

library(readxl)
library(plyr)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(glmnet)
library(data.table)
library(lme4)
library(car)
library(ggpubr)
library(tidymodels)
library(caret)
library(psych)
library(bestNormalize)
library(emmeans)
library(rstanarm)
library(coda)
library(parallel)
library(glmnetUtils)
library(parallelly)

#### DEFINE PATHS AND VARIABLES

BASE_DIR <- "/projects/gmgi/Fisheries/epiage/haddock/modelplots_2026"
RUN_ID <- "8-4-2026_1"

#sites <- 453
iterations <- 1000
ridge_rounds <- 9
corr_percent <- 0.5
ridge_percent <- 0.25 ## 0.25=75% opposite
sig_percent <- 0.05 ## 0.25=25% same
alpha_value <- 0.005

# Safer core limit for shared nodes
ncores <- min(4, max(1, availableCores() - 1))
options(mc.cores = ncores)
set.seed(123)

#CONFIG <- paste0(
#  RUN_ID,
#  "_Ridgex", ridge_rounds,
#  "_alpha", alpha_value,
#  "x", sites,
#  "x", iterations
#)

CONFIG <- paste0(
  RUN_ID,
  "_Ridgex", ridge_rounds,
  "_alpha", alpha_value,
  "_AllSites",
  "x", iterations
)

dir.create(file.path(BASE_DIR, CONFIG), recursive = TRUE, showWarnings = FALSE)

COMMON_PATH <- file.path(BASE_DIR, CONFIG, RUN_ID)
EXPORT_PLOT_PATH <- paste0(COMMON_PATH, "_plot_")
EXPORT_LASSO_PATH <- paste0(COMMON_PATH, "_lasso_processed_sample_")
EXPORT_ELASTIC_PATH <- paste0(COMMON_PATH, "_elastic_results_")

############ Load data

under96BC <- read_xlsx(
  "/projects/gmgi/Fisheries/epiage/haddock/conversion_eff/under96.xlsx"
)

meta <- read_xlsx(
  "/projects/gmgi/Fisheries/epiage/haddock/metadata/Haddock_labwork.xlsx",
  sheet = "Sample List"
) %>%
  dplyr::select(GMGI_ID, Length, Sex, AgeRounded, Season) %>%
  filter(!GMGI_ID %in% under96BC$GMGI_ID)

#load("/projects/gmgi/Fisheries/epiage/haddock/GLM/df100_filtered4/seq2/df100_f4_agelength_final-7-05-2026.RData")

load("/projects/gmgi/Fisheries/epiage/haddock/GLM/df_filtered4/df_f4_agelength_imputed_data-7-05-2026.RData")

df_f4_agelength_imputed <- results1 %>%
  rownames_to_column(var = "Loc") %>%
  gather("GMGI_ID", "percent.meth", 2:last_col()) %>%
  left_join(meta, by = "GMGI_ID")

sig_values <- read.csv(
  "/projects/gmgi/Fisheries/epiage/haddock/GLM/df_filtered4/df_f4_AL_sig-7-05-2026.csv"
) %>%
  dplyr::select(-X) %>%
  arrange(p.value) %>%
  slice_head(prop = sig_percent) %>%
  mutate(
    Loc = gsub(" ", "_", Loc),
    Loc = gsub("\\|", "_", Loc)
  )

############ Filter data

df <- df_f4_agelength_imputed %>%
  dplyr::select(-Length, -Sex, -Season) %>%
  filter(!GMGI_ID %in% under96BC$GMGI_ID)

# Optional:
df <- df %>% filter(Loc %in% sig_values$Loc)

print(length(unique(df$Loc)))

############ REMOVE OR SUBSET TO HIGHLY CORRELATED SITES

df_wide <- df %>%
  spread(Loc, percent.meth)

x_matrix <- as.matrix(df_wide[, -(1:2)])

corr_matrix <- corr.test(
  x = as.matrix(x_matrix),
  y = df_wide[, 2],
  use = "pairwise",
  method = "pearson",
  adjust = "BH",
  alpha = 0.05
)

corr_results <- data.frame(corr_matrix$r, corr_matrix$p.adj)
corr_results <- tibble::rownames_to_column(corr_results, "Loc")
colnames(corr_results) <- c("Loc", "r", "padj")
corr_results$absr <- abs(corr_results$r)

quant <- quantile(corr_results$absr, corr_percent, na.rm = TRUE)
loc_highr <- corr_results %>%
  filter(absr > quant)

# Optional:
# df <- df %>% filter(Loc %in% loc_highr$Loc)

print(length(unique(df$Loc)))

############ Training Testing Split Bootstrap

bootstrap_sample_splits <- function(data, iterations = 100) {
  split_samples_df <- list()

  for (i in seq_len(iterations)) {
    splits <- initial_split(data, strata = AgeRounded, prop = 0.7)

    age_training <- training(splits)
    age_test <- testing(splits)

    age_training_list <- age_training %>%
      dplyr::select(GMGI_ID)

    age_test_list <- age_test %>%
      dplyr::select(GMGI_ID)

    df_significant_train <- left_join(age_training_list, df, by = "GMGI_ID")
    df_significant_test <- left_join(age_test_list, df, by = "GMGI_ID")

    column_to_use <- "percent.meth"

    training_matrix <- df_significant_train %>%
      dplyr::select(GMGI_ID, Loc, column_to_use) %>%
      spread(Loc, column_to_use) %>%
      arrange(GMGI_ID) %>%
      column_to_rownames(var = "GMGI_ID") %>%
      as.matrix()

    testing_matrix <- df_significant_test %>%
      dplyr::select(GMGI_ID, Loc, column_to_use) %>%
      spread(Loc, column_to_use) %>%
      arrange(GMGI_ID) %>%
      column_to_rownames(var = "GMGI_ID") %>%
      as.matrix()

    age_training_vector <- df_significant_train %>%
      dplyr::select(GMGI_ID, AgeRounded) %>%
      distinct() %>%
      arrange(GMGI_ID) %>%
      pull(AgeRounded)

    split_samples_df[[i]] <- list(
      training = training_matrix,
      testing = testing_matrix,
      age_vector = age_training_vector
    )
  }

  split_samples_df
}

bootstrap_samples_df <- bootstrap_sample_splits(meta, iterations = 100)

############ LASSO / RIDGE FEATURE REDUCTION

perform_lasso <- function(bootstrap_sample, round_num) {
  cat(sprintf("\n### Round %d\n", round_num))

  training_matrix <- bootstrap_sample$training
  testing_matrix <- bootstrap_sample$testing
  age_training_vector <- bootstrap_sample$age_vector

  CVGLM <- cv.glmnet(
    x = training_matrix,
    y = age_training_vector,
    nfolds = nrow(training_matrix),
    alpha = 0,
    type.measure = "mae",
    family = "gaussian",
    grouped = FALSE
  )

  cat("Minimum MAE:", min(CVGLM$cvm), "\n")

  coefList <- coef(CVGLM, s = CVGLM$lambda.min)

  coefList <- data.frame(
    Loc = coefList@Dimnames[[1]][coefList@i + 1],
    Weight = coefList@x
  )[-1, ]

  coefList$AbsWeight <- abs(coefList$Weight)

  loc_highweights <- coefList %>%
    filter(AbsWeight > quantile(AbsWeight, ridge_percent, na.rm = TRUE))

  #if (nrow(loc_highweights) < sites) {
  #  stop("Too few loci remaining after lasso/ridge filtering")
  #}
  
  if (nrow(loc_highweights) == 0) {
  stop("No loci remaining after lasso/ridge filtering")
    }

    cat("Remaining loci:", nrow(loc_highweights), "\n")

  list(
    n_sites = loc_highweights,
    training = training_matrix[, loc_highweights$Loc, drop = FALSE],
    testing = testing_matrix[, loc_highweights$Loc, drop = FALSE],
    age_vector = age_training_vector
  )
}

lasso_process_bootstrap_sample <- function(bootstrap_sample, num_rounds = ridge_rounds) {
  filtered_matrices <- bootstrap_sample

  for (i in seq_len(num_rounds)) {
    filtered_matrices <- perform_lasso(filtered_matrices, i)
  }

  filtered_matrices
}

safe_lasso <- function(sample, i) {
  tryCatch(
    {
      lasso_process_bootstrap_sample(sample)
    },
    error = function(e) {
      message("LASSO failed for bootstrap sample ", i, ": ", conditionMessage(e))
      NULL
    }
  )
}

lasso_processed_samples <- mclapply(
  seq_along(bootstrap_samples_df),
  function(i) safe_lasso(bootstrap_samples_df[[i]], i),
  mc.cores = ncores,
  mc.preschedule = FALSE
)

valid_lasso_idx <- which(!vapply(lasso_processed_samples, is.null, logical(1)))

lasso_processed_samples <- lasso_processed_samples[valid_lasso_idx]

cat("\nValid lasso samples:", length(lasso_processed_samples), "\n")

if (length(lasso_processed_samples) == 0) {
  stop("No valid lasso samples remained. Check earlier error messages.")
}

filtered_result_sample_1 <- lasso_processed_samples[[1]]
print(filtered_result_sample_1$n_sites)

############ SELECT BEST ELASTIC NET FROM LASSO OUTPUT

#run_random_subsets <- function(filtered_sample, num_iterations = iterations, num_sites = sites) {
run_random_subsets <- function(filtered_sample, num_iterations = iterations, num_sites = NULL) {
  mae_train <- numeric(num_iterations)
  mae_test <- numeric(num_iterations)
  r2_train <- numeric(num_iterations)
  r2_test <- numeric(num_iterations)
  num_sites_chosen <- numeric(num_iterations)
  cv_models <- list()
  subset_columns <- list()

  best_r2_test <- -Inf
  best_iteration <- NA_integer_

  filtered_training_matrix <- filtered_sample$training
  filtered_testing_matrix <- filtered_sample$testing
  age_training_vector <- filtered_sample$age_vector
  
  if (is.null(num_sites)) {
  num_sites <- ncol(filtered_training_matrix)
    }

  if (num_sites > ncol(filtered_training_matrix)) {
    stop("Requested number of sites exceeds available features in filtered matrix")
  }

  for (i in seq_len(num_iterations)) {
    #subset_cols <- sample(ncol(filtered_training_matrix), num_sites)
    subset_cols <- seq_len(ncol(filtered_training_matrix))

    train_subset <- filtered_training_matrix[, subset_cols, drop = FALSE]
    test_subset <- filtered_testing_matrix[, subset_cols, drop = FALSE]

    cv_model <- cv.glmnet(
      x = train_subset,
      y = age_training_vector,
      alpha = alpha_value,
      nfolds = 10,
      type.measure = "mae",
      standardize = FALSE
    )

    pred_train <- as.data.frame(
      predict(cv_model, newx = train_subset, s = "lambda.min")
    ) %>%
      rownames_to_column(var = "GMGI_ID") %>%
      dplyr::rename(epi.age = lambda.min) %>%
      left_join(meta, by = "GMGI_ID") %>%
      mutate(epi.age = pmax(epi.age, 0))

    pred_test <- as.data.frame(
      predict(cv_model, newx = test_subset, s = "lambda.min")
    ) %>%
      rownames_to_column(var = "GMGI_ID") %>%
      dplyr::rename(epi.age = lambda.min) %>%
      left_join(meta, by = "GMGI_ID") %>%
      mutate(epi.age = pmax(epi.age, 0))

    mae_train[i] <- mean(abs(pred_train$epi.age - pred_train$AgeRounded), na.rm = TRUE)
    mae_test[i] <- mean(abs(pred_test$epi.age - pred_test$AgeRounded), na.rm = TRUE)

    r2_train[i] <- 1 - (
      sum((pred_train$AgeRounded - pred_train$epi.age)^2, na.rm = TRUE) /
        sum((pred_train$AgeRounded - mean(pred_train$AgeRounded, na.rm = TRUE))^2, na.rm = TRUE)
    )

    r2_test[i] <- 1 - (
      sum((pred_test$AgeRounded - pred_test$epi.age)^2, na.rm = TRUE) /
        sum((pred_test$AgeRounded - mean(pred_test$AgeRounded, na.rm = TRUE))^2, na.rm = TRUE)
    )

    coef_list <- coef(cv_model, s = "lambda.min")
    non_zero_indices <- which(coef_list != 0)[-1]
    selected_sites <- subset_cols[non_zero_indices]

    num_sites_chosen[i] <- length(selected_sites)

    cv_models[[i]] <- cv_model
    subset_columns[[i]] <- list(
      input_sites = subset_cols,
      selected_sites = selected_sites
    )

    if (
      is.finite(r2_test[i]) &&
        (
          is.na(best_iteration) ||
            r2_test[i] > best_r2_test ||
            (
              r2_test[i] == best_r2_test &&
                mae_test[i] < mae_test[best_iteration]
            )
        )
    ) {
      best_r2_test <- r2_test[i]
      best_iteration <- i
    }
  }

  if (is.na(best_iteration)) {
    stop("No valid elastic-net model found")
  }

  list(
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
  )
}

safe_run_random_subsets <- function(sample, i) {
  tryCatch(
    {
      if (!is.list(sample) || is.null(sample$training) || is.null(sample$testing)) {
        stop("Bad lasso sample structure")
      }

      run_random_subsets(
        filtered_sample = sample,
        num_iterations = iterations#,
        #num_sites = sites
      )
    },
    error = function(e) {
      message("Elastic net failed for sample ", i, ": ", conditionMessage(e))
      NULL
    }
  )
}

elastic_results <- mclapply(
  seq_along(lasso_processed_samples),
  function(i) safe_run_random_subsets(lasso_processed_samples[[i]], i),
  mc.cores = ncores,
  mc.preschedule = FALSE
)

valid_elastic_idx <- which(!vapply(elastic_results, is.null, logical(1)))

elastic_results_valid <- elastic_results[valid_elastic_idx]
lasso_processed_samples_valid <- lasso_processed_samples[valid_elastic_idx]

cat("\nValid elastic-net samples:", length(elastic_results_valid), "\n")

if (length(elastic_results_valid) == 0) {
  stop("No valid elastic-net results remained. Check earlier error messages.")
}

############ PLOTTING BEST MODELS

all_predictions <- list()

for (j in seq_along(elastic_results_valid)) {
  best_model <- elastic_results_valid[[j]]$best_model
  best_subset <- elastic_results_valid[[j]]$best_input

  filtered_training_matrix <- lasso_processed_samples_valid[[j]]$training
  filtered_testing_matrix <- lasso_processed_samples_valid[[j]]$testing

  best_training_subset <- filtered_training_matrix[, best_subset, drop = FALSE]
  best_testing_subset <- filtered_testing_matrix[, best_subset, drop = FALSE]

  predicted_age <- as.data.frame(
    predict(best_model, newx = best_training_subset, s = "lambda.min")
  ) %>%
    rownames_to_column(var = "GMGI_ID") %>%
    dplyr::rename(epi.age = lambda.min)

  predicted_age_testing <- as.data.frame(
    predict(best_model, newx = best_testing_subset, s = "lambda.min")
  ) %>%
    rownames_to_column(var = "GMGI_ID") %>%
    dplyr::rename(epi.age = lambda.min)

  predicted_age$group <- "training"
  predicted_age_testing$group <- "testing"

  predictions <- full_join(
    predicted_age,
    predicted_age_testing,
    by = join_by(GMGI_ID, epi.age, group)
  ) %>%
    left_join(meta, by = "GMGI_ID") %>%
    mutate(epi.age = pmax(epi.age, 0))

  all_predictions[[j]] <- predictions

  plot <- predictions %>%
    ggplot(aes(x = AgeRounded, y = epi.age)) +
    theme_classic() +
    geom_abline(
      intercept = 0,
      slope = 1,
      linetype = "dashed",
      color = "grey70"
    ) +
    geom_smooth(method = "lm", se = FALSE, color = "grey", alpha = 0.8) +
    geom_point(
      aes(fill = group),
      size = 3,
      alpha = 0.8,
      color = "black",
      shape = 21
    ) +
    scale_fill_manual(values = c("#588157", "grey90")) +
    xlim(0, 12) +
    ylim(0, 12) +
    labs(
      fill = "Set",
      y = "Epigenetic Age",
      x = "Otolith Age"
    ) +
    theme(
      legend.position = "right",
      legend.title = element_text(face = "bold", size = 18),
      legend.text = element_text(size = 16),
      strip.text = element_text(face = "bold", size = 16),
      axis.title.y = element_text(
        margin = margin(t = 0, r = 15, b = 0, l = 0),
        size = 20,
        face = "bold"
      ),
      axis.title.x = element_text(
        margin = margin(t = 10, r = 0, b = 0, l = 0),
        size = 20,
        face = "bold"
      ),
      axis.text.x = element_text(color = "black", size = 16),
      axis.text.y = element_text(color = "black", size = 16),
      plot.caption = element_text(hjust = 0.75, size = 16, face = "italic")
    ) +
    stat_regline_equation(
      label.x = 0.2,
      label.y = 11,
      size = 6,
      aes(label = after_stat(rr.label))
    ) +
    annotate(
      geom = "label",
      x = 0,
      y = 10,
      label = paste0("# Sites: ", length(elastic_results_valid[[j]]$best_selected)),
      hjust = 0,
      vjust = 1,
      label.size = NA,
      color = "black",
      size = 6,
      fill = NA
    ) +
    annotate(
      geom = "label",
      x = 0,
      y = 8.5,
      label = paste0("MAE: ", round(elastic_results_valid[[j]]$best_mae_test, 2)),
      hjust = 0,
      vjust = 1,
      label.size = NA,
      color = "black",
      size = 6,
      fill = NA
    )

  ggsave(
    filename = paste0(EXPORT_PLOT_PATH, j, "_plot.png"),
    plot = plot,
    width = 7,
    height = 5.5
  )
}

############ EXPORTING MODEL DATA

for (j in seq_along(lasso_processed_samples_valid)) {
  sample_obj <- lasso_processed_samples_valid[[j]]
  save_filename <- paste0(EXPORT_LASSO_PATH, j, ".RData")
  save(sample_obj, file = save_filename)
}

for (j in seq_along(elastic_results_valid)) {
  sample_obj_elastic <- elastic_results_valid[[j]]
  save_filename_elastic <- paste0(EXPORT_ELASTIC_PATH, j, ".RData")
  save(sample_obj_elastic, file = save_filename_elastic)
}

cat("\nDONE\n")
cat("Lasso samples saved:", length(lasso_processed_samples_valid), "\n")
cat("Elastic results saved:", length(elastic_results_valid), "\n")
cat("Plots saved:", length(all_predictions), "\n")