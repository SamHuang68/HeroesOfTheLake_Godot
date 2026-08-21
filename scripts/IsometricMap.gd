# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 2.5D 等角沙盤要塞地景、多城切換與設施動態管理系統
class_name IsometricMap
extends Node2D

const IsometricFacilityScript = preload("res://scripts/IsometricFacility.gd")
const IsometricDecorScript = preload("res://scripts/IsometricDecor.gd")
const FortressDatabaseScript = preload("res://scripts/FortressDatabase.gd")

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
	WATER,      ## 八百里蔚藍水泊 / 護城河 / 長江 (0)
	GRASS,      ## 翠綠草地平原 (1)
	FARMLAND,   ## 金黃耕地水田 (2)
	ROAD,       ## 碎石寨道與泥土路 (3)
	DIRT_FLOOR, ## 夯土建築基底 (4)
	FOREST_MOSS,## 密林苔原 (5)
	STONE_PAVE  ## 皇城青磚石板路 (6)
}

## 儲存地圖網格資料
var current_fortress_id: String = "liangshan"
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
signal fortress_loaded(fortress_data: Dictionary)

func _ready() -> void:
	load_ground_textures()
	ensure_child_containers()
	load_fortress_map("liangshan")

func ensure_child_containers() -> void:
	decorations_container = get_node_or_null("Decorations")
	if not decorations_container:
		decorations_container = Node2D.new()
		decorations_container.name = "Decorations"
		decorations_container.y_sort_enabled = true
		add_child(decorations_container)

	facilities_container = get_node_or_null("Facilities")
	if not facilities_container:
		facilities_container = Node2D.new()
		facilities_container.name = "Facilities"
		facilities_container.y_sort_enabled = true
		add_child(facilities_container)

func _process(delta: float) -> void:
	map_anim_timer += delta
	queue_redraw()

## 載入並切換至特定要塞名城 (梁山泊、少華山、二龍山、祝家莊、曾頭市、大名府、江州、東京等)
func load_fortress_map(fortress_id: String) -> void:
	current_fortress_id = fortress_id
	var f_data: Dictionary = FortressDatabaseScript.get_fortress_data(fortress_id)

	# 1. 清空既有物件
	ensure_child_containers()
	for child in decorations_container.get_children():
		decorations_container.remove_child(child)
		child.free()
	for child in facilities_container.get_children():
		facilities_container.remove_child(child)
		child.free()

	# 2. 依照要塞地形生成演算法生成地形
	var gen_type: String = f_data.get("terrain_generator", "water_ring")
	generate_terrain_by_type(gen_type)

	# 3. 建立專屬道路網絡
	generate_road_network_by_type(gen_type)

	# 4. 生成自然植被與景觀物件
	spawn_natural_decorations_by_theme(f_data.get("theme", "water_fortress"))

	# 5. 實例化該要塞之專屬古風設施
	var facs_list: Array = f_data.get("initial_facilities", [])
	for fac in facs_list:
		create_facility_node(fac)

	fortress_loaded.emit(f_data)
	queue_redraw()

