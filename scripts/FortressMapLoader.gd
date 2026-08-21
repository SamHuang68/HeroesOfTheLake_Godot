# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 要塞地圖資料注入與 TileMapLayer 實例化生成器 (Fortress Map Loader)
class_name FortressMapLoader
extends Node2D

@export var scenario_data_path: String = "res://data/native_converted/scenarios_database.json"

@onready var ground_layer: Node2D = $GroundLayer
@onready var road_layer: Node2D = $RoadLayer
@onready var ysort_layer: Node2D = $YSortObjectLayer
@onready var hero_spawner: Node2D = $HeroEntities

## 當前載入之劇本與要塞 ID
var current_scenario_id: String = "SCE1"
var current_fortress_id: String = "liangshan"
var current_fortress_data: Dictionary = {}

func _ready() -> void:
	_ensure_subnodes()
	# 預設載入第 1 劇本水泊梁山要塞
	if current_fortress_data.is_empty():
		load_fortress_scenario(current_scenario_id, current_fortress_id)

func _ensure_subnodes() -> void:
	if ground_layer == null:
		ground_layer = get_node_or_null("GroundLayer")
		if ground_layer == null:
			ground_layer = Node2D.new()
			ground_layer.name = "GroundLayer"
			ground_layer.z_index = 0
			add_child(ground_layer)
			
	if road_layer == null:
		road_layer = get_node_or_null("RoadLayer")
		if road_layer == null:
			road_layer = Node2D.new()
			road_layer.name = "RoadLayer"
			road_layer.z_index = 1
			add_child(road_layer)
			
	if ysort_layer == null:
		ysort_layer = get_node_or_null("YSortObjectLayer")
		if ysort_layer == null:
			ysort_layer = Node2D.new()
			ysort_layer.name = "YSortObjectLayer"
			ysort_layer.z_index = 2
			ysort_layer.y_sort_enabled = true
			add_child(ysort_layer)
			
	if hero_spawner == null:
		hero_spawner = get_node_or_null("HeroEntities")
		if hero_spawner == null:
			hero_spawner = Node2D.new()
			hero_spawner.name = "HeroEntities"
			hero_spawner.z_index = 3
			hero_spawner.y_sort_enabled = true
			add_child(hero_spawner)

## 載入劇本與要塞資料並自動實例化地貌、道路、建築與好漢
func load_fortress_scenario(scenario_id: String, fortress_id: String) -> void:
	_ensure_subnodes()
	current_scenario_id = scenario_id
	current_fortress_id = fortress_id
	
	var json_data: Dictionary = {}
	var paths_to_check := [
		scenario_data_path,
		"res://data/native_converted/scenarios_database.json",
		"res://data/scenarios_database.json",
		"res://data/native_converted/scenarios/scenarios_database.json"
	]
	
	for p in paths_to_check:
		if FileAccess.file_exists(p):
			var file = FileAccess.open(p, FileAccess.READ)
			if file:
				var parsed = JSON.parse_string(file.get_as_text())
				if parsed is Dictionary:
					json_data = parsed
				file.close()
				break
				
	var sce_dict = json_data.get(scenario_id, {})
	var fortress_data: Dictionary = {}
	if sce_dict.has("fortresses"):
		fortress_data = sce_dict["fortresses"].get(fortress_id, {})
	
	if fortress_data.is_empty():
		# Fallback 到 FortressDatabase 內建沙盤地圖
		fortress_data = FortressDatabase.get_fortress_data(fortress_id)
		
	if fortress_data.is_empty():
		push_error("找不到要塞資料: %s / %s" % [scenario_id, fortress_id])
		return
		
	current_fortress_data = fortress_data
	
	# 1. 生成自然地貌層 (Layer 0: GroundLayer)
	_generate_terrain(fortress_data.get("terrain_grid", []))
	
	# 2. 生成道路路網層 (Layer 1: RoadLayer)
	_generate_roads(fortress_data.get("road_grid", []))
	
	# 3. 生成建築與自然障礙層 (Layer 2: YSortObjectLayer)
	_spawn_facilities(fortress_data.get("facilities", []))
	
	# 4. 生成初始好漢模型實體層 (HeroEntities)
	_spawn_initial_heroes(fortress_data.get("initial_heroes", []))
	
	print("✅ 要塞地圖 [%s / %s] 成功解析並實例化完畢！" % [scenario_id, fortress_id])

## 生成自然地貌地塊 (草地 Tile 0, 土地 Tile 1, 水泊 Tile 2, 沼澤 Tile 3)
func _generate_terrain(grid: Array) -> void:
	for child in ground_layer.get_children():
		child.queue_free()
		
	if ground_layer is TileMapLayer:
		(ground_layer as TileMapLayer).clear()
		for y in range(grid.size()):
			for x in range(grid[y].size()):
				var tile_id = grid[y][x]
				(ground_layer as TileMapLayer).set_cell(Vector2i(x, y), 0, Vector2i(tile_id, 0))
	else:
		# 以 2.5D 精靈圖塊填充地圖
		var grass_tex = preload("res://assets/sprites/terrain/tile_grass.png")
		var dirt_tex = preload("res://assets/sprites/terrain/tile_farmland.png")
		var water_tex = preload("res://assets/sprites/terrain/tile_water.png")
		var stone_tex = preload("res://assets/sprites/terrain/tile_stone.png")
		
		for y in range(grid.size()):
			for x in range(grid[y].size()):
				var tile_id = grid[y][x]
				var sp = Sprite2D.new()
				match tile_id:
					1: sp.texture = dirt_tex
					2: sp.texture = water_tex
					3: sp.texture = stone_tex
					_: sp.texture = grass_tex
				sp.position = grid_to_screen(Vector2i(x, y))
				ground_layer.add_child(sp)

