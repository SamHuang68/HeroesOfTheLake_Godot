# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 2.5D 等角要塞地景、多層次路網、自然景觀與設施管理系統
class_name IsometricMap
extends Node2D

const IsometricFacilityScript = preload("res://scripts/IsometricFacility.gd")
const IsometricDecorScript = preload("res://scripts/IsometricDecor.gd")

## 2:1 標準等角菱形網格規格
const TILE_WIDTH: float = 64.0
const TILE_HEIGHT: float = 32.0
const HALF_W: float = TILE_WIDTH / 2.0
const HALF_H: float = TILE_HEIGHT / 2.0

## 地圖長寬 (網格座標 32x32)
const MAP_SIZE_X: int = 32
const MAP_SIZE_Y: int = 32

## 地塊類型定義 (GroundLayer)
enum TileType {
	WATER,      ## 八百里蔚藍水泊 (波紋流動) (0)
	GRASS,      ## 翠綠草地荒原 (1)
	FARMLAND,   ## 金黃水泊耕地 (2)
	ROAD,       ## 碎石寨道與泥土路 (3)
	DIRT_FLOOR, ## 夯土建築基底 (4)
	FOREST_MOSS ## 密林苔原 (5)
}

## 儲存地圖網格資料
var grid_data: Dictionary = {}
var road_grid: Dictionary = {}
var hovered_grid: Vector2i = Vector2i(-1, -1)
var selected_grid: Vector2i = Vector2i(-1, -1)

## 營造模式狀態
var is_in_build_mode: bool = false
var pending_facility: Dictionary = {}

var facilities_container: Node2D = null
var decorations_container: Node2D = null

var map_anim_timer: float = 0.0

signal tile_clicked(grid_pos: Vector2i, tile_type: int)
signal facility_constructed(facility: Dictionary, grid_pos: Vector2i)
signal facility_inspected(facility_node: Node2D)

func _ready() -> void:
	generate_fortress_terrain()
	generate_road_network()
	spawn_initial_natural_decorations()
	spawn_initial_fortress_facilities()
	queue_redraw()

func _process(delta: float) -> void:
	map_anim_timer += delta
	queue_redraw()

## 1. 產生梁山泊要塞自然沙盤地形 (水泊、平原、耕地、密林)
func generate_fortress_terrain() -> void:
	for x in range(MAP_SIZE_X):
		for y in range(MAP_SIZE_Y):
			var pos := Vector2i(x, y)
			var type: int = TileType.GRASS

			# 外圍水泊環繞 (西側大水泊，四面環水)
			if x < 5 or x >= MAP_SIZE_X - 4 or y < 4 or y >= MAP_SIZE_Y - 4:
				type = TileType.WATER
			# 內部良田耕作區
			elif (x >= 7 and x <= 11 and y >= 7 and y <= 11) or (x >= 21 and x <= 25 and y >= 21 and y <= 25):
				type = TileType.FARMLAND
			# 密林防禦帶
			elif (x >= 6 and x <= 8 and y >= 18 and y <= 24) or (x >= 23 and x <= 26 and y >= 6 and y <= 10):
				type = TileType.FOREST_MOSS
			# 中心聚義基底
			elif x >= 14 and x <= 18 and y >= 14 and y <= 18:
				type = TileType.DIRT_FLOOR

			grid_data[pos] = type

## 2. 建立連接主城、碼頭與各設施的蜿蜒路網 (Road Network)
func generate_road_network() -> void:
	road_grid.clear()
	# 主幹道：忠義堂 (16, 16) 向西直通水泊碼頭 (4, 16)
	for rx in range(4, 17):
		road_grid[Vector2i(rx, 16)] = true
		road_grid[Vector2i(rx, 17)] = true

	# 主幹道：忠義堂 (16, 16) 向南直達南寨門 (16, 27)
	for ry in range(16, 28):
		road_grid[Vector2i(16, ry)] = true
		road_grid[Vector2i(15, ry)] = true

	# 連接鐵匠坊 (13, 13) 與酒館 (19, 14)
	road_grid[Vector2i(14, 14)] = true
	road_grid[Vector2i(15, 14)] = true
	road_grid[Vector2i(17, 15)] = true
	road_grid[Vector2i(18, 14)] = true

	# 連接糧倉 (14, 18) 與軍營 (20, 19)
	road_grid[Vector2i(17, 18)] = true
	road_grid[Vector2i(18, 18)] = true
	road_grid[Vector2i(19, 19)] = true

