# ==============================================================================
# Script 12: Parametric Regression Assumption Diagnostics
# Project: Week 3 - Statistical Analysis and Predictive Modeling Using R
# ==============================================================================

if (!exists("lm_model")) source("R/10_model_training.R")

cat(">>> [12_model_diagnostics.R] Generating 4-panel regression diagnostic plots...\n")

# Augment training data with residuals, fitted values, studentized residuals, and leverage
diag_data <- tibble(
  Fitted          = fitted(lm_model),
  Residuals       = residuals(lm_model),
  Std_Residuals   = rstandard(lm_model),
  Sqrt_Abs_StdRes = sqrt(abs(rstandard(lm_model))),
  Leverage_H      = hatvalues(lm_model),
  Cooks_D         = cooks.distance(lm_model)
)

# Plot 1: Residuals vs Fitted (Linearity & Homoscedasticity)
p_diag1 <- ggplot(diag_data, aes(x = Fitted, y = Residuals)) +
  geom_point(alpha = 0.25, color = "#1B365D", size = 1.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#DC2626") +
  geom_smooth(method = "loess", color = "#D97706", se = FALSE, linewidth = 1) +
  scale_x_continuous(labels = dollar_format()) +
  scale_y_continuous(labels = dollar_format()) +
  labs(title = "1. Linearity & Homoscedasticity",
       subtitle = "Residuals vs Fitted Values (Funneling reflects retail profit variance)",
       x = "Fitted Values ($USD)", y = "Residuals ($USD)")

# Plot 2: Normal Q-Q Plot (Residual Normality)
p_diag2 <- ggplot(diag_data, aes(sample = Std_Residuals)) +
  stat_qq(alpha = 0.25, color = "#1B365D", size = 1.2) +
  stat_qq_line(color = "#DC2626", linewidth = 1) +
  labs(title = "2. Normality of Residuals",
       subtitle = "Standardized Residual Q-Q Plot (Pronounced heavy tails)",
       x = "Theoretical Standard Normal Quantiles", y = "Standardized Residuals")

# Plot 3: Scale-Location Plot (Spread-Location)
p_diag3 <- ggplot(diag_data, aes(x = Fitted, y = Sqrt_Abs_StdRes)) +
  geom_point(alpha = 0.25, color = "#1B365D", size = 1.2) +
  geom_smooth(method = "loess", color = "#D97706", se = FALSE, linewidth = 1) +
  scale_x_continuous(labels = dollar_format()) +
  labs(title = "3. Scale-Location (Spread-Location)",
       subtitle = "sqrt(|Standardized Residuals|) vs Fitted Values",
       x = "Fitted Values ($USD)", y = "sqrt(|Standardized Residuals|)")

# Plot 4: Residuals vs Leverage & Cook's Distance
p_diag4 <- ggplot(diag_data, aes(x = Leverage_H, y = Std_Residuals)) +
  geom_point(aes(size = Cooks_D), alpha = 0.35, color = "#1B365D") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#DC2626") +
  geom_smooth(method = "loess", color = "#D97706", se = FALSE, linewidth = 1) +
  scale_size_continuous(range = c(1, 6), name = "Cook's D") +
  labs(title = "4. Influence & Leverage Diagnostics",
       subtitle = "Standardized Residuals vs Leverage with Cook's Distance weighting",
       x = "Leverage (Hat Value h_ii)", y = "Standardized Residuals")

# Assemble 4-panel diagnostic figure
fig09_diagnostics <- (p_diag1 + p_diag2) / (p_diag3 + p_diag4) +
  plot_annotation(
    title = "Statistical Diagnostic Suite: Multiple Linear Regression Assumptions",
    subtitle = "Rigorous empirical evaluation of OLS Gauss-Markov conditions on Superstore transaction dataset",
    theme = theme_week3_model()
  )

ggsave("visualizations/diagnostics/09_regression_diagnostics_4panel.png", fig09_diagnostics, width = 11, height = 8.5, dpi = 300)

# Export Influential Observations Audit (Top 10 highest Cook's Distance)
influential_audit <- train_data %>%
  mutate(
    Cooks_D   = diag_data$Cooks_D,
    Leverage  = diag_data$Leverage_H,
    Residual  = diag_data$Residuals,
    Fitted    = diag_data$Fitted
  ) %>%
  arrange(desc(Cooks_D)) %>%
  slice_head(n = 10) %>%
  select(Order_ID, Customer_Name, Category, Sub_Category, Sales, Discount, Profit, Fitted, Residual, Cooks_D, Leverage) %>%
  mutate(across(where(is.numeric), ~ round(.x, 2)))

readr::write_csv(influential_audit, "outputs/tables/influential_observations_audit.csv")

cat(">>> [12_model_diagnostics.R] Diagnostic plots and influential cases audit saved.\n")
