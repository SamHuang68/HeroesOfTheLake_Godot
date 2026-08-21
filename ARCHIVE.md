# 📦 《水滸英雄錄：天導108星》專案封存紀錄 (Project Archive Record)

- **封存日期**：2026-08-21
- **專案狀態**：已封存 (Archived)
- **遠端代碼庫**：[https://github.com/SamHuang68/HeroesOfTheLake_Godot](https://github.com/SamHuang68/HeroesOfTheLake_Godot)
- **最後穩定版本標籤**：`v1.0-archived`

---

## 📑 封存成果與資產總覽

本專案於封存前已完整完成以下技術資產與原生 Clean-Room 工具鏈：

1. **PSX 原版 Clean-Room ISO 9660 二進位轉換工具鏈**：
   - `tools/extract_iso9660.py`：PS 光碟 Track 1 ISO 9660 資料軌與音軌解碼。
   - `tools/suikoden_psx_converter.py`：解出 400 位好漢立繪頭像（`kao_000.png` ~ `kao_399.png`）、150+ 裝備道具圖示、大宋大地圖與無損 CD-DA 音軌。
   - `tools/mips_recompiler.py`：將 211,968 條 MIPS R3000A 機器碼轉譯為 C 語言核心代碼。

2. **400 位水滸好漢全域資料庫**：
   - `data/hero_model_mapping.json`：收錄 400 位好漢姓名、立繪路徑、模型 ID、性別與預設兵器配置。
   - `data/native_converted/scenarios_database.json`：三大劇本與要塞沙盤網格。

3. **39 套好漢 8 方向 × 18 通用動作 × 8 影格等角 SpriteSheet 動畫庫**：
   - 包含 990 張 $512 \times 512$ 動畫精靈圖表（共 44,928 個影格），涵蓋移動、戰鬥、奇門施法、色誘與 10 大營運勞作動作。
   - `scripts/HeroSpriteRenderer.gd`：腳底接觸錨點 `(0.5, 0.92)` 鎖定與 40% 不透明度接地陰影。

4. **2:1 等角菱形沙盤地圖與原版 2.5D 古風建築/景觀資產**：
   - `scripts/IsometricMap.gd` & `scripts/FortressMapLoader.gd`：嚴格數學逆變換，游標無偏差吸附。
   - 水墨青松、垂柳、銀杏、巨石、蘆葦、忠義堂大殿、箭樓、拒馬木柵等原版手繪精靈圖。

5. **10 大核心管理系統與自動化驗收測試集**：
   - 存讀檔（SaveManager）、隨機江湖事件（EventManager）、15 大職業成長（ProfessionManager）、戰鬥天候（CombatManager）、外交通商、名將單挑、人事錄用等 8 套自動化測試通過率 100%。

---

## 🔒 封存維護說明

若未來需重啟或調閱本專案：
1. 複製 GitHub 儲存庫：
   ```bash
   git clone https://github.com/SamHuang68/HeroesOfTheLake_Godot.git
   ```
2. 使用 Godot Engine 4.x 直接開啟即可完整還原所有資料與功能。
