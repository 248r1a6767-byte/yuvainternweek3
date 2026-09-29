# ==============================================================================
# Script 14: Champion Model Architecture and Feature Importance
# Project: Week 3 - Statistical Analysis and Predictive Modeling Using R
# ==============================================================================

if (!exists("rf_full")) source("R/13_model_comparison.R")

cat(">>> [14_final_model.R] Analyzing champion model (Random Forest)...\n")

# Extract Random Forest Feature Importance
rf_imp_mat <- randomForest::importance(rf_full)
imp_df <- as_tibble(rf_imp_mat, rownames = "Feature") %>%
  rename(
    Pct_Inc_MSE = `%IncMSE`,
    Inc_Node_Purity = IncNodePurity
  ) %>%
  arrange(desc(Pct_Inc_MSE)) %>%
  mutate(across(where(is.numeric), ~ round(.x, 2)))

readr::write_csv(imp_df, "outputs/tables/feature_importance_rf.csv")

# Save Champion Model Object
saveRDS(rf_full, "models/model_objects/champion_random_forest.rds")

# Visual: Feature Importance Bar Plot
fig11_feat_imp <- ggplot(imp_df, aes(x = reorder(Feature, Pct_Inc_MSE), y = Pct_Inc_MSE, fill = Pct_Inc_MSE)) +
  geom_col(width = 0.55, alpha = 0.9, color = "#1B365D") +
  geom_text(aes(label = sprintf("%.1f%%", Pct_Inc_MSE)), hjust = -0.15, fontface = "bold", size = 3.6) +
  coord_flip() +
  scale_fill_gradient(low = "#4B6B94", high = "#1B365D", name = "% Inc MSE") +
  scale_y_continuous(limits = c(0, max(imp_df$Pct_Inc_MSE) * 1.15)) +
  labs(
    title = "Predictor Importance in Champion Random Forest Model",
    subtitle = "Percentage Increase in Mean Squared Error (%IncMSE) following predictor permutation",
    x = "Predictor Variable", y = "% Increase in Out-of-Bag MSE",
    caption = "Higher values denote greater predictive contribution; feature importance does not establish direct causation."
  ) +
  theme(legend.position = "none")

ggsave("visualizations/model_performance/11_feature_importance_rf.png", fig11_feat_imp, width = 8.5, height = 5.5, dpi = 300)

cat(">>> [14_final_model.R] Champion model feature importance exported.\n")
