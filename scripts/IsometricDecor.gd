# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 2.5D 自然地貌物件 (松樹、柳樹、銀杏、巨石、水泊蘆葦)
class_name IsometricDecor
extends Node2D

enum DecorType {
	PINE_TREE,    # 蒼勁青松 (高山密林)
	WILLOW_TREE,  # 垂柳 (水泊湖畔)
	GINKGO_TREE,  # 金黃銀杏
	BOULDER,      # 嶙峋巨石 / 碎岩
	WATER_REEDS   # 水泊蘆葦叢
}

@export var decor_type: DecorType = DecorType.PINE_TREE
@export var grid_coord: Vector2i = Vector2i(0, 0)

var sway_timer: float = 0.0

func _ready() -> void:
	z_as_relative = true
	update_screen_position()

func update_screen_position() -> void:
	var map: Node2D = get_parent()
	if map and map.has_method("grid_to_screen"):
		position = map.call("grid_to_screen", grid_coord.x, grid_coord.y)

func _process(delta: float) -> void:
	sway_timer += delta
	queue_redraw()

func _draw() -> void:
	var sway: float = sin(sway_timer * 2.0 + grid_coord.x * 0.5 + grid_coord.y * 0.5) * 1.5

	match decor_type:
		DecorType.PINE_TREE:
			draw_pine_tree(sway)
		DecorType.WILLOW_TREE:
			draw_willow_tree(sway)
		DecorType.GINKGO_TREE:
			draw_ginkgo_tree(sway)
		DecorType.BOULDER:
			draw_boulder()
		DecorType.WATER_REEDS:
			draw_water_reeds(sway)

## 繪製蒼勁青松 (Pine Tree)
func draw_pine_tree(sway: float) -> void:
	# 影子
	draw_colored_polygon(PackedVector2Array([
		Vector2(-12, 1), Vector2(0, -3), Vector2(12, 1), Vector2(0, 5)
	]), Color(0.0, 0.0, 0.0, 0.3))

	# 樹幹
	draw_line(Vector2(0, 2), Vector2(0 + sway * 0.3, -16), Color(0.38, 0.24, 0.12, 1.0), 3.5)
	draw_line(Vector2(0, -10), Vector2(-6 + sway * 0.5, -20), Color(0.38, 0.24, 0.12, 1.0), 2.0)
	draw_line(Vector2(0, -12), Vector2(6 + sway * 0.5, -22), Color(0.38, 0.24, 0.12, 1.0), 2.0)

	# 3 層松針冠 (深綠厚實)
	var pine_cols := [
		Color(0.12, 0.32, 0.15, 1.0),
		Color(0.18, 0.42, 0.20, 1.0),
		Color(0.25, 0.52, 0.26, 1.0)
	]
	
	# 底層
	var pts1 := PackedVector2Array([
		Vector2(-18, -14), Vector2(18, -14), Vector2(0 + sway * 0.6, -30)
	])
	draw_colored_polygon(pts1, pine_cols[0])

	# 中層
	var pts2 := PackedVector2Array([
		Vector2(-14, -24), Vector2(14, -24), Vector2(0 + sway * 0.8, -40)
	])
	draw_colored_polygon(pts2, pine_cols[1])

	# 頂層
	var pts3 := PackedVector2Array([
		Vector2(-10, -34), Vector2(10, -34), Vector2(0 + sway, -48)
	])
	draw_colored_polygon(pts3, pine_cols[2])

## 繪製水泊垂柳 (Willow Tree)
func draw_willow_tree(sway: float) -> void:
	# 影子
	draw_colored_polygon(PackedVector2Array([
		Vector2(-14, 1), Vector2(0, -4), Vector2(14, 1), Vector2(0, 5)
	]), Color(0.0, 0.0, 0.0, 0.3))

	# 彎曲老幹
	draw_line(Vector2(0, 2), Vector2(-4 + sway * 0.3, -18), Color(0.42, 0.28, 0.16, 1.0), 4.0)

	# 蓬鬆柳冠
	draw_circle(Vector2(-4 + sway * 0.5, -28), 16.0, Color(0.35, 0.58, 0.22, 0.95))
	draw_circle(Vector2(4 + sway * 0.6, -26), 14.0, Color(0.42, 0.66, 0.26, 0.9))

	# 垂落枝條 (正弦擺動)
	var strand_col := Color(0.30, 0.52, 0.18, 0.9)
	for i in range(-4, 5):
		var x_off: float = i * 4.0
		var s_sway: float = sin(sway_timer * 2.5 + i) * 3.0
		draw_line(Vector2(x_off, -22), Vector2(x_off + s_sway, -2), strand_col, 1.5)

## 繪製金黃銀杏 (Ginkgo Tree)
func draw_ginkgo_tree(sway: float) -> void:
	# 影子
	draw_colored_polygon(PackedVector2Array([
		Vector2(-12, 1), Vector2(0, -3), Vector2(12, 1), Vector2(0, 5)
	]), Color(0.0, 0.0, 0.0, 0.3))

	# 樹幹
	draw_line(Vector2(0, 2), Vector2(0 + sway * 0.3, -20), Color(0.45, 0.30, 0.18, 1.0), 3.5)

	# 金黃秋葉樹冠
	draw_circle(Vector2(0 + sway * 0.7, -30), 16.0, Color(0.92, 0.75, 0.15, 1.0))
	draw_circle(Vector2(-6 + sway * 0.5, -26), 12.0, Color(0.85, 0.65, 0.10, 0.95))
	draw_circle(Vector2(6 + sway * 0.6, -28), 12.0, Color(0.98, 0.82, 0.22, 0.95))

## 繪製嶙峋巨石 (Boulder)
func draw_boulder() -> void:
	# 影子
	draw_colored_polygon(PackedVector2Array([
		Vector2(-14, 2), Vector2(0, -3), Vector2(14, 2), Vector2(0, 6)
	]), Color(0.0, 0.0, 0.0, 0.35))

	# 幾何岩石多邊形
	var stone_pts := PackedVector2Array([
		Vector2(-12, 0), Vector2(-10, -12), Vector2(-2, -18),
		Vector2(10, -14), Vector2(12, -2), Vector2(6, 4), Vector2(-8, 3)
	])
	draw_colored_polygon(stone_pts, Color(0.48, 0.48, 0.50, 1.0))
	
	# 陰影切面
	var shade_pts := PackedVector2Array([
		Vector2(-12, 0), Vector2(-10, -12), Vector2(-2, -18), Vector2(0, 2), Vector2(-8, 3)
	])
	draw_colored_polygon(shade_pts, Color(0.38, 0.38, 0.42, 1.0))
	draw_polyline(PackedVector2Array([stone_pts[0], stone_pts[1], stone_pts[2], stone_pts[3], stone_pts[4], stone_pts[5], stone_pts[6], stone_pts[0]]), Color(0.25, 0.25, 0.28, 1.0), 1.5)

## 繪製水泊蘆葦叢 (Water Reeds)
func draw_water_reeds(sway: float) -> void:
	var reed_col := Color(0.55, 0.68, 0.30, 1.0)
	var tip_col := Color(0.60, 0.45, 0.25, 1.0)

	for i in range(-3, 4):
		var rx: float = i * 4.0
		var r_sway: float = sin(sway_timer * 3.0 + i) * 3.5
		var top_p := Vector2(rx + r_sway, -18 - absi(i) * 2)
		draw_line(Vector2(rx, 2), top_p, reed_col, 1.5)
		draw_line(top_p + Vector2(0, 2), top_p - Vector2(0, 4), tip_col, 2.5)
