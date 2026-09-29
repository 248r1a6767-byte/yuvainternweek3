# ==============================================================================
# Script 08: Train/Test Partitioning and Cross-Validation Scheme
# Project: Week 3 - Statistical Analysis and Predictive Modeling Using R
# ==============================================================================

if (!exists("superstore_engineered")) source("R/07_feature_engineering.R")

cat(">>> [08_train_test_split.R] Partitioning data (80% Train / 20% Test)...\n")

set.seed(GLOBAL_SEED)

n_total <- nrow(superstore_engineered)
train_indices <- sample(seq_len(n_total), size = round(0.80 * n_total), replace = FALSE)

train_data <- superstore_engineered[train_indices, ]
test_data  <- superstore_engineered[-train_indices, ]

cat(sprintf(">>> Train partition: %d observations (%.2f%%)\n", nrow(train_data), (nrow(train_data) / n_total) * 100))
cat(sprintf(">>> Test partition : %d observations (%.2f%%) [HELD OUT / UNTOUCHED]\n", nrow(test_data), (nrow(test_data) / n_total) * 100))

# Create 5-Fold Cross-Validation partition indices on training data
K_FOLDS <- 5
n_train <- nrow(train_data)
fold_assignments <- sample(rep(1:K_FOLDS, length.out = n_train))
cv_folds <- split(seq_len(n_train), fold_assignments)

saveRDS(train_data, "data/processed/train_data.rds")
saveRDS(test_data, "data/processed/test_data.rds")
saveRDS(cv_folds, "data/processed/cv_folds.rds")

# Export split summary audit
split_summary <- tibble(
  Partition = c("Training Set", "Validation Scheme (Inside Train)", "Test Set (Final Evaluation)", "Total Complete Master"),
  Observations = c(nrow(train_data), nrow(train_data), nrow(test_data), n_total),
  Percentage = c("80.00%", "5-Fold Cross-Validation (K=5)", "20.00%", "100.00%"),
  Target_Mean = c(sprintf("$%.2f", mean(train_data$Profit)), "Cross-Fold Mean", sprintf("$%.2f", mean(test_data$Profit)), sprintf("$%.2f", mean(superstore_engineered$Profit))),
  Target_SD = c(sprintf("$%.2f", sd(train_data$Profit)), "Cross-Fold SD", sprintf("$%.2f", sd(test_data$Profit)), sprintf("$%.2f", sd(superstore_engineered$Profit))),
  Target_Min = c(sprintf("$%.2f", min(train_data$Profit)), "Cross-Fold Min", sprintf("$%.2f", min(test_data$Profit)), sprintf("$%.2f", min(superstore_engineered$Profit))),
  Target_Max = c(sprintf("$%.2f", max(train_data$Profit)), "Cross-Fold Max", sprintf("$%.2f", max(test_data$Profit)), sprintf("$%.2f", max(superstore_engineered$Profit))),
  Usage_Protocol = c(
    "Model estimation, feature transformation, parameter learning",
    "Hyperparameter tuning & out-of-fold performance estimation",
    "Strictly untouched; evaluated exactly ONCE for final generalization",
    "Source empirical population"
  )
)

readr::write_csv(split_summary, "outputs/tables/train_test_split_summary.csv")

cat(">>> [08_train_test_split.R] Splitting completed and cached.\n")
