# Week 3 — Statistical Analysis and Predictive Modeling Using R

Welcome to the **Week 3 Internship Final Capstone Project** for the Data Analytics & Predictive Science Track. This project delivers an end-to-end inferential statistical analysis and predictive modeling pipeline implemented in **R (v4.6.1)** on the **Tableau / Kaggle Sample Superstore Sales Dataset**.

---

## 📌 Executive Summary

- **Primary Analytical Objective:** Perform in-depth inferential hypothesis testing, classical Gauss-Markov assumption auditing, and develop a defensible machine-learning regression architecture to predict transaction-level commercial net profit ($USD).
- **Dataset:** Kaggle / Tableau Superstore Sales Dataset (9,994 line-item transactions, 21 attributes, 4 full fiscal years across 49 US States, 209,874 empirical cells).
- **Core Modeling Paradigm:** Supervised Continuous Regression evaluated via **5-Fold Cross-Validation** and an **untouched 20% Holdout Test Set** (n = 1,999, seed 12345).
- **Champion Predictive Model:** **Random Forest Regression** (ntree = 200, mtry = 3) achieving a **Test Set $R^2$ of 0.7417** and **Test RMSE of $130.46** (reducing generalization error by 49.20% over the Naive Mean Baseline).
- **Deliverables:** 16 modular R scripts, 34 structured summary tables, 13 publication-grade figures (300 DPI), 10 dark-themed terminal capture cards, and an executive 55-page Microsoft Word report (`Week3_Statistical_Analysis_and_Predictive_Modeling_Report.docx`, 755 KB — strictly compliant with the 2,048 KB portal limit).

---

## 🔬 Formal Hypothesis Testing Suite

All tests were conducted at $\alpha = 0.05$ with full assumption verification:

| Test ID | Method / Test Name | Research Question | Null Hypothesis ($H_0$) | Test Statistic & df | $p$-Value | Effect Size | Empirical Decision |
| :---: | :--- | :--- | :--- | :--- | :---: | :---: | :--- |
| **HT-01** | **Welch's Two-Sample t-Test** | Does promotional discounting suppress transactional profit? | $\mu_{\text{NoDisc}} = \mu_{\text{Disc}}$ | $t = 15.74$, $\text{df} = 9162.2$ | $< 0.0001$ | Cohen's $d = 0.318$ | **Reject $H_0$** (Full price profit \$66.90 vs Discounted -\$6.66) |
| **HT-02** | **One-Way ANOVA & Post-Hoc Tukey HSD** | Are there significant differences in mean profit across merchandise categories? | $\mu_{\text{Tech}} = \mu_{\text{Office}} = \mu_{\text{Furn}}$ | $F(2, 9991) = 54.31$ | $< 0.0001$ | $\eta^2 = 0.0108$ | **Reject $H_0$** (Technology \$78.75 > Office \$20.33 > Furniture \$8.70) |
| **HT-03** | **Pearson Chi-Square Test of Independence** | Is order loss incidence geographically independent of sales regions? | Region $\perp$ Profitability | $\chi^2 = 436.70$, $\text{df} = 3$ | $< 0.0001$ | Cramér's $V = 0.2090$ | **Reject $H_0$** (Central region loss rate 24.3% vs West 16.2%) |
| **HT-04** | **Spearman Rank Correlation Test** | Is there a monotonic inverse relationship between discount and profit? | $\rho_s = 0$ | $S = 2.568 \times 10^{11}$ | $< 0.0001$ | $\rho_s = -0.5434$ | **Reject $H_0$** (Robust negative non-linear margin decay) |

---

## 🤖 Predictive Modeling Performance Summary

Models were fitted strictly on the 80% training partition ($n = 7,995$) and evaluated across 5-fold cross-validation and the holdout test set ($n = 1,999$):

