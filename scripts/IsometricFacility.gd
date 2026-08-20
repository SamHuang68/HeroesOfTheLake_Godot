# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 2.5D 等角要塞建築與設施 (含 3x3 忠義堂、碼頭戰船、鍛造坊與繁榮 VFX)
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

# 動態特效與計時器
var anim_time: float = 0.0
var smoke_particles: Array[Dictionary] = []
var spark_particles: Array[Dictionary] = []

signal facility_selected(facility: IsometricFacility)

func _ready() -> void:
	z_as_relative = true
	update_screen_position()

func update_screen_position() -> void:
	var map: Node2D = get_parent()
	if map and map.has_method("grid_to_screen"):
		position = map.call("grid_to_screen", grid_coord.x, grid_coord.y)

func _process(delta: float) -> void:
	anim_time += delta

	if is_operating:
		# 1. 煙囪白煙粒子 (Smithy / Tavern / Granary)
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
				sp["vel"].y += 75.0 * delta # 重力
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
	# 繪製各類型 2.5D 古風建築實體
	match facility_type:
		"MainHall":
			draw_grand_zhongyi_hall()
		"Smithy":
			draw_smithy_facility()
		"Tavern":
			draw_tavern_facility()
		"Granary":
			draw_granary_facility()
		"Barracks":
			draw_barracks_facility()
		"Shipyard":
			draw_shipyard_dock_and_ship()
		"Watchtower":
			draw_watchtower_facility()
		"Palisade":
			draw_palisade_defense()
		"Farm":
			draw_farmland_facility()
		_:
			draw_generic_building()

	# 繪製動態繁榮特效 (白煙、火花)
	if is_operating:
		draw_prosperity_vfx()

	# 繪製頭頂等級與進駐好漢標籤
	draw_overhead_badge()

