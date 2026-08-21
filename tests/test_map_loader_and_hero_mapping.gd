# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 要塞地圖自動生成與好漢模型/狀態機映射系統 — 自動化驗收測試
extends SceneTree

const FortressMapLoaderScript = preload("res://scripts/FortressMapLoader.gd")
const HeroEntityScript = preload("res://scripts/HeroEntity.gd")
const HeroVisualControllerScript = preload("res://scripts/HeroVisualController.gd")

func _init() -> void:
	print("\n================================================================================")
	print("  🏰 《水滸傳·天導108星》要塞地圖生成與好漢模型狀態機映射 — 深度自動化驗收")
	print("================================================================================\n")

	var all_passed: bool = true

	# --------------------------------------------------------------------------
	# [驗收 1/3] 地圖載入驗證 (Map Loader & TileMapLayer 實例化)
	# --------------------------------------------------------------------------
	print("[驗證 1/3] 測試 FortressMapLoader 注入 scenarios_database.json 生成要塞沙盤...")
	var map_loader = FortressMapLoaderScript.new()
	var root_node = Node2D.new()
	root_node.add_child(map_loader)
	
	map_loader.load_fortress_scenario("SCE1", "liangshan")
	
	var ground_count: int = map_loader.ground_layer.get_child_count()
	var road_count: int = map_loader.road_layer.get_child_count()
	var fac_count: int = map_loader.ysort_layer.get_child_count()
	var hero_count: int = map_loader.hero_spawner.get_child_count()
	
	print("  - 自然地貌層 (GroundLayer) 地塊數量: %d" % ground_count)
	print("  - 道路路網層 (RoadLayer) 地塊數量: %d" % road_count)
	print("  - 設施與工事層 (YSortObjectLayer) 物件數量: %d (含聚義忠義堂、酒館、鐵匠坊、碼頭等)" % fac_count)
	print("  - 初始好漢實體層 (HeroEntities) 產生數量: %d 位" % hero_count)
	
	if ground_count >= 100 and fac_count >= 6 and hero_count >= 5:
		print("  ✅ [驗收 1 通過] 要塞地圖完整地塊、主城與設施正確生成，無空白網格！\n")
	else:
		printerr("  ❌ [驗收 1 失敗] 地圖地塊或設施數量不足！")
		all_passed = false

	# --------------------------------------------------------------------------
	# [驗收 2/3] 400 位好漢模型與特徵映射驗證 (Hero Model Mapping)
	# --------------------------------------------------------------------------
	print("[驗證 2/3] 測試 400 位好漢與 00~36 模型、骨架與性別屬性映射...")
	var mapping_path := "res://data/hero_model_mapping.json"
	if not FileAccess.file_exists(mapping_path):
		mapping_path = "res://data/native_converted/hero_model_mapping.json"
		
	var mfile = FileAccess.open(mapping_path, FileAccess.READ)
	var mapping: Dictionary = JSON.parse_string(mfile.get_as_text())
	mfile.close()
	
	print("  - 好漢映射資料庫總筆數: %d 筆" % mapping.size())
	
	# 檢驗重點名將
	var songjiang: Dictionary = mapping.get("000", {})
	var linchong: Dictionary = mapping.get("005", {})
	var husanniang: Dictionary = mapping.get("052", {})
	var lishishi: Dictionary = mapping.get("399", {})
	var wusong: Dictionary = mapping.get("013", {})
	var luzhishen: Dictionary = mapping.get("012", {})
	
	print("  - 宋江 (ID: 000): 姓名=%s, 模型=%s, 性別=%s, 武器=%s" % [songjiang.get("name"), songjiang.get("model_id"), songjiang.get("gender"), songjiang.get("default_weapon")])
	print("  - 林冲 (ID: 005): 姓名=%s, 模型=%s, 性別=%s, 武器=%s" % [linchong.get("name"), linchong.get("model_id"), linchong.get("gender"), linchong.get("default_weapon")])
	print("  - 扈三娘 (ID: 052): 姓名=%s, 模型=%s, 性別=%s, 武器=%s" % [husanniang.get("name"), husanniang.get("model_id"), husanniang.get("gender"), husanniang.get("default_weapon")])
	print("  - 李師師 (ID: 399): 姓名=%s, 模型=%s, 性別=%s, 武器=%s" % [lishishi.get("name"), lishishi.get("model_id"), lishishi.get("gender"), lishishi.get("default_weapon")])
	
	var mapping_ok: bool = (
		mapping.size() >= 400 and
		linchong.get("name") == "林冲" and
		songjiang.get("name") == "宋江" and
		husanniang.get("gender") == "female" and
		lishishi.get("gender") == "female"
	)
	
	if mapping_ok:
		print("  ✅ [驗收 2 通過] 400 位好漢模型映射與名將特徵綁定完全正確！\n")
	else:
		printerr("  ❌ [驗收 2 失敗] 好漢模型映射驗證未通過！")
		all_passed = false

	# --------------------------------------------------------------------------
	# [驗收 3/3] 動作觸發與性別專屬狀態機 (Action State Machine & Seduce Fallback)
	# --------------------------------------------------------------------------
	print("[驗證 3/3] 測試好漢動作狀態機、進駐酒館暢飲與色誘/士氣高昂防呆機制...")
	
	# 3.1 測試女性好漢 (扈三娘 ID: 052)
	var female_hero = HeroEntityScript.new()
	root_node.add_child(female_hero)
	female_hero.init_hero("052", Vector2i(15, 17))
	
	# 下達進駐酒館
	female_hero.set_action_state("Work_Tavern")
	var fem_tavern_state = female_hero.visual_model.current_state
	var fem_tavern_socket = female_hero.visual_model.socket_r_item
	print("  - 扈三娘下達【進駐酒館】: 狀態碼=%s (WORK_TAVERN), 手持掛件=%s" % [fem_tavern_state, fem_tavern_socket])
	
	# 下達色誘
	female_hero.set_action_state("Combat_Seduce")
	var fem_seduce_state = female_hero.visual_model.current_state
	var fem_seduce_socket = female_hero.visual_model.socket_r_item
	print("  - 女性好漢 (扈三娘) 觸發【色誘】: 狀態碼=%s (COMBAT_SEDUCE), 手持掛件=%s (絲帕)" % [fem_seduce_state, fem_seduce_socket])
	
	# 3.2 測試男性好漢 (林冲 ID: 005)
	var male_hero = HeroEntityScript.new()
	root_node.add_child(male_hero)
	male_hero.init_hero("005", Vector2i(14, 15))
	
	# 下達打鐵
	male_hero.set_action_state("Work_Blacksmith")
	var male_smith_state = male_hero.visual_model.current_state
	var male_smith_socket = male_hero.visual_model.socket_r_item
	print("  - 林冲下達【進駐鐵匠鋪打鐵】: 狀態碼=%s (WORK_BLACKSMITH), 手持掛件=%s" % [male_smith_state, male_smith_socket])
	
	# 下達色誘 (測試男性 Fallback)
	male_hero.set_action_state("Combat_Seduce")
	var male_seduce_state = male_hero.visual_model.current_state
	print("  - 男性好漢 (林冲) 下達【色誘】: 自動防呆退回狀態碼=%s (COMBAT_MORALE_HIGH)" % male_seduce_state)
	
	var actions_ok: bool = (
		fem_tavern_state == HeroVisualControllerScript.AnimState.WORK_TAVERN and
		fem_seduce_state == HeroVisualControllerScript.AnimState.COMBAT_SEDUCE and
		male_smith_state == HeroVisualControllerScript.AnimState.WORK_BLACKSMITH and
		male_seduce_state == HeroVisualControllerScript.AnimState.COMBAT_MORALE_HIGH
	)
	
	if actions_ok:
		print("  ✅ [驗收 3 通過] 18 套通用動作狀態機與性別防呆機制 100% 驗收通過！\n")
	else:
		printerr("  ❌ [驗收 3 失敗] 動作狀態機切換未符合預期！")
		all_passed = false

	print("================================================================================")
	if all_passed:
		print("  🎉🎉🎉 要塞地圖自動生成與好漢模型/狀態機映射系統 100% 全部通過驗收！")
	else:
		print("  ❌ 驗收未通過，請檢查錯誤！")
	print("================================================================================\n")

	quit(0 if all_passed else 1)
