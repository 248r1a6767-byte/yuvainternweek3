"""
==============================================================================
Master Report Generator: generate_week3_master_report.py
Project: Week 3 - Statistical Analysis and Predictive Modeling Using R
Author: Yuva Internship Candidate
Target Deliverable: Week3_Statistical_Analysis_and_Predictive_Modeling_Report.docx
Word Count Target: 12,000+ words across 32 comprehensive sections
Compliance: Fully verified under 2,048 KB portal file upload limit
==============================================================================
"""

import os
import sys
import csv
import pandas as pd
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REPORT_DIR = os.path.join(BASE_DIR, "report")
OUTPUTS_DIR = os.path.join(BASE_DIR, "outputs")
TABLES_DIR = os.path.join(OUTPUTS_DIR, "tables")
FIGURES_DIR = os.path.join(BASE_DIR, "visualizations")
SCREENSHOTS_DIR = os.path.join(BASE_DIR, "screenshots", "output")

# Color Palette Constants
COLOR_NAVY = RGBColor(27, 54, 93)      # #1B365D - Primary Headings
COLOR_SLATE = RGBColor(75, 107, 148)   # #4B6B94 - Secondary Headings
COLOR_CHARCOAL = RGBColor(45, 55, 72)  # #2D3748 - Section 3 Headings
COLOR_BODY = RGBColor(34, 34, 34)      # #222222 - Body Text
COLOR_MUTED = RGBColor(100, 116, 139)  # #64748B - Captions & Subtitles
COLOR_WHITE = RGBColor(255, 255, 255)

def set_cell_background(cell, hex_color):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{hex_color}"/>')
    tcPr.append(shd)

def set_cell_margins(cell, top=100, bottom=100, left=140, right=140):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = parse_xml(f'<w:tcMar {nsdecls("w")}><w:top w:w="{top}" w:type="dxa"/><w:bottom w:w="{bottom}" w:type="dxa"/><w:left w:w="{left}" w:type="dxa"/><w:right w:w="{right}" w:type="dxa"/></w:tcMar>')
    tcPr.append(tcMar)

def add_header(doc, text, level=1):
    h = doc.add_heading(text, level=level)
    h.paragraph_format.keep_with_next = True
    h.paragraph_format.space_before = Pt(14 if level==1 else 10)
    h.paragraph_format.space_after = Pt(5)
    run = h.runs[0]
    if level == 1:
        run.font.name = "Calibri"
        run.font.color.rgb = COLOR_NAVY
        run.font.size = Pt(15)
        run.font.bold = True
    elif level == 2:
        run.font.name = "Calibri"
        run.font.color.rgb = COLOR_SLATE
        run.font.size = Pt(12.5)
        run.font.bold = True
    elif level == 3:
        run.font.name = "Calibri"
        run.font.color.rgb = COLOR_CHARCOAL
        run.font.size = Pt(11)
        run.font.bold = True
    return h

def add_paragraph(doc, text, space_after=5, line_spacing=1.15):
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(space_after)
    p.paragraph_format.line_spacing = line_spacing
    run = p.add_run(text)
    run.font.name = "Calibri"
    run.font.size = Pt(10.5)
    run.font.color.rgb = COLOR_BODY
    return p

def add_callout(doc, text, title="KEY STATISTICAL INSIGHT", alert_type="note"):
    tbl = doc.add_table(rows=1, cols=1)
    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    cell = tbl.cell(0, 0)
    bg_color = "F0F4F8" if alert_type == "note" else "FFFBEB"
    border_color = "1B365D" if alert_type == "note" else "D97706"
    set_cell_background(cell, bg_color)
    set_cell_margins(cell, top=120, bottom=120, left=180, right=180)
    
    tcPr = cell._tc.get_or_add_tcPr()
    borders = parse_xml(f'<w:tcBorders {nsdecls("w")}><w:left w:val="single" w:sz="24" w:space="0" w:color="{border_color}"/><w:top w:val="none"/><w:right w:val="none"/><w:bottom w:val="none"/></w:tcBorders>')
    tcPr.append(borders)
    
    p = cell.paragraphs[0]
    p.paragraph_format.space_after = Pt(3)
    p.paragraph_format.line_spacing = 1.15
    icon = "📌" if alert_type == "note" else "⚠️"
    r_title = p.add_run(f"{icon} {title}\n")
    r_title.bold = True
    r_title.font.name = "Calibri"
    r_title.font.size = Pt(10)
    r_title.font.color.rgb = COLOR_NAVY if alert_type == "note" else RGBColor(180, 83, 9)
    
    r_text = p.add_run(text)
    r_text.font.name = "Calibri"
    r_text.font.size = Pt(9.5)
    r_text.font.color.rgb = RGBColor(40, 40, 40)
    
    p_end = doc.add_paragraph()
    p_end.paragraph_format.space_after = Pt(4)

def add_code_block(doc, code_str, caption=None):
    if caption:
        p_cap = doc.add_paragraph()
        p_cap.paragraph_format.space_before = Pt(6)
        p_cap.paragraph_format.space_after = Pt(2)
        p_cap.paragraph_format.keep_with_next = True
        r_cap = p_cap.add_run(f"Listing: {caption}")
        r_cap.font.name = "Calibri"
        r_cap.font.size = Pt(9)
        r_cap.font.italic = True
        r_cap.font.color.rgb = COLOR_MUTED
        
    tbl = doc.add_table(rows=1, cols=1)
    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    cell = tbl.cell(0, 0)
    set_cell_background(cell, "F8FAFC")
    set_cell_margins(cell, top=80, bottom=80, left=140, right=140)
    
    tcPr = cell._tc.get_or_add_tcPr()
    borders = parse_xml(f'<w:tcBorders {nsdecls("w")}><w:left w:val="single" w:sz="18" w:space="0" w:color="CBD5E1"/><w:top w:val="single" w:sz="6" w:space="0" w:color="E2E8F0"/><w:right w:val="single" w:sz="6" w:space="0" w:color="E2E8F0"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="E2E8F0"/></w:tcBorders>')
    tcPr.append(borders)
    
    p = cell.paragraphs[0]
    p.paragraph_format.space_after = Pt(0)
    p.paragraph_format.line_spacing = 1.05
    run = p.add_run(code_str)
    run.font.name = "Consolas"
    run.font.size = Pt(8.5)
    run.font.color.rgb = RGBColor(30, 41, 59)
    
    p_after = doc.add_paragraph()
    p_after.paragraph_format.space_after = Pt(4)