## 依據要塞地貌類型動態生成地形網格 (GroundLayer)
func generate_terrain_by_type(gen_type: String) -> void:
	grid_data.clear()
	for x in range(MAP_SIZE_X):
		for y in range(MAP_SIZE_Y):
			var pos := Vector2i(x, y)
			var type: int = TileType.GRASS

			match gen_type:
				"water_ring": # 梁山泊 (四周水泊環繞)
					if x < 5 or x >= MAP_SIZE_X - 4 or y < 4 or y >= MAP_SIZE_Y - 4:
						type = TileType.WATER
					elif (x >= 7 and x <= 11 and y >= 7 and y <= 11) or (x >= 21 and x <= 25 and y >= 21 and y <= 25):
						type = TileType.FARMLAND
					elif (x >= 6 and x <= 8 and y >= 18 and y <= 24) or (x >= 23 and x <= 26 and y >= 6 and y <= 10):
						type = TileType.FOREST_MOSS
					elif x >= 14 and x <= 18 and y >= 14 and y <= 18:
						type = TileType.DIRT_FLOOR

				"mountain_peaks": # 少華山 / 桃花山 / 芒碭山 (險峰峻嶺)
					if x < 6 or x >= MAP_SIZE_X - 6 or y < 6 or y >= MAP_SIZE_Y - 6:
						type = TileType.FOREST_MOSS
					elif (x + y) % 5 == 0:
						type = TileType.DIRT_FLOOR
					elif x >= 14 and x <= 18 and y >= 14 and y <= 18:
						type = TileType.DIRT_FLOOR

				"canyon_temple": # 二龍山寶珠寺 (峽谷天險)
					if x < 10 or x > 22:
						type = TileType.FOREST_MOSS
					elif y < 5:
						type = TileType.DIRT_FLOOR
					elif x >= 14 and x <= 18 and y >= 14 and y <= 18:
						type = TileType.DIRT_FLOOR

				"maze_plain": # 祝家莊 (獨龍岡盤陀路)
					if (x >= 6 and x <= 10 and y >= 6 and y <= 10) or (x >= 22 and x <= 26 and y >= 22 and y <= 26):
						type = TileType.FARMLAND
					elif (x + y) % 4 == 0:
						type = TileType.FOREST_MOSS

				"great_river": # 江州 (滔滔長江水岸)
					if x < 8:
						type = TileType.WATER
					elif x >= 9 and x <= 13 and y >= 7 and y <= 12:
						type = TileType.FARMLAND
					elif x >= 14 and x <= 18 and y >= 14 and y <= 18:
						type = TileType.STONE_PAVE

				"imperial_city", "imperial_capital": # 大名府 / 東京汴京 (皇城護城河與青磚街道)
					# 護城河
					if x == 3 or x == MAP_SIZE_X - 4 or y == 3 or y == MAP_SIZE_Y - 4:
						type = TileType.WATER
					elif x >= 12 and x <= 20 and y >= 12 and y <= 20:
						type = TileType.STONE_PAVE
					elif (x >= 6 and x <= 10 and y >= 6 and y <= 10):
						type = TileType.DIRT_FLOOR

				_:
					if x < 4 or x >= MAP_SIZE_X - 4 or y < 4 or y >= MAP_SIZE_Y - 4:
						type = TileType.WATER

			grid_data[pos] = type

## 依據要塞地貌生成專屬路網
func generate_road_network_by_type(gen_type: String) -> void:
	road_grid.clear()
	match gen_type:
		"water_ring": # 梁山泊
			for rx in range(4, 17):
				road_grid[Vector2i(rx, 16)] = true
				road_grid[Vector2i(rx, 17)] = true
			for ry in range(16, 28):
				road_grid[Vector2i(16, ry)] = true
				road_grid[Vector2i(15, ry)] = true
			road_grid[Vector2i(14, 14)] = true
			road_grid[Vector2i(18, 14)] = true
			road_grid[Vector2i(19, 19)] = true

		"mountain_peaks", "canyon_temple": # 盤山階梯山道
			for ry in range(10, 28):
				road_grid[Vector2i(16, ry)] = true
			for rx in range(12, 21):
				road_grid[Vector2i(rx, 16)] = true

		"imperial_city", "imperial_capital": # 皇城十字大街
			for rx in range(4, 28):
				road_grid[Vector2i(rx, 16)] = true
			for ry in range(4, 28):
				road_grid[Vector2i(16, ry)] = true

		_:
			for rx in range(6, 26):
				road_grid[Vector2i(rx, 16)] = true
			for ry in range(6, 26):
				road_grid[Vector2i(16, ry)] = true

