# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 全國十大名城與要塞沙盤地圖自動化驗收測試
extends SceneTree

const IsometricMapScript = preload("res://scripts/IsometricMap.gd")
const FortressDatabaseScript = preload("res://scripts/FortressDatabase.gd")

func _init() -> void:
	print("\n================================================================================")
	print("  🏰 《水滸英雄錄：天導108星》全國十大名城與要塞沙盤地圖 — 自動化驗證測試")
	print("================================================================================\n")

	var all_passed: bool = true
	var map: Node2D = IsometricMapScript.new()
	map.call("_ready")

	var fortresses: Array[String] = FortressDatabaseScript.get_all_fortress_ids()
	print("即將逐一驗收全國 %d 大名城與要塞沙盤格局 (包含地形、道路、歷史設施與植被)..." % fortresses.size())

	for fid in fortresses:
		var fdata: Dictionary = FortressDatabaseScript.get_fortress_data(fid)
		var fname: String = fdata["name"]
		var fgov: String = fdata["governor"]
		var cap: int = fdata["capacity"]
		var theme: String = fdata["theme"]

		print("\n[測試要塞] %s (首領: %s, 設施上限: %d, 主題: %s)" % [fname, fgov, cap, theme])

		# 載入並切換沙盤
		map.call("load_fortress_map", fid)

		var g_data: Dictionary = map.get("grid_data")
		var r_grid: Dictionary = map.get("road_grid")
		var facs_container: Node2D = map.get_node_or_null("Facilities")
		var decs_container: Node2D = map.get_node_or_null("Decorations")

		var fac_count: int = facs_container.get_child_count() if facs_container else 0
		var dec_count: int = decs_container.get_child_count() if decs_container else 0

		print("  - 地形網格數: %d 格, 碎石路網: %d 格" % [g_data.size(), r_grid.size()])
		print("  - 初始實例化古風設施: %d 座 (含主殿/軍營/酒肆/鐵匠鋪/哨塔/鹿角)" % fac_count)
		print("  - 自然景觀植被物件: %d 處" % dec_count)

		if g_data.size() == 1024 and fac_count >= 5 and dec_count >= 5:
			print("  ✅ 【%s】沙盤地圖與設施格局 100%% 驗證通過！" % [fname])
		else:
			printerr("  ❌ 【%s】地圖或設施生成異常！" % [fname])
			all_passed = false

	print("\n================================================================================")
	if all_passed:
		print("  🎉🎉🎉 全國十大名城與要塞地圖資料庫 100% 全部通過深度驗收！")
	else:
		print("  ❌ 部分要塞驗收失敗，請檢查日誌！")
	print("================================================================================\n")

	quit(0 if all_passed else 1)