## 繪製 3x3 宏偉忠義堂本營 (Grand Zhongyi Hall)
func draw_grand_zhongyi_hall() -> void:
	# 1. 漢白玉高台石基 (Multi-tier Stone Base)
	var base_pts := PackedVector2Array([
		Vector2(0, -32), Vector2(70, 2), Vector2(0, 36), Vector2(-70, 2)
	])
	draw_colored_polygon(base_pts, Color(0.78, 0.78, 0.80, 1.0))
	draw_polyline(PackedVector2Array([base_pts[0], base_pts[1], base_pts[2], base_pts[3], base_pts[0]]), Color(0.92, 0.92, 0.95, 1.0), 2.0)

	# 階梯
	for step in range(3):
		var sy: float = 18.0 + step * 6.0
		draw_line(Vector2(-18, sy), Vector2(18, sy), Color(0.65, 0.65, 0.68, 1.0), 2.0)

	# 2. 朱紅大殿柱與回廊牆體 (Red Pillars)
	draw_rect(Rect2(-54, -40, 108, 42), Color(0.65, 0.18, 0.15, 1.0))
	# 立柱
	for px in [-50, -25, 0, 25, 50]:
		draw_rect(Rect2(px - 3, -42, 6, 44), Color(0.45, 0.10, 0.08, 1.0))

	# 3. 下層飛簷 (Lower Eaves)
	var lower_roof := PackedVector2Array([
		Vector2(0, -56), Vector2(76, -18), Vector2(0, 20), Vector2(-76, -18)
	])
	draw_colored_polygon(lower_roof, Color(0.85, 0.55, 0.15, 1.0)) # 琉璃金瓦
	draw_polyline(PackedVector2Array([lower_roof[0], lower_roof[1], lower_roof[2], lower_roof[3], lower_roof[0]]), Color(1.0, 0.85, 0.3, 1.0), 2.0)

	# 4. 上層主殿殿頂 (Upper Grand Roof)
	var upper_wall := PackedVector2Array([
		Vector2(-35, -54), Vector2(35, -54), Vector2(35, -70), Vector2(-35, -70)
	])
	draw_colored_polygon(upper_wall, Color(0.65, 0.18, 0.15, 1.0))

	var upper_roof := PackedVector2Array([
		Vector2(0, -96), Vector2(60, -66), Vector2(0, -36), Vector2(-60, -66)
	])
	draw_colored_polygon(upper_roof, Color(0.92, 0.60, 0.18, 1.0))
	draw_polyline(PackedVector2Array([upper_roof[0], upper_roof[1], upper_roof[2], upper_roof[3], upper_roof[0]]), Color(1.0, 0.90, 0.4, 1.0), 2.5)

	# 正脊與吻獸
	draw_line(Vector2(-30, -82), Vector2(30, -82), Color(1.0, 0.85, 0.2, 1.0), 4.0)
	draw_circle(Vector2(-32, -84), 4.0, Color(1.0, 0.75, 0.1, 1.0))
	draw_circle(Vector2(32, -84), 4.0, Color(1.0, 0.75, 0.1, 1.0))

	# 5. 「替天行道」杏黃大旗與「忠義堂」金字匾額
	var flag_wave := sin(anim_time * 3.5) * 4.0
	draw_line(Vector2(-58, 10), Vector2(-58, -60), Color(0.35, 0.20, 0.10, 1.0), 3.0) # 旗桿
	var flag_pts := PackedVector2Array([
		Vector2(-58, -58), Vector2(-28 + flag_wave, -50), Vector2(-32 + flag_wave, -32), Vector2(-58, -40)
	])
	draw_colored_polygon(flag_pts, Color(0.95, 0.85, 0.25, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(-52 + flag_wave * 0.5, -42), "替天行道", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(0.7, 0.1, 0.1, 1.0))

	# 匾額
	draw_rect(Rect2(-20, -52, 40, 14), Color(0.12, 0.10, 0.35, 0.95))
	draw_rect(Rect2(-20, -52, 40, 14), Color(1.0, 0.85, 0.3, 1.0), false, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(-18, -41), "忠 義 堂", HORIZONTAL_ALIGNMENT_CENTER, 36, 9, Color(1.0, 0.95, 0.4, 1.0))

## 繪製神兵鐵匠坊 (Smithy)
func draw_smithy_facility() -> void:
	var h_off: float = -24.0 * level
	# 石牆基座
	draw_colored_polygon(PackedVector2Array([Vector2(-32, -6), Vector2(32, -6), Vector2(32, 10), Vector2(-32, 10)]), Color(0.55, 0.50, 0.45, 1.0))
	# 瓦頂
	var roof := PackedVector2Array([Vector2(0, h_off - 18), Vector2(36, h_off), Vector2(0, h_off + 18), Vector2(-36, h_off)])
	draw_colored_polygon(roof, Color(0.42, 0.42, 0.48, 1.0))
	draw_polyline(PackedVector2Array([roof[0], roof[1], roof[2], roof[3], roof[0]]), Color(0.85, 0.75, 0.3, 1.0), 1.5)
	# 鍛造爐與高聳煙囪
	draw_rect(Rect2(18, h_off - 26, 10, 28), Color(0.35, 0.28, 0.22, 1.0))
	draw_rect(Rect2(16, h_off - 30, 14, 5), Color(0.22, 0.18, 0.14, 1.0))
	# 鐵砧與兵器架
	draw_rect(Rect2(-16, -10, 12, 10), Color(0.3, 0.3, 0.35, 1.0))
	draw_line(Vector2(20, 8), Vector2(26, -14), Color(0.85, 0.85, 0.9, 1.0), 2.0)

## 繪製聚義酒館 (Tavern)
func draw_tavern_facility() -> void:
	var h_off: float = -26.0 * level
	draw_colored_polygon(PackedVector2Array([Vector2(-30, -8), Vector2(30, -8), Vector2(30, 10), Vector2(-30, 10)]), Color(0.68, 0.55, 0.42, 1.0))
	var roof := PackedVector2Array([Vector2(0, h_off - 16), Vector2(34, h_off), Vector2(0, h_off + 16), Vector2(-34, h_off)])
	draw_colored_polygon(roof, Color(0.78, 0.42, 0.18, 1.0))
	draw_polyline(PackedVector2Array([roof[0], roof[1], roof[2], roof[3], roof[0]]), Color(1.0, 0.85, 0.2, 1.0), 1.5)
	# 酒旗 (飄動)
	var wave := sin(anim_time * 3.5) * 3.5
	draw_line(Vector2(-26, 6), Vector2(-26, -36), Color(0.4, 0.25, 0.15, 1.0), 2.5)
	var flag := PackedVector2Array([Vector2(-26, -34), Vector2(-6 + wave, -30), Vector2(-8 + wave, -16), Vector2(-26, -20)])
	draw_colored_polygon(flag, Color(0.92, 0.88, 0.35, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(-20 + wave * 0.5, -22), "酒", HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color(0.75, 0.1, 0.1, 1.0))
	# 紅燈籠發光
	var glow := (sin(anim_time * 4.0) + 1.0) * 0.2 + 0.7
	draw_circle(Vector2(24, -12), 6.0, Color(1.0, 0.35, 0.1, glow))

## 繪製聚義糧倉 (Granary)
func draw_granary_facility() -> void:
	# 圓形石木底座
	draw_circle(Vector2(0, 0), 24.0, Color(0.65, 0.52, 0.38, 1.0))
	# 圓錐茅草頂
	var cone_roof := PackedVector2Array([Vector2(0, -48), Vector2(28, -12), Vector2(0, 8), Vector2(-28, -12)])
	draw_colored_polygon(cone_roof, Color(0.85, 0.72, 0.32, 1.0))
	draw_polyline(PackedVector2Array([cone_roof[0], cone_roof[1], cone_roof[2], cone_roof[3], cone_roof[0]]), Color(0.95, 0.85, 0.45, 1.0), 1.5)
	# 糧袋堆
	draw_circle(Vector2(-18, 8), 5.0, Color(0.85, 0.80, 0.65, 1.0))
	draw_circle(Vector2(-12, 10), 5.0, Color(0.85, 0.80, 0.65, 1.0))

## 繪製先鋒軍營 (Barracks)
func draw_barracks_facility() -> void:
	var h_off: float = -22.0 * level
	draw_rect(Rect2(-32, -8, 64, 18), Color(0.58, 0.28, 0.20, 1.0))
	var roof := PackedVector2Array([Vector2(0, h_off - 16), Vector2(36, h_off), Vector2(0, h_off + 16), Vector2(-36, h_off)])
	draw_colored_polygon(roof, Color(0.75, 0.15, 0.15, 1.0))
	# 戰旗
	var fwave := sin(anim_time * 4.0) * 4.0
	draw_line(Vector2(24, 6), Vector2(24, -36), Color(0.3, 0.2, 0.1, 1.0), 2.0)
	draw_colored_polygon(PackedVector2Array([Vector2(24, -36), Vector2(44 + fwave, -28), Vector2(24, -20)]), Color(0.9, 0.1, 0.1, 1.0))

## 繪製水泊碼頭與樓船戰艦 (Shipyard & Warship)
func draw_shipyard_dock_and_ship() -> void:
	# 木棧橋
	draw_rect(Rect2(-36, -2, 72, 12), Color(0.48, 0.35, 0.20, 1.0))
	# 停靠戰船隨水波上下浮動 (Sine Wave Buoyancy)
	var boat_y := sin(anim_time * 2.2) * 3.5
	var boat_pts := PackedVector2Array([
		Vector2(-24, 8 + boat_y), Vector2(24, 8 + boat_y), Vector2(32, -4 + boat_y), Vector2(-32, -4 + boat_y)
	])
	draw_colored_polygon(boat_pts, Color(0.38, 0.26, 0.15, 1.0))
	draw_line(Vector2(0, -4 + boat_y), Vector2(0, -32 + boat_y), Color(0.3, 0.2, 0.1, 1.0), 2.5) # 桅桿
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -30 + boat_y), Vector2(18, -20 + boat_y), Vector2(0, -10 + boat_y)
	]), Color(0.92, 0.90, 0.82, 1.0)) # 戰船主帆

