"""
Generate high-resolution dark-themed R console cards from output text files.
Produces clean, publication-grade terminal screenshots for the Week 3 report.
"""

import os
from PIL import Image, ImageDraw, ImageFont

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCREENSHOTS_DIR = os.path.join(BASE_DIR, "screenshots", "output")

CARD_SPECS = [
    ("01_dataset_structure.txt", "01_dataset_structure.png", "R Console: Dataset Structure & Variable Types (glimpse)"),
    ("02_summary_statistics.txt", "02_summary_statistics.png", "R Console: Descriptive Statistics & Distributional Moments"),
    ("03_hypothesis_test_1.txt", "03_hypothesis_test_1.png", "R Console: Hypothesis Test 1 (Welch's Two-Sample t-Test & Cohen's d)"),
    ("04_hypothesis_test_2.txt", "04_hypothesis_test_2.png", "R Console: Hypothesis Test 2 (One-Way ANOVA & Post-Hoc Tukey HSD)"),
    ("05_correlation_output.txt", "05_correlation_output.png", "R Console: Bivariate Correlation Matrices (Pearson & Spearman)"),
    ("06_model_summary.txt", "06_model_summary.png", "R Console: OLS Multiple Linear Regression Summary & VIF"),
    ("07_cross_validation_results.txt", "07_cross_validation_results.png", "R Console: 5-Fold Cross-Validation Performance Summary"),
    ("08_residual_diagnostics.txt", "08_residual_diagnostics.png", "R Console: Regression Influence & Leverage Audit (Top 10 Cook's D)"),
    ("09_model_performance.txt", "09_model_performance.png", "R Console: Master Model Evaluation on Unseen Test Partition"),
    ("10_final_evaluation.txt", "10_final_evaluation.png", "R Console: Champion Random Forest Test Set Performance & Top Residuals"),
]

def render_terminal_card(txt_path, png_path, title):
    if not os.path.exists(txt_path):
        print(f"Skipping missing: {txt_path}")
        return
        
    with open(txt_path, "r", encoding="utf-8", errors="replace") as f:
        lines = [line.rstrip() for line in f.readlines()]
        
    # Cap lines to max 26 for clean framing
    lines = lines[:26]
    
    font_size = 15
    try:
        font = ImageFont.truetype("consola.ttf", font_size)
        font_title = ImageFont.truetype("consolab.ttf", 14)
    except:
        font = ImageFont.load_default()
        font_title = font

    # Calculate dimensions
    max_len = max(len(l) for l in lines) if lines else 40
    char_w = 9
    line_h = 22
    
    width = max(800, max_len * char_w + 60)
    height = 50 + len(lines) * line_h + 30
    
    img = Image.new("RGB", (width, height), color="#0F172A") # Dark slate
    draw = ImageDraw.Draw(img)
    
    # Title bar
    draw.rectangle([(0, 0), (width, 38)], fill="#1E293B")
    draw.line([(0, 38), (width, 38)], fill="#334155", width=1)
    
    # Window controls (mac-style dots)
    draw.ellipse([(14, 13), (26, 25)], fill="#EF4444")
    draw.ellipse([(34, 13), (46, 25)], fill="#F59E0B")
    draw.ellipse([(54, 13), (66, 25)], fill="#10B981")
    
    # Title text
    draw.text((80, 11), title, font=font_title, fill="#94A3B8")
    
    # Console prompt / lines
    y = 52
    for line in lines:
        if line.startswith("===") or line.startswith("---"):
            draw.text((25, y), line, font=font, fill="#38BDF8") # Cyan header
        elif "p-value" in line.lower() or "reject" in line.lower() or "***" in line:
            draw.text((25, y), line, font=font, fill="#4ADE80") # Green highlight
        elif "error" in line.lower() or "residual" in line.lower() or "loss" in line.lower():
            draw.text((25, y), line, font=font, fill="#FCA5A5") # Light red
        elif line.startswith(">") or line.startswith("$"):
            draw.text((25, y), line, font=font, fill="#FBBF24") # Amber prompt
        else:
            draw.text((25, y), line, font=font, fill="#E2E8F0") # Clean light gray
        y += line_h
        
    img.save(png_path, format="PNG", optimize=True)
    print(f"Generated card: {os.path.basename(png_path)} ({os.path.getsize(png_path)/1024:.1f} KB)")

def main():
    os.makedirs(SCREENSHOTS_DIR, exist_ok=True)
    for txt_file, png_file, title in CARD_SPECS:
        t_path = os.path.join(SCREENSHOTS_DIR, txt_file)
        p_path = os.path.join(SCREENSHOTS_DIR, png_file)
        render_terminal_card(t_path, p_path, title)

if __name__ == "__main__":
    main()
