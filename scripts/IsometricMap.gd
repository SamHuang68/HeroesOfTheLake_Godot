# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 純 2D 等角 (Isometric 2.5D) 要塞地景地圖與設施系統
class_name IsometricMap
extends Node2D

const IsometricFacilityScript = preload("res://scripts/IsometricFacility.gd")

## 2:1 標準等角菱形網格規格
const TILE_WIDTH: float = 64.0
const TILE_HEIGHT: float = 32.0
const HALF_W: float = TILE_WIDTH / 2.0
const HALF_H: float = TILE_HEIGHT / 2.0

## 地圖長寬 (網格座標)
const MAP_SIZE_X: int = 32
const MAP_SIZE_Y: int = 32

## 地塊類型定義
enum TileType {
	WATER,      ## 蔚藍水泊 / 沼澤 (0)
	GRASS,      ## 翠綠草地 / 荒野 (1)
	FARMLAND,   ## 金黃耕作農田 (2)
	ROAD,       ## 碎石寨道 (3)
	BUILDING,   ## 聚義堂 / 建築基底 (4)
	PALISADE,   ## 木鹿角防禦工事 (5)
	WATCHTOWER  ## 哨塔箭樓 (6)
}

## 儲存地圖網格資料
var grid_data: Dictionary = {}
var hovered_grid: Vector2i = Vector2i(-1, -1)
var selected_grid: Vector2i = Vector2i(-1, -1)

## 營造模式狀態
var is_in_build_mode: bool = false
var pending_facility: Dictionary = {}

@onready var facilities_container: Node2D = $Facilities

signal tile_clicked(grid_pos: Vector2i, tile_type: int)
signal facility_constructed(facility: Dictionary, grid_pos: Vector2i)
signal facility_inspected(facility_node: Node2D)

func _ready() -> void:
	generate_fortress_terrain()
	spawn_initial_fortress_facilities()
	queue_redraw()

## 產生梁山泊要塞初始沙盤地形
func generate_fortress_terrain() -> void:
	for x in range(MAP_SIZE_X):
		for y in range(MAP_SIZE_Y):
			var pos := Vector2i(x, y)
			var type: int = TileType.GRASS
			
			# 外圍水泊環繞 (梁山八百里水泊)
			if x < 4 or x >= MAP_SIZE_X - 4 or y < 4 or y >= MAP_SIZE_Y - 4:
				type = TileType.WATER
			# 內部農田耕作區
			elif (x >= 6 and x <= 11 and y >= 6 and y <= 11) or (x >= 20 and x <= 25 and y >= 20 and y <= 25):
				type = TileType.FARMLAND
			# 中心要塞主幹道
			elif x == 16 or y == 16:
				type = TileType.ROAD
			# 防禦柵欄木鹿角
			elif (x == 5 or x == MAP_SIZE_X - 6 or y == 5 or y == MAP_SIZE_Y - 6) and (x % 2 == 0):
				type = TileType.PALISADE
			# 四角哨塔
			elif (x == 5 and y == 5) or (x == 26 and y == 5) or (x == 5 and y == 26) or (x == 26 and y == 26):
				type = TileType.WATCHTOWER
				
			grid_data[pos] = type

## 生成初始要塞設施實體 (忠義堂、兵器坊、聚義酒館、高產農田、先鋒軍營、水泊碼頭)
func spawn_initial_fortress_facilities() -> void:
	if not facilities_container:
		facilities_container = Node2D.new()
		facilities_container.name = "Facilities"
		facilities_container.y_sort_enabled = true
		add_child(facilities_container)

	var initial_facs := [
		{"id": "main_hall", "type": "MainHall", "name": "忠義堂本營", "grid": Vector2i(16, 16), "lvl": 3, "heroes": ["宋江", "吳用"]},
		{"id": "smithy_01", "type": "Smithy", "name": "神兵鐵匠坊", "grid": Vector2i(12, 12), "lvl": 2, "heroes": ["湯隆"]},
		{"id": "tavern_01", "type": "Tavern", "name": "聚義好漢酒館", "grid": Vector2i(18, 14), "lvl": 2, "heroes": ["朱貴"]},
		{"id": "farm_01", "type": "Farm", "name": "水泊豐饒糧田", "grid": Vector2i(8, 8), "lvl": 2, "heroes": ["陶宗旺"]},
		{"id": "barracks_01", "type": "Barracks", "name": "馬步軍營", "grid": Vector2i(20, 20), "lvl": 2, "heroes": ["林沖"]},
		{"id": "shipyard_01", "type": "Shipyard", "name": "梁山水泊船塢", "grid": Vector2i(4, 16), "lvl": 2, "heroes": ["李俊"]}
	]

	for f in initial_facs:
		create_facility_node(f)