## 3. 生成自然景觀裝飾物件 (松樹林、水泊柳樹、銀杏、巨石與蘆葦叢)
func spawn_initial_natural_decorations() -> void:
	if not decorations_container:
		decorations_container = Node2D.new()
		decorations_container.name = "Decorations"
		decorations_container.y_sort_enabled = true
		add_child(decorations_container)

	# 水泊湖畔垂柳與蘆葦
	var willows := [Vector2i(5, 12), Vector2i(5, 14), Vector2i(5, 19), Vector2i(5, 21), Vector2i(12, 4), Vector2i(20, 4)]
	for wp in willows:
		create_decor_node(1, wp) # WILLOW_TREE

	var reeds := [Vector2i(4, 10), Vector2i(4, 22), Vector2i(10, 3), Vector2i(22, 3), Vector2i(27, 14)]
	for rp in reeds:
		create_decor_node(4, rp) # WATER_REEDS

	# 後山與密林蒼勁青松群
	var pines := [
		Vector2i(7, 20), Vector2i(8, 22), Vector2i(6, 24), Vector2i(24, 7), Vector2i(25, 9),
		Vector2i(26, 8), Vector2i(10, 14), Vector2i(22, 14), Vector2i(12, 23), Vector2i(20, 24)
	]
	for pp in pines:
		create_decor_node(0, pp) # PINE_TREE

	# 金黃銀杏與山石碎岩
	var ginkgos := [Vector2i(12, 11), Vector2i(20, 12), Vector2i(17, 21)]
	for gp in ginkgos:
		create_decor_node(2, gp) # GINKGO_TREE

	var rocks := [Vector2i(9, 18), Vector2i(22, 17), Vector2i(13, 25), Vector2i(18, 25), Vector2i(8, 9)]
	for rk in rocks:
		create_decor_node(3, rk) # BOULDER

func create_decor_node(type: int, grid_pos: Vector2i) -> Node2D:
	var d_node: Node2D = IsometricDecorScript.new()
	d_node.set("decor_type", type)
	d_node.set("grid_coord", grid_pos)
	decorations_container.add_child(d_node)
	return d_node