## 依據要塞主題生成專屬植被景觀 (Decorations Y-Sort Layer)
func spawn_natural_decorations_by_theme(theme: String) -> void:
	ensure_child_containers()
	match theme:
		"water_fortress", "river_metropolis": # 水泊湖畔垂柳、青松與蘆葦
			for wp in [Vector2i(5, 12), Vector2i(5, 14), Vector2i(5, 19), Vector2i(5, 21), Vector2i(12, 4), Vector2i(20, 4)]:
				create_decor_node(1, wp) # WILLOW_TREE
			for rp in [Vector2i(4, 10), Vector2i(4, 22), Vector2i(10, 3), Vector2i(22, 3), Vector2i(27, 14)]:
				create_decor_node(4, rp) # WATER_REEDS
			for pp in [Vector2i(7, 20), Vector2i(8, 22), Vector2i(24, 7), Vector2i(25, 9), Vector2i(10, 14), Vector2i(22, 14)]:
				create_decor_node(0, pp) # PINE_TREE

		"mountain_fortress", "temple_fortress", "daoist_mountain": # 蒼勁古松與巨石
			for pp in [
				Vector2i(8, 8), Vector2i(9, 10), Vector2i(7, 20), Vector2i(8, 22), Vector2i(24, 8),
				Vector2i(25, 10), Vector2i(23, 22), Vector2i(24, 24), Vector2i(10, 15), Vector2i(22, 15)
			]:
				create_decor_node(0, pp) # PINE_TREE
			for rk in [Vector2i(9, 18), Vector2i(22, 17), Vector2i(13, 25), Vector2i(18, 25), Vector2i(8, 9), Vector2i(24, 18)]:
				create_decor_node(3, rk) # BOULDER

		"blossom_mountain": # 桃花山 (金黃銀杏與古松)
			for gp in [Vector2i(10, 12), Vector2i(12, 14), Vector2i(20, 12), Vector2i(22, 14), Vector2i(16, 22)]:
				create_decor_node(2, gp) # GINKGO_TREE
			for pp in [Vector2i(8, 8), Vector2i(24, 8), Vector2i(8, 24), Vector2i(24, 24)]:
				create_decor_node(0, pp) # PINE_TREE

		"walled_village": # 祝家莊 (獨龍岡白楊樹與耕地樹叢)
			for pp in [Vector2i(6, 6), Vector2i(10, 6), Vector2i(6, 10), Vector2i(22, 22), Vector2i(26, 22), Vector2i(22, 26), Vector2i(26, 26), Vector2i(12, 18), Vector2i(20, 18)]:
				create_decor_node(0, pp) # PINE_TREE
			for gp in [Vector2i(8, 14), Vector2i(24, 14), Vector2i(16, 11), Vector2i(16, 21)]:
				create_decor_node(2, gp) # GINKGO_TREE

		"market_fortress": # 曾頭市 (商埠大道柳樹與外圍松林)
			for wp in [Vector2i(14, 12), Vector2i(18, 12), Vector2i(14, 20), Vector2i(18, 20), Vector2i(14, 24), Vector2i(18, 24)]:
				create_decor_node(1, wp) # WILLOW_TREE
			for pp in [Vector2i(6, 8), Vector2i(26, 8), Vector2i(6, 24), Vector2i(26, 24), Vector2i(10, 16), Vector2i(22, 16)]:
				create_decor_node(0, pp) # PINE_TREE

		"metropolis_fortress", "capital_city": # 大名府 / 東京汴京 (護城河垂柳、銀杏御道與庭院松柏)
			for wp in [Vector2i(4, 8), Vector2i(4, 12), Vector2i(4, 20), Vector2i(4, 24), Vector2i(28, 8), Vector2i(28, 12), Vector2i(28, 20), Vector2i(28, 24)]:
				create_decor_node(1, wp) # WILLOW_TREE
			for gp in [Vector2i(14, 14), Vector2i(18, 14), Vector2i(14, 18), Vector2i(18, 18), Vector2i(12, 16), Vector2i(20, 16)]:
				create_decor_node(2, gp) # GINKGO_TREE
			for pp in [Vector2i(8, 8), Vector2i(24, 8), Vector2i(8, 24), Vector2i(24, 24), Vector2i(16, 10), Vector2i(16, 22)]:
				create_decor_node(0, pp) # PINE_TREE

		_:
			for pp in [Vector2i(8, 8), Vector2i(24, 8), Vector2i(8, 24), Vector2i(24, 24), Vector2i(10, 10), Vector2i(22, 10)]:
				create_decor_node(0, pp) # PINE_TREE

