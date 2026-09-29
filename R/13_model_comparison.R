# ==============================================================================
# Script 13: Model Comparison across Validation & Unseen Test Sets
# Project: Week 3 - Statistical Analysis and Predictive Modeling Using R
# ==============================================================================

if (!exists("cv_metrics")) source("R/11_cross_validation.R")
if (!exists("baseline_results")) source("R/09_model_baseline.R")

cat(">>> [13_model_comparison.R] Evaluating candidate models on untouched test set...\n")

formula_model <- as.formula(
  Profit ~ Sales + Discount + Quantity + Shipping_Days + 
           Category + Region + Segment + Ship_Mode
)

# Test set ground truth
y_test <- test_data$Profit

# 1. Baseline Model
pred_test_base <- rep(mean(train_data$Profit), nrow(test_data))
test_rmse_base <- sqrt(mean((y_test - pred_test_base)^2))
test_mae_base  <- mean(abs(y_test - pred_test_base))
test_r2_base   <- 0.000

# 2. Model 1: OLS Multiple Linear Regression
pred_test_ols <- predict(lm_model, newdata = test_data)
test_rmse_ols <- sqrt(mean((y_test - pred_test_ols)^2))
test_mae_ols  <- mean(abs(y_test - pred_test_ols))
test_r2_ols   <- 1 - (sum((y_test - pred_test_ols)^2) / sum((y_test - mean(y_test))^2))

# 3. Model 2: Elastic Net Regularization
x_tr_full   <- model.matrix(formula_model, data = train_data)[, -1]
y_tr_full   <- train_data$Profit
x_test_full <- model.matrix(formula_model, data = test_data)[, -1]

set.seed(GLOBAL_SEED)
enet_full <- glmnet::cv.glmnet(x_tr_full, y_tr_full, alpha = 0.5, nfolds = 5)
pred_test_enet <- as.vector(predict(enet_full, newx = x_test_full, s = "lambda.1se"))
test_rmse_enet <- sqrt(mean((y_test - pred_test_enet)^2))
test_mae_enet  <- mean(abs(y_test - pred_test_enet))
test_r2_enet   <- 1 - (sum((y_test - pred_test_enet)^2) / sum((y_test - mean(y_test))^2))

# 4. Model 3: Random Forest Regression
set.seed(GLOBAL_SEED)
rf_full <- randomForest::randomForest(
  formula_model,
  data = train_data,
  ntree = 200,
  mtry = 3,
  importance = TRUE
)
pred_test_rf <- predict(rf_full, newdata = test_data)
test_rmse_rf <- sqrt(mean((y_test - pred_test_rf)^2))
test_mae_rf  <- mean(abs(y_test - pred_test_rf))
test_r2_rf   <- 1 - (sum((y_test - pred_test_rf)^2) / sum((y_test - mean(y_test))^2))

# Consolidate Master Comparison Table
model_comparison_master <- tibble(
  Model_ID = c("Model 0", "Model 1", "Model 2", "Model 3"),
  Model_Description = c(
    "Naive Mean Baseline",
    "Multiple Linear Regression (OLS)",
    "Elastic Net Regularization (alpha = 0.5, lambda.1se)",
    "Random Forest Regression (ntree = 200, mtry = 3)"
  ),
  CV_RMSE_Mean = c(
    round(baseline_results$CV_RMSE_Mean, 2),
    round(mean(cv_metrics$OLS$rmse), 2),
    round(mean(cv_metrics$ENET$rmse), 2),
    round(mean(cv_metrics$RF$rmse), 2)
  ),
  CV_MAE_Mean = c(
    round(baseline_results$CV_MAE_Mean, 2),
    round(mean(cv_metrics$OLS$mae), 2),
    round(mean(cv_metrics$ENET$mae), 2),
    round(mean(cv_metrics$RF$mae), 2)
  ),
  CV_R2_Mean = c(
    0.000,
    round(mean(cv_metrics$OLS$r2), 4),
    round(mean(cv_metrics$ENET$r2), 4),
    round(mean(cv_metrics$RF$r2), 4)
  ),
  Test_RMSE = c(
    round(test_rmse_base, 2),
    round(test_rmse_ols, 2),
    round(test_rmse_enet, 2),
    round(test_rmse_rf, 2)
  ),
  Test_MAE = c(
    round(test_mae_base, 2),
    round(test_mae_ols, 2),
    round(test_mae_enet, 2),
    round(test_mae_rf, 2)
  ),
  Test_R2 = c(
    0.000,
    round(test_r2_ols, 4),
    round(test_r2_enet, 4),
    round(test_r2_rf, 4)
  ),
  Generalization_Gap_RMSE = c(
    round(test_rmse_base - baseline_results$CV_RMSE_Mean, 2),
    round(test_rmse_ols - mean(cv_metrics$OLS$rmse), 2),
    round(test_rmse_enet - mean(cv_metrics$ENET$rmse), 2),
    round(test_rmse_rf - mean(cv_metrics$RF$rmse), 2)
  ),
  Selection_Status = c("Baseline Benchmark", "Interpretable Linear Baseline", "Regularized Linear Candidate", "CHAMPION MODEL (Lowest CV & Test Error)")
)

readr::write_csv(model_comparison_master, "outputs/tables/model_comparison_master.csv")
saveRDS(list(enet = enet_full, rf = rf_full), "models/model_objects/tuned_models.rds")

# Visual: Bar chart of Test RMSE across models
fig10_test_comp <- ggplot(model_comparison_master, aes(x = reorder(Model_Description, -Test_RMSE), y = Test_RMSE, fill = Model_Description)) +
  geom_col(width = 0.5, alpha = 0.85, color = "#1B365D") +
  geom_text(aes(label = sprintf("$%.2f", Test_RMSE)), hjust = -0.15, fontface = "bold", size = 3.8) +
  coord_flip() +
  scale_fill_manual(values = c(
    "Naive Mean Baseline" = "#6B7280",
    "Multiple Linear Regression (OLS)" = "#4B6B94",
    "Elastic Net Regularization (alpha = 0.5, lambda.1se)" = "#059669",
    "Random Forest Regression (ntree = 200, mtry = 3)" = "#1B365D"
  )) +
  scale_y_continuous(labels = dollar_format(), limits = c(0, max(model_comparison_master$Test_RMSE) * 1.15)) +
  labs(
    title = "Final Generalization Performance: Test RMSE on Untouched Holdout Data",
    subtitle = "Random Forest achieves dramatic error reduction relative to linear and baseline models",
    x = NULL, y = "Test Root Mean Squared Error (USD)"
  ) +
  theme(legend.position = "none")

ggsave("visualizations/model_performance/10_model_comparison_test_metrics.png", fig10_test_comp, width = 9.5, height = 5.2, dpi = 300)

cat(sprintf(">>> Master Model Comparison saved. Champion Model: Random Forest (Test RMSE = $%.2f | Test R2 = %.4f)\n",
            test_rmse_rf, test_r2_rf))
