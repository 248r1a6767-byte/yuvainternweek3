# ==============================================================================
# Script 15: Out-of-Sample Predictions and Forensic Error Analysis
# Project: Week 3 - Statistical Analysis and Predictive Modeling Using R
# ==============================================================================

if (!exists("pred_test_rf")) source("R/13_model_comparison.R")

cat(">>> [15_predictions.R] Generating test predictions and auditing errors...\n")

# Construct Comprehensive Test Prediction Dataset
test_eval_df <- test_data %>%
  mutate(
    Predicted_Profit_Baseline = pred_test_base,
    Predicted_Profit_OLS      = pred_test_ols,
    Predicted_Profit_RF       = pred_test_rf,
    Residual_RF               = Profit - pred_test_rf,
    Abs_Residual_RF           = abs(Residual_RF),
    Pct_Error_RF              = ifelse(Profit != 0, (Residual_RF / Profit) * 100, NA)
  )

readr::write_csv(test_eval_df, "outputs/predictions/test_set_predictions.csv")

# Forensic Audit of Top 10 Largest Prediction Errors
top_errors <- test_eval_df %>%
  arrange(desc(Abs_Residual_RF)) %>%
  slice_head(n = 10) %>%
  select(Order_ID, Customer_Name, Category, Sub_Category, Sales, Discount, Profit, Predicted_Profit_RF, Residual_RF) %>%
  mutate(
    Error_Type = ifelse(Residual_RF > 0, "Under-predicted (Profit > Pred)", "Over-predicted (Profit < Pred)"),
    across(where(is.numeric), ~ round(.x, 2))
  )

readr::write_csv(top_errors, "outputs/tables/top_prediction_errors_audit.csv")

# Error breakdown across Merchandise Categories
cat_error_summary <- test_eval_df %>%
  group_by(Category) %>%
  summarise(
    Test_N     = n(),
    Mean_Profit= round(mean(Profit), 2),
    RMSE_RF    = round(sqrt(mean(Residual_RF^2)), 2),
    MAE_RF     = round(mean(Abs_Residual_RF), 2),
    .groups    = "drop"
  )

readr::write_csv(cat_error_summary, "outputs/tables/category_error_breakdown.csv")

# ==============================================================================
# Visualizations: Actual vs Predicted and Residual Distribution
# ==============================================================================
cat(">>> Generating prediction evaluation visual exhibits...\n")

# Fig 12: Actual vs Predicted Scatter Plot (Random Forest vs OLS)
fig12_actual_pred <- ggplot(test_eval_df, aes(x = Profit, y = Predicted_Profit_RF)) +
  geom_point(alpha = 0.35, color = "#1B365D", size = 1.4) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "#DC2626", linewidth = 1) +
  geom_smooth(method = "loess", color = "#D97706", se = FALSE, linewidth = 0.9) +
  scale_x_continuous(labels = dollar_format()) +
  scale_y_continuous(labels = dollar_format()) +
  coord_cartesian(xlim = c(-2000, 3000), ylim = c(-2000, 3000)) +
  annotate("text", x = -1500, y = 2500, 
           label = sprintf("Champion RF Model\nTest R2 = %.4f\nTest RMSE = $%.2f\nRed dashed line: Perfect 45-deg prediction", 
                           test_rmse_rf, test_rmse_rf),
           color = "#1B365D", size = 3.6, fontface = "bold", hjust = 0) +
  labs(
    title = "Actual vs. Predicted Transaction Profit on Untouched Test Data",
    subtitle = "Champion Random Forest model performance on n = 1,999 unseen holdout observations",
    x = "Actual Ground-Truth Profit (USD)", y = "Model-Predicted Profit (USD)"
  )

ggsave("visualizations/model_performance/12_actual_vs_predicted.png", fig12_actual_pred, width = 8.5, height = 6, dpi = 300)

# Fig 13: Prediction Residual Distribution and Quantile Plot
p13_hist <- ggplot(test_eval_df, aes(x = Residual_RF)) +
  geom_histogram(bins = 50, fill = "#1B365D", color = "white", alpha = 0.85) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "#DC2626") +
  scale_x_continuous(labels = dollar_format()) +
  coord_cartesian(xlim = c(-1000, 1000)) +
  labs(title = "A: Test Set Residual Distribution", x = "Residual (Actual - Predicted)", y = "Count")

p13_box <- ggplot(test_eval_df, aes(x = Category, y = Residual_RF, fill = Category)) +
  geom_boxplot(outlier.alpha = 0.3, width = 0.45) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#DC2626") +
  scale_fill_manual(values = c("Furniture" = "#D97706", "Office Supplies" = "#4B6B94", "Technology" = "#1B365D")) +
  scale_y_continuous(labels = dollar_format()) +
  coord_cartesian(ylim = c(-500, 500)) +
  labs(title = "B: Prediction Errors across Categories", x = "Category", y = "Residual ($USD)") +
  theme(legend.position = "none")

fig13_residuals <- p13_hist / p13_box + plot_annotation(
  title = "Out-of-Sample Error Analysis: Residual Profiles across Holdout Orders",
  subtitle = "Evaluation of prediction bias, error symmetry, and categorical dispersion",
  theme = theme_week3_model()
)

ggsave("visualizations/model_performance/13_prediction_residual_analysis.png", fig13_residuals, width = 9.5, height = 7, dpi = 300)

cat(">>> [15_predictions.R] Test predictions, top errors, and visual diagnostics saved.\n")
