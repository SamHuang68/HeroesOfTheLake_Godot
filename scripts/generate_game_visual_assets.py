# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 視覺資產生成腳本 (Character Sprites, 2.5D Buildings & UI Icons)
import os, math
from PIL import Image, ImageDraw

base_dir = r"c:\Users\Sam\Documents\antigravity\Game Developing\HeroesOfTheLake_Godot\assets"
char_dir = os.path.join(base_dir, "sprites", "characters")
bld_dir = os.path.join(base_dir, "sprites", "buildings")
icon_dir = os.path.join(base_dir, "icons")

os.makedirs(char_dir, exist_ok=True)
os.makedirs(bld_dir, exist_ok=True)
os.makedirs(icon_dir, exist_ok=True)

# 1. 忠義堂本營 (192 x 160 px)
def create_main_hall():
    w, h = 192, 160
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy = w // 2, 120
    
    # 漢白玉台基
    d.polygon([(cx, cy - 32), (cx + 80, cy + 4), (cx, cy + 40), (cx - 80, cy + 4)], fill=(195, 195, 200, 255), outline=(230, 230, 240, 255))
    d.polygon([(cx, cy - 26), (cx + 74, cy + 6), (cx, cy + 36), (cx - 74, cy + 6)], fill=(210, 210, 215, 255))
    for i in range(4):
        d.line([(cx - 20, cy + 18 + i*5), (cx + 20, cy + 18 + i*5)], fill=(170, 170, 175, 255), width=2)
        
    # 朱紅大殿身與立柱
    d.rectangle([(cx - 60, cy - 45), (cx + 60, cy + 2)], fill=(175, 45, 35, 255), outline=(120, 25, 20, 255))
    for px in [-55, -28, 0, 28, 55]:
        d.rectangle([(cx + px - 3, cy - 48), (cx + px + 3, cy + 4)], fill=(110, 20, 15, 255))
        
    # 下層金色琉璃殿簷
    d.polygon([(cx, cy - 65), (cx + 88, cy - 24), (cx, cy + 16), (cx - 88, cy - 24)], fill=(225, 150, 35, 255), outline=(255, 220, 80, 255))
    # 上層殿頂 (重簷廡殿頂)
    d.rectangle([(cx - 40, cy - 80), (cx + 40, cy - 65)], fill=(160, 35, 25, 255))
    d.polygon([(cx, cy - 115), (cx + 72, cy - 78), (cx, cy - 42), (cx - 72, cy - 78)], fill=(240, 170, 45, 255), outline=(255, 235, 100, 255))
    
    # 正脊金龍與寶珠
    d.line([(cx - 35, cy - 98), (cx + 35, cy - 98)], fill=(255, 225, 60, 255), width=5)
    d.ellipse([(cx - 40, cy - 102), (cx - 32, cy - 94)], fill=(255, 200, 30, 255))
    d.ellipse([(cx + 32, cy - 102), (cx + 40, cy - 94)], fill=(255, 200, 30, 255))
    d.ellipse([(cx - 5, cy - 105), (cx + 5, cy - 95)], fill=(255, 255, 120, 255))
    
    # 杏黃大旗「替天行道」
    d.line([(cx - 68, cy + 15), (cx - 68, cy - 70)], fill=(85, 50, 25, 255), width=3)
    d.polygon([(cx - 68, cy - 68), (cx - 32, cy - 58), (cx - 36, cy - 36), (cx - 68, cy - 46)], fill=(245, 215, 60, 255), outline=(200, 30, 20, 255))
    
    img.save(os.path.join(bld_dir, "main_hall_3x3.png"))
    print("✅ 已生成 忠義堂本營: main_hall_3x3.png")

