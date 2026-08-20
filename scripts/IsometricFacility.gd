# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 2.5D 等角要塞建築實體 (支援高解析/像素貼圖、動態 VFX 與滑鼠互動高亮)
class_name IsometricFacility
extends Node2D

@export var facility_id: String = "facility_01"
@export var facility_type: String = "MainHall" # MainHall, Smithy, Tavern, Farm, Barracks, Granary, Shipyard, Watchtower, Palisade
@export var display_name: String = "忠義堂本營"
@export var grid_coord: Vector2i = Vector2i(16, 16)
@export var footprint: Vector2i = Vector2i(3, 3) # 3x3, 2x2, 1x1
@export var level: int = 3 # 1~3
@export var assigned_heroes: Array[String] = []
@export var is_operating: bool = true

# 建築貼圖快取
var building_texture: Texture2D = null
var is_hovered: bool = false

# 動態特效與計時器
var anim_time: float = 0.0
var smoke_particles: Array[Dictionary] = []
var spark_particles: Array[Dictionary] = []

signal facility_selected(facility: IsometricFacility)

func _ready() -> void:
	z_as_relative = true
	load_facility_texture()
	update_screen_position()

func load_facility_texture() -> void:
	var tex_map := {
		"MainHall": "res://assets/sprites/buildings/main_hall_3x3.png",
		"Smithy": "res://assets/sprites/buildings/smithy_2x2.png",
		"Tavern": "res://assets/sprites/buildings/tavern_2x2.png",
		"Granary": "res://assets/sprites/buildings/granary_2x2.png",
		"Barracks": "res://assets/sprites/buildings/barracks_2x2.png",
		"Shipyard": "res://assets/sprites/buildings/shipyard_2x2.png"
	}
	if tex_map.has(facility_type):
		var p: String = tex_map[facility_type]
		if ResourceLoader.exists(p):
			building_texture = load(p)

func update_screen_position() -> void:
	var map: Node2D = get_parent()
	if map and map.has_method("grid_to_screen"):
		position = map.call("grid_to_screen", grid_coord.x, grid_coord.y)

func _process(delta: float) -> void:
	anim_time += delta

	if is_operating:
		# 1. 煙囪白煙粒子 (Smithy / Tavern / MainHall)
		if facility_type in ["Smithy", "Tavern", "MainHall"]:
			if smoke_particles.size() < 8 and randf() < 0.25:
				var chim_pos := Vector2(24, -60) if facility_type == "Smithy" else Vector2(0, -75)
				smoke_particles.append({
					"pos": chim_pos,
					"vel": Vector2(randf_range(-5, 5), randf_range(-20, -30)),
					"radius": 4.5,
					"alpha": 0.8,
					"life": 2.0
				})

			for i in range(smoke_particles.size() - 1, -1, -1):
				var p: Dictionary = smoke_particles[i]
				p["pos"] += p["vel"] * delta
				p["radius"] += delta * 7.0
				p["alpha"] -= delta * 0.4
				p["life"] -= delta
				if p["life"] <= 0.0:
					smoke_particles.remove_at(i)

		# 2. 鐵砧打鐵火花粒子 (Smithy)
		if facility_type == "Smithy" and assigned_heroes.size() > 0:
			if spark_particles.size() < 10 and randf() < 0.35:
				spark_particles.append({
					"pos": Vector2(-10, -12),
					"vel": Vector2(randf_range(-25, 25), randf_range(-35, -12)),
					"alpha": 1.0,
					"life": 0.45
				})

			for i in range(spark_particles.size() - 1, -1, -1):
				var sp: Dictionary = spark_particles[i]
				sp["pos"] += sp["vel"] * delta
				sp["vel"].y += 75.0 * delta
				sp["alpha"] -= delta * 2.2
				sp["life"] -= delta
				if sp["life"] <= 0.0:
					spark_particles.remove_at(i)

	queue_redraw()

func upgrade_facility() -> bool:
	if level < 3:
		level += 1
		queue_redraw()
		return true
	return false

