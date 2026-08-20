# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- PSX 原版 CD-ROM 圖像資產提取器
import zipfile, struct, os
from PIL import Image

zip_path = r"C:\Users\Sam\Downloads\水滸傳：天導108星.zip"
out_dir = r"c:\Users\Sam\Documents\antigravity\Game Developing\HeroesOfTheLake_Godot\assets\psx_extracted"
os.makedirs(out_dir, exist_ok=True)
os.makedirs(os.path.join(out_dir, "buildings"), exist_ok=True)
os.makedirs(os.path.join(out_dir, "characters"), exist_ok=True)
os.makedirs(os.path.join(out_dir, "terrain"), exist_ok=True)
os.makedirs(os.path.join(out_dir, "items"), exist_ok=True)

def decode_tim(data, offset=0):
    if len(data) < offset + 8:
        return None, 4
    tag, flag = struct.unpack("<II", data[offset:offset+8])
    if tag != 0x10:
        return None, 4
    
    bpp_mode = flag & 0x07
    has_clut = (flag & 0x08) != 0
    
    ptr = offset + 8
    cluts = []
    
    if has_clut:
        if len(data) < ptr + 12:
            return None, 4
        clut_len = struct.unpack("<I", data[ptr:ptr+4])[0]
        if clut_len < 12 or ptr + clut_len > len(data):
            return None, 4
        cx, cy, cw, ch = struct.unpack("<HHHH", data[ptr+4:ptr+12])
        clut_data = data[ptr+12:ptr+clut_len]
        ptr += clut_len
        
        num_colors = (clut_len - 12) // 2
        for i in range(num_colors):
            c = struct.unpack("<H", clut_data[i*2:i*2+2])[0]
            r = (c & 0x1F) << 3
            g = ((c >> 5) & 0x1F) << 3
            b = ((c >> 10) & 0x1F) << 3
            a = 0 if (c == 0x7C1F or (i == 0 and c == 0)) else 255
            cluts.append((r, g, b, a))

    if len(data) < ptr + 12:
        return None, 4
    img_len = struct.unpack("<I", data[ptr:ptr+4])[0]
    if img_len < 12 or ptr + img_len > len(data):
        return None, 4
    ix, iy, iw, ih = struct.unpack("<HHHH", data[ptr+4:ptr+12])
    pixel_data = data[ptr+12:ptr+img_len]
    total_tim_size = (ptr + img_len) - offset
    
    if iw <= 0 or ih <= 0:
        return None, 4

    try:
        if bpp_mode == 0: # 4bpp
            real_w = iw * 4
            real_h = ih
            img = Image.new("RGBA", (real_w, real_h), (0, 0, 0, 0))
            pixels = img.load()
            for y in range(real_h):
                for x in range(0, real_w, 2):
                    byte_idx = y * (iw * 2) + (x // 2)
                    if byte_idx < len(pixel_data):
                        b_val = pixel_data[byte_idx]
                        p1 = b_val & 0x0F
                        p2 = (b_val >> 4) & 0x0F
                        if cluts and p1 < len(cluts):
                            pixels[x, y] = cluts[p1]
                        if cluts and p2 < len(cluts) and (x + 1 < real_w):
                            pixels[x+1, y] = cluts[p2]
            return img, total_tim_size
        elif bpp_mode == 1: # 8bpp
            real_w = iw * 2
            real_h = ih
            img = Image.new("RGBA", (real_w, real_h), (0, 0, 0, 0))
            pixels = img.load()
            for y in range(real_h):
                for x in range(real_w):
                    byte_idx = y * (iw * 2) + x
                    if byte_idx < len(pixel_data):
                        val = pixel_data[byte_idx]
                        if cluts and val < len(cluts):
                            pixels[x, y] = cluts[val]
            return img, total_tim_size
        elif bpp_mode == 2: # 16bpp
            real_w = iw
            real_h = ih
            img = Image.new("RGBA", (real_w, real_h), (0, 0, 0, 0))
            pixels = img.load()
            for y in range(real_h):
                for x in range(real_w):
                    idx = (y * iw + x) * 2
                    if idx + 1 < len(pixel_data):
                        c = struct.unpack("<H", pixel_data[idx:idx+2])[0]
                        r = (c & 0x1F) << 3
                        g = ((c >> 5) & 0x1F) << 3
                        b = ((c >> 10) & 0x1F) << 3
                        a = 0 if c == 0x7C1F else 255
                        pixels[x, y] = (r, g, b, a)
            return img, total_tim_size
    except Exception as e:
        print("解碼例外:", e)
        return None, 4

    return None, 4

with zipfile.ZipFile(zip_path, "r") as z:
    for name in z.namelist():
        if name.endswith("Track 1).bin"):
            with z.open(name) as f:
                def read_file_data(lba, size):
                    sectors = (size + 2047) // 2048
                    data = b""
                    for s in range(sectors):
                        f.seek((lba + s) * 2352 + 24)
                        data += f.read(2048)
                    return data[:size]
                
                # 1. 抽取 GRP/SHISETSU.BIN (設施建築圖塊)
                print("解碼 GRP/SHISETSU.BIN 設施建築資產...")
                shisetsu_data = read_file_data(3426, 107008)
                ptr = 0
                f_idx = 0
                while ptr < len(shisetsu_data) - 8:
                    if shisetsu_data[ptr:ptr+4] == b"\x10\x00\x00\x00":
                        im, sz = decode_tim(shisetsu_data, ptr)
                        if im:
                            im.save(os.path.join(out_dir, "buildings", f"psx_facility_{f_idx:02d}.png"))
                            print(f"  - 設施圖塊 {f_idx:02d}: {im.size}")
                            f_idx += 1
                        ptr += max(sz, 4)
                    else:
                        ptr += 4
                        
                # 2. 抽取 GRP/SCHARA_M.BIN & SCHARA_W.BIN (好漢精靈圖)
                print("解碼 GRP/SCHARA_M.BIN 男性好漢精靈資產...")
                schara_data = read_file_data(3392, 33024)
                ptr = 0
                c_idx = 0
                while ptr < len(schara_data) - 8:
                    if schara_data[ptr:ptr+4] == b"\x10\x00\x00\x00":
                        im, sz = decode_tim(schara_data, ptr)
                        if im:
                            im.save(os.path.join(out_dir, "characters", f"psx_char_m_{c_idx:02d}.png"))
                            print(f"  - 男性角色 Sprite {c_idx:02d}: {im.size}")
                            c_idx += 1
                        ptr += max(sz, 4)
                    else:
                        ptr += 4

                # 3. 抽取 GRP/CHIKEI.BIN (地形圖塊)
                print("解碼 GRP/CHIKEI.BIN 地形資產...")
                chikei_data = read_file_data(1665, 4864)
                ptr = 0
                t_idx = 0
                while ptr < len(chikei_data) - 8:
                    if chikei_data[ptr:ptr+4] == b"\x10\x00\x00\x00":
                        im, sz = decode_tim(chikei_data, ptr)
                        if im:
                            im.save(os.path.join(out_dir, "terrain", f"psx_terrain_{t_idx:02d}.png"))
                            print(f"  - 地形圖塊 {t_idx:02d}: {im.size}")
                            t_idx += 1
                        ptr += max(sz, 4)
                    else:
                        ptr += 4

                # 4. 抽取 GRP/ITEM.BIN (寶物道具)
                print("解碼 GRP/ITEM.BIN 寶物資產...")
                item_data = read_file_data(1859, 301056)
                ptr = 0
                i_idx = 0
                while ptr < len(item_data) - 8:
                    if item_data[ptr:ptr+4] == b"\x10\x00\x00\x00":
                        im, sz = decode_tim(item_data, ptr)
                        if im:
                            im.save(os.path.join(out_dir, "items", f"psx_item_{i_idx:02d}.png"))
                            i_idx += 1
                        ptr += max(sz, 4)
                    else:
                        ptr += 4
                print(f"  - 共解碼 {i_idx} 個寶物神兵圖塊！")

print("🎉🎉🎉 PS 原版遊戲圖像資產（設施、好漢、地形、神兵）抽取完畢！")
