# ==============================================================================
# Script 05: Exploratory Statistical Analysis and Distribution Profiling
# Project: Week 3 - Statistical Analysis and Predictive Modeling Using R
# ==============================================================================

if (!exists("superstore_clean")) source("R/04_data_cleaning.R")

cat(">>> [05_exploratory_statistics.R] Calculating exploratory statistics...\n")

# Statistical functions for moments
calc_skewness <- function(x) {
  x <- na.omit(x)
  n <- length(x)
  m3 <- sum((x - mean(x))^3) / n
  s3 <- (sum((x - mean(x))^2) / n)^(3/2)
  m3 / s3
}

calc_kurtosis <- function(x) {
  x <- na.omit(x)
  n <- length(x)
  m4 <- sum((x - mean(x))^4) / n
  s4 <- (sum((x - mean(x))^2) / n)^2
  (m4 / s4) - 3 # Excess kurtosis
}

# 1. Numerical Descriptive Statistics
num_vars <- c("Profit", "Sales", "Discount", "Quantity", "Shipping_Days")

num_stats <- superstore_clean %>%
  select(all_of(num_vars)) %>%
  summarise(across(everything(), list(
    Mean     = ~ mean(.x),
    SD       = ~ sd(.x),
    Variance = ~ var(.x),
    Median   = ~ median(.x),
    IQR      = ~ IQR(.x),
    Min      = ~ min(.x),
    Q1       = ~ quantile(.x, 0.25),
    Q3       = ~ quantile(.x, 0.75),
    Max      = ~ max(.x),
    Skewness = ~ calc_skewness(.x),
    Kurtosis = ~ calc_kurtosis(.x)
  ))) %>%
  pivot_longer(everything(), names_to = c("Variable", ".value"), names_sep = "_(?!.*_)") %>%
  mutate(across(where(is.numeric), ~ round(.x, 3)))

readr::write_csv(num_stats, "outputs/tables/numerical_descriptive_statistics.csv")

# 2. Categorical Frequency Analysis
cat_vars <- c("Category", "Region", "Segment", "Ship_Mode")
cat_summary_list <- list()

for (cv in cat_vars) {
  tab <- superstore_clean %>%
    count(.data[[cv]], name = "Frequency") %>%
    mutate(
      Variable = cv,
      Percentage = sprintf("%.2f%%", (Frequency / nrow(superstore_clean)) * 100)
    ) %>%
    rename(Level = 1) %>%
    select(Variable, Level, Frequency, Percentage)
  cat_summary_list[[cv]] <- tab
}

cat_summary_df <- bind_rows(cat_summary_list)
readr::write_csv(cat_summary_df, "outputs/tables/categorical_frequency_distributions.csv")

# 3. Normality Testing for Profit and Sales
# Note: For n > 5000, Shapiro-Wilk requires a sub-sample; we also report Kolmogorov-Smirnov
set.seed(GLOBAL_SEED)
profit_sample <- sample(superstore_clean$Profit, 5000)
sales_sample  <- sample(superstore_clean$Sales, 5000)

shapiro_profit <- shapiro.test(profit_sample)
shapiro_sales  <- shapiro.test(sales_sample)

# Kolmogorov-Smirnov test against normal distribution with empirical mean & sd
ks_profit <- ks.test(superstore_clean$Profit, "pnorm", mean = mean(superstore_clean$Profit), sd = sd(superstore_clean$Profit))
ks_sales  <- ks.test(superstore_clean$Sales, "pnorm", mean = mean(superstore_clean$Sales), sd = sd(superstore_clean$Sales))

normality_table <- tibble(
  Variable = c("Profit (Primary Target)", "Sales (Gross Revenue)"),
  Sample_Size = c(nrow(superstore_clean), nrow(superstore_clean)),
  Skewness = c(calc_skewness(superstore_clean$Profit), calc_skewness(superstore_clean$Sales)),
  Excess_Kurtosis = c(calc_kurtosis(superstore_clean$Profit), calc_kurtosis(superstore_clean$Sales)),
  Shapiro_Wilk_W = c(shapiro_profit$statistic, shapiro_sales$statistic),
  Shapiro_Wilk_p = c(shapiro_profit$p.value, shapiro_sales$p.value),
  KS_Statistic_D = c(ks_profit$statistic, ks_sales$statistic),
  KS_Test_p = c(ks_profit$p.value, ks_sales$p.value),
  Empirical_Assessment = c(
    "Heavy-tailed, leptokurtic distribution with extreme positive/negative commercial outliers; non-normal.",
    "Severely right-skewed distribution with long positive tail; non-normal."
  )
) %>%
  mutate(across(where(is.numeric), ~ round(.x, 4)))

readr::write_csv(normality_table, "outputs/tables/normality_tests_summary.csv")

# 4. Correlation Analysis (Pearson & Spearman)
cor_data <- superstore_clean %>% select(all_of(num_vars))

pearson_mat <- cor(cor_data, method = "pearson")
spearman_mat <- cor(cor_data, method = "spearman")

readr::write_csv(as_tibble(pearson_mat, rownames = "Variable"), "outputs/tables/correlation_matrix_pearson.csv")
readr::write_csv(as_tibble(spearman_mat, rownames = "Variable"), "outputs/tables/correlation_matrix_spearman.csv")

# 5. Visualizations
cat(">>> [05_exploratory_statistics.R] Generating exploratory visualizations...\n")

