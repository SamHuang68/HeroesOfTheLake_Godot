# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 2.5D 等角地圖設施 (含多等級外觀與繁榮度動態 VFX)
class_name IsometricFacility
extends Node2D

## 設施基礎屬性
@export var facility_id: String = "facility_01"
@export var facility_type: String = "Smithy" # Farm, Market, Tavern, Smithy, Barracks, Temple, Shipyard, MainHall
@export var display_name: String = "兵器坊"
@export var grid_coord: Vector2i = Vector2i(10, 10)
@export var footprint: Vector2i = Vector2i(1, 1) # 1x1, 2x2, 3x3
@export var level: int = 1 # 1: 初級, 2: 中級, 3: 高級/繁榮
@export var assigned_heroes: Array[String] = [] # 指派好漢名單 (e.g. ["林沖", "湯隆"])
@export var is_operating: bool = true

# 動態特效計時器
var anim_time: float = 0.0
var smoke_particles: Array[Dictionary] = [] # 煙霧粒子
var spark_particles: Array[Dictionary] = [] # 火花粒子

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
		# 1. 煙囪白煙粒子循環 (Smithy / Tavern / Farmhouse)
		if facility_type in ["Smithy", "Tavern", "Farm"]:
			if smoke_particles.size() < 6 and randf() < 0.2:
				smoke_particles.append({
					"pos": Vector2(14, -40), # 煙囪位置
					"vel": Vector2(randf_range(-4, 4), randf_range(-18, -26)),
					"radius": 4.0,
					"alpha": 0.75,
					"life": 1.8
				})

			for i in range(smoke_particles.size() - 1, -1, -1):
				var p: Dictionary = smoke_particles[i]
				p["pos"] += p["vel"] * delta
				p["radius"] += delta * 6.0 # 擴散
				p["alpha"] -= delta * 0.4
				p["life"] -= delta
				if p["life"] <= 0.0:
					smoke_particles.remove_at(i)

		# 2. 鐵砧打鐵火花粒子循環 (Smithy)
		if facility_type == "Smithy" and assigned_heroes.size() > 0:
			if spark_particles.size() < 8 and randf() < 0.3:
				spark_particles.append({
					"pos": Vector2(-6, -8),
					"vel": Vector2(randf_range(-20, 20), randf_range(-30, -10)),
					"alpha": 1.0,
					"life": 0.4
				})

			for i in range(spark_particles.size() - 1, -1, -1):
				var sp: Dictionary = spark_particles[i]
				sp["pos"] += sp["vel"] * delta
				sp["vel"].y += 60.0 * delta # 重力
				sp["alpha"] -= delta * 2.5
				sp["life"] -= delta
				if sp["life"] <= 0.0:
					spark_particles.remove_at(i)

	queue_redraw()

func upgrade_facility() -> bool:
	if level < 3:
		level += 1
		if level == 3:
			footprint = Vector2i(2, 2)
		queue_redraw()
		return true
	return false

func _draw() -> void:
	# 依照等級與設施類型繪製 2.5D 等角多層次結構
	match facility_type:
		"Smithy":
			draw_smithy_building()
		"Farm":
			draw_farm_building()
		"Tavern":
			draw_tavern_building()
		"Barracks":
			draw_barracks_building()
		"Shipyard":
			draw_shipyard_building()
		"MainHall":
			draw_main_hall_building()
		_:
			draw_generic_building()

	# 繪製繁榮動態特效層 (VFX Overlays)
	if is_operating:
		draw_prosperity_vfx()

	# 繪製設施名稱與等級浮標 (Level & Assigned Status)
	draw_facility_overhead_badge()

