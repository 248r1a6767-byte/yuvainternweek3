# ==============================================================================
# Script 16: Centralized Output Export and Quality Assurance Audit
# Project: Week 3 - Statistical Analysis and Predictive Modeling Using R
# ==============================================================================

if (!exists("test_eval_df")) source("R/15_predictions.R")

cat(">>> [16_export_results.R] Consolidating all analytical outputs and QA audit...\n")

# 1. Capture Formatted Text Outputs for Console / Screenshots
sink("screenshots/output/01_dataset_structure.txt")
cat("=== DATASET STRUCTURE (glimpse & str) ===\n")
dplyr::glimpse(superstore_clean)
sink()

sink("screenshots/output/02_summary_statistics.txt")
cat("=== NUMERICAL DESCRIPTIVE STATISTICS ===\n")
print(as.data.frame(num_stats))
sink()

sink("screenshots/output/03_hypothesis_test_1.txt")
cat("=== HYPOTHESIS TEST 1: WELCH TWO-SAMPLE T-TEST ===\n")
print(welch_t1)
cat("\nCohen's d Effect Size:\n")
print(cohen_t1)
sink()

sink("screenshots/output/04_hypothesis_test_2.txt")
cat("=== HYPOTHESIS TEST 2: ONE-WAY ANOVA & TUKEY HSD ===\n")
print(aov_summary)
cat("\nPost-Hoc Tukey HSD:\n")
print(tukey_posthoc)
sink()

sink("screenshots/output/05_correlation_output.txt")
cat("=== BIVARIATE CORRELATION MATRICES ===\n")
cat("\n--- Pearson Linear Correlation ---\n")
print(round(pearson_mat, 4))
cat("\n--- Spearman Rank Correlation ---\n")
print(round(spearman_mat, 4))
sink()

sink("screenshots/output/06_model_summary.txt")
cat("=== OLS MULTIPLE LINEAR REGRESSION SUMMARY ===\n")
print(lm_summary)
cat("\nVariance Inflation Factors (VIF):\n")
print(vif_df)
sink()

sink("screenshots/output/07_cross_validation_results.txt")
cat("=== 5-FOLD CROSS-VALIDATION SUMMARY ===\n")
print(as.data.frame(cv_summary_table))
sink()

sink("screenshots/output/08_residual_diagnostics.txt")
cat("=== REGRESSION INFLUENCE & LEVERAGE AUDIT (TOP 10 COOK'S D) ===\n")
print(as.data.frame(influential_audit))
sink()

sink("screenshots/output/09_model_performance.txt")
cat("=== MASTER MODEL EVALUATION ON UNSEEN TEST DATA ===\n")
print(as.data.frame(model_comparison_master))
sink()

sink("screenshots/output/10_final_evaluation.txt")
cat("=== CHAMPION RANDOM FOREST TEST SET PERFORMANCE ===\n")
cat(sprintf("Test RMSE: $%.2f\n", test_rmse_rf))
cat(sprintf("Test MAE : $%.2f\n", test_mae_rf))
cat(sprintf("Test R2  : %.4f\n", test_r2_rf))
cat("\nTop Prediction Residuals:\n")
print(as.data.frame(top_errors))
sink()

# 2. Render Code & Console Terminal Captures as PNG Images (Phase 42 & 54)
render_text_card <- function(title_text, content_lines, outfile, width = 9, height = 5.5) {
  df <- tibble(
    line_no = seq_along(content_lines),
    text = content_lines
  )
  p <- ggplot(df, aes(x = 1, y = -line_no, label = text)) +
    geom_text(hjust = 0, family = "mono", size = 3.2, color = "#1E293B") +
    scale_y_continuous(limits = c(-max(length(content_lines), 20) - 2, 0)) +
    scale_x_continuous(limits = c(0.9, 2.5)) +
    theme_void() +
    theme(
      plot.background = element_rect(fill = "#F8FAFC", color = "#CBD5E1", linewidth = 1),
      plot.title = element_text(face = "bold", size = 11, color = "#1B365D", margin = ggplot2::margin(t = 10, b = 6, l = 10)),
      plot.margin = ggplot2::margin(10, 10, 10, 10)
    ) +
    labs(title = title_text)
  ggsave(outfile, p, width = width, height = height, dpi = 300)
}

# Generate PNG Captures for Key Statistical Outputs
s1_lines <- readLines("screenshots/output/01_dataset_structure.txt")[1:min(20, length(readLines("screenshots/output/01_dataset_structure.txt")))]
render_text_card("R Console Output: Dataset Structure & Schema", s1_lines, "screenshots/output/01_dataset_structure.png")

s3_lines <- readLines("screenshots/output/03_hypothesis_test_1.txt")[1:min(18, length(readLines("screenshots/output/03_hypothesis_test_1.txt")))]
render_text_card("R Console Output: Hypothesis Test 1 (Welch's Two-Sample t-Test)", s3_lines, "screenshots/output/03_hypothesis_test_1.png")

s4_lines <- readLines("screenshots/output/04_hypothesis_test_2.txt")[1:min(18, length(readLines("screenshots/output/04_hypothesis_test_2.txt")))]
render_text_card("R Console Output: Hypothesis Test 2 (ANOVA & Tukey HSD)", s4_lines, "screenshots/output/04_hypothesis_test_2.png")

s6_lines <- readLines("screenshots/output/06_model_summary.txt")[1:min(20, length(readLines("screenshots/output/06_model_summary.txt")))]
render_text_card("R Console Output: OLS Linear Regression Summary & VIF", s6_lines, "screenshots/output/06_model_summary.png")

s9_lines <- readLines("screenshots/output/09_model_performance.txt")[1:min(15, length(readLines("screenshots/output/09_model_performance.txt")))]
render_text_card("R Console Output: Final Model Comparison (CV & Test Metrics)", s9_lines, "screenshots/output/09_model_performance.png")

# 3. Save Centralized Execution Manifest
execution_manifest <- list(
  timestamp       = Sys.time(),
  r_version       = R.version.string,
  seed            = GLOBAL_SEED,
  raw_observations= nrow(superstore_raw),
  clean_rows      = nrow(superstore_clean),
  train_rows      = nrow(train_data),
  test_rows       = nrow(test_data),
  cv_folds        = K,
  champion_model  = "Random Forest Regression (ntree = 200, mtry = 3)",
  champion_test_rmse = test_rmse_rf,
  champion_test_mae  = test_mae_rf,
  champion_test_r2   = test_r2_rf,
  baseline_test_rmse = test_rmse_base,
  ols_test_rmse      = test_rmse_ols,
  enet_test_rmse     = test_rmse_enet
)

saveRDS(execution_manifest, "outputs/diagnostics/week3_execution_manifest.rds")

# Export manifest as CSV
manifest_df <- tibble(
  Metric_Key   = names(execution_manifest),
  Metric_Value = as.character(execution_manifest)
)
readr::write_csv(manifest_df, "outputs/diagnostics/week3_execution_manifest.csv")

cat(">>> [16_export_results.R] Execution manifest and capture outputs generated successfully.\n")