# 2. 神兵鐵匠坊 (128 x 128 px)
def create_smithy():
    w, h = 128, 128
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy = w // 2, 85
    d.polygon([(cx, cy - 24), (cx + 48, cy), (cx, cy + 24), (cx - 48, cy)], fill=(140, 130, 120, 255), outline=(100, 90, 80, 255))
    d.rectangle([(cx - 36, cy - 30), (cx + 36, cy + 6)], fill=(120, 95, 80, 255))
    d.polygon([(cx, cy - 55), (cx + 44, cy - 25), (cx, cy + 5), (cx - 44, cy - 25)], fill=(95, 95, 110, 255), outline=(210, 190, 80, 255))
    d.rectangle([(cx + 20, cy - 65), (cx + 34, cy - 20)], fill=(85, 65, 55, 255), outline=(50, 40, 30, 255))
    d.rectangle([(cx + 18, cy - 70), (cx + 36, cy - 64)], fill=(65, 50, 40, 255))
    d.rectangle([(cx - 24, cy - 12), (cx - 8, cy + 2)], fill=(60, 60, 70, 255))
    d.line([(cx + 12, cy + 6), (cx + 18, cy - 16)], fill=(210, 210, 225, 255), width=2)
    img.save(os.path.join(bld_dir, "smithy_2x2.png"))
    print("✅ 已生成 神兵鐵匠坊: smithy_2x2.png")

# 3. 聚義好漢酒館 (128 x 128 px)
def create_tavern():
    w, h = 128, 128
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy = w // 2, 85
    d.polygon([(cx, cy - 24), (cx + 48, cy), (cx, cy + 24), (cx - 48, cy)], fill=(160, 135, 105, 255))
    d.rectangle([(cx - 36, cy - 35), (cx + 36, cy + 5)], fill=(155, 115, 80, 255))
    d.polygon([(cx, cy - 60), (cx + 46, cy - 28), (cx, cy + 4), (cx - 46, cy - 28)], fill=(195, 95, 45, 255), outline=(245, 210, 80, 255))
    d.line([(cx - 38, cy + 8), (cx - 38, cy - 45)], fill=(80, 50, 30, 255), width=3)
    d.polygon([(cx - 38, cy - 42), (cx - 12, cy - 36), (cx - 16, cy - 18), (cx - 38, cy - 24)], fill=(240, 220, 90, 255), outline=(180, 20, 20, 255))
    d.ellipse([(cx + 24, cy - 20), (cx + 38, cy - 6)], fill=(240, 60, 30, 255), outline=(255, 220, 50, 255))
    img.save(os.path.join(bld_dir, "tavern_2x2.png"))
    print("✅ 已生成 聚義好漢酒館: tavern_2x2.png")

# 4. 水泊碼頭與樓船 (128 x 128 px)
def create_shipyard():
    w, h = 128, 128
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy = w // 2, 85
    d.rectangle([(cx - 48, cy - 6), (cx + 48, cy + 10)], fill=(125, 90, 55, 255), outline=(80, 55, 30, 255))
    for px in range(-40, 48, 16):
        d.line([(cx + px, cy - 6), (cx + px, cy + 10)], fill=(70, 50, 25, 255), width=1)
    d.polygon([(cx - 36, cy + 12), (cx + 36, cy + 12), (cx + 48, cy - 4), (cx - 48, cy - 4)], fill=(95, 65, 40, 255), outline=(50, 35, 20, 255))
    d.line([(cx, cy - 4), (cx, cy - 48)], fill=(75, 45, 25, 255), width=3)
    d.polygon([(cx, cy - 44), (cx + 26, cy - 30), (cx, cy - 14)], fill=(235, 230, 215, 255), outline=(180, 170, 150, 255))
    img.save(os.path.join(bld_dir, "shipyard_2x2.png"))
    print("✅ 已生成 水泊碼頭與樓船: shipyard_2x2.png")

# 5. 聚義糧倉 (128 x 128 px)
def create_granary():
    w, h = 128, 128
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy = w // 2, 85
    d.polygon([(cx, cy - 24), (cx + 40, cy), (cx, cy + 24), (cx - 40, cy)], fill=(155, 125, 95, 255))
    d.rectangle([(cx - 28, cy - 24), (cx + 28, cy + 8)], fill=(140, 105, 75, 255))
    d.polygon([(cx, cy - 60), (cx + 36, cy - 18), (cx, cy + 10), (cx - 36, cy - 18)], fill=(215, 185, 80, 255), outline=(245, 225, 120, 255))
    d.ellipse([(cx - 26, cy + 6), (cx - 14, cy + 16)], fill=(220, 210, 175, 255))
    d.ellipse([(cx - 18, cy + 8), (cx - 6, cy + 18)], fill=(220, 210, 175, 255))
    img.save(os.path.join(bld_dir, "granary_2x2.png"))
    print("✅ 已生成 聚義糧倉: granary_2x2.png")