## 繪製兵器鐵匠坊 (Smithy)
func draw_smithy_building() -> void:
	var roof_col := Color(0.45, 0.45, 0.48, 1.0) if level == 1 else (Color(0.55, 0.35, 0.25, 1.0) if level == 2 else Color(0.25, 0.30, 0.45, 1.0))
	var wall_col := Color(0.60, 0.55, 0.45, 1.0)
	
	# 石基與牆體
	var h_offset: float = -20.0 * level
	draw_colored_polygon(PackedVector2Array([
		Vector2(-24, -4), Vector2(24, -4), Vector2(24, 8), Vector2(-24, 8)
	]), wall_col)
	
	# 屋頂 (等角 2:1 菱形瓦頂)
	var roof_pts := PackedVector2Array([
		Vector2(0, h_offset - 16),
		Vector2(28, h_offset),
		Vector2(0, h_offset + 16),
		Vector2(-28, h_offset)
	])
	draw_colored_polygon(roof_pts, roof_col)
	draw_polyline(PackedVector2Array([roof_pts[0], roof_pts[1], roof_pts[2], roof_pts[3], roof_pts[0]]), Color(0.9, 0.8, 0.3, 1.0), 1.5)

	# 煙囪
	draw_rect(Rect2(10, h_offset - 20, 8, 20), Color(0.35, 0.30, 0.25, 1.0))
	draw_rect(Rect2(8, h_offset - 24, 12, 4), Color(0.25, 0.20, 0.15, 1.0))

	# Lv2+ 物資箱與武器架
	if level >= 2:
		draw_rect(Rect2(-22, -8, 8, 8), Color(0.55, 0.38, 0.22, 1.0)) # 箱
		draw_line(Vector2(16, 6), Vector2(20, -12), Color(0.8, 0.8, 0.85, 1.0), 2.0) # 槍架

## 繪製酒館客棧 (Tavern)
func draw_tavern_building() -> void:
	var roof_col := Color(0.75, 0.45, 0.20, 1.0) if level < 3 else Color(0.85, 0.25, 0.20, 1.0)
	var h_offset: float = -22.0 * level

	# 本體大堂
	draw_colored_polygon(PackedVector2Array([
		Vector2(-26, -6), Vector2(26, -6), Vector2(26, 8), Vector2(-26, 8)
	]), Color(0.70, 0.60, 0.48, 1.0))

	# 兩層飛簷 (Lv2+)
	var roof_pts := PackedVector2Array([
		Vector2(0, h_offset - 16), Vector2(30, h_offset), Vector2(0, h_offset + 16), Vector2(-30, h_offset)
	])
	draw_colored_polygon(roof_pts, roof_col)
	draw_polyline(PackedVector2Array([roof_pts[0], roof_pts[1], roof_pts[2], roof_pts[3], roof_pts[0]]), Color(1.0, 0.85, 0.2, 1.0), 1.5)

	# 酒旗桿與招牌 (飄動正弦動畫)
	var wave: float = sin(anim_time * 3.5) * 3.0
	draw_line(Vector2(-22, 4), Vector2(-22, -32), Color(0.4, 0.25, 0.15, 1.0), 2.5)
	var flag_pts := PackedVector2Array([
		Vector2(-22, -30), Vector2(-6 + wave, -26), Vector2(-8 + wave, -14), Vector2(-22, -18)
	])
	draw_colored_polygon(flag_pts, Color(0.9, 0.85, 0.4, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(-18 + wave * 0.5, -20), "酒", HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color(0.7, 0.1, 0.1, 1.0))

	# 燈籠 (夜間/活躍發光)
	var glow := (sin(anim_time * 4.0) + 1.0) * 0.15 + 0.7
	draw_circle(Vector2(20, -10), 5.0, Color(1.0, 0.4, 0.1, glow))

## 繪製耕地農田 (Farm)
func draw_farm_building() -> void:
	# 耕作條紋
	var fill_col := Color(0.65, 0.52, 0.25, 1.0) if level == 1 else Color(0.75, 0.62, 0.20, 1.0)
	for i in range(-3, 4):
		var y_off: float = i * 4.0
		draw_line(Vector2(-20, y_off), Vector2(20, y_off), fill_col, 2.0)
	
	# 水車或農舍 (Lv2+)
	if level >= 2:
		draw_rect(Rect2(-18, -26, 16, 16), Color(0.55, 0.40, 0.25, 1.0))
		draw_colored_polygon(PackedVector2Array([
			Vector2(-20, -26), Vector2(-10, -36), Vector2(0, -26)
		]), Color(0.7, 0.5, 0.3, 1.0))

## 繪製軍營演武 (Barracks)
func draw_barracks_building() -> void:
	var h_offset: float = -20.0 * level
	draw_rect(Rect2(-24, -8, 48, 16), Color(0.6, 0.3, 0.2, 1.0))
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, h_offset - 14), Vector2(28, h_offset), Vector2(0, h_offset + 14), Vector2(-28, h_offset)
	]), Color(0.75, 0.15, 0.15, 1.0))
	
	# 戰旗飄揚
	var fwave := sin(anim_time * 4.0) * 4.0
	draw_line(Vector2(18, 4), Vector2(18, -32), Color(0.3, 0.2, 0.1, 1.0), 2.0)
	draw_colored_polygon(PackedVector2Array([
		Vector2(18, -32), Vector2(34 + fwave, -26), Vector2(18, -20)
	]), Color(0.9, 0.1, 0.1, 1.0))

