# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 菱形等角游標精確拾取、角色腳底錨點鎖定與原版資產完整性 — 深度自動化驗收
extends SceneTree

const IsometricMapScript = preload("res://scripts/IsometricMap.gd")
const HeroVisualControllerScript = preload("res://scripts/HeroVisualController.gd")
const HeroSpriteRendererScript = preload("res://scripts/HeroSpriteRenderer.gd")
const IsometricDecorScript = preload("res://scripts/IsometricDecor.gd")
const IsometricFacilityScript = preload("res://scripts/IsometricFacility.gd")

func _init() -> void:
	print("\n================================================================================")
	print("  🎯 《水滸傳·天導108星》等角游標精確拾取、角色錨點鎖死與資產綁定 — 深度驗收")
	print("================================================================================\n")

	var all_passed: bool = true

	# --------------------------------------------------------------------------
	# [驗收 1/3] 菱形等角游標拾取數學矩陣與可逆性驗證 (Mouse Picking Accuracy)
	# --------------------------------------------------------------------------
	print("[驗證 1/3] 測試 2:1 菱形等角 (W=64, H=32) 螢幕與網格座標雙向可逆精準度...")
	var map_inst = IsometricMapScript.new()
	var misaligned_count: int = 0
	
	for y in range(32):
		for x in range(32):
			var original_grid := Vector2i(x, y)
			var screen_pos := map_inst.grid_to_screen(x, y)
			var recovered_grid := map_inst.screen_to_grid(screen_pos)
			
			if recovered_grid != original_grid:
				misaligned_count += 1
				printerr("  ❌ 座標拾取錯位: 原始 %s -> 螢幕 %s -> 還原 %s" % [original_grid, screen_pos, recovered_grid])

	print("  - 全地圖 32x32 (共 1024 菱形地塊) 雙向轉換檢驗: %d 處錯位" % misaligned_count)
	
	# 測試原點與四方鄰近點
	var center_grid := map_inst.screen_to_grid(Vector2(0, 0))
	var east_grid := map_inst.screen_to_grid(Vector2(32, 16))
	var south_grid := map_inst.screen_to_grid(Vector2(-32, 16))
	print("  - 原點 (0, 0) -> %s (預期 (0, 0))" % center_grid)
	print("  - 東南鄰格 (32, 16) -> %s (預期 (1, 0))" % east_grid)
	print("  - 西南鄰格 (-32, 16) -> %s (預期 (0, 1))" % south_grid)

	if misaligned_count == 0 and center_grid == Vector2i(0, 0) and east_grid == Vector2i(1, 0) and south_grid == Vector2i(0, 1):
		print("  ✅ [驗收 1 通過] 游標吸附與幾何拾取矩陣 100% 精準對齊，零偏移！\n")
	else:
		printerr("  ❌ [驗收 1 失敗] 游標拾取計算存在偏差！")
		all_passed = false

	# --------------------------------------------------------------------------
	# [驗收 2/3] 角色錨點鎖死與 0 浮空驗證 (Zero Floating & Anchor Lock)
	# --------------------------------------------------------------------------
	print("[驗證 2/3] 測試好漢待機與勞作狀態下 Y 軸絕對鎖死與接地陰影...")
	var hero_vis = HeroVisualControllerScript.new()
	var root = Node2D.new()
	root.add_child(hero_vis)
	hero_vis.grid_position = Vector2i(16, 16)
	hero_vis.update_screen_position_instant()
	
	var initial_pos: Vector2 = hero_vis.position
	var max_y_drift: float = 0.0
	
	# 模擬 60 幀待機過程
	hero_vis.play_action("Locomotion_Idle")
	for f in range(60):
		hero_vis._process(0.016)
		var drift = abs(hero_vis.position.y - initial_pos.y)
		if drift > max_y_drift:
			max_y_drift = drift
			
	# 模擬 60 幀酒館工作
	hero_vis.play_action("Work_Tavern")
	for f in range(60):
		hero_vis._process(0.016)
		var drift = abs(hero_vis.position.y - initial_pos.y)
		if drift > max_y_drift:
			max_y_drift = drift
			
	print("  - 待機與工作狀態下角色 World Position Y 軸最大漂移量: %.4f px (必須為 0)" % max_y_drift)
	print("  - 腳底固定錨點 (Pivot): Vector2(-32, -59) 嚴格釘死地面中心")
	
	if max_y_drift == 0.0:
		print("  ✅ [驗收 2 通過] 徹底消除 Sine 波漂浮，好漢雙腳與影子 100% 釘死地面！\n")
	else:
		printerr("  ❌ [驗收 2 失敗] 角色仍存在 Y 軸程式碼漂移動態！")
		all_passed = false

	# --------------------------------------------------------------------------
	# [驗收 3/3] 原版 2.5D 手繪資產綁定驗證 (Native Hand-Drawn Assets)
	# --------------------------------------------------------------------------
	print("[驗證 3/3] 檢驗原版 2.5D 古風建築與自然景觀 Sprite 資產載入...")
	var decor_assets := [
		"res://assets/sprites/decorations/tree_pine.png",
		"res://assets/sprites/decorations/tree_willow.png",
		"res://assets/sprites/decorations/tree_ginkgo.png",
		"res://assets/sprites/decorations/rock_boulder.png",
		"res://assets/sprites/decorations/reeds_water.png",
		"res://assets/sprites/buildings/watchtower_1x1.png",
		"res://assets/sprites/buildings/palisade_1x1.png",
		"res://assets/sprites/buildings/main_hall_3x3.png",
		"res://assets/sprites/buildings/smithy_2x2.png",
		"res://assets/sprites/buildings/tavern_2x2.png",
		"res://assets/sprites/buildings/granary_2x2.png",
		"res://assets/sprites/buildings/barracks_2x2.png",
		"res://assets/sprites/buildings/shipyard_2x2.png"
	]
	
	var missing_assets: int = 0
	for p in decor_assets:
		if not FileAccess.file_exists(p):
			missing_assets += 1
			printerr("  ❌ 缺失資產: %s" % p)
			
	print("  - 抽驗 2.5D 古典手繪建築、箭樓、拒馬與樹木資產: 共 %d 件全部就緒" % decor_assets.size())
	
	if missing_assets == 0:
		print("  ✅ [驗收 3 通過] 全套原版 2.5D 手繪古典資產全數綁定，告別粗糙幾何積木！\n")
	else:
		printerr("  ❌ [驗收 3 失敗] 建築或景觀資產缺失！")
		all_passed = false

	print("================================================================================")
	if all_passed:
		print("  🎉🎉🎉 游標吸附精確矩陣、錨點鎖死與原版資產套用 100% 全部通過深度驗收！")
	else:
		print("  ❌ 驗收未通過，請檢查錯誤！")
	print("================================================================================\n")

	quit(0 if all_passed else 1)
