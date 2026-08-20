# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- KOEI 原版品質 2.5D 美術資產產生器
import os, math, random
from PIL import Image, ImageDraw, ImageFilter

base_dir = r"c:\Users\Sam\Documents\antigravity\Game Developing\HeroesOfTheLake_Godot\assets"
terr_dir = os.path.join(base_dir, "sprites", "terrain")
bld_dir = os.path.join(base_dir, "sprites", "buildings")
char_dir = os.path.join(base_dir, "sprites", "characters")

os.makedirs(terr_dir, exist_ok=True)
os.makedirs(bld_dir, exist_ok=True)
os.makedirs(char_dir, exist_ok=True)

# ==============================================================================
# 1. 2:1 等角地形圖塊 (64 x 32 px Isometric Ground Tiles)
# ==============================================================================

def create_isometric_mask(w=64, h=32):
    mask = Image.new("L", (w, h), 0)
    d = ImageDraw.Draw(mask)
    d.polygon([(w//2, 0), (w-1, h//2), (w//2, h-1), (0, h//2)], fill=255)
    return mask

def generate_water_tile():
    w, h = 64, 32
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    mask = create_isometric_mask(w, h)
    
    # 水體漸層基底 (深蔚藍至青碧)
    for y in range(h):
        for x in range(w):
            if mask.getpixel((x, y)) > 0:
                # 計算距離中心與波紋
                dist = math.sqrt((x - w/2)**2 + (y - h/2)**2)
                r = int(28 + (x % 7) * 2)
                g = int(85 + (y % 5) * 4 + math.sin(x*0.4 + y*0.6)*15)
                b = int(145 + (x % 9) * 3 + math.cos(x*0.5 - y*0.5)*20)
                img.putpixel((x, y), (r, g, b, 255))
                
    # 疊加波光反光水紋
    for i in range(5):
        wy = 8 + i * 4
        wx = 16 + (i * 7) % 24
        d.line([(wx, wy), (wx + 14, wy)], fill=(160, 220, 255, 180), width=1)
        d.line([(wx + 4, wy + 2), (wx + 10, wy + 2)], fill=(200, 240, 255, 220), width=1)
        
    img.save(os.path.join(terr_dir, "tile_water.png"))
    print("✅ 已生成 KOEI 等角水泊圖塊: tile_water.png")

def generate_grass_tile():
    w, h = 64, 32
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    mask = create_isometric_mask(w, h)
    
    random.seed(42)
    for y in range(h):
        for x in range(w):
            if mask.getpixel((x, y)) > 0:
                noise = random.randint(-8, 8)
                r = max(0, min(255, int(65 + noise)))
                g = max(0, min(255, int(135 + noise * 1.5)))
                b = max(0, min(255, int(45 + noise)))
                img.putpixel((x, y), (r, g, b, 255))
                
    d = ImageDraw.Draw(img)
    # 草叢細葉點綴
    for _ in range(12):
        gx = random.randint(12, 52)
        gy = random.randint(6, 26)
        if mask.getpixel((gx, gy)) > 0:
            d.line([(gx, gy), (gx - 1, gy - 2)], fill=(95, 185, 65, 255), width=1)
            d.line([(gx, gy), (gx + 1, gy - 3)], fill=(120, 205, 80, 255), width=1)
            if random.random() < 0.25: # 小野花
                d.point((gx + 2, gy - 2), fill=(245, 235, 120, 255))
                
    img.save(os.path.join(terr_dir, "tile_grass.png"))
    print("✅ 已生成 KOEI 等角草地圖塊: tile_grass.png")

def generate_farmland_tile():
    w, h = 64, 32
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    mask = create_isometric_mask(w, h)
    
    # 沃土底色
    for y in range(h):
        for x in range(w):
            if mask.getpixel((x, y)) > 0:
                noise = (x * 3 + y * 7) % 9
                img.putpixel((x, y), (135 + noise, 95 + noise, 50 + noise, 255))
                
    # 金黃耕作壟溝與秧苗
    for i in range(5):
        ly = 6 + i * 5
        d.line([(16 + i*2, ly), (48 - i*2, ly)], fill=(110, 70, 35, 255), width=2)
        # 綠油油秧苗
        for cx in range(20, 45, 4):
            if mask.getpixel((cx, ly)) > 0:
                d.line([(cx, ly), (cx, ly - 2)], fill=(185, 215, 60, 255), width=1)
                d.point((cx + 1, ly - 2), fill=(225, 185, 40, 255))
                
    img.save(os.path.join(terr_dir, "tile_farmland.png"))
    print("✅ 已生成 KOEI 等角農田圖塊: tile_farmland.png")

def generate_road_tile():
    w, h = 64, 32
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    mask = create_isometric_mask(w, h)
    
    # 碎石泥土路基底
    for y in range(h):
        for x in range(w):
            if mask.getpixel((x, y)) > 0:
                noise = (x * 11 + y * 17) % 15
                img.putpixel((x, y), (150 + noise, 135 + noise, 115 + noise, 255))
                
    # 鵝卵石與石板路面
    cobbles = [(24, 14), (32, 10), (40, 16), (28, 20), (36, 22), (20, 16), (44, 12)]
    for cx, cy in cobbles:
        d.ellipse([(cx - 3, cy - 2), (cx + 3, cy + 2)], fill=(125, 115, 100, 255), outline=(175, 165, 145, 255))
        
    img.save(os.path.join(terr_dir, "tile_road.png"))
    print("✅ 已生成 KOEI 等角道路圖塊: tile_road.png")

def generate_stone_pave_tile():
    w, h = 64, 32
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    mask = create_isometric_mask(w, h)
    
    for y in range(h):
        for x in range(w):
            if mask.getpixel((x, y)) > 0:
                noise = (x * 5 + y * 9) % 11
                img.putpixel((x, y), (160 + noise, 165 + noise, 175 + noise, 255))
                
    # 青磚格線
    for y in range(4, 28, 6):
        d.line([(w//2 - y, y), (w//2 + y, y)], fill=(120, 125, 135, 255), width=1)
        
    img.save(os.path.join(terr_dir, "tile_stone.png"))
    print("✅ 已生成 KOEI 等角石板圖塊: tile_stone.png")

generate_water_tile()
generate_grass_tile()
generate_farmland_tile()
generate_road_tile()
generate_stone_pave_tile()

# ==============================================================================
# 2. KOEI 原版品質 2.5D 等角古風建築精靈圖
# ==============================================================================

def create_koei_grand_zhongyi_hall():
    w, h = 192, 160
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy = w // 2, 122
    
    # 1. 漢白玉三層須彌座高台 (Triple Tier Marble Terrace)
    d.polygon([(cx, cy - 36), (cx + 84, cy + 6), (cx, cy + 48), (cx - 84, cy + 6)], fill=(185, 185, 195, 255), outline=(225, 225, 235, 255))
    d.polygon([(cx, cy - 30), (cx + 76, cy + 8), (cx, cy + 42), (cx - 76, cy + 8)], fill=(210, 210, 220, 255))
    d.polygon([(cx, cy - 24), (cx + 68, cy + 10), (cx, cy + 36), (cx - 68, cy + 10)], fill=(230, 230, 240, 255))
    
    # 漢白玉螭首與御道階梯
    for i in range(5):
        sy = cy + 16 + i * 5
        d.line([(cx - 24, sy), (cx + 24, sy)], fill=(160, 160, 170, 255), width=2)
        d.line([(cx - 8, sy), (cx + 8, sy)], fill=(215, 175, 75, 255), width=2) # 金龍御道雕刻
        
    # 2. 朱紅殿身、立柱、斗栱與格子門 (Red Pillars & Song Dynasty Brackets)
    d.rectangle([(cx - 56, cy - 50), (cx + 56, cy + 2)], fill=(155, 35, 25, 255), outline=(95, 20, 15, 255))
    for px in [-50, -25, 0, 25, 50]:
        d.rectangle([(cx + px - 4, cy - 54), (cx + px + 4, cy + 4)], fill=(100, 18, 12, 255), outline=(60, 10, 8, 255))
        # 斗栱金漆
        d.polygon([(cx + px - 6, cy - 54), (cx + px + 6, cy - 54), (cx + px, cy - 48)], fill=(235, 185, 50, 255))
        
    # 格子門窗 (Lattice Windows)
    for wx in [-38, -12, 12, 38]:
        d.rectangle([(cx + wx - 7, cy - 40), (cx + wx + 7, cy - 6)], fill=(50, 25, 20, 255), outline=(210, 180, 120, 255))
        d.line([(cx + wx, cy - 40), (cx + wx, cy - 6)], fill=(210, 180, 120, 255), width=1)
        d.line([(cx + wx - 7, cy - 23), (cx + wx + 7, cy - 23)], fill=(210, 180, 120, 255), width=1)
        
    # 3. 下層金色琉璃重簷 (Lower Eaves)
    d.polygon([(cx, cy - 72), (cx + 94, cy - 26), (cx, cy + 18), (cx - 94, cy - 26)], fill=(215, 145, 30, 255), outline=(255, 215, 75, 255))
    # 瓦壟細線
    for vx in range(-80, 85, 10):
        d.line([(cx + vx, cy - 26 + abs(vx)*0.4), (cx + vx*0.6, cy - 65)], fill=(185, 115, 20, 255), width=1)
        
    # 4. 上層殿閣主體與重簷廡殿頂 (Upper Pavilion & Imperial Roof)
    d.rectangle([(cx - 36, cy - 88), (cx + 36, cy - 72)], fill=(145, 30, 20, 255), outline=(90, 15, 10, 255))
    d.polygon([(cx, cy - 122), (cx + 78, cy - 84), (cx, cy - 46), (cx - 78, cy - 84)], fill=(240, 170, 40, 255), outline=(255, 235, 100, 255))
    
    # 飛簷翹角 (Curved Upturned Eaves)
    d.line([(cx - 78, cy - 84), (cx - 86, cy - 90)], fill=(255, 220, 60, 255), width=3)
    d.line([(cx + 78, cy - 84), (cx + 86, cy - 90)], fill=(255, 220, 60, 255), width=3)
    
    # 正脊大金龍與寶珠 (Dragon Ridge & Pearl)
    d.line([(cx - 40, cy - 105), (cx + 40, cy - 105)], fill=(255, 220, 50, 255), width=6)
    d.ellipse([(cx - 46, cy - 110), (cx - 36, cy - 100)], fill=(255, 190, 30, 255), outline=(255, 240, 120, 255))
    d.ellipse([(cx + 36, cy - 110), (cx + 46, cy - 100)], fill=(255, 190, 30, 255), outline=(255, 240, 120, 255))
    d.ellipse([(cx - 6, cy - 112), (cx + 6, cy - 100)], fill=(255, 255, 150, 255), outline=(255, 200, 40, 255))
    
    # 5. 「替天行道」杏黃大旗
    d.line([(cx - 72, cy + 20), (cx - 72, cy - 75)], fill=(75, 45, 20, 255), width=3)
    d.polygon([(cx - 72, cy - 72), (cx - 32, cy - 62), (cx - 36, cy - 38), (cx - 72, cy - 48)], fill=(245, 215, 60, 255), outline=(195, 30, 20, 255))
    # 旗牙
    for fy in range(int(cy - 62), int(cy - 38), 6):
        d.polygon([(cx - 32, fy), (cx - 26, fy + 3), (cx - 32, fy + 6)], fill=(195, 30, 20, 255))
        
    # 6. 「忠義堂」金字九龍御匾
    d.rectangle([(cx - 22, cy - 58), (cx + 22, cy - 42)], fill=(15, 20, 45, 255), outline=(245, 210, 60, 255), width=2)
    
    img.save(os.path.join(bld_dir, "main_hall_3x3.png"))
    print("✅ 已生成 KOEI 頂級忠義堂本營: main_hall_3x3.png")

def create_koei_smithy():
    w, h = 128, 128
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy = w // 2, 85
    
    d.polygon([(cx, cy - 26), (cx + 52, cy + 2), (cx, cy + 28), (cx - 52, cy + 2)], fill=(130, 120, 110, 255), outline=(90, 80, 70, 255))
    d.rectangle([(cx - 38, cy - 32), (cx + 38, cy + 6)], fill=(110, 85, 70, 255), outline=(65, 50, 40, 255))
    d.polygon([(cx, cy - 60), (cx + 48, cy - 28), (cx, cy + 8), (cx - 48, cy - 28)], fill=(85, 85, 100, 255), outline=(205, 185, 75, 255))
    
    # 磚石煙囪
    d.rectangle([(cx + 22, cy - 72), (cx + 36, cy - 22)], fill=(75, 55, 45, 255), outline=(45, 35, 25, 255))
    d.rectangle([(cx + 20, cy - 78), (cx + 38, cy - 70)], fill=(55, 40, 30, 255))
    
    # 熊熊炭火與鐵砧
    d.ellipse([(cx - 22, cy - 14), (cx - 8, cy - 4)], fill=(255, 85, 20, 255), outline=(255, 220, 50, 255))
    d.rectangle([(cx - 24, cy - 6), (cx - 6, cy + 6)], fill=(50, 50, 60, 255), outline=(100, 100, 120, 255))
    
    # 淬火水桶與長槍兵器架
    d.ellipse([(cx + 12, cy + 2), (cx + 24, cy + 14)], fill=(70, 50, 35, 255), outline=(100, 160, 220, 255))
    d.line([(cx + 28, cy + 6), (cx + 34, cy - 24)], fill=(210, 210, 225, 255), width=2)
    d.line([(cx + 32, cy + 8), (cx + 38, cy - 22)], fill=(210, 210, 225, 255), width=2)
    
    img.save(os.path.join(bld_dir, "smithy_2x2.png"))
    print("✅ 已生成 KOEI 神兵鐵匠坊: smithy_2x2.png")

def create_koei_tavern():
    w, h = 128, 128
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy = w // 2, 85
    
    d.polygon([(cx, cy - 26), (cx + 52, cy + 2), (cx, cy + 28), (cx - 52, cy + 2)], fill=(150, 125, 95, 255))
    d.rectangle([(cx - 38, cy - 38), (cx + 38, cy + 6)], fill=(145, 105, 70, 255), outline=(85, 60, 40, 255))
    d.polygon([(cx, cy - 65), (cx + 50, cy - 30), (cx, cy + 6), (cx - 50, cy - 30)], fill=(185, 85, 35, 255), outline=(240, 205, 75, 255))
    
    # 酒旗 (飄逸杏黃紅字)
    d.line([(cx - 40, cy + 10), (cx - 40, cy - 50)], fill=(75, 45, 25, 255), width=3)
    d.polygon([(cx - 40, cy - 48), (cx - 10, cy - 40), (cx - 14, cy - 20), (cx - 40, cy - 28)], fill=(245, 225, 85, 255), outline=(175, 20, 20, 255))
    
    # 懸掛紅燈籠 (發光)
    d.ellipse([(cx + 26, cy - 24), (cx + 40, cy - 8)], fill=(245, 55, 25, 255), outline=(255, 215, 45, 255))
    
    # 陶土酒罈堆 (紅布封口)
    for bx, by in [(-24, 6), (-14, 10), (-20, 14)]:
        d.ellipse([(cx + bx - 5, cy + by - 6), (cx + bx + 5, cy + by + 6)], fill=(130, 80, 50, 255), outline=(70, 40, 25, 255))
        d.ellipse([(cx + bx - 3, cy + by - 6), (cx + bx + 3, cy + by - 2)], fill=(215, 35, 30, 255))
        
    img.save(os.path.join(bld_dir, "tavern_2x2.png"))
    print("✅ 已生成 KOEI 聚義好漢酒館: tavern_2x2.png")

def create_koei_shipyard():
    w, h = 128, 128
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy = w // 2, 85
    
    # 木棧橋與繫船樁
    d.rectangle([(cx - 52, cy - 8), (cx + 52, cy + 12)], fill=(120, 85, 50, 255), outline=(75, 50, 25, 255))
    for px in range(-45, 50, 15):
        d.line([(cx + px, cy - 8), (cx + px, cy + 12)], fill=(65, 45, 20, 255), width=1)
    d.ellipse([(cx - 48, cy - 12), (cx - 42, cy - 4)], fill=(60, 40, 20, 255))
    d.ellipse([(cx + 42, cy - 12), (cx + 48, cy - 4)], fill=(60, 40, 20, 255))
    
    # 停靠大宋樓船戰艦
    d.polygon([(cx - 42, cy + 14), (cx + 42, cy + 14), (cx + 54, cy - 6), (cx - 54, cy - 6)], fill=(90, 60, 35, 255), outline=(45, 30, 15, 255))
    d.line([(cx, cy - 6), (cx, cy - 54)], fill=(70, 40, 20, 255), width=3) # 主桅
    d.polygon([(cx, cy - 50), (cx + 32, cy - 34), (cx, cy - 16)], fill=(235, 230, 215, 255), outline=(175, 165, 145, 255)) # 主帆
    
    # 水波反光
    d.line([(cx - 38, cy + 18), (cx + 38, cy + 18)], fill=(140, 210, 255, 180), width=1)
    
    img.save(os.path.join(bld_dir, "shipyard_2x2.png"))
    print("✅ 已生成 KOEI 水泊碼頭與樓船: shipyard_2x2.png")

def create_koei_granary():
    w, h = 128, 128
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy = w // 2, 85
    
    d.polygon([(cx, cy - 26), (cx + 45, cy), (cx, cy + 26), (cx - 45, cy)], fill=(145, 115, 85, 255))
    d.rectangle([(cx - 32, cy - 26), (cx + 32, cy + 8)], fill=(135, 100, 70, 255), outline=(75, 55, 35, 255))
    d.polygon([(cx, cy - 65), (cx + 40, cy - 20), (cx, cy + 12), (cx - 40, cy - 20)], fill=(210, 180, 75, 255), outline=(245, 220, 115, 255))
    
    # 堆積如山的麻袋糧食與木輪手推車
    d.ellipse([(cx - 30, cy + 6), (cx - 16, cy + 18)], fill=(215, 205, 170, 255), outline=(160, 150, 120, 255))
    d.ellipse([(cx - 20, cy + 8), (cx - 6, cy + 20)], fill=(215, 205, 170, 255), outline=(160, 150, 120, 255))
    d.ellipse([(cx + 14, cy + 10), (cx + 26, cy + 22)], fill=(80, 55, 30, 255)) # 木輪
    
    img.save(os.path.join(bld_dir, "granary_2x2.png"))
    print("✅ 已生成 KOEI 聚義糧倉: granary_2x2.png")

def create_koei_barracks():
    w, h = 128, 128
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy = w // 2, 85
    
    d.polygon([(cx, cy - 26), (cx + 52, cy + 2), (cx, cy + 28), (cx - 52, cy + 2)], fill=(140, 105, 75, 255))
    d.rectangle([(cx - 38, cy - 28), (cx + 38, cy + 6)], fill=(140, 40, 35, 255), outline=(80, 20, 18, 255))
    d.polygon([(cx, cy - 58), (cx + 48, cy - 26), (cx, cy + 8), (cx - 48, cy - 26)], fill=(180, 30, 25, 255), outline=(235, 205, 75, 255))
    
    # 雙面三軍戰旗
    d.line([(cx + 36, cy + 10), (cx + 36, cy - 52)], fill=(60, 40, 20, 255), width=3)
    d.polygon([(cx + 36, cy - 50), (cx + 62, cy - 38), (cx + 36, cy - 26)], fill=(215, 25, 20, 255), outline=(255, 215, 45, 255))
    
    # 兵器架與箭靶
    d.ellipse([(cx - 26, cy - 2), (cx - 14, cy + 10)], fill=(225, 220, 205, 255), outline=(180, 30, 20, 255))
    d.ellipse([(cx - 22, cy + 2), (cx - 18, cy + 6)], fill=(180, 30, 20, 255))
    
    img.save(os.path.join(bld_dir, "barracks_2x2.png"))
    print("✅ 已生成 KOEI 先鋒軍營演武場: barracks_2x2.png")

create_koei_grand_zhongyi_hall()
create_koei_smithy()
create_koei_tavern()
create_koei_shipyard()
create_koei_granary()
create_koei_barracks()

print("\n🎉🎉🎉 全套 KOEI 頂級畫質 2.5D 美術資產產生完畢！")
