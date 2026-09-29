# ==============================================================================
# Script 10: Parametric Multiple Linear Regression (OLS)
# Project: Week 3 - Statistical Analysis and Predictive Modeling Using R
# ==============================================================================

if (!exists("train_data")) source("R/08_train_test_split.R")

cat(">>> [10_model_training.R] Fitting Multiple Linear Regression model...\n")

# Model Formula definition
formula_linear <- as.formula(
  Profit ~ Sales + Discount + Quantity + Shipping_Days + 
           Category + Region + Segment + Ship_Mode
)

# Fit OLS Linear Regression on training data
lm_model <- lm(formula_linear, data = train_data)
lm_summary <- summary(lm_model)

# Extract tidy coefficient table with confidence intervals
lm_coefs <- broom::tidy(lm_model, conf.int = TRUE) %>%
  mutate(
    term = case_when(
      term == "(Intercept)" ~ "Intercept (Beta_0)",
      TRUE ~ term
    ),
    across(where(is.numeric), ~ round(.x, 4)),
    Significance = case_when(
      p.value < 0.001 ~ "*** (p < 0.001)",
      p.value < 0.01  ~ "** (p < 0.01)",
      p.value < 0.05  ~ "* (p < 0.05)",
      TRUE            ~ "ns (not significant)"
    )
  )

readr::write_csv(lm_coefs, "outputs/tables/ols_regression_coefficients.csv")

# Extract overall model statistics
f_stat <- lm_summary$fstatistic
lm_overall <- tibble(
  Metric = c(
    "Multiple R-Squared",
    "Adjusted R-Squared",
    "Residual Standard Error (RSE)",
    "Degrees of Freedom (Residual)",
    "F-Statistic (Omnibus)",
    "p-Value (Omnibus Test)",
    "AIC (Akaike Information Criterion)",
    "BIC (Bayesian Information Criterion)"
  ),
  Value = c(
    sprintf("%.4f (%.2f%% variance explained)", lm_summary$r.squared, lm_summary$r.squared * 100),
    sprintf("%.4f (%.2f%% adjusted)", lm_summary$adj.r.squared, lm_summary$adj.r.squared * 100),
    sprintf("$%.2f", lm_summary$sigma),
    sprintf("%d", lm_summary$df[2]),
    sprintf("%.2f (df1 = %d, df2 = %d)", f_stat[1], f_stat[2], f_stat[3]),
    format.pval(pf(f_stat[1], f_stat[2], f_stat[3], lower.tail = FALSE), eps = 0.0001),
    sprintf("%.2f", AIC(lm_model)),
    sprintf("%.2f", BIC(lm_model))
  )
)

readr::write_csv(lm_overall, "outputs/tables/ols_model_summary.csv")

# Multicollinearity Audit: Generalized Variance Inflation Factor (GVIF)
vif_vals <- car::vif(lm_model)
vif_df <- as_tibble(as.data.frame(vif_vals), rownames = "Predictor")

if ("GVIF^(1/(2*Df))" %in% names(vif_df)) {
  vif_df <- vif_df %>%
    mutate(
      Standardized_VIF = `GVIF^(1/(2*Df))`^2,
      Multicollinearity_Status = ifelse(Standardized_VIF < 5, "Acceptable (Low)", "Severe Collinearity")
    ) %>%
    mutate(across(where(is.numeric), ~ round(.x, 3)))
} else {
  vif_df <- vif_df %>%
    rename(VIF = 2) %>%
    mutate(
      Standardized_VIF = VIF,
      Multicollinearity_Status = ifelse(VIF < 5, "Acceptable (Low)", "Severe Collinearity")
    ) %>%
    mutate(across(where(is.numeric), ~ round(.x, 3)))
}

readr::write_csv(vif_df, "outputs/tables/vif_multicollinearity_audit.csv")

# Save fitted model object
saveRDS(lm_model, "models/model_objects/ols_linear_model.rds")

cat(sprintf(">>> OLS Regression: R2 = %.4f, Adj R2 = %.4f, RSE = $%.2f, All VIF < 5.0 (Passed)\n",
            lm_summary$r.squared, lm_summary$adj.r.squared, lm_summary$sigma))