# 6. 先鋒軍營演武場 (128 x 128 px)
def create_barracks():
    w, h = 128, 128
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy = w // 2, 85
    d.polygon([(cx, cy - 24), (cx + 48, cy), (cx, cy + 24), (cx - 48, cy)], fill=(145, 110, 80, 255))
    d.rectangle([(cx - 36, cy - 26), (cx + 36, cy + 6)], fill=(145, 45, 40, 255))
    d.polygon([(cx, cy - 54), (cx + 44, cy - 24), (cx, cy + 6), (cx - 44, cy - 24)], fill=(185, 35, 30, 255), outline=(240, 210, 80, 255))
    d.line([(cx + 32, cy + 8), (cx + 32, cy - 48)], fill=(65, 45, 25, 255), width=3)
    d.polygon([(cx + 32, cy - 46), (cx + 56, cy - 36), (cx + 32, cy - 26)], fill=(220, 30, 25, 255), outline=(255, 220, 50, 255))
    img.save(os.path.join(bld_dir, "barracks_2x2.png"))
    print("✅ 已生成 先鋒軍營演武場: barracks_2x2.png")

create_main_hall()
create_smithy()
create_tavern()
create_shipyard()
create_granary()
create_barracks()

# ==========================================
# 2. 生成主要名將精靈圖 (Hero Character Sprites)
# ==========================================

heroes = [
    {"id": "linchong", "name": "林沖", "color_robe": (225, 225, 230), "color_armor": (45, 75, 145), "weapon": "spear", "hat": "felt_hat"},
    {"id": "wusong", "name": "武松", "color_robe": (180, 150, 110), "color_armor": (140, 45, 35), "weapon": "twin_sabres", "hat": "headband"},
    {"id": "luzhishen", "name": "魯智深", "color_robe": (45, 45, 50), "color_armor": (185, 125, 45), "weapon": "spade", "hat": "monk"},
    {"id": "lijun", "name": "李俊", "color_robe": (35, 95, 145), "color_armor": (45, 135, 165), "weapon": "oar", "hat": "sailor"},
    {"id": "huarong", "name": "花榮", "color_robe": (235, 235, 240), "color_armor": (195, 195, 205), "weapon": "bow", "hat": "silver_helmet"},
    {"id": "songjiang", "name": "宋江", "color_robe": (130, 40, 35), "color_armor": (185, 145, 45), "weapon": "sword", "hat": "official_cap"},
    {"id": "wuyong", "name": "吳用", "color_robe": (240, 240, 235), "color_armor": (75, 95, 140), "weapon": "fan", "hat": "scholar_cap"},
    {"id": "tanglong", "name": "湯隆", "color_robe": (95, 75, 60), "color_armor": (65, 65, 70), "weapon": "hammer", "hat": "bandana"}
]

