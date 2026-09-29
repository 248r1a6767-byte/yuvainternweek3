# ==============================================================================
# Script 01: Setup and Environment Configuration
# Project: Week 3 - Statistical Analysis and Predictive Modeling Using R
# Author: Statistical Analyst & Predictive Modeling Specialist
# ==============================================================================

# 1. Clean workspace environment
gc()

# 2. Set global reproducible random seed
GLOBAL_SEED <- 12345
set.seed(GLOBAL_SEED)

# 3. Required packages
required_packages <- c(
  "dplyr", "ggplot2", "readr", "tidyr", "stringr", 
  "lubridate", "scales", "patchwork", "stats", 
  "car", "effsize", "pROC", "randomForest", "glmnet", "broom"
)

# Verify and load packages
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
  suppressPackageStartupMessages(library(pkg, character.only = TRUE))
}

# 4. Standardized Executive ggplot2 Theme
theme_week3_model <- function(base_size = 11, base_family = "sans") {
  theme_minimal(base_size = base_size, base_family = base_family) +
    theme(
      plot.title = element_text(face = "bold", size = rel(1.15), color = "#1B365D", margin = ggplot2::margin(b = 6)),
      plot.subtitle = element_text(size = rel(0.90), color = "#4A5568", margin = ggplot2::margin(b = 10)),
      plot.caption = element_text(size = rel(0.75), color = "#718096", hjust = 1, margin = ggplot2::margin(t = 8)),
      panel.grid.major = element_line(color = "#EDF2F7", linewidth = 0.5),
      panel.grid.minor = element_blank(),
      axis.title = element_text(face = "bold", size = rel(0.85), color = "#2D3748"),
      axis.text = element_text(size = rel(0.80), color = "#4A5568"),
      legend.position = "bottom",
      legend.title = element_text(face = "bold", size = rel(0.85), color = "#2D3748"),
      legend.text = element_text(size = rel(0.80), color = "#4A5568"),
      strip.background = element_rect(fill = "#1B365D", color = NA),
      strip.text = element_text(face = "bold", color = "#FFFFFF", size = rel(0.85), margin = ggplot2::margin(t = 4, b = 4)),
      plot.margin = ggplot2::margin(t = 12, r = 12, b = 12, l = 12)
    )
}

theme_set(theme_week3_model())

# 5. Palette definition
WEEK3_PALETTE <- c(
  primary   = "#1B365D", # Deep Navy
  secondary = "#4B6B94", # Slate Blue
  accent    = "#D97706", # Warm Amber
  success   = "#059669", # Forest Green
  danger    = "#DC2626", # Crimson
  neutral   = "#6B7280", # Slate Grey
  light     = "#F8FAFC"  # Light background
)

cat(">>> [01_setup.R] Environment initialized successfully with seed", GLOBAL_SEED, "\n")