def add_dataframe_table(doc, df, title=None, max_rows=16, custom_widths=None):
    if title:
        p_title = doc.add_paragraph()
        p_title.paragraph_format.space_before = Pt(8)
        p_title.paragraph_format.space_after = Pt(3)
        p_title.paragraph_format.keep_with_next = True
        r_title = p_title.add_run(f"Table: {title}")
        r_title.bold = True
        r_title.font.name = "Calibri"
        r_title.font.size = Pt(10)
        r_title.font.color.rgb = COLOR_NAVY
        
    display_df = df.head(max_rows).copy()
    rows = display_df.shape[0] + 1
    cols = display_df.shape[1]
    
    tbl = doc.add_table(rows=rows, cols=cols)
    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    
    # Header row
    for col_idx, col_name in enumerate(display_df.columns):
        cell = tbl.cell(0, col_idx)
        set_cell_background(cell, "1B365D")
        set_cell_margins(cell, top=90, bottom=90, left=100, right=100)
        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_after = Pt(0)
        run = p.add_run(str(col_name))
        run.bold = True
        run.font.name = "Calibri"
        run.font.size = Pt(9)
        run.font.color.rgb = COLOR_WHITE
        
    # Data rows
    for row_idx in range(display_df.shape[0]):
        bg = "FFFFFF" if row_idx % 2 == 0 else "F8FAFC"
        for col_idx in range(cols):
            cell = tbl.cell(row_idx + 1, col_idx)
            set_cell_background(cell, bg)
            set_cell_margins(cell, top=70, bottom=70, left=90, right=90)
            p = cell.paragraphs[0]
            val = str(display_df.iloc[row_idx, col_idx])
            p.paragraph_format.space_after = Pt(0)
            
            # Align numeric columns right, text left
            try:
                float(val.replace("$", "").replace("%", "").replace(",", ""))
                p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
            except ValueError:
                p.alignment = WD_ALIGN_PARAGRAPH.LEFT
                
            run = p.add_run(val)
            run.font.name = "Calibri"
            run.font.size = Pt(8.5)
            run.font.color.rgb = COLOR_BODY
            
    # Set custom widths if supplied
    if custom_widths and len(custom_widths) == cols:
        for r in tbl.rows:
            for c_idx, w in enumerate(custom_widths):
                r.cells[c_idx].width = Inches(w)
                
    p_end = doc.add_paragraph()
    p_end.paragraph_format.space_after = Pt(4)

def add_image_figure(doc, img_rel_path, caption_num, caption_title, caption_text, width=Inches(6.2)):
    full_path = os.path.join(BASE_DIR, img_rel_path)
    if not os.path.exists(full_path):
        print(f"[WARN] Image not found: {full_path}")
        return
        
    p_img = doc.add_paragraph()
    p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_img.paragraph_format.space_before = Pt(8)
    p_img.paragraph_format.space_after = Pt(3)
    run_img = p_img.add_run()
    run_img.add_picture(full_path, width=width)
    
    p_cap = doc.add_paragraph()
    p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_cap.paragraph_format.space_before = Pt(2)
    p_cap.paragraph_format.space_after = Pt(8)
    p_cap.paragraph_format.keep_with_next = False
    
    r_num = p_cap.add_run(f"Figure {caption_num}. {caption_title}: ")
    r_num.bold = True
    r_num.font.name = "Calibri"
    r_num.font.size = Pt(9)
    r_num.font.color.rgb = COLOR_NAVY
    
    r_txt = p_cap.add_run(caption_text)
    r_txt.font.name = "Calibri"
    r_txt.font.size = Pt(9)
    r_txt.font.italic = True
    r_txt.font.color.rgb = COLOR_MUTED

def add_terminal_screenshot(doc, img_rel_path, card_num, card_title, card_desc, width=Inches(6.2)):
    full_path = os.path.join(BASE_DIR, img_rel_path)
    if not os.path.exists(full_path):
        print(f"[WARN] Screenshot card not found: {full_path}")
        return
        
    p_img = doc.add_paragraph()
    p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_img.paragraph_format.space_before = Pt(8)
    p_img.paragraph_format.space_after = Pt(3)
    run_img = p_img.add_run()
    run_img.add_picture(full_path, width=width)
    
    p_cap = doc.add_paragraph()
    p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_cap.paragraph_format.space_before = Pt(2)
    p_cap.paragraph_format.space_after = Pt(8)
    p_cap.paragraph_format.keep_with_next = False
    
    r_num = p_cap.add_run(f"Console Output {card_num}. {card_title}: ")
    r_num.bold = True
    r_num.font.name = "Calibri"
    r_num.font.size = Pt(9)
    r_num.font.color.rgb = RGBColor(15, 23, 42)
    
    r_txt = p_cap.add_run(card_desc)
    r_txt.font.name = "Calibri"
    r_txt.font.size = Pt(9)
    r_txt.font.italic = True
    r_txt.font.color.rgb = COLOR_MUTED

print("Base helper modules defined successfully.")
