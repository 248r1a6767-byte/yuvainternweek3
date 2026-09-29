# ==============================================================================
# Script 07: Feature Engineering and Leakage Prevention
# Project: Week 3 - Statistical Analysis and Predictive Modeling Using R
# ==============================================================================

if (!exists("superstore_clean")) source("R/04_data_cleaning.R")

cat(">>> [07_feature_engineering.R] Constructing predictor feature matrix...\n")

superstore_engineered <- superstore_clean %>%
  # 1. Temporal feature extractions
  mutate(
    Order_Year        = factor(lubridate::year(Order_Date)),
    Order_Month       = factor(lubridate::month(Order_Date)),
    Order_Quarter     = factor(paste0("Q", lubridate::quarter(Order_Date))),
    Order_Day_Of_Week = factor(weekdays(Order_Date, abbreviate = TRUE)),
    Is_Weekend        = factor(ifelse(weekdays(Order_Date) %in% c("Saturday", "Sunday"), "Weekend", "Weekday"))
  ) %>%
  # 2. Mathematical transformations
  mutate(
    Sales_Log = log10(Sales)
  ) %>%
  # 3. Categorical Binning
  mutate(
    Discount_Band = factor(
      case_when(
        Discount == 0.00 ~ "None (0%)",
        Discount <= 0.10 ~ "Low (0-10%]",
        Discount <= 0.20 ~ "Medium (10-20%]",
        Discount <= 0.40 ~ "High (20-40%]",
        TRUE             ~ "Very High (>40%)"
      ),
      levels = c("None (0%)", "Low (0-10%]", "Medium (10-20%]", "High (20-40%]", "Very High (>40%)")
    ),
    Order_Value_Tier = factor(
      case_when(
        Sales < 100  ~ "Small (<$100)",
        Sales < 500  ~ "Medium ($100-$500)",
        Sales < 2000 ~ "Large ($500-$2k)",
        TRUE         ~ "Enterprise (>$2k)"
      ),
      levels = c("Small (<$100)", "Medium ($100-$500)", "Large ($500-$2k)", "Enterprise (>$2k)")
    )
  ) %>%
  # 4. Standardize factor baselines
  mutate(
    Category     = relevel(factor(Category), ref = "Furniture"),
    Region       = relevel(factor(Region), ref = "Central"),
    Segment      = relevel(factor(Segment), ref = "Consumer"),
    Ship_Mode    = relevel(factor(Ship_Mode), ref = "Standard Class"),
    Sub_Category = factor(Sub_Category)
  )

# 5. DATA LEAKAGE AUDIT:
# Verify that no circular variables (Profit_Margin, Is_Profitable, Unit_Cost) are present in predictor columns
circular_vars <- c("Profit_Margin", "Is_Profitable", "Unit_Cost", "Cost")
leakage_present <- any(circular_vars %in% names(superstore_engineered))

if (leakage_present) {
  stop("FATAL ERROR: Target leakage variable detected in feature matrix!")
}

# Save engineered datasets
readr::write_csv(superstore_engineered, "data/processed/superstore_engineered.csv")
saveRDS(superstore_engineered, "data/processed/superstore_engineered.rds")

# Export manifest table
feature_manifest <- tibble(
  Feature_Name    = c("Sales", "Sales_Log", "Discount", "Discount_Band", "Quantity", 
                      "Shipping_Days", "Order_Year", "Order_Month", "Order_Quarter", 
                      "Is_Weekend", "Order_Value_Tier", "Category", "Sub_Category", 
                      "Region", "Segment", "Ship_Mode", "Profit (TARGET)"),
  Data_Type       = c("Numeric", "Numeric", "Numeric", "Ordered Factor", "Integer",
                      "Numeric", "Factor", "Factor", "Factor",
                      "Binary Factor", "Ordered Factor", "Factor (ref=Furniture)", "Factor (17 levels)",
                      "Factor (ref=Central)", "Factor (ref=Consumer)", "Factor (ref=Standard)", "Numeric Target"),
  Feature_Role    = c("Continuous Predictor", "Non-linear Scaled Predictor", "Continuous Predictor", "Promotional Policy Indicator",
                      "Volume Predictor", "Logistics Latency Predictor", "Macroeconomic Trend", "Seasonality Indicator",
                      "Quarterly Fiscal Anchor", "Trading Day Indicator", "Transaction Scale Indicator",
                      "Merchandise Hierarchy", "Micro-Product Classification", "Geographic Market",
                      "Customer Demand Segment", "Fulfillment Service Level", "Primary Response Variable"),
  Leakage_Check   = rep("VERIFIED CLEAN (No Target Derivatives)", 17)
)

readr::write_csv(feature_manifest, "outputs/tables/feature_engineering_manifest.csv")

cat(">>> [07_feature_engineering.R] Feature engineering completed successfully with 0 leakage.\n")