## 生成道路路網 (泥土路 10, 石板路 11)
func _generate_roads(grid: Array) -> void:
	for child in road_layer.get_children():
		child.queue_free()
		
	if road_layer is TileMapLayer:
		(road_layer as TileMapLayer).clear()
		for y in range(grid.size()):
			for x in range(grid[y].size()):
				var road_id = grid[y][x]
				if road_id > 0:
					(road_layer as TileMapLayer).set_cell(Vector2i(x, y), 1, Vector2i(road_id, 0))
	else:
		var road_tex = preload("res://assets/sprites/terrain/tile_road.png")
		var stone_tex = preload("res://assets/sprites/terrain/tile_stone.png")
		for y in range(grid.size()):
			for x in range(grid[y].size()):
				var road_id = grid[y][x]
				if road_id > 0:
					var sp = Sprite2D.new()
					sp.texture = stone_tex if road_id == 11 else road_tex
					sp.position = grid_to_screen(Vector2i(x, y))
					road_layer.add_child(sp)

## 生成營運設施、防禦工事與忠義堂大殿
func _spawn_facilities(facilities: Array) -> void:
	for child in ysort_layer.get_children():
		child.queue_free()
		
	if ysort_layer is TileMapLayer:
		(ysort_layer as TileMapLayer).clear()
		for fac in facilities:
			var pos = Vector2i(fac["x"], fac["y"])
			var fac_type = fac["type"]
			var atlas_coords = _get_facility_atlas(fac_type, fac.get("level", 1))
			(ysort_layer as TileMapLayer).set_cell(pos, 2, atlas_coords)
	else:
		for fac in facilities:
			var fac_pos = Vector2i(fac["x"], fac["y"])
			var fac_type: String = fac["type"]
			var fac_lvl: int = fac.get("level", 1)
			
			var fac_node = IsometricFacility.new()
			fac_node.facility_type = _get_canonical_facility_type(fac_type)
			fac_node.display_name = _get_facility_title(fac_type)
			fac_node.grid_coord = fac_pos
			fac_node.level = fac_lvl
			fac_node.position = grid_to_screen(fac_pos)
			fac_node.z_index = int(fac_node.position.y)
			ysort_layer.add_child(fac_node)

## 產生好漢實體 (HeroEntity)
func _spawn_initial_heroes(heroes: Array) -> void:
	for child in hero_spawner.get_children():
		child.queue_free()
		
	var hero_scene_res = "res://scenes/characters/HeroEntity.tscn"
	var hero_packed = null
	if ResourceLoader.exists(hero_scene_res):
		hero_packed = load(hero_scene_res)
		
	for h in heroes:
		var hero_id: String = str(h["hero_id"])
		var g_pos = Vector2i(h["x"], h["y"])
		
		var hero_inst: HeroEntity = null
		if hero_packed:
			hero_inst = hero_packed.instantiate() as HeroEntity
		else:
			hero_inst = HeroEntity.new()
			
		hero_spawner.add_child(hero_inst)
		hero_inst.init_hero(hero_id, g_pos)

## 座標換算：菱形等角網格轉 2D 螢幕座標 (2:1 等角變換)
static func grid_to_screen(pos: Vector2i) -> Vector2:
	return Vector2(
		(pos.x - pos.y) * 32.0,
		(pos.x + pos.y) * 16.0
	)

## 座標換算：2D 螢幕座標轉菱形等角網格
static func screen_to_grid(screen_pos: Vector2) -> Vector2i:
	var gx = int(round((screen_pos.x / 32.0 + screen_pos.y / 16.0) / 2.0))
	var gy = int(round((screen_pos.y / 16.0 - screen_pos.x / 32.0) / 2.0))
	return Vector2i(gx, gy)

func _get_facility_atlas(fac_type: String, level: int) -> Vector2i:
	match fac_type:
		"main_hall": return Vector2i(0, 0)
		"smithy": return Vector2i(1, 0)
		"tavern": return Vector2i(2, 0)
		"dock", "shipyard": return Vector2i(3, 0)
		"granary": return Vector2i(4, 0)
		"barracks": return Vector2i(5, 0)
		"farmland": return Vector2i(6, 0)
		"barricade": return Vector2i(7, 0)
		"watchtower": return Vector2i(8, 0)
		_: return Vector2i(0, 0)

func _get_canonical_facility_type(fac_type: String) -> String:
	match fac_type:
		"main_hall": return "MainHall"
		"smithy": return "Smithy"
		"tavern": return "Tavern"
		"dock", "shipyard": return "Shipyard"
		"granary": return "Granary"
		"barracks": return "Barracks"
		"farmland": return "Farm"
		_: return "MainHall"

func _get_facility_title(fac_type: String) -> String:
	match fac_type:
		"main_hall": return "聚義忠義堂"
		"smithy": return "神兵鐵匠坊"
		"tavern": return "聚義水泊酒館"
		"dock", "shipyard": return "水軍樓船碼頭"
		"granary": return "聚義糧倉"
		"barracks": return "先鋒軍營"
		"farmland": return "肥沃水田"
		"barricade": return "拒馬木柵"
		"watchtower": return "瞭望箭樓"
		_: return "山寨設施"
