# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 遊戲主控制器 (Main Game Coordinator)
extends Node2D

const IsometricMapScript = preload("res://scripts/IsometricMap.gd")
const TopMenuBarScript = preload("res://scripts/TopMenuBar.gd")
const HeroDetailModalScript = preload("res://scripts/HeroDetailModal.gd")
const FortressOverviewModalScript = preload("res://scripts/FortressOverviewModal.gd")
const MinimapWindowScript = preload("res://scripts/MinimapWindow.gd")
const HeroCharacter2DScript = preload("res://scripts/HeroCharacter2D.gd")

@onready var camera: Camera2D = $Camera2D
@onready var map: Node2D = $World2D/IsometricMap
@onready var characters_container: Node2D = $World2D/IsometricMap/Characters
@onready var ui_layer: CanvasLayer = $CanvasLayer
@onready var top_menu_bar: VBoxContainer = $CanvasLayer/TopMenuBar
@onready var hero_modal: PanelContainer = $CanvasLayer/HeroDetailModal
@onready var fortress_modal: PanelContainer = $CanvasLayer/FortressOverviewModal
@onready var minimap_window: PanelContainer = $CanvasLayer/MinimapWindow

var is_dragging_camera: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO
var zoom_level: float = 1.0

func _ready() -> void:
	# 綁定頂部選單事件
	if top_menu_bar.has_signal("menu_item_selected"):
		top_menu_bar.connect("menu_item_selected", _on_menu_item_selected)
	if top_menu_bar.has_signal("quick_action_triggered"):
		top_menu_bar.connect("quick_action_triggered", _on_quick_action_triggered)
	if top_menu_bar.has_signal("advance_month_clicked"):
		top_menu_bar.connect("advance_month_clicked", _on_advance_month)

	# 綁定地圖點擊事件
	if map.has_signal("tile_clicked"):
		map.connect("tile_clicked", _on_tile_clicked)

	# 傳遞地圖與攝影機參考至縮圖
	minimap_window.set("map_ref", map)
	minimap_window.set("camera_ref", camera)

	# 生成初始 2D 好漢角色
	spawn_initial_heroes()

	# 置中攝影機至聚義廳 (網格 16, 16)
	var center_pos: Vector2 = map.call("grid_to_screen", 16, 16)
	camera.position = center_pos

	# 預設顯示左側好漢面板與右側要塞一覽表 (1:1 截圖情境)
	hero_modal.position = Vector2(20, 80)
	hero_modal.show()

	fortress_modal.position = Vector2(720, 160)
	fortress_modal.show()

	minimap_window.position = Vector2(20, 480)
	minimap_window.show()

func spawn_initial_heroes() -> void:
	var heroes_data: Array[Dictionary] = [
		{
			"name": "林沖", "title": "豹子頭", "grid": Vector2i(16, 16),
			"might": 92.0, "skill": 85.0, "intel": 69.0, "stamina_curr": 95, "stamina_max": 95,
			"loyalty": 91, "benevolence": 82, "courage": 86, "allegiance": -1,
			"portrait": "portrait_linchong.jpg", "action": "現在正在山東搜索",
			"bio": "【天雄星 · 豹子頭 林沖】\n梁山馬軍五虎將之首，生得豹頭環眼、燕頷虎鬚，人稱小張飛。原為東京八十萬禁軍槍棒教頭，武藝高強，擅使丈八蛇矛。"
		},
		{
			"name": "武松", "title": "行者", "grid": Vector2i(17, 15),
			"might": 95.0, "skill": 88.0, "intel": 64.0, "stamina_curr": 98, "stamina_max": 98,
			"loyalty": 94, "benevolence": 76, "courage": 99, "allegiance": -1,
			"portrait": "portrait_wusong.jpg", "action": "正在要塞巡哨",
			"bio": "【天傷星 · 行者 武松】\n清河縣人氏，景陽岡赤手空拳打死猛虎，威震天下。血濺鴛鴦樓，快意恩仇，雙戒刀所向無敵！"
		},
		{
			"name": "魯智深", "title": "花和尚", "grid": Vector2i(15, 17),
			"might": 96.0, "skill": 82.0, "intel": 60.0, "stamina_curr": 99, "stamina_max": 99,
			"loyalty": 96, "benevolence": 88, "courage": 98, "allegiance": -1,
			"portrait": "portrait_luzhishen.jpg", "action": "正在操練步軍",
			"bio": "【天孤星 · 花和尚 魯智深】\n原為延安府提轄，為救金翠蓮三拳打死鎮關西，大鬧五台山、倒拔垂楊柳，使六十二斤水磨禪杖！"
		},
		{
			"name": "李俊", "title": "混江龍", "grid": Vector2i(14, 14),
			"might": 84.0, "skill": 82.0, "intel": 78.0, "stamina_curr": 92, "stamina_max": 92,
			"loyalty": 88, "benevolence": 84, "courage": 90, "allegiance": -1,
			"portrait": "portrait_lijun.jpg", "action": "正在水泊巡航",
			"bio": "【天壽星 · 混江龍 李俊】\n梁山水軍大都督之首，生於潯陽江上，水性通神，智勇兼備！"
		}
	]

	for data in heroes_data:
		var hero_node: Node2D = HeroCharacter2DScript.new()
		hero_node.set("hero_name", data["name"])
		hero_node.set("title_name", data["title"])
		hero_node.set("grid_position", data["grid"])
		hero_node.set("current_stamina", data["stamina_curr"])
		hero_node.set("max_stamina", data["stamina_max"])
		hero_node.set("current_energy", int(data["might"] * 0.5))
		hero_node.set("portrait_file", data["portrait"])
		
		var hero_dict: Dictionary = data
		if hero_node.has_signal("hero_selected"):
			hero_node.connect("hero_selected", func(_h):
				hero_modal.call("display_hero", hero_dict)
			)
		
		characters_container.add_child(hero_node)

func _on_menu_item_selected(menu_name: String) -> void:
	match menu_name:
		"personnel":
			hero_modal.visible = !hero_modal.visible
		"fortress", "info":
			fortress_modal.visible = !fortress_modal.visible
		"file", "settings":
			pass

func _on_quick_action_triggered(action: String) -> void:
	match action:
		"地":
			minimap_window.visible = !minimap_window.visible
		"人":
			hero_modal.visible = !hero_modal.visible
		"寨":
			fortress_modal.visible = !fortress_modal.visible

func _on_advance_month() -> void:
	top_menu_bar.call("advance_time", 30)

func _on_tile_clicked(grid_pos: Vector2i, _type: int) -> void:
	# 若選中好漢，指示其移動
	for child in characters_container.get_children():
		if child.get("hero_name") == "林沖":
			child.call("move_to_grid", grid_pos)
			break

func _unhandled_input(event: InputEvent) -> void:
	# 攝影機拖曳 (中鍵或右鍵)
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