for h in heroes:
    img = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy = 32, 48
    
    d.polygon([(cx - 14, cy), (cx, cy - 4), (cx + 14, cy), (cx, cy + 4)], fill=(0, 0, 0, 80))
    d.line([(cx - 4, cy - 2), (cx - 4, cy - 12)], fill=(35, 35, 40, 255), width=3)
    d.line([(cx + 4, cy - 2), (cx + 4, cy - 12)], fill=(35, 35, 40, 255), width=3)
    d.polygon([(cx - 9, cy - 12), (cx + 9, cy - 12), (cx + 11, cy - 2), (cx - 11, cy - 2)], fill=h["color_robe"] + (255,))
    d.polygon([(cx - 8, cy - 26), (cx + 8, cy - 26), (cx + 9, cy - 12), (cx - 9, cy - 12)], fill=h["color_armor"] + (255,))
    
    d.ellipse([(cx - 7, cy - 38), (cx + 7, cy - 24)], fill=(245, 205, 165, 255))
    
    hat = h["hat"]
    if hat == "felt_hat":
        d.polygon([(cx - 13, cy - 36), (cx + 13, cy - 36), (cx, cy - 46)], fill=(235, 230, 215, 255), outline=(190, 180, 160, 255))
    elif hat == "headband":
        d.line([(cx - 8, cy - 33), (cx + 8, cy - 33)], fill=(185, 30, 25, 255), width=3)
    elif hat == "monk":
        d.line([(cx - 7, cy - 34), (cx + 7, cy - 34)], fill=(225, 175, 45, 255), width=2)
    elif hat == "silver_helmet":
        d.polygon([(cx - 9, cy - 36), (cx + 9, cy - 36), (cx, cy - 45)], fill=(215, 215, 225, 255), outline=(245, 215, 60, 255))
        d.line([(cx, cy - 45), (cx, cy - 50)], fill=(220, 30, 20, 255), width=2)
    elif hat == "scholar_cap":
        d.rectangle([(cx - 6, cy - 44), (cx + 6, cy - 36)], fill=(45, 55, 85, 255))
    else:
        d.ellipse([(cx - 7, cy - 40), (cx + 7, cy - 34)], fill=(65, 45, 35, 255))
        
    wpn = h["weapon"]
    if wpn == "spear":
        d.line([(cx + 6, cy - 2), (cx + 16, cy - 52)], fill=(160, 110, 60, 255), width=2)
        d.line([(cx + 16, cy - 52), (cx + 18, cy - 60)], fill=(225, 225, 235, 255), width=3)
        d.polygon([(cx + 14, cy - 50), (cx + 20, cy - 50), (cx + 17, cy - 44)], fill=(220, 40, 30, 255))
    elif wpn == "twin_sabres":
        d.line([(cx - 8, cy - 14), (cx - 16, cy - 32)], fill=(220, 220, 230, 255), width=3)
        d.line([(cx + 8, cy - 14), (cx + 16, cy - 32)], fill=(220, 220, 230, 255), width=3)
    elif wpn == "spade":
        d.line([(cx + 6, cy), (cx + 15, cy - 50)], fill=(120, 90, 50, 255), width=3)
        d.ellipse([(cx + 10, cy - 56), (cx + 20, cy - 46)], fill=(210, 190, 60, 255))
    elif wpn == "bow":
        d.arc([(cx + 6, cy - 40), (cx + 20, cy - 10)], start=270, end=90, fill=(135, 80, 40, 255), width=2)
    elif wpn == "fan":
        d.polygon([(cx + 6, cy - 20), (cx + 16, cy - 28), (cx + 12, cy - 16)], fill=(235, 235, 240, 255))
    elif wpn == "hammer":
        d.line([(cx + 6, cy - 16), (cx + 14, cy - 32)], fill=(110, 75, 45, 255), width=3)
        d.rectangle([(cx + 10, cy - 36), (cx + 18, cy - 28)], fill=(75, 75, 85, 255))
        
    img.save(os.path.join(char_dir, f"{h['id']}_sprite.png"))
    print(f"✅ 已生成好漢 Sprite: {h['id']}_sprite.png ({h['name']})")

# ==========================================
# 3. 生成 48x48 經典復古 UI 功能與資源圖示 (Icons)
# ==========================================

icons = [
    ("icon_gold", (245, 200, 35)),
    ("icon_food", (145, 195, 60)),
    ("icon_arms", (110, 120, 140)),
    ("icon_troops", (210, 60, 50)),
    ("icon_prestige", (240, 130, 40)),
    ("icon_build", (180, 120, 60)),
    ("icon_personnel", (60, 110, 210)),
    ("icon_military", (195, 45, 40)),
    ("icon_diplomacy", (75, 155, 215)),
    ("icon_strat", (145, 65, 185)),
    ("icon_save", (65, 145, 85))
]

for name, col in icons:
    img = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([(2, 2), (45, 45)], radius=6, fill=col + (230,), outline=(255, 255, 255, 255), width=2)
    img.save(os.path.join(icon_dir, f"{name}.png"))
    print(f"✅ 已生成 UI 圖示: {name}.png")

print("\n🎉🎉🎉 全套 2.5D 精靈圖、名將人物模組與 UI 圖示全部生成完畢！")
