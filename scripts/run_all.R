# ==============================================================================
# Master Orchestration Script: run_all.R
# Project: Week 3 - Statistical Analysis and Predictive Modeling Using R
# ==============================================================================

cat("\n==============================================================================\n")
cat("   STARTING END-TO-END WEEK 3 STATISTICAL & PREDICTIVE MODELING PIPELINE       \n")
cat("==============================================================================\n\n")

start_time <- Sys.time()

pipeline_scripts <- c(
  "R/01_setup.R",
  "R/02_import_data.R",
  "R/03_data_quality.R",
  "R/04_data_cleaning.R",
  "R/05_exploratory_statistics.R",
  "R/06_hypothesis_testing.R",
  "R/07_feature_engineering.R",
  "R/08_train_test_split.R",
  "R/09_model_baseline.R",
  "R/10_model_training.R",
  "R/11_cross_validation.R",
  "R/12_model_diagnostics.R",
  "R/13_model_comparison.R",
  "R/14_final_model.R",
  "R/15_predictions.R",
  "R/16_export_results.R"
)

for (s in pipeline_scripts) {
  if (!file.exists(s)) {
    stop("CRITICAL PIPELINE FAILURE: Required script not found: ", s)
  }
  cat(sprintf("\n>>> [%s] SOURCING: %-40s ...\n", format(Sys.time(), "%H:%M:%S"), s))
  source(s)
}

end_time <- Sys.time()
elapsed <- round(as.numeric(difftime(end_time, start_time, units = "secs")), 2)

cat("\n==============================================================================\n")
cat(sprintf("   WEEK 3 PIPELINE COMPLETED IN %.2f SECONDS WITH ZERO FATAL ERRORS!          \n", elapsed))
cat("==============================================================================\n\n")