func create_facility_node(fac_data: Dictionary) -> Node2D:
	var fac_node: Node2D = IsometricFacilityScript.new()
	fac_node.set("facility_id", fac_data.get("id", "fac"))
	fac_node.set("facility_type", fac_data.get("type", "Smithy"))
	fac_node.set("display_name", fac_data.get("name", "設施"))
	fac_node.set("grid_coord", fac_data.get("grid", Vector2i(16, 16)))
	fac_node.set("level", fac_data.get("lvl", 1))
	fac_node.set("assigned_heroes", fac_data.get("heroes", []))

	if fac_node.has_signal("facility_selected"):
		fac_node.connect("facility_selected", func(f_inst):
			facility_inspected.emit(f_inst)
		)

	facilities_container.add_child(fac_node)
	return fac_node

## 網格座標 (GridX, GridY) 轉為 2D 螢幕座標 (ScreenX, ScreenY)
func grid_to_screen(gx: float, gy: float) -> Vector2:
	var sx: float = (gx - gy) * HALF_W
	var sy: float = (gx + gy) * HALF_H
	return Vector2(sx, sy)

## 2D 螢幕座標 (ScreenX, ScreenY) 轉為網格座標 (GridX, GridY)
func screen_to_grid(screen_pos: Vector2) -> Vector2i:
	var gx: float = (screen_pos.x / HALF_W + screen_pos.y / HALF_H) / 2.0
	var gy: float = (screen_pos.y / HALF_H - screen_pos.x / HALF_W) / 2.0
	return Vector2i(roundi(gx), roundi(gy))

func start_build_mode(facility_data: Dictionary) -> void:
	is_in_build_mode = true
	pending_facility = facility_data
	queue_redraw()

func cancel_build_mode() -> void:
	is_in_build_mode = false
	pending_facility = {}
	queue_redraw()

func _draw() -> void:
	# 依照從上到下 (Isometric Y-Sorting) 順序繪製 2:1 菱形地塊底座
	for y in range(MAP_SIZE_Y):
		for x in range(MAP_SIZE_X):
			var pos := Vector2i(x, y)
			var type: int = grid_data.get(pos, TileType.GRASS)
			draw_isometric_tile(pos, type)

	# 繪製營造預覽高亮框
	if is_in_build_mode and grid_data.has(hovered_grid):
		var is_valid: bool = (grid_data[hovered_grid] == TileType.GRASS)
		var preview_col: Color = Color(0.2, 0.9, 0.3, 0.6) if is_valid else Color(0.9, 0.2, 0.2, 0.6)
		draw_tile_highlight(hovered_grid, preview_col, Color.WHITE)
	elif grid_data.has(hovered_grid):
		draw_tile_highlight(hovered_grid, Color(1.0, 1.0, 0.4, 0.45), Color(1.0, 0.9, 0.2, 0.9))

	if grid_data.has(selected_grid):
		draw_tile_highlight(selected_grid, Color(0.2, 0.8, 1.0, 0.5), Color(0.1, 0.9, 1.0, 1.0))

