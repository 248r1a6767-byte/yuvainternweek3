# ==============================================================================
# Script 09: Baseline Benchmark Model Evaluation
# Project: Week 3 - Statistical Analysis and Predictive Modeling Using R
# ==============================================================================

if (!exists("train_data")) source("R/08_train_test_split.R")

cat(">>> [09_model_baseline.R] Evaluating naive baseline mean predictor...\n")

# Calculate training set mean
baseline_mean <- mean(train_data$Profit)

# Evaluate Baseline over 5-Fold Cross-Validation
cv_baseline_rmse <- numeric(length(cv_folds))
cv_baseline_mae  <- numeric(length(cv_folds))

for (k in seq_along(cv_folds)) {
  val_indices <- cv_folds[[k]]
  val_fold    <- train_data[val_indices, ]
  tr_fold     <- train_data[-val_indices, ]
  
  fold_mean <- mean(tr_fold$Profit)
  fold_preds <- rep(fold_mean, nrow(val_fold))
  
  cv_baseline_rmse[k] <- sqrt(mean((val_fold$Profit - fold_preds)^2))
  cv_baseline_mae[k]  <- mean(abs(val_fold$Profit - fold_preds))
}

# Test set evaluation
test_preds_baseline <- rep(baseline_mean, nrow(test_data))
test_baseline_rmse <- sqrt(mean((test_data$Profit - test_preds_baseline)^2))
test_baseline_mae  <- mean(abs(test_data$Profit - test_preds_baseline))
test_baseline_r2   <- 0.000 # Naive mean model explains 0% of variance by definition

baseline_results <- tibble(
  Model           = "Model 0: Naive Mean Baseline",
  Predictor_Count = 0,
  Tuning_Params   = "None (Intercept only = mean(y_train))",
  CV_RMSE_Mean    = round(mean(cv_baseline_rmse), 2),
  CV_RMSE_SD      = round(sd(cv_baseline_rmse), 2),
  CV_MAE_Mean     = round(mean(cv_baseline_mae), 2),
  CV_MAE_SD       = round(sd(cv_baseline_mae), 2),
  CV_R2_Mean      = 0.000,
  Test_RMSE       = round(test_baseline_rmse, 2),
  Test_MAE        = round(test_baseline_mae, 2),
  Test_R2         = 0.000,
  Model_Role      = "Reference benchmark for evaluating candidate predictive models"
)

saveRDS(list(mean = baseline_mean, results = baseline_results), "models/model_objects/baseline_model.rds")
readr::write_csv(baseline_results, "outputs/tables/model_baseline_performance.csv")

cat(sprintf(">>> Baseline Model: CV RMSE = $%.2f, Test RMSE = $%.2f, Test MAE = $%.2f\n",
            mean(cv_baseline_rmse), test_baseline_rmse, test_baseline_mae))
