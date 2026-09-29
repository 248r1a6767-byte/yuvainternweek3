# ==============================================================================
# Script 11: 5-Fold Cross-Validation for Candidate Models
# Project: Week 3 - Statistical Analysis and Predictive Modeling Using R
# ==============================================================================

if (!exists("lm_model")) source("R/10_model_training.R")

cat(">>> [11_cross_validation.R] Commencing 5-Fold Cross-Validation across candidate models...\n")

formula_model <- as.formula(
  Profit ~ Sales + Discount + Quantity + Shipping_Days + 
           Category + Region + Segment + Ship_Mode
)

K <- length(cv_folds)

# Storage vectors for CV metrics
cv_metrics <- list(
  OLS = list(rmse = numeric(K), mae = numeric(K), r2 = numeric(K)),
  ENET = list(rmse = numeric(K), mae = numeric(K), r2 = numeric(K)),
  RF = list(rmse = numeric(K), mae = numeric(K), r2 = numeric(K))
)

# Prepare model matrices for glmnet
x_train_mat <- model.matrix(formula_model, data = train_data)[, -1] # Remove intercept
y_train_vec <- train_data$Profit

cat(">>> Running Cross-Validation loops...\n")

for (k in 1:K) {
  val_idx <- cv_folds[[k]]
  
  tr_df  <- train_data[-val_idx, ]
  val_df <- train_data[val_idx, ]
  
  y_val <- val_df$Profit
  
  # --- 1. Model 1: OLS Linear Regression ---
  m_ols <- lm(formula_model, data = tr_df)
  pred_ols <- predict(m_ols, newdata = val_df)
  
  cv_metrics$OLS$rmse[k] <- sqrt(mean((y_val - pred_ols)^2))
  cv_metrics$OLS$mae[k]  <- mean(abs(y_val - pred_ols))
  cv_metrics$OLS$r2[k]   <- 1 - (sum((y_val - pred_ols)^2) / sum((y_val - mean(y_val))^2))
  
  # --- 2. Model 2: Elastic Net Regularization (alpha = 0.5) ---
  x_tr_fold  <- model.matrix(formula_model, data = tr_df)[, -1]
  y_tr_fold  <- tr_df$Profit
  x_val_fold <- model.matrix(formula_model, data = val_df)[, -1]
  
  set.seed(GLOBAL_SEED + k)
  cv_enet_tune <- glmnet::cv.glmnet(x_tr_fold, y_tr_fold, alpha = 0.5, nfolds = 5)
  pred_enet <- as.vector(predict(cv_enet_tune, newx = x_val_fold, s = "lambda.1se"))
  
  cv_metrics$ENET$rmse[k] <- sqrt(mean((y_val - pred_enet)^2))
  cv_metrics$ENET$mae[k]  <- mean(abs(y_val - pred_enet))
  cv_metrics$ENET$r2[k]   <- 1 - (sum((y_val - pred_enet)^2) / sum((y_val - mean(y_val))^2))
  
  # --- 3. Model 3: Random Forest Regression ---
  set.seed(GLOBAL_SEED + k)
  m_rf <- randomForest::randomForest(
    formula_model,
    data = tr_df,
    ntree = 200,
    mtry = 3,
    importance = FALSE
  )
  pred_rf <- predict(m_rf, newdata = val_df)
  
  cv_metrics$RF$rmse[k] <- sqrt(mean((y_val - pred_rf)^2))
  cv_metrics$RF$mae[k]  <- mean(abs(y_val - pred_rf))
  cv_metrics$RF$r2[k]   <- 1 - (sum((y_val - pred_rf)^2) / sum((y_val - mean(y_val))^2))
  
  cat(sprintf("    Finished Fold %d/%d (OLS RMSE: $%.1f | ENET RMSE: $%.1f | RF RMSE: $%.1f)\n",
              k, K, cv_metrics$OLS$rmse[k], cv_metrics$ENET$rmse[k], cv_metrics$RF$rmse[k]))
}

# Consolidate Cross-Validation Results Table
cv_summary_table <- tibble(
  Candidate_Model = c(
    "Model 1: Multiple Linear Regression (OLS)",
    "Model 2: Elastic Net Regularization (alpha = 0.5, lambda = 1se)",
    "Model 3: Random Forest Regression (ntree = 200, mtry = 3)"
  ),
  CV_RMSE_Mean = c(mean(cv_metrics$OLS$rmse), mean(cv_metrics$ENET$rmse), mean(cv_metrics$RF$rmse)),
  CV_RMSE_SD   = c(sd(cv_metrics$OLS$rmse), sd(cv_metrics$ENET$rmse), sd(cv_metrics$RF$rmse)),
  CV_MAE_Mean  = c(mean(cv_metrics$OLS$mae), mean(cv_metrics$ENET$mae), mean(cv_metrics$RF$mae)),
  CV_MAE_SD    = c(sd(cv_metrics$OLS$mae), sd(cv_metrics$ENET$mae), sd(cv_metrics$RF$mae)),
  CV_R2_Mean   = c(mean(cv_metrics$OLS$r2), mean(cv_metrics$ENET$r2), mean(cv_metrics$RF$r2)),
  CV_R2_SD     = c(sd(cv_metrics$OLS$r2), sd(cv_metrics$ENET$r2), sd(cv_metrics$RF$r2))
) %>%
  mutate(across(where(is.numeric), ~ round(.x, 3)))

readr::write_csv(cv_summary_table, "outputs/tables/cross_validation_performance_summary.csv")
saveRDS(cv_metrics, "outputs/diagnostics/cross_validation_raw_metrics.rds")

# Visual comparison of CV folds
cv_folds_df <- tibble(
  Fold = rep(1:K, 3),
  Model = factor(rep(c("OLS Linear Regression", "Elastic Net (alpha=0.5)", "Random Forest (ntree=200)"), each = K)),
  RMSE = c(cv_metrics$OLS$rmse, cv_metrics$ENET$rmse, cv_metrics$RF$rmse),
  MAE = c(cv_metrics$OLS$mae, cv_metrics$ENET$mae, cv_metrics$RF$mae)
)

fig08_cv_box <- ggplot(cv_folds_df, aes(x = Model, y = RMSE, fill = Model)) +
  geom_boxplot(width = 0.45, alpha = 0.85, color = "#1B365D", outlier.shape = NA) +
  geom_jitter(width = 0.12, size = 3, color = "#D97706", alpha = 0.9) +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 4.5, fill = "#FFFFFF", color = "#1B365D") +
  scale_fill_manual(values = c("OLS Linear Regression" = "#4B6B94", "Elastic Net (alpha=0.5)" = "#059669", "Random Forest (ntree=200)" = "#1B365D")) +
  scale_y_continuous(labels = dollar_format()) +
  labs(
    title = "5-Fold Cross-Validation Performance: Validation RMSE by Model",
    subtitle = "Boxplots show fold distributions; white diamonds denote Mean CV RMSE; gold points show individual folds",
    x = "Candidate Predictive Model", y = "Cross-Validation RMSE (USD)"
  ) +
  theme(legend.position = "none")

ggsave("visualizations/model_performance/08_cv_model_comparison.png", fig08_cv_box, width = 8.5, height = 5.5, dpi = 300)

cat(">>> [11_cross_validation.R] 5-Fold Cross-Validation completed and saved.\n")
