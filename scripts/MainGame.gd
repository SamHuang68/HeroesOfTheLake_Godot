# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 遊戲主控制器 (Main Game Coordinator)
extends Node2D

const DataManagerScript = preload("res://scripts/DataManager.gd")
const HeroCharacter2DScript = preload("res://scripts/HeroCharacter2D.gd")

@onready var camera: Camera2D = $Camera2D
@onready var map: Node2D = $World2D/IsometricMap
@onready var characters_container: Node2D = $World2D/IsometricMap/Characters
@onready var ui_layer: CanvasLayer = $CanvasLayer
@onready var top_menu_bar: VBoxContainer = $CanvasLayer/TopMenuBar
@onready var hero_modal: PanelContainer = $CanvasLayer/HeroDetailModal
@onready var fortress_modal: PanelContainer = $CanvasLayer/FortressOverviewModal
@onready var minimap_window: PanelContainer = $CanvasLayer/MinimapWindow
@onready var personnel_modal: PanelContainer = $CanvasLayer/PersonnelModal
@onready var build_modal: PanelContainer = $CanvasLayer/BuildModal
@onready var military_modal: PanelContainer = $CanvasLayer/MilitaryModal
@onready var diplomacy_modal: PanelContainer = $CanvasLayer/DiplomacyModal
@onready var facility_info_modal: PanelContainer = $CanvasLayer/FacilityInfoModal
@onready var hero_action_modal: PanelContainer = $CanvasLayer/HeroActionModal

var is_dragging_camera: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO
var zoom_level: float = 1.0

