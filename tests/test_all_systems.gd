# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 全系統全自動驗證測試腳本 (Automated Systems Verification)
extends SceneTree

const DataManagerScript = preload("res://scripts/DataManager.gd")
const IsometricMapScript = preload("res://scripts/IsometricMap.gd")
const TopMenuBarScript = preload("res://scripts/TopMenuBar.gd")
const MilitaryModalScript = preload("res://scripts/MilitaryModal.gd")

func _init() -> void:
	print("\n========================================================")
	print("  《水滸英雄錄：天導108星》Godot 2D 全系統自動驗證測試")
	print("========================================================\n")

	var all_passed: bool = true

	# 測試 1: 數據庫載入測試 (CSV 解析與 211 位好漢)
	print("[測試 1] 測試 CSV 數據庫解析與好漢載入...")
	DataManagerScript.initialize()
	var all_heroes: Array = DataManagerScript.get_all_heroes()
	print("  - 成功載入好漢數量: %d 位" % all_heroes.size())
	if all_heroes.size() < 108:
		printerr("  ❌ 好漢數量不足 108 星！")
		all_passed = false
	else:
		var linchong: Dictionary = DataManagerScript.get_hero("LinChong")
		if linchong.get("name") == "林沖" and linchong.get("title") == "豹子頭" and linchong.get("might") > 90:
			print("  ✅ 林沖五維數據驗證通過: 臂力 %.2f, 技能 %.2f, 智力 %.2f, 忠義 %d" % [linchong["might"], linchong["skill"], linchong["intel"], linchong["loyalty"]])
		else:
			printerr("  ❌ 林沖數據不符！")
			all_passed = false

	# 測試 2: 設施數據庫測試
	print("\n[測試 2] 測試設施數據庫載入...")
	var farm: Dictionary = DataManagerScript.get_facility("Farm")
	if farm.get("name") == "耕地" and farm.get("cost_gold") == 100:
		print("  ✅ 設施數據驗證通過: %s (耗金 %d, 耗糧 %d)" % [farm["name"], farm["cost_gold"], farm["cost_food"]])
	else:
		printerr("  ❌ 設施數據載入失敗！")
		all_passed = false

	# 測試 3: 2:1 等角菱形網格轉換測試
	print("\n[測試 3] 測試 2:1 等角網格座標互轉公式...")
	var map: Node2D = IsometricMapScript.new()
	var test_gx: int = 16
	var test_gy: int = 16
	var screen_p: Vector2 = map.call("grid_to_screen", test_gx, test_gy)
	var back_grid: Vector2i = map.call("screen_to_grid", screen_p)
	if back_grid.x == test_gx and back_grid.y == test_gy:
		print("  ✅ 網格轉螢幕 (16, 16) -> (%.1f, %.1f) -> 逆轉網格 (16, 16) 100%% 精確吻合！" % [screen_p.x, screen_p.y])
	else:
		printerr("  ❌ 座標轉換誤差: 原始 (%d, %d) vs 回算 (%d, %d)" % [test_gx, test_gy, back_grid.x, back_grid.y])
		all_passed = false

	# 測試 4: 設施建造與地塊變更測試
	print("\n[測試 4] 測試要塞地塊設施建造流程...")
	var build_pos := Vector2i(10, 10)
	map.call("place_facility", build_pos, farm)
	var gdata: Dictionary = map.get("grid_data")
	var facs: Array = map.get("constructed_facilities")
	if gdata.get(build_pos) == 2 and facs.size() == 1:
		print("  ✅ 設施建造成功！地塊 (10, 10) 成功轉為金黃耕地 (FARMLAND)")
	else:
		printerr("  ❌ 設施建造失敗！")
		all_passed = false

	# 測試 5: 月度產能與政略推進測試
	print("\n[測試 5] 測試政略月度結算與時間推進...")
	var topbar: VBoxContainer = TopMenuBarScript.new()
	topbar.set("gold", 10000)
	topbar.set("food", 5000)
	topbar.set("current_month", 6)
	topbar.call("advance_time", 30)
	var m: int = topbar.get("current_month")
	var g: int = topbar.get("gold")
	var f: int = topbar.get("food")
	if m == 7 and g > 10000 and f > 5000:
		print("  ✅ 月度推進成功！月份: %d月, 金庫增至: %d, 糧食增至: %d" % [m, g, f])
	else:
		printerr("  ❌ 月度推進結算異常！")
		all_passed = false

	# 測試 6: 演武單挑戰鬥系統測試
	print("\n[測試 6] 測試演武堂 1v1 名將單挑戰鬥邏輯...")
	var mil: PanelContainer = MilitaryModalScript.new()
	mil.call("reset_duel")
	var initial_enemy_hp: int = mil.get("hero2_hp")
	mil.call("perform_attack", "果斷突擊", 38, 30)
	var curr_enemy_hp: int = mil.get("hero2_hp")
	var curr_h1_stam: int = mil.get("hero1_stamina")
	if curr_enemy_hp < initial_enemy_hp and curr_h1_stam < 95:
		print("  ✅ 單挑技能發動成功！敵將受創氣血降至 %d/100, 我方體力消耗至 %d" % [curr_enemy_hp, curr_h1_stam])
	else:
		printerr("  ❌ 單挑傷害計算異常！")
		all_passed = false

	print("\n========================================================")
	if all_passed:
		print("  🎉🎉🎉 全數 6 大核心功能測試 100% 通過！驗證完全成功！")
	else:
		print("  ❌ 部分測試未通過，請檢查錯誤日誌！")
	print("========================================================\n")

	quit(0 if all_passed else 1)