| Model Architecture | 5-Fold CV RMSE | 5-Fold CV MAE | 5-Fold CV $R^2$ | Test Set RMSE | Test Set MAE | Test Set $R^2$ | Selection Verdict |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **Model 0: Naive Mean Baseline** | \$226.15 | \$61.14 | 0.0000 | \$256.79 | \$69.21 | 0.0000 | Reference Benchmark |
| **Model 1: Multiple Linear Regression (OLS)** | \$203.98 | \$57.10 | 0.1711 | \$200.68 | \$62.94 | 0.3887 | Interpretable Linear Baseline |
| **Model 2: Elastic Net Regularization ($\alpha=0.5$)** | \$227.64 | \$58.14 | -0.0128 | \$224.24 | \$54.00 | 0.2367 | Regularized Linear Candidate |
| **Model 3: Random Forest Regression (Champion)** | **\$149.35** | **\$28.58** | **0.5671** | **\$130.46** | **\$32.00** | **0.7417** | **CHAMPION MODEL (Lowest Error & Best Generalization)** |

---

## 📁 Repository Architecture

```text
Week3_Statistical_Analysis_Predictive_Modeling/
├── README.md
├── Week3_Statistical_Analysis_Predictive_Modeling.Rproj
├── generate_week3_master_report.py                     # Master Word report compiler
├── submission_description.txt                         # Portal description (500+ words)
├── R/                                                 # 16 modular R scripts
│   ├── 01_setup.R
│   ├── 02_import_data.R
│   ├── 03_data_quality.R
│   ├── 04_data_cleaning.R
│   ├── 05_exploratory_statistics.R
│   ├── 06_hypothesis_testing.R
│   ├── 07_feature_engineering.R
│   ├── 08_train_test_split.R
│   ├── 09_model_baseline.R
│   ├── 10_model_training.R
│   ├── 11_cross_validation.R
│   ├── 12_model_diagnostics.R
│   ├── 13_model_comparison.R
│   ├── 14_final_model.R
│   ├── 15_predictions.R
│   └── 16_export_results.R
├── data/
│   ├── raw/superstore_raw.csv                         # 9,994 immutable transactions
│   └── processed/
│       ├── superstore_clean.csv
│       ├── superstore_clean.rds
│       ├── superstore_engineered.csv
│       ├── train_data.rds                             # 7,995 training records
│       ├── test_data.rds                              # 1,999 untouched test records
│       └── cv_folds.rds                               # 5-fold cross-validation partition
├── models/model_objects/                              # Serialized model artifacts
│   ├── baseline_model.rds
│   ├── ols_linear_model.rds
│   ├── tuned_models.rds
│   └── champion_random_forest.rds
├── outputs/
│   ├── tables/                                        # 23 summary CSV tables
│   ├── predictions/test_set_predictions.csv
│   └── diagnostics/                                   # QA logs and metrics manifests
├── visualizations/                                    # 13 high-resolution 300 DPI figures
│   ├── exploratory/
│   ├── diagnostics/
│   └── model_performance/
├── screenshots/output/                                # 10 dark-themed terminal console cards
├── scripts/
│   ├── run_all.R                                      # One-command master pipeline runner
│   ├── generate_terminal_cards.py                     # Console card renderer
│   ├── optimize_images.py                             # Image compressor (<= 2048 KB docx)
│   └── report_helpers.py                              # Report styling helpers
└── report/
    └── Week3_Statistical_Analysis_and_Predictive_Modeling_Report.docx  # 755 KB Final Report
```

---

## 🚀 Execution & Reproducibility Guide

To reproduce all results, models, figures, and reports:

```powershell
# 1. Run the complete statistical & predictive modeling pipeline in R (runtime ~68s)
Rscript scripts/run_all.R

# 2. Render all 10 terminal screenshot cards
python scripts/generate_terminal_cards.py

# 3. Optimize images to comply with portal upload limits
python scripts/optimize_images.py

# 4. Compile the professional Microsoft Word report
python generate_week3_master_report.py
```