## 繪製水泊碼頭造船塢 (Shipyard)
func draw_shipyard_building() -> void:
	# 木棧橋
	draw_rect(Rect2(-24, 0, 48, 8), Color(0.48, 0.35, 0.20, 1.0))
	# 停靠戰船隨水波上下浮動 (Sine Wave Buoyancy)
	var boat_y := sin(anim_time * 2.2) * 3.0
	var boat_pts := PackedVector2Array([
		Vector2(-18, 6 + boat_y), Vector2(18, 6 + boat_y), Vector2(24, -2 + boat_y), Vector2(-24, -2 + boat_y)
	])
	draw_colored_polygon(boat_pts, Color(0.38, 0.26, 0.15, 1.0))
	draw_line(Vector2(0, -2 + boat_y), Vector2(0, -20 + boat_y), Color(0.3, 0.2, 0.1, 1.0), 2.0) # 桅杆
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -18 + boat_y), Vector2(12, -12 + boat_y), Vector2(0, -6 + boat_y)
	]), Color(0.9, 0.88, 0.8, 1.0)) # 帆

## 繪製聚義廳忠義堂本營 (MainHall)
func draw_main_hall_building() -> void:
	var roof_pts := PackedVector2Array([
		Vector2(0, -42), Vector2(40, -16), Vector2(0, 10), Vector2(-40, -16)
	])
	draw_colored_polygon(roof_pts, Color(0.85, 0.18, 0.15, 1.0)) # 朱紅大殿頂
	draw_polyline(PackedVector2Array([roof_pts[0], roof_pts[1], roof_pts[2], roof_pts[3], roof_pts[0]]), Color(1.0, 0.85, 0.2, 1.0), 2.0)
	
	# 忠義堂匾額
	draw_rect(Rect2(-14, -26, 28, 10), Color(0.1, 0.1, 0.4, 0.9))
	draw_string(ThemeDB.fallback_font, Vector2(-12, -18), "忠義堂", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(1.0, 0.9, 0.3, 1.0))

func draw_generic_building() -> void:
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -30), Vector2(24, -10), Vector2(0, 10), Vector2(-24, -10)
	]), Color(0.6, 0.5, 0.4, 1.0))

## 繪製動態繁榮特效 (白煙/火花)
func draw_prosperity_vfx() -> void:
	# 煙霧
	for p in smoke_particles:
		draw_circle(p["pos"], p["radius"], Color(0.92, 0.92, 0.95, p["alpha"]))

	# 火花
	for sp in spark_particles:
		draw_circle(sp["pos"], 1.8, Color(1.0, 0.85, 0.2, sp["alpha"]))

## 繪製設施上方等級與駐守標籤
func draw_facility_overhead_badge() -> void:
	var badge_y: float = -52.0 - (level * 6.0)
	var badge_rect := Rect2(-36, badge_y, 72, 16)
	draw_rect(badge_rect, Color(0.08, 0.12, 0.20, 0.85), true)
	draw_rect(badge_rect, Color(0.8, 0.7, 0.3, 0.9), false, 1.0)

	var stars := ""
	for i in range(level): stars += "★"
	var text := "%s %s" % [display_name, stars]
	draw_string(ThemeDB.fallback_font, Vector2(-34, badge_y + 11), text, HORIZONTAL_ALIGNMENT_CENTER, 68, 9, Color(1.0, 0.95, 0.7, 1.0))

	# 若有好漢進駐，顯示進駐標記
	if assigned_heroes.size() > 0:
		var hero_str: String = "👤" + assigned_heroes[0]
		draw_string(ThemeDB.fallback_font, Vector2(-34, badge_y - 2), hero_str, HORIZONTAL_ALIGNMENT_CENTER, 68, 8, Color(0.3, 0.9, 0.4, 1.0))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var local_m := to_local(event.position)
		if local_m.distance_to(Vector2(0, -15)) < 35.0:
			facility_selected.emit(self)