func draw_isometric_tile(grid_pos: Vector2i, type: int) -> void:
	var center := grid_to_screen(grid_pos.x, grid_pos.y)
	
	var p_top := center + Vector2(0, -HALF_H)
	var p_right := center + Vector2(HALF_W, 0)
	var p_bottom := center + Vector2(0, HALF_H)
	var p_left := center + Vector2(-HALF_W, 0)
	
	var points := PackedVector2Array([p_top, p_right, p_bottom, p_left])
	
	var fill_color: Color
	var border_color: Color = Color(0.15, 0.15, 0.12, 0.3)
	
	match type:
		TileType.WATER:
			fill_color = Color(0.22, 0.45, 0.65, 0.95)
			border_color = Color(0.35, 0.60, 0.85, 0.5)
		TileType.GRASS:
			fill_color = Color(0.38, 0.60, 0.28, 1.0)
		TileType.FARMLAND:
			fill_color = Color(0.68, 0.54, 0.28, 1.0)
		TileType.ROAD:
			fill_color = Color(0.55, 0.52, 0.45, 1.0)
		TileType.PALISADE:
			fill_color = Color(0.48, 0.38, 0.22, 1.0)
		TileType.WATCHTOWER:
			fill_color = Color(0.60, 0.45, 0.30, 1.0)
		_:
			fill_color = Color(0.4, 0.5, 0.3, 1.0)
			
	draw_colored_polygon(points, fill_color)
	draw_polyline(PackedVector2Array([p_top, p_right, p_bottom, p_left, p_top]), border_color, 1.0)

	if type == TileType.WATCHTOWER:
		draw_line(center + Vector2(-8, 0), center + Vector2(-8, -28), Color(0.35, 0.22, 0.12, 1.0), 3.0)
		draw_line(center + Vector2(8, 0), center + Vector2(8, -28), Color(0.35, 0.22, 0.12, 1.0), 3.0)
		draw_rect(Rect2(center.x - 12, center.y - 34, 24, 8), Color(0.6, 0.2, 0.1, 1.0))
	elif type == TileType.PALISADE:
		draw_line(center + Vector2(-6, 4), center + Vector2(6, -12), Color(0.45, 0.30, 0.15, 1.0), 2.5)
		draw_line(center + Vector2(-6, -12), center + Vector2(6, 4), Color(0.45, 0.30, 0.15, 1.0), 2.5)

func draw_tile_highlight(grid_pos: Vector2i, fill_col: Color, line_col: Color) -> void:
	var center := grid_to_screen(grid_pos.x, grid_pos.y)
	var pts := PackedVector2Array([
		center + Vector2(0, -HALF_H),
		center + Vector2(HALF_W, 0),
		center + Vector2(0, HALF_H),
		center + Vector2(-HALF_W, 0)
	])
	draw_colored_polygon(pts, fill_col)
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), line_col, 2.0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var local_pos := to_local(event.position)
		var new_hover := screen_to_grid(local_pos)
		if new_hover != hovered_grid:
			hovered_grid = new_hover
			queue_redraw()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var local_pos := to_local(event.position)
			var clicked := screen_to_grid(local_pos)
			if grid_data.has(clicked):
				if is_in_build_mode:
					if grid_data[clicked] == TileType.GRASS:
						place_facility(clicked, pending_facility)
					cancel_build_mode()
				else:
					selected_grid = clicked
					tile_clicked.emit(clicked, grid_data[clicked])
					queue_redraw()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and is_in_build_mode:
			cancel_build_mode()

func place_facility(grid_pos: Vector2i, fac_data: Dictionary) -> void:
	var f_type_str: String = fac_data.get("type", "Farm")
	var f_name_str: String = fac_data.get("name", "設施")
	grid_data[grid_pos] = TileType.BUILDING

	var fac_dict := {
		"id": "fac_%d_%d" % [grid_pos.x, grid_pos.y],
		"type": f_type_str,
		"name": f_name_str,
		"grid": grid_pos,
		"lvl": 1,
		"heroes": []
	}

	create_facility_node(fac_dict)
	facility_constructed.emit(fac_data, grid_pos)
	queue_redraw()