func _draw() -> void:
	# 1. 若有對應的真實精靈貼圖，直接繪製高解析/像素建築貼圖
	if building_texture:
		var tex_size := building_texture.get_size()
		var dest_rect := Rect2(-tex_size.x / 2.0, -tex_size.y + 32, tex_size.x, tex_size.y)
		draw_texture(building_texture, dest_rect.position)

		# 若滑鼠懸停，繪製金黃光暈外框 (Interactive Hover Highlight)
		if is_hovered:
			draw_rect(dest_rect, Color(1.0, 0.9, 0.2, 0.3), false, 2.0)
	else:
		draw_procedural_building()

	# 2. 繪製動態繁榮特效 (白煙、火花)
	if is_operating:
		draw_prosperity_vfx()

	# 3. 繪製頭頂等級與進駐好漢標籤
	draw_overhead_badge()

func draw_procedural_building() -> void:
	match facility_type:
		"Watchtower": draw_watchtower_facility()
		"Palisade": draw_palisade_defense()
		"Farm": draw_farmland_facility()
		_: draw_generic_building()

func draw_watchtower_facility() -> void:
	draw_line(Vector2(-10, 0), Vector2(-10, -38), Color(0.35, 0.22, 0.12, 1.0), 3.5)
	draw_line(Vector2(10, 0), Vector2(10, -38), Color(0.35, 0.22, 0.12, 1.0), 3.5)
	draw_rect(Rect2(-16, -46, 32, 10), Color(0.65, 0.25, 0.15, 1.0))
	var roof := PackedVector2Array([Vector2(0, -56), Vector2(18, -46), Vector2(0, -36), Vector2(-18, -46)])
	draw_colored_polygon(roof, Color(0.4, 0.35, 0.3, 1.0))

func draw_palisade_defense() -> void:
	draw_line(Vector2(-10, 6), Vector2(10, -14), Color(0.45, 0.30, 0.15, 1.0), 3.0)
	draw_line(Vector2(-10, -14), Vector2(10, 6), Color(0.45, 0.30, 0.15, 1.0), 3.0)

func draw_farmland_facility() -> void:
	var col := Color(0.72, 0.60, 0.22, 1.0)
	for i in range(-3, 4):
		draw_line(Vector2(-24, i * 5.0), Vector2(24, i * 5.0), col, 2.5)

func draw_generic_building() -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(0, -30), Vector2(24, -10), Vector2(0, 10), Vector2(-24, -10)]), Color(0.6, 0.5, 0.4, 1.0))

func draw_prosperity_vfx() -> void:
	for p in smoke_particles:
		draw_circle(p["pos"], p["radius"], Color(0.92, 0.92, 0.95, p["alpha"]))
	for sp in spark_particles:
		draw_circle(sp["pos"], 2.0, Color(1.0, 0.85, 0.2, sp["alpha"]))

func draw_overhead_badge() -> void:
	var badge_y: float = -62.0 - (level * 8.0)
	if facility_type == "MainHall": badge_y = -115.0

	var badge_rect := Rect2(-40, badge_y, 80, 18)
	draw_rect(badge_rect, Color(0.08, 0.12, 0.20, 0.90), true)
	draw_rect(badge_rect, Color(0.85, 0.75, 0.35, 0.95), false, 1.0)

	var stars := ""
	for i in range(level): stars += "★"
	var text := "%s %s" % [display_name, stars]
	draw_string(ThemeDB.fallback_font, Vector2(-38, badge_y + 12), text, HORIZONTAL_ALIGNMENT_CENTER, 76, 9, Color(1.0, 0.95, 0.7, 1.0))

	if assigned_heroes.size() > 0:
		draw_string(ThemeDB.fallback_font, Vector2(-38, badge_y - 2), "👤 " + assigned_heroes[0], HORIZONTAL_ALIGNMENT_CENTER, 76, 8, Color(0.3, 0.9, 0.4, 1.0))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var local_m := to_local(event.position)
		var check_rad: float = 75.0 if facility_type == "MainHall" else 45.0
		var hover_now: bool = (local_m.distance_to(Vector2(0, -25)) < check_rad)
		if hover_now != is_hovered:
			is_hovered = hover_now
			queue_redraw()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var local_m := to_local(event.position)
		var click_radius: float = 75.0 if facility_type == "MainHall" else 45.0
		if local_m.distance_to(Vector2(0, -25)) < click_radius:
			facility_selected.emit(self)