## 4. 生成初始要塞設施實體 (包含 3x3 忠義堂、碼頭樓船、酒館、鐵匠坊、糧倉、軍營)
func spawn_initial_fortress_facilities() -> void:
	if not facilities_container:
		facilities_container = Node2D.new()
		facilities_container.name = "Facilities"
		facilities_container.y_sort_enabled = true
		add_child(facilities_container)

	var initial_facs := [
		{"id": "main_hall", "type": "MainHall", "name": "忠義堂本營", "grid": Vector2i(16, 16), "lvl": 3, "heroes": ["宋江", "吳用"]},
		{"id": "smithy_01", "type": "Smithy", "name": "神兵鐵匠坊", "grid": Vector2i(13, 13), "lvl": 2, "heroes": ["湯隆"]},
		{"id": "tavern_01", "type": "Tavern", "name": "聚義好漢酒館", "grid": Vector2i(19, 14), "lvl": 2, "heroes": ["朱貴"]},
		{"id": "granary_01", "type": "Granary", "name": "聚義糧倉", "grid": Vector2i(14, 18), "lvl": 2, "heroes": ["陶宗旺"]},
		{"id": "barracks_01", "type": "Barracks", "name": "先鋒軍營演武場", "grid": Vector2i(20, 19), "lvl": 2, "heroes": ["武松"]},
		{"id": "shipyard_01", "type": "Shipyard", "name": "水泊碼頭與樓船", "grid": Vector2i(4, 16), "lvl": 2, "heroes": ["李俊"]},
		{"id": "farm_01", "type": "Farm", "name": "水泊高產水田", "grid": Vector2i(8, 8), "lvl": 2, "heroes": []},
		{"id": "tower_01", "type": "Watchtower", "name": "西北瞭望哨塔", "grid": Vector2i(6, 6), "lvl": 1, "heroes": []},
		{"id": "tower_02", "type": "Watchtower", "name": "西南瞭望哨塔", "grid": Vector2i(6, 26), "lvl": 1, "heroes": []},
		{"id": "tower_03", "type": "Watchtower", "name": "東北瞭望哨塔", "grid": Vector2i(26, 6), "lvl": 1, "heroes": []},
		{"id": "tower_04", "type": "Watchtower", "name": "東南瞭望哨塔", "grid": Vector2i(26, 26), "lvl": 1, "heroes": []},
		{"id": "palisade_01", "type": "Palisade", "name": "南門防禦鹿角", "grid": Vector2i(15, 27), "lvl": 1, "heroes": []},
		{"id": "palisade_02", "type": "Palisade", "name": "南門防禦鹿角", "grid": Vector2i(17, 27), "lvl": 1, "heroes": []}
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

## 2D 螢幕座標轉網格
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
	# 依照 Isometric Y-Sort 順序繪製多層次地貌 (GroundLayer & RoadLayer)
	for y in range(MAP_SIZE_Y):
		for x in range(MAP_SIZE_X):
			var pos := Vector2i(x, y)
			var type: int = grid_data.get(pos, TileType.GRASS)
			draw_textured_ground_tile(pos, type)

			# 若此格有道路，覆蓋繪製碎石道路層
			if road_grid.get(pos, false):
				draw_road_tile(pos)

	# 繪製營造預覽高亮框
	if is_in_build_mode and grid_data.has(hovered_grid):
		var is_valid: bool = (grid_data[hovered_grid] == TileType.GRASS and not road_grid.get(hovered_grid, false))
		var preview_col: Color = Color(0.2, 0.9, 0.3, 0.6) if is_valid else Color(0.9, 0.2, 0.2, 0.6)
		draw_tile_highlight(hovered_grid, preview_col, Color.WHITE)
	elif grid_data.has(hovered_grid):
		draw_tile_highlight(hovered_grid, Color(1.0, 1.0, 0.4, 0.45), Color(1.0, 0.9, 0.2, 0.9))

	if grid_data.has(selected_grid):
		draw_tile_highlight(selected_grid, Color(0.2, 0.8, 1.0, 0.5), Color(0.1, 0.9, 1.0, 1.0))

## 繪製具備材質質感與動態流動水紋的地面圖塊 (GroundLayer)
func draw_textured_ground_tile(grid_pos: Vector2i, type: int) -> void:
	var center := grid_to_screen(grid_pos.x, grid_pos.y)
	var p_top := center + Vector2(0, -HALF_H)
	var p_right := center + Vector2(HALF_W, 0)
	var p_bottom := center + Vector2(0, HALF_H)
	var p_left := center + Vector2(-HALF_W, 0)
	var points := PackedVector2Array([p_top, p_right, p_bottom, p_left])

	var fill_color: Color
	var border_color: Color = Color(0.12, 0.15, 0.10, 0.2)

	match type:
		TileType.WATER:
			# 水泊波光流動漸變
			var wave := sin(map_anim_timer * 2.5 + grid_pos.x * 0.8 + grid_pos.y * 0.8) * 0.05
			fill_color = Color(0.20 + wave, 0.46 + wave, 0.68 + wave, 0.95)
			border_color = Color(0.35, 0.65, 0.88, 0.4)
		TileType.GRASS:
			# 翠綠草地 (微幅明暗質感)
			var g_var: float = ((grid_pos.x * 7 + grid_pos.y * 13) % 7) * 0.02
			fill_color = Color(0.36 + g_var, 0.62 + g_var, 0.26 + g_var, 1.0)
		TileType.FARMLAND:
			fill_color = Color(0.68, 0.54, 0.26, 1.0)
		TileType.DIRT_FLOOR:
			fill_color = Color(0.72, 0.62, 0.48, 1.0)
		TileType.FOREST_MOSS:
			fill_color = Color(0.24, 0.45, 0.20, 1.0)
		_:
			fill_color = Color(0.4, 0.5, 0.3, 1.0)

	draw_colored_polygon(points, fill_color)
	draw_polyline(PackedVector2Array([p_top, p_right, p_bottom, p_left, p_top]), border_color, 1.0)

	# 水面波光水紋線
	if type == TileType.WATER:
		var wave_off := sin(map_anim_timer * 3.0 + grid_pos.x) * 4.0
		draw_line(center + Vector2(-12 + wave_off, -4), center + Vector2(12 + wave_off, -4), Color(0.6, 0.85, 1.0, 0.5), 1.5)
		draw_line(center + Vector2(-8 - wave_off, 4), center + Vector2(8 - wave_off, 4), Color(0.6, 0.85, 1.0, 0.4), 1.5)
	elif type == TileType.FARMLAND:
		# 耕作壟溝
		for i in range(-2, 3):
			draw_line(center + Vector2(-16, i * 4), center + Vector2(16, i * 4), Color(0.55, 0.42, 0.20, 0.8), 2.0)

## 繪製碎石泥土道路層 (RoadLayer)
func draw_road_tile(grid_pos: Vector2i) -> void:
	var center := grid_to_screen(grid_pos.x, grid_pos.y)
	var pts := PackedVector2Array([
		center + Vector2(0, -HALF_H + 4),
		center + Vector2(HALF_W - 8, 0),
		center + Vector2(0, HALF_H - 4),
		center + Vector2(-HALF_W + 8, 0)
	])
	draw_colored_polygon(pts, Color(0.62, 0.56, 0.44, 0.9))
	# 碎石細節
	draw_circle(center + Vector2(-4, -2), 1.5, Color(0.45, 0.40, 0.30, 0.8))
	draw_circle(center + Vector2(6, 2), 2.0, Color(0.45, 0.40, 0.30, 0.8))

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
					if grid_data[clicked] == TileType.GRASS and not road_grid.get(clicked, false):
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
	grid_data[grid_pos] = TileType.DIRT_FLOOR

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