func create_decor_node(type: int, grid_pos: Vector2i) -> Node2D:
	var d_node: Node2D = IsometricDecorScript.new()
	d_node.set("decor_type", type)
	d_node.set("grid_coord", grid_pos)
	decorations_container.add_child(d_node)
	return d_node

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

## 2D 螢幕座標轉網格 (嚴格 2:1 等角逆變換，無偏移)
func screen_to_grid(screen_pos: Vector2) -> Vector2i:
	var gx: float = floor((screen_pos.x / HALF_W + screen_pos.y / HALF_H + 1.0) / 2.0)
	var gy: float = floor((screen_pos.y / HALF_H - screen_pos.x / HALF_W + 1.0) / 2.0)
	return Vector2i(int(gx), int(gy))

func start_build_mode(facility_data: Dictionary) -> void:
	is_in_build_mode = true
	pending_facility = facility_data
	queue_redraw()

func cancel_build_mode() -> void:
	is_in_build_mode = false
	pending_facility = {}
	queue_redraw()

func _draw() -> void:
	for y in range(MAP_SIZE_Y):
		for x in range(MAP_SIZE_X):
			var pos := Vector2i(x, y)
			var type: int = grid_data.get(pos, TileType.GRASS)
			draw_textured_ground_tile(pos, type)

			if road_grid.get(pos, false):
				draw_road_tile(pos)

	if is_in_build_mode and grid_data.has(hovered_grid):
		var is_valid: bool = (grid_data[hovered_grid] in [TileType.GRASS, TileType.DIRT_FLOOR] and not road_grid.get(hovered_grid, false))
		var preview_col: Color = Color(0.2, 0.9, 0.3, 0.6) if is_valid else Color(0.9, 0.2, 0.2, 0.6)
		draw_tile_highlight(hovered_grid, preview_col, Color.WHITE)
	elif grid_data.has(hovered_grid):
		draw_tile_highlight(hovered_grid, Color(1.0, 1.0, 0.4, 0.45), Color(1.0, 0.9, 0.2, 0.9))

	if grid_data.has(selected_grid):
		draw_tile_highlight(selected_grid, Color(0.2, 0.8, 1.0, 0.5), Color(0.1, 0.9, 1.0, 1.0))

# 地面圖塊材質快取
var tile_textures: Dictionary = {}

func load_ground_textures() -> void:
	var paths := {
		TileType.WATER: "res://assets/sprites/terrain/tile_water.png",
		TileType.GRASS: "res://assets/sprites/terrain/tile_grass.png",
		TileType.FARMLAND: "res://assets/sprites/terrain/tile_farmland.png",
		TileType.ROAD: "res://assets/sprites/terrain/tile_road.png",
		TileType.STONE_PAVE: "res://assets/sprites/terrain/tile_stone.png",
		TileType.DIRT_FLOOR: "res://assets/sprites/terrain/tile_road.png",
		TileType.FOREST_MOSS: "res://assets/sprites/terrain/tile_grass.png"
	}
	for t in paths.keys():
		var p: String = paths[t]
		if ResourceLoader.exists(p):
			tile_textures[t] = load(p)



