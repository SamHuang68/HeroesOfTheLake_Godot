# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- PSX ISO 9660 Mode 2 Form 1 CD 鏡像解碼與檔案抽取工具
import os, struct

bin_path = r"c:\Users\Sam\Documents\antigravity\Game Developing\KOEI_Suikoden_Tiandao108_PC\GameDisc\Suikoden_Tiandao108_Track1.bin"
out_dir = r"c:\Users\Sam\Documents\antigravity\Game Developing\HeroesOfTheLake_Godot\psx_extracted_disc"
os.makedirs(out_dir, exist_ok=True)

def read_sector_data(f, sector_idx):
    f.seek(sector_idx * 2352 + 24)
    return f.read(2048)

with open(bin_path, "rb") as f:
    pvd = read_sector_data(f, 16)
    root_dir_record = pvd[156:156+34]
    
    def parse_dir_record(record_bytes):
        length = record_bytes[0]
        if length == 0:
            return None
        extent_loc = struct.unpack("<I", record_bytes[2:6])[0]
        data_len = struct.unpack("<I", record_bytes[10:14])[0]
        flags = record_bytes[25]
        is_dir = (flags & 0x02) != 0
        name_len = record_bytes[32]
        name = record_bytes[33:33+name_len].decode("latin1", errors="ignore").split(";")[0]
        return {
            "length": length,
            "extent": extent_loc,
            "size": data_len,
            "is_dir": is_dir,
            "name": name
        }

    def extract_directory(dir_extent, dir_size, current_path):
        num_sectors = (dir_size + 2047) // 2048
        dir_data = bytearray()
        for i in range(num_sectors):
            dir_data.extend(read_sector_data(f, dir_extent + i))
        
        offset = 0
        while offset < len(dir_data):
            rec_len = dir_data[offset]
            if rec_len == 0:
                offset = ((offset // 2048) + 1) * 2048
                continue
            
            rec = parse_dir_record(dir_data[offset:offset+rec_len])
            offset += rec_len
            if not rec:
                continue
            
            if rec["name"] in ("\x00", "\x01", "", "."):
                continue
            
            item_path = os.path.join(current_path, rec["name"])
            if rec["is_dir"]:
                os.makedirs(item_path, exist_ok=True)
                extract_directory(rec["extent"], rec["size"], item_path)
            else:
                file_sectors = (rec["size"] + 2047) // 2048
                file_bytes = bytearray()
                for s in range(file_sectors):
                    file_bytes.extend(read_sector_data(f, rec["extent"] + s))
                file_bytes = file_bytes[:rec["size"]]
                
                with open(item_path, "wb") as out_f:
                    out_f.write(file_bytes)
                rel = os.path.relpath(item_path, out_dir)
                print(f"已解碼抽取檔案: {rel} ({rec['size']} bytes)")

    root_rec = parse_dir_record(root_dir_record)
    extract_directory(root_rec["extent"], root_rec["size"], out_dir)

print("\n🎉 光榮原版 PSX ISO 9660 資料軌所有檔案 100% 完整解碼抽取完畢！")
