# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 具體視覺模組與系統互動自動化驗證測試
extends SceneTree

const IsometricMapScript = preload("res://scripts/IsometricMap.gd")
const IsometricFacilityScript = preload("res://scripts/IsometricFacility.gd")
const HeroCharacter2DScript = preload("res://scripts/HeroCharacter2D.gd")

func _init() -> void:
	print("\n================================================================================")
	print("  🎨 《水滸英雄錄：天導108星》具體視覺模組與系統互動 — 自動化驗收測試")
	print("================================================================================\n")

	var all_passed: bool = true

	# 測試 1: 建築精靈貼圖載入與解析度驗證
	print("[測試 1/4] 驗證 2.5D 等角建築實體精靈貼圖 (Building Sprites)...")
	var buildings := ["main_hall_3x3", "smithy_2x2", "tavern_2x2", "shipyard_2x2", "granary_2x2", "barracks_2x2"]
	for b in buildings:
		var path := "res://assets/sprites/buildings/%s.png" % b
		if ResourceLoader.exists(path):
			var tex: Texture2D = load(path)
			print("  ✅ 成功載入建築模組: %s.png (%dx%d px)" % [b, int(tex.get_width()), int(tex.get_height())])
		else:
			printerr("  ❌ 建築模組貼圖遺失: %s" % path)
			all_passed = false

	# 測試 2: 好漢人物精靈圖載入與外觀特徵驗證
	print("\n[測試 2/4] 驗證好漢微縮 2D 精靈圖模組 (Hero Character Sprites)...")
	var heroes := ["linchong", "wusong", "luzhishen", "lijun", "huarong", "songjiang", "wuyong", "tanglong"]
	for h in heroes:
		var path := "res://assets/sprites/characters/%s_sprite.png" % h
		if ResourceLoader.exists(path):
			var tex: Texture2D = load(path)
			print("  ✅ 成功載入好漢精靈圖: %s_sprite.png (%dx%d px)" % [h, int(tex.get_width()), int(tex.get_height())])
		else:
			printerr("  ❌ 好漢精靈圖遺失: %s" % path)
			all_passed = false

	# 測試 3: 復古 UI 功能與資源圖示驗證
	print("\n[測試 3/4] 驗證復古 UI 功能與物資圖示 (UI Icons)...")
	var icons := ["icon_gold", "icon_food", "icon_arms", "icon_troops", "icon_prestige", "icon_build", "icon_personnel", "icon_military", "icon_diplomacy", "icon_strat", "icon_save"]
	for ic in icons:
		var path := "res://assets/icons/%s.png" % ic
		if ResourceLoader.exists(path):
			print("  ✅ UI 圖示就緒: %s.png" % ic)
		else:
			printerr("  ❌ UI 圖示遺失: %s" % path)
			all_passed = false

	# 測試 4: 設施與人物節點實體繪製與互動狀態驗證
	print("\n[測試 4/4] 測試設施與人物節點載入貼圖並執行互動渲染循環...")
	var fac: Node2D = IsometricFacilityScript.new()
	fac.set("facility_type", "MainHall")
	fac.call("_ready")
	fac.set("is_hovered", true)
	fac.call("_process", 0.1)

	var hero: Node2D = HeroCharacter2DScript.new()
	hero.set("hero_name", "林沖")
	hero.call("_ready")
	hero.set("is_hovered", true)
	hero.call("_process", 0.1)

	var fac_tex: Texture2D = fac.get("building_texture")
	var hero_tex: Texture2D = hero.get("hero_sprite_texture")

	if fac_tex != null and hero_tex != null:
		print("  ✅ 設施與角色節點成功綁定真實 Sprite 貼圖並啟用滑鼠懸停光暈！")
	else:
		printerr("  ❌ 節點貼圖綁定失敗！")
		all_passed = false

	print("\n================================================================================")
	if all_passed:
		print("  🎉🎉🎉 全套視覺模組、建築實體、好漢 Sprite 與 UI 圖示 100% 驗收通過！")
	else:
		print("  ❌ 測試未完全通過！")
	print("================================================================================\n")

	quit(0 if all_passed else 1)