func _ready() -> void:
	# 1. 初始化數據庫
	DataManagerScript.initialize()

	# 2. 綁定頂部選單事件
	if top_menu_bar.has_signal("menu_item_selected"):
		top_menu_bar.connect("menu_item_selected", _on_menu_item_selected)
	if top_menu_bar.has_signal("quick_action_triggered"):
		top_menu_bar.connect("quick_action_triggered", _on_quick_action_triggered)
	if top_menu_bar.has_signal("advance_month_clicked"):
		top_menu_bar.connect("advance_month_clicked", _on_advance_month)

	# 3. 綁定地圖點擊與設施檢視事件
	if map.has_signal("tile_clicked"):
		map.connect("tile_clicked", _on_tile_clicked)
	if map.has_signal("facility_constructed"):
		map.connect("facility_constructed", _on_facility_constructed)
	if map.has_signal("facility_inspected"):
		map.connect("facility_inspected", func(fac_node):
			facility_info_modal.call("display_facility", fac_node)
		)

	# 4. 綁定設施升級與好漢指派事件
	if facility_info_modal.has_signal("facility_upgraded"):
		facility_info_modal.connect("facility_upgraded", func(_f, g_cost, f_cost):
			top_menu_bar.set("gold", top_menu_bar.get("gold") - g_cost)
			top_menu_bar.set("food", top_menu_bar.get("food") - f_cost)
			top_menu_bar.call("update_status_display")
		)
	if facility_info_modal.has_signal("hero_assigned_to_facility"):
		facility_info_modal.connect("hero_assigned_to_facility", func(fac, h_name):
			# 同步好漢的工作狀態與動畫
			for child in characters_container.get_children():
				if child.get("hero_name") == h_name:
					var f_type: String = fac.get("facility_type")
					var job := "打鐵" if f_type == "Smithy" else ("農耕" if f_type == "Farm" else ("操練" if f_type == "Barracks" else "駐館"))
					child.call("assign_work", job)
					break
		)

	# 5. 綁定好漢快捷指令事件
	if hero_action_modal.has_signal("hero_reward_clicked"):
		hero_action_modal.connect("hero_reward_clicked", func(hero_inst, g_cost):
			top_menu_bar.set("gold", top_menu_bar.get("gold") - g_cost)
			top_menu_bar.call("update_status_display")
		)
	if hero_action_modal.has_signal("hero_full_detail_requested"):
		hero_action_modal.connect("hero_full_detail_requested", func(h_name):
			var h_data: Dictionary = DataManagerScript.get_hero(h_name)
			if not h_data.is_empty():
				hero_modal.call("display_hero", h_data)
		)

	# 6. 綁定人事名冊事件
	if personnel_modal.has_signal("hero_inspect_requested"):
		personnel_modal.connect("hero_inspect_requested", func(h_data):
			hero_modal.call("display_hero", h_data)
		)
	if personnel_modal.has_signal("hero_rewarded"):
		personnel_modal.connect("hero_rewarded", func(_h_id, gold_amt):
			top_menu_bar.set("gold", top_menu_bar.get("gold") - gold_amt)
			top_menu_bar.call("update_status_display")
		)

	# 7. 綁定建造事件
	if build_modal.has_signal("facility_chosen_to_build"):
		build_modal.connect("facility_chosen_to_build", func(f_data):
			var cost_gold: int = f_data.get("cost_gold", 100)
			var cost_food: int = f_data.get("cost_food", 50)
			if top_menu_bar.get("gold") >= cost_gold and top_menu_bar.get("food") >= cost_food:
				map.call("start_build_mode", f_data)
		)

	# 8. 綁定外交事件
	if diplomacy_modal.has_signal("resources_traded"):
		diplomacy_modal.connect("resources_traded", func(g_delta, f_delta, a_delta):
			top_menu_bar.set("gold", top_menu_bar.get("gold") + g_delta)
			top_menu_bar.set("food", top_menu_bar.get("food") + f_delta)
			top_menu_bar.set("arms", top_menu_bar.get("arms") + a_delta)
			top_menu_bar.call("update_status_display")
		)

	# 9. 傳遞縮圖參考
	minimap_window.set("map_ref", map)
	minimap_window.set("camera_ref", camera)

	# 10. 生成初始好漢角色
	spawn_initial_heroes()

	# 11. 置中攝影機至聚義廳 (網格 16, 16)
	var center_pos: Vector2 = map.call("grid_to_screen", 16, 16)
	camera.position = center_pos

	# 12. 初始視窗位置與狀態
	hero_modal.position = Vector2(20, 80)
	hero_modal.hide()

	fortress_modal.position = Vector2(720, 160)
	fortress_modal.hide()

	minimap_window.position = Vector2(20, 480)
	minimap_window.show()

	personnel_modal.position = Vector2(200, 100)
	personnel_modal.hide()

	build_modal.position = Vector2(300, 120)
	build_modal.hide()

	military_modal.position = Vector2(240, 90)
	military_modal.hide()

	diplomacy_modal.position = Vector2(280, 110)
	diplomacy_modal.hide()

	facility_info_modal.position = Vector2(420, 150)
	facility_info_modal.hide()

	hero_action_modal.position = Vector2(440, 180)
	hero_action_modal.hide()

func spawn_initial_heroes() -> void:
	var initial_hero_names := ["LinChong", "WuSong", "LuZhishen", "LiJun", "YangZhi", "ShiJin", "HuaRong", "DaiZong"]
	var grid_offsets: Array[Vector2i] = [
		Vector2i(16, 16), Vector2i(17, 15), Vector2i(15, 17), Vector2i(14, 14),
		Vector2i(18, 16), Vector2i(16, 18), Vector2i(15, 15), Vector2i(17, 17)
	]

	for i in range(initial_hero_names.size()):
		var h_id: String = initial_hero_names[i]
		var h_data: Dictionary = DataManagerScript.get_hero(h_id)
		if h_data.is_empty():
			continue

		var hero_node: Node2D = HeroCharacter2DScript.new()
		hero_node.set("hero_name", h_data["name"])
		hero_node.set("title_name", h_data["title"])
		hero_node.set("grid_position", grid_offsets[i])
		hero_node.set("current_stamina", h_data["stamina_curr"])
		hero_node.set("max_stamina", h_data["stamina_max"])
		hero_node.set("current_energy", int(h_data["might"] * 0.5))
		hero_node.set("portrait_file", h_data["portrait"])

		if hero_node.has_signal("hero_selected"):
			hero_node.connect("hero_selected", func(h_inst):
				hero_action_modal.call("display_hero", h_inst)
			)

		characters_container.add_child(hero_node)