## 繪製哨塔箭樓 (Watchtower)
func draw_watchtower_facility() -> void:
	draw_line(Vector2(-10, 0), Vector2(-10, -38), Color(0.35, 0.22, 0.12, 1.0), 3.5)
	draw_line(Vector2(10, 0), Vector2(10, -38), Color(0.35, 0.22, 0.12, 1.0), 3.5)
	draw_rect(Rect2(-16, -46, 32, 10), Color(0.65, 0.25, 0.15, 1.0))
	var roof := PackedVector2Array([Vector2(0, -56), Vector2(18, -46), Vector2(0, -36), Vector2(-18, -46)])
	draw_colored_polygon(roof, Color(0.4, 0.35, 0.3, 1.0))

## 繪製防禦木鹿角 (Palisade)
func draw_palisade_defense() -> void:
	draw_line(Vector2(-10, 6), Vector2(10, -14), Color(0.45, 0.30, 0.15, 1.0), 3.0)
	draw_line(Vector2(-10, -14), Vector2(10, 6), Color(0.45, 0.30, 0.15, 1.0), 3.0)

## 繪製高產農田水田 (Farmland)
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
	if facility_type == "MainHall": badge_y = -105.0

	var badge_rect := Rect2(-38, badge_y, 76, 17)
	draw_rect(badge_rect, Color(0.08, 0.12, 0.20, 0.88), true)
	draw_rect(badge_rect, Color(0.85, 0.75, 0.35, 0.95), false, 1.0)

	var stars := ""
	for i in range(level): stars += "★"
	var text := "%s %s" % [display_name, stars]
	draw_string(ThemeDB.fallback_font, Vector2(-36, badge_y + 12), text, HORIZONTAL_ALIGNMENT_CENTER, 72, 9, Color(1.0, 0.95, 0.7, 1.0))

	if assigned_heroes.size() > 0:
		draw_string(ThemeDB.fallback_font, Vector2(-36, badge_y - 2), "👤 " + assigned_heroes[0], HORIZONTAL_ALIGNMENT_CENTER, 72, 8, Color(0.3, 0.9, 0.4, 1.0))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var local_m := to_local(event.position)
		var click_radius: float = 65.0 if facility_type == "MainHall" else 38.0
		if local_m.distance_to(Vector2(0, -25)) < click_radius:
			facility_selected.emit(self)
