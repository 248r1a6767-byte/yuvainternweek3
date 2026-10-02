"""
Image optimization script for Week 3 Statistical & Predictive Modeling Report.
Ensures that all embedded figures and screenshot cards fit cleanly within the
2048 KB (2.0 MB) submission portal file limit while preserving high-resolution
readability and crisp visual aesthetics.
"""

import os
from PIL import Image

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VIS_DIR = os.path.join(BASE_DIR, "visualizations")
SCREENSHOTS_DIR = os.path.join(BASE_DIR, "screenshots")

def optimize_file(img_path, max_width=1200, colors=256):
    if not os.path.isfile(img_path) or not img_path.lower().endswith(".png"):
        return 0, 0
    
    orig_size = os.path.getsize(img_path)
    img = Image.open(img_path)
    
    # 1. Resize if image exceeds max_width
    w, h = img.size
    if w > max_width:
        new_w = max_width
        new_h = int(h * (max_width / w))
        img = img.resize((new_w, new_h), Image.Resampling.LANCZOS)
    
    # 2. Check alpha channel / convert to RGB if not transparent
    if img.mode == 'RGBA':
        alpha = img.split()[-1]
        if alpha.getextrema() == (255, 255):
            img = img.convert('RGB')
        else:
            bg = Image.new("RGB", img.size, (255, 255, 255))
            bg.paste(img, mask=alpha)
            img = bg
    elif img.mode != 'RGB':
        img = img.convert('RGB')
        
    # 3. Adaptive quantization (256 colors for graphs, crystal crisp text)
    img_opt = img.quantize(colors=colors, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    
    temp_path = img_path + ".tmp.png"
    img_opt.save(temp_path, format="PNG", optimize=True)
    new_size = os.path.getsize(temp_path)
    
    if new_size < orig_size:
        os.replace(temp_path, img_path)
        print(f"Optimized: {os.path.relpath(img_path, BASE_DIR):<55} {orig_size/1024:6.1f} KB -> {new_size/1024:6.1f} KB (saved {((orig_size-new_size)/orig_size)*100:.1f}%)")
        return orig_size, new_size
    else:
        if os.path.exists(temp_path):
            os.remove(temp_path)
        print(f"Retained:  {os.path.relpath(img_path, BASE_DIR):<55} {orig_size/1024:6.1f} KB")
        return orig_size, orig_size

def main():
    print("=" * 70)
    print("OPTIMIZING WEEK 3 IMAGES FOR DOCX REPORT COMPLIANCE (<= 2048 KB)")
    print("=" * 70)
    
    targets = [VIS_DIR, SCREENSHOTS_DIR]
    total_orig = 0
    total_opt = 0
    count = 0
    
    for target in targets:
        for root, dirs, files in os.walk(target):
            for file in files:
                if file.lower().endswith(".png"):
                    full_p = os.path.join(root, file)
                    c = 128 if "card" in file.lower() or "screenshot" in root.lower() else 256
                    mw = 1200
                    orig_s, opt_s = optimize_file(full_p, max_width=mw, colors=c)
                    total_orig += orig_s
                    total_opt += opt_s
                    count += 1
                    
    print("=" * 70)
    print(f"Total Images Processed: {count}")
    print(f"Original Total Size:    {total_orig / 1024 / 1024:.2f} MB ({total_orig:,} bytes)")
    print(f"Optimized Total Size:   {total_opt / 1024 / 1024:.2f} MB ({total_opt:,} bytes)")
    print(f"Total Bytes Saved:      {(total_orig - total_opt) / 1024 / 1024:.2f} MB ({((total_orig - total_opt)/total_orig)*100:.1f}%)")
    print("=" * 70)

if __name__ == "__main__":
    main()