func _on_menu_item_selected(menu_name: String) -> void:
	match menu_name:
		"personnel":
			personnel_modal.visible = !personnel_modal.visible
			if personnel_modal.visible: personnel_modal.call("refresh_table")
		"fortress", "info":
			fortress_modal.visible = !fortress_modal.visible
		"build":
			build_modal.visible = !build_modal.visible
		"military":
			military_modal.visible = !military_modal.visible
		"diplomacy":
			diplomacy_modal.visible = !diplomacy_modal.visible
		"faction":
			var linchong_data: Dictionary = DataManagerScript.get_hero("LinChong")
			hero_modal.call("display_hero", linchong_data)

func _on_quick_action_triggered(action: String) -> void:
	match action:
		"地":
			minimap_window.visible = !minimap_window.visible
		"人":
			personnel_modal.visible = !personnel_modal.visible
			if personnel_modal.visible: personnel_modal.call("refresh_table")
		"寨":
			fortress_modal.visible = !fortress_modal.visible
		"土":
			build_modal.visible = !build_modal.visible
		"全":
			fortress_modal.visible = !fortress_modal.visible

func _on_advance_month() -> void:
	top_menu_bar.call("advance_time", 30)

	# 依據所有設施與進駐好漢加乘計算月產能
	var facs_node: Node2D = map.get_node_or_null("Facilities")
	var extra_gold: int = 0
	var extra_food: int = 0
	var extra_arms: int = 0

	if facs_node:
		for f in facs_node.get_children():
			var f_type: String = f.get("facility_type")
			var lvl: int = f.get("level")
			var assigned: Array = f.get("assigned_heroes")
			var hero_mult: float = 1.5 if assigned.size() > 0 else 1.0

			match f_type:
				"Farm": extra_food += int(lvl * 250 * hero_mult)
				"Market", "Tavern": extra_gold += int(lvl * 300 * hero_mult)
				"Smithy": extra_arms += int(lvl * 150 * hero_mult)

	top_menu_bar.set("gold", top_menu_bar.get("gold") + extra_gold)
	top_menu_bar.set("food", top_menu_bar.get("food") + extra_food)
	top_menu_bar.set("arms", top_menu_bar.get("arms") + extra_arms)
	top_menu_bar.call("update_status_display")

func _on_facility_constructed(fac_data: Dictionary, _grid_pos: Vector2i) -> void:
	var cost_gold: int = fac_data.get("cost_gold", 100)
	var cost_food: int = fac_data.get("cost_food", 50)
	top_menu_bar.set("gold", top_menu_bar.get("gold") - cost_gold)
	top_menu_bar.set("food", top_menu_bar.get("food") - cost_food)
	top_menu_bar.call("update_status_display")

func _on_tile_clicked(grid_pos: Vector2i, _type: int) -> void:
	for child in characters_container.get_children():
		if child.get("hero_name") == "林沖":
			child.call("move_to_grid", grid_pos)
			break

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				is_dragging_camera = true
				last_mouse_pos = event.position
			else:
				is_dragging_camera = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_level = clampf(zoom_level + 0.1, 0.5, 2.0)
			camera.zoom = Vector2(zoom_level, zoom_level)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_level = clampf(zoom_level - 0.1, 0.5, 2.0)
			camera.zoom = Vector2(zoom_level, zoom_level)
	elif event is InputEventMouseMotion and is_dragging_camera:
		var delta: Vector2 = event.position - last_mouse_pos
		camera.position -= delta / zoom_level
		last_mouse_pos = event.position