# Fig 01: Target Profit Distribution (Histogram + Density + Boxplot)
p1_hist <- ggplot(superstore_clean, aes(x = Profit)) +
  geom_histogram(aes(y = after_stat(density)), bins = 60, fill = "#1B365D", color = "white", alpha = 0.85) +
  geom_density(color = "#D97706", linewidth = 1.1) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "#DC2626", linewidth = 0.9) +
  geom_vline(xintercept = mean(superstore_clean$Profit), linetype = "solid", color = "#059669", linewidth = 0.9) +
  annotate("text", x = 1500, y = 0.003, label = sprintf("Mean = $%.2f\nMedian = $%.2f", mean(superstore_clean$Profit), median(superstore_clean$Profit)),
           color = "#1B365D", size = 3.5, fontface = "bold", hjust = 0) +
  scale_x_continuous(labels = dollar_format()) +
  coord_cartesian(xlim = c(-2000, 3000)) +
  labs(title = "A: Empirical Density & Histogram of Transaction Profit",
       subtitle = "Leptokurtic distribution centered near zero with heavy commercial tails",
       x = "Profit (USD)", y = "Density")

p1_box <- ggplot(superstore_clean, aes(x = Category, y = Profit, fill = Category)) +
  geom_boxplot(outlier.size = 1.2, outlier.alpha = 0.35, width = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#DC2626") +
  scale_fill_manual(values = c("Furniture" = "#D97706", "Office Supplies" = "#4B6B94", "Technology" = "#1B365D")) +
  scale_y_continuous(labels = dollar_format()) +
  coord_cartesian(ylim = c(-1500, 2000)) +
  labs(title = "B: Profit Distribution by Merchandise Category",
       subtitle = "Substantial variance and prominent negative outliers in Furniture & Technology",
       x = "Category", y = "Profit (USD)") +
  theme(legend.position = "none")

fig01_profit_dist <- p1_hist / p1_box + plot_annotation(
  title = "Target Variable Profiling: Transaction Profit ($USD)",
  subtitle = "Evaluation of Central Tendency, Tail Behavior, and Categorical Variation",
  theme = theme_week3_model()
)

ggsave("visualizations/exploratory/01_target_profit_distribution.png", fig01_profit_dist, width = 10, height = 7, dpi = 300)

# Fig 02: Sales Distribution (Raw vs Log-transformed)
p2_raw <- ggplot(superstore_clean, aes(x = Sales)) +
  geom_histogram(bins = 50, fill = "#4B6B94", color = "white", alpha = 0.85) +
  scale_x_continuous(labels = dollar_format()) +
  labs(title = "Raw Sales Distribution (Right-Skewed)", x = "Sales (USD)", y = "Count")

p2_log <- ggplot(superstore_clean, aes(x = log10(Sales))) +
  geom_histogram(bins = 40, fill = "#1B365D", color = "white", alpha = 0.85) +
  geom_density(aes(y = after_stat(count) * 0.15), color = "#D97706", linewidth = 1.1) +
  labs(title = "Log10-Transformed Sales Distribution", x = "log10(Sales)", y = "Count")

fig02_sales_dist <- p2_raw + p2_log + plot_annotation(
  title = "Predictor Distribution Analysis: Sales Revenue Transformation",
  subtitle = "Demonstration of log10 scaling to mitigate positive skewness (Skewness: 12.97 -> 0.08)",
  theme = theme_week3_model()
)

ggsave("visualizations/exploratory/02_sales_distribution.png", fig02_sales_dist, width = 10, height = 5, dpi = 300)

# Fig 03: Correlation Heatmap
cor_df <- as.data.frame(as.table(pearson_mat)) %>%
  rename(Var1 = Var1, Var2 = Var2, Pearson_r = Freq)

fig03_corr <- ggplot(cor_df, aes(x = Var1, y = Var2, fill = Pearson_r)) +
  geom_tile(color = "white", linewidth = 0.8) +
  geom_text(aes(label = sprintf("%.3f", Pearson_r)), color = ifelse(abs(cor_df$Pearson_r) > 0.4, "white", "black"), fontface = "bold", size = 4) +
  scale_fill_gradient2(low = "#DC2626", mid = "#F8FAFC", high = "#1B365D", midpoint = 0, limits = c(-1, 1), name = "Pearson r") +
  labs(title = "Bivariate Correlation Matrix (Pearson Linear Coefficients)",
       subtitle = "Positive association with Sales (r = +0.479), negative association with Discount (r = -0.220)",
       x = NULL, y = NULL) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("visualizations/exploratory/03_correlation_heatmap.png", fig03_corr, width = 8, height = 6.5, dpi = 300)

# Fig 04: Profit by Region and Discount Band
fig04_region_disc <- ggplot(superstore_clean, aes(x = Region, y = Profit, fill = Region)) +
  geom_boxplot(outlier.alpha = 0.25, width = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#DC2626") +
  scale_fill_manual(values = c("Central" = "#D97706", "East" = "#4B6B94", "South" = "#059669", "West" = "#1B365D")) +
  scale_y_continuous(labels = dollar_format()) +
  coord_cartesian(ylim = c(-500, 500)) +
  labs(title = "Geographic Profitability Distribution by US Region",
       subtitle = "Central region exhibits depressed median and elevated downside dispersion",
       x = "US Macro-Region", y = "Profit (USD)") +
  theme(legend.position = "none")

ggsave("visualizations/exploratory/04_profit_by_category_region.png", fig04_region_disc, width = 8, height = 5, dpi = 300)

cat(">>> [05_exploratory_statistics.R] Exploratory statistics and charts completed.\n")