func draw_textured_ground_tile(grid_pos: Vector2i, type: int) -> void:
	var center := grid_to_screen(grid_pos.x, grid_pos.y)
	var top_left := center - Vector2(HALF_W, HALF_H)

	# 1. 繪製基底材質
	if tile_textures.has(type):
		draw_texture(tile_textures[type], top_left)
	else:
		var p_top := center + Vector2(0, -HALF_H)
		var p_right := center + Vector2(HALF_W, 0)
		var p_bottom := center + Vector2(0, HALF_H)
		var p_left := center + Vector2(-HALF_W, 0)
		var points := PackedVector2Array([p_top, p_right, p_bottom, p_left])
		var fill_color := Color(0.35, 0.60, 0.25, 1.0) if type != TileType.WATER else Color(0.20, 0.45, 0.70, 1.0)
		draw_colored_polygon(points, fill_color)

	# 2. 水陸過渡與岸邊泥土/碎石 (Coastline Transition & Bank Blending)
	if type == TileType.WATER:
		# 動態水面波紋
		var wave_off := sin(map_anim_timer * 3.0 + grid_pos.x * 0.8) * 3.0
		draw_line(center + Vector2(-10 + wave_off, -2), center + Vector2(10 + wave_off, -2), Color(0.75, 0.92, 1.0, 0.45), 1.2)
		draw_line(center + Vector2(-6 - wave_off, 4), center + Vector2(8 - wave_off, 4), Color(0.80, 0.95, 1.0, 0.35), 1.0)

		# 檢驗周圍是否相鄰陸地 (繪製岸邊泥沙與浪花過渡)
		var neighbors := [
			Vector2i(grid_pos.x, grid_pos.y - 1),
			Vector2i(grid_pos.x + 1, grid_pos.y),
			Vector2i(grid_pos.x, grid_pos.y + 1),
			Vector2i(grid_pos.x - 1, grid_pos.y)
		]
		for n in neighbors:
			if grid_data.has(n) and grid_data[n] != TileType.WATER:
				var n_center := grid_to_screen(n.x, n.y)
				var edge_mid := (center + n_center) / 2.0
				# 岸邊碎石與泥灘
				draw_circle(edge_mid, 4.0, Color(0.42, 0.36, 0.26, 0.65))
				draw_circle(edge_mid + Vector2(2, -1), 2.0, Color(0.85, 0.90, 0.95, 0.70))
	elif type in [TileType.GRASS, TileType.FOREST_MOSS]:
		# 3. 平原區自然點綴 (Natural Terrain Scatter: 雜草、碎石、野花)
		var seed_val: int = (grid_pos.x * 73 + grid_pos.y * 37) % 100
		if seed_val < 35: # 雜草叢
			var off_x: float = (seed_val % 7 - 3) * 3.0
			var off_y: float = (seed_val % 5 - 2) * 2.0
			var grass_pos := center + Vector2(off_x, off_y)
			draw_line(grass_pos, grass_pos + Vector2(-2, -5), Color(0.22, 0.48, 0.18, 0.8), 1.2)
			draw_line(grass_pos, grass_pos + Vector2(2, -6), Color(0.30, 0.55, 0.22, 0.8), 1.2)
		elif seed_val < 50: # 野花點綴
			var flow_pos := center + Vector2((seed_val % 9 - 4) * 2.5, (seed_val % 7 - 3) * 2.0)
			var flower_col := Color(0.95, 0.85, 0.35, 0.85) if seed_val % 2 == 0 else Color(0.92, 0.45, 0.55, 0.85)
			draw_circle(flow_pos, 1.5, flower_col)
		elif seed_val < 60: # 碎石
			var rock_pos := center + Vector2((seed_val % 6 - 3) * 3.0, (seed_val % 4 - 2) * 2.0)
			draw_circle(rock_pos, 2.0, Color(0.50, 0.48, 0.45, 0.75))

func draw_road_tile(grid_pos: Vector2i) -> void:
	var center := grid_to_screen(grid_pos.x, grid_pos.y)
	var top_left := center - Vector2(HALF_W, HALF_H)
	if tile_textures.has(TileType.ROAD):
		draw_texture(tile_textures[TileType.ROAD], top_left)
	else:
		draw_circle(center, 4.0, Color(0.55, 0.48, 0.36, 0.85))

	# 道路邊緣碎石與自然泥路銜接 (Road Gravel Blending)
	var seed_r: int = (grid_pos.x * 29 + grid_pos.y * 53) % 10
	if seed_r < 5:
		draw_circle(center + Vector2(-6, 2), 1.5, Color(0.45, 0.40, 0.30, 0.6))
		draw_circle(center + Vector2(7, -3), 1.5, Color(0.45, 0.40, 0.30, 0.6))

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
					if grid_data[clicked] in [TileType.GRASS, TileType.DIRT_FLOOR] and not road_grid.get(clicked, false):
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
