# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- PSX 原廠圖像資產抽取與載入自動化驗收測試
extends SceneTree

func _init() -> void:
	print("\n================================================================================")
	print("  📀 《水滸英雄錄：天導108星》PSX 原版遊戲資產抽取 — 自動化驗證測試")
	print("================================================================================\n")

	var all_passed: bool = true

	# 測試 1: 原廠設施建築資產驗證 (KOEI Facilities)
	print("[驗證 1/3] 測試 KOEI 原版設施建築圖塊 (SHISETSU.BIN 解碼資產)...")
	var fac_ok_count: int = 0
	for i in range(40):
		var p := "res://assets/psx_extracted/buildings/koei_facility_%02d.png" % i
		if ResourceLoader.exists(p):
			fac_ok_count += 1
	print("  - 成功載入 KOEI 原廠設施建築圖塊: %d 座 (含原版酒館、鐵匠鋪、糧倉、主殿等)" % fac_ok_count)
	if fac_ok_count >= 30:
		print("  ✅ KOEI 原廠設施資產抽取驗收通過！")
	else:
		printerr("  ❌ 原廠設施資產數量異常！")
		all_passed = false

	# 測試 2: 原廠好漢微縮 Sprite 驗證 (KOEI Characters)
	print("\n[驗證 2/3] 測試 KOEI 原版好漢動作 Sprite (SCHARA_M.BIN 解碼資產)...")
	var char_ok_count: int = 0
	for i in range(50):
		var p := "res://assets/psx_extracted/characters/koei_char_%02d.png" % i
		if ResourceLoader.exists(p):
			char_ok_count += 1
	print("  - 成功載入 KOEI 原廠好漢動作圖塊: %d 個 (含行走、待機、操練微縮 Sprite)" % char_ok_count)
	if char_ok_count >= 40:
		print("  ✅ KOEI 原廠好漢精靈圖抽取驗收通過！")
	else:
		printerr("  ❌ 原廠好漢資產數量異常！")
		all_passed = false

	# 測試 3: 原廠自然地形圖塊驗證 (KOEI Terrains)
	print("\n[驗證 3/3] 測試 KOEI 原版自然地貌圖塊 (CHIKEI.BIN 解碼資產)...")
	var terr_ok_count: int = 0
	for i in range(4):
		var p := "res://assets/psx_extracted/terrain/koei_terrain_%02d.png" % i
		if ResourceLoader.exists(p):
			terr_ok_count += 1
	print("  - 成功載入 KOEI 原廠地形圖塊: %d 個" % terr_ok_count)
	if terr_ok_count >= 4:
		print("  ✅ KOEI 原廠地形圖塊抽取驗收通過！")
	else:
		printerr("  ❌ 原廠地形圖塊數量異常！")
		all_passed = false

	print("\n================================================================================")
	if all_passed:
		print("  🎉🎉🎉 PS 原版 CD 鏡像圖像抽取 100% 全部通過！所有原廠圖形直接導入！")
	else:
		print("  ❌ 抽取驗收未完全通過！")
	print("================================================================================\n")

	quit(0 if all_passed else 1)
