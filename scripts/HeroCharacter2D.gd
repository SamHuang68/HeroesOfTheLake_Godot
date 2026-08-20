# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 2D 等角好漢角色 (帶有頭頂數值懸浮條與 Y-Sort 深度排序)
class_name HeroCharacter2D
extends Node2D

@export var hero_name: String = "林沖"
@export var title_name: String = "豹子頭"
@export var current_stamina: int = 94
@export var max_stamina: int = 95
@export var current_energy: int = 47
@export var max_energy: int = 100
@export var grid_position: Vector2i = Vector2i(16, 16)
@export var move_speed: float = 80.0
@export var portrait_file: String = "portrait_linchong.jpg"

var target_screen_pos: Vector2 = Vector2.ZERO
var is_moving: bool = false
var path_points: Array[Vector2i] = []

signal hero_selected(hero: Node2D)

func _ready() -> void:
	# 啟用 Y-Sort 深度排序 (依據腳底 Y 軸自動遮擋)
	z_as_relative = true
	update_screen_position_instant()

## 立即同步網格位置至螢幕像素
func update_screen_position_instant() -> void:
	var map: Node2D = get_parent()
	if map and map.has_method("grid_to_screen"):
		position = map.call("grid_to_screen", grid_position.x, grid_position.y)

func _process(delta: float) -> void:
	if is_moving:
		position = position.move_toward(target_screen_pos, move_speed * delta)
		if position.distance_to(target_screen_pos) < 2.0:
			position = target_screen_pos
			if path_points.size() > 0:
				var next_grid: Vector2i = path_points.pop_front()
				grid_position = next_grid
				var map: Node2D = get_parent()
				if map and map.has_method("grid_to_screen"):
					target_screen_pos = map.call("grid_to_screen", next_grid.x, next_grid.y)
			else:
				is_moving = false
	queue_redraw()

func move_to_grid(new_grid: Vector2i) -> void:
	var map: Node2D = get_parent()
	if map and map.has_method("grid_to_screen"):
		grid_position = new_grid
		target_screen_pos = map.call("grid_to_screen", new_grid.x, new_grid.y)
		is_moving = true

func _draw() -> void:
	# 1. 繪製好漢 2.5D 精緻像素立身 (Sprite / Silhouette)
	# 影子 (橢圓)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-12, 2), Vector2(0, -3), Vector2(12, 2), Vector2(0, 7)
	]), Color(0.0, 0.0, 0.0, 0.35))

	# 角色身體披風與長袍
	draw_colored_polygon(PackedVector2Array([
		Vector2(-7, -4), Vector2(7, -4), Vector2(9, 2), Vector2(-9, 2)
	]), Color(0.85, 0.85, 0.82, 1.0)) # 白袍
	draw_colored_polygon(PackedVector2Array([
		Vector2(-6, -18), Vector2(6, -18), Vector2(7, -4), Vector2(-7, -4)
	]), Color(0.2, 0.35, 0.65, 1.0)) # 藍甲

	# 頭部與白氈大帽
	draw_circle(Vector2(0, -22), 6.0, Color(0.95, 0.80, 0.65, 1.0))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-10, -25), Vector2(10, -25), Vector2(0, -32)
	]), Color(0.9, 0.88, 0.8, 1.0)) # 白氈笠

	# 丈八長槍 / 武器
	draw_line(Vector2(5, 2), Vector2(12, -36), Color(0.7, 0.5, 0.3, 1.0), 2.0)
	draw_line(Vector2(12, -36), Vector2(14, -42), Color(0.9, 0.9, 0.9, 1.0), 2.5)

	# 2. 依據規範：頭頂懸浮微型體力/氣力數值（如 47/94）
	var badge_rect := Rect2(-30, -56, 60, 16)
	draw_rect(badge_rect, Color(0.05, 0.08, 0.15, 0.85), true)
	draw_rect(badge_rect, Color(0.8, 0.7, 0.4, 0.9), false, 1.0)

	var stat_text := "%s %d/%d" % [hero_name, current_energy, current_stamina]
	var default_font := ThemeDB.fallback_font
	draw_string(default_font, Vector2(-28, -44), stat_text, HORIZONTAL_ALIGNMENT_CENTER, 56, 10, Color(1.0, 0.95, 0.7, 1.0))

	# 微型體力血條
	var bar_width: float = 54.0 * (float(current_stamina) / float(max_stamina))
	draw_rect(Rect2(-27, -42, 54, 2), Color(0.3, 0.1, 0.1, 0.8))
	draw_rect(Rect2(-27, -42, bar_width, 2), Color(0.2, 0.85, 0.3, 1.0))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_local := to_local(event.position)
		if mouse_local.distance_to(Vector2(0, -20)) < 25.0:
			hero_selected.emit(self)
