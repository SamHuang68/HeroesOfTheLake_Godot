# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 好漢實體與 3D/2.5D 模型狀態機綁定實例 (Hero Entity)
class_name HeroEntity
extends Node2D

@export var hero_data_path: String = "res://data/hero_model_mapping.json"
var hero_id: String = ""
var hero_info: Dictionary = {}
var visual_model: HeroVisualController = null
var grid_position: Vector2i = Vector2i(0, 0)
var current_action_state: String = "Locomotion_Idle"

@onready var hud: Node2D = $HUD
@onready var name_label: Label = $HUD/NameLabel
@onready var hp_label: Label = $HUD/HPLabel
@onready var action_label: Label = $HUD/ActionLabel

func _ready() -> void:
	if visual_model == null:
		# 若無子節點則自動建立視覺控制器
		var existing_vis = get_node_or_null("VisualController")
		if existing_vis is HeroVisualController:
			visual_model = existing_vis
		else:
			visual_model = HeroVisualController.new()
			visual_model.name = "VisualController"
			add_child(visual_model)

## 初始化好漢基本資訊、模型映射與菱形網格座標
func init_hero(p_hero_id: String, grid_pos: Vector2i) -> void:
	hero_id = p_hero_id
	grid_position = grid_pos
	
	# 讀取 400 位好漢模型映射配置
	var mapping: Dictionary = {}
	var paths_to_try := [
		hero_data_path,
		"res://data/hero_model_mapping.json",
		"res://data/native_converted/hero_model_mapping.json"
	]
	for p in paths_to_try:
		if FileAccess.file_exists(p):
			var file = FileAccess.open(p, FileAccess.READ)
			if file:
				var parsed = JSON.parse_string(file.get_as_text())
				if parsed is Dictionary:
					mapping = parsed
				file.close()
				break
				
	hero_info = mapping.get(hero_id, {})
	if hero_info.is_empty():
		# 支援以純數字或英文名稱做 Fallback
		var int_id = hero_id.to_int()
		var formatted_id = "%03d" % int_id
		hero_info = mapping.get(formatted_id, {})
		
	if hero_info.is_empty():
		# Fallback 到內建資料庫
		var fallback_mid = CharacterModelDatabase.get_model_for_hero(hero_id)
		var mid_info = CharacterModelDatabase.get_model_info(fallback_mid)
		hero_info = {
			"name": hero_id,
			"portrait": "res://assets/portraits/Portrait_LinChong.jpg",
			"model_id": fallback_mid,
			"gender": "female" if mid_info.get("is_female", false) else "male",
			"default_weapon": mid_info.get("r_socket", "spear")
		}

	# 1. 設置 UI 資訊 (預設隱藏，僅選取/懸停時顯現)
	if name_label:
		name_label.text = hero_info.get("name", hero_id)
		name_label.visible = false
	if hp_label:
		hp_label.text = "100/100"
		hp_label.visible = false
	if action_label:
		action_label.text = "巡邏中"
		action_label.visible = false

	# 2. 轉換菱形網格座標為 2D 螢幕位置 (TileW=64, TileH=32)
	position = Vector2(
		(grid_pos.x - grid_pos.y) * 32.0,
		(grid_pos.x + grid_pos.y) * 16.0
	)
	z_index = int(position.y)

	# 3. 動態掛載對應 3D/2.5D 模型、骨架與武器配件
	var model_id: String = hero_info.get("model_id", "00")
	var is_female: bool = (hero_info.get("gender") == "female")
	
	if visual_model == null:
		visual_model = HeroVisualController.new()
		visual_model.name = "VisualController"
		add_child(visual_model)
		
	visual_model.model_id = model_id
	visual_model.hero_name = hero_info.get("name", hero_id)
	visual_model.is_female = is_female
	
	# 設定預設掛點武器
	var wpn = hero_info.get("default_weapon", "spear")
	visual_model.socket_r_item = wpn
	visual_model.queue_redraw()

## 切換好漢動作狀態 (支援 18 大通用狀態機與男女防呆判定)
func set_action_state(action_type: String) -> void:
	current_action_state = action_type
	if action_label:
		action_label.text = action_type
		
	if visual_model == null:
		return
		
	match action_type:
		"Work_Tavern", "Tavern", "喝酒":
			visual_model.set_state(HeroVisualController.AnimState.WORK_TAVERN)
		"Work_Farm", "Farm", "種田":
			visual_model.set_state(HeroVisualController.AnimState.WORK_FARM)
		"Work_Fish", "Fish", "捕魚":
			visual_model.set_state(HeroVisualController.AnimState.WORK_FISH)
		"Work_Market", "Market", "買賣":
			visual_model.set_state(HeroVisualController.AnimState.WORK_MARKET)
		"Work_Blacksmith", "Blacksmith", "打鐵":
			visual_model.set_state(HeroVisualController.AnimState.WORK_BLACKSMITH)
		"Work_Shipyard", "Shipyard", "修船":
			visual_model.set_state(HeroVisualController.AnimState.WORK_SHIPYARD)
		"Work_Taoist", "Taoist", "讀經":
			visual_model.set_state(HeroVisualController.AnimState.WORK_TAOIST)
		"Work_Alchemy", "Alchemy", "煉丹":
			visual_model.set_state(HeroVisualController.AnimState.WORK_ALCHEMY)
		"Work_Pleasure", "Pleasure", "遊樂":
			visual_model.set_state(HeroVisualController.AnimState.WORK_PLEASURE)
		"Work_Ranch", "Ranch", "養馬":
			visual_model.set_state(HeroVisualController.AnimState.WORK_RANCH)
		"Combat_Attack", "Attack", "攻擊":
			visual_model.set_state(HeroVisualController.AnimState.COMBAT_ATTACK)
		"Combat_Raze", "Raze", "破壞":
			visual_model.set_state(HeroVisualController.AnimState.COMBAT_RAZE)
		"Combat_MoraleHigh", "MoraleHigh", "高昂":
			visual_model.set_state(HeroVisualController.AnimState.COMBAT_MORALE_HIGH)
		"Combat_CastSpell", "CastSpell", "施法":
			visual_model.set_state(HeroVisualController.AnimState.COMBAT_CAST_SPELL)
		"Combat_Seduce", "Seduce", "色誘":
			# 女性好漢可正常播放色誘；男性自動 Fallback 至士氣高昂
			visual_model.set_state(HeroVisualController.AnimState.COMBAT_SEDUCE)
			if not visual_model.is_female and action_label:
				action_label.text = "Combat_MoraleHigh (Fallback)"
		"Locomotion_Walk", "Walk", "行走":
			visual_model.set_state(HeroVisualController.AnimState.LOCOMOTION_WALK)
		"Locomotion_Run", "Run", "奔跑":
			visual_model.set_state(HeroVisualController.AnimState.LOCOMOTION_RUN)
		_:
			visual_model.set_state(HeroVisualController.AnimState.LOCOMOTION_IDLE)
			
	visual_model.queue_redraw()

func move_to_grid(target_grid: Vector2i) -> void:
	grid_position = target_grid
	if visual_model:
		visual_model.move_to_grid(target_grid)
