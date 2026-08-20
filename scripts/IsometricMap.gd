# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 純 2D 等角 (Isometric 2.5D) 要塞地景地圖
class_name IsometricMap
extends Node2D

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

signal tile_clicked(grid_pos: Vector2i, tile_type: int)

func _ready() -> void:
	generate_fortress_terrain()
	queue_redraw()

## 產生梁山泊要塞初始沙盤地形
func generate_fortress_terrain() -> void:
	for x in range(MAP_SIZE_X):
		for y in range(MAP_SIZE_Y):
			var pos := Vector2i(x, y)
			# 預設為草地
			var type: int = TileType.GRASS
			
			# 外圍水泊環繞 (梁山八百里水泊)
			if x < 4 or x >= MAP_SIZE_X - 4 or y < 4 or y >= MAP_SIZE_Y - 4:
				type = TileType.WATER
			# 內部農田耕作區
			elif (x >= 6 and x <= 11 and y >= 6 and y <= 11) or (x >= 20 and x <= 25 and y >= 20 and y <= 25):
				type = TileType.FARMLAND
			# 中心要塞聚義廳本營
			elif x >= 14 and x <= 18 and y >= 14 and y <= 18:
				type = TileType.BUILDING
			# 要塞主幹道
			elif x == 16 or y == 16:
				type = TileType.ROAD
			# 防禦柵欄木鹿角
			elif (x == 5 or x == MAP_SIZE_X - 6 or y == 5 or y == MAP_SIZE_Y - 6) and (x % 2 == 0):
				type = TileType.PALISADE
			# 四角哨塔
			elif (x == 5 and y == 5) or (x == 26 and y == 5) or (x == 5 and y == 26) or (x == 26 and y == 26):
				type = TileType.WATCHTOWER
				
			grid_data[pos] = type

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

func _draw() -> void:
	# 依照從上到下、從左到右 (Isometric Y-Sorting) 順序繪製 2:1 菱形地塊
	for y in range(MAP_SIZE_Y):
		for x in range(MAP_SIZE_X):
			var pos := Vector2i(x, y)
			var type: int = grid_data.get(pos, TileType.GRASS)
			draw_isometric_tile(pos, type)

	# 繪製滑鼠懸浮高亮框
	if grid_data.has(hovered_grid):
		draw_tile_highlight(hovered_grid, Color(1.0, 1.0, 0.4, 0.45), Color(1.0, 0.9, 0.2, 0.9))

	# 繪製選中地塊高亮框
	if grid_data.has(selected_grid):
		draw_tile_highlight(selected_grid, Color(0.2, 0.8, 1.0, 0.5), Color(0.1, 0.9, 1.0, 1.0))

## 繪製單個 2:1 菱形地塊
func draw_isometric_tile(grid_pos: Vector2i, type: int) -> void:
	var center := grid_to_screen(grid_pos.x, grid_pos.y)
	
	var p_top := center + Vector2(0, -HALF_H)
	var p_right := center + Vector2(HALF_W, 0)
	var p_bottom := center + Vector2(0, HALF_H)
	var p_left := center + Vector2(-HALF_W, 0)
	
	var points := PackedVector2Array([p_top, p_right, p_bottom, p_left])
	
	# 依地塊類型取得配色
	var fill_color: Color
	var border_color: Color = Color(0.15, 0.15, 0.12, 0.3)
	
	match type:
		TileType.WATER:
			fill_color = Color(0.22, 0.45, 0.65, 0.95) # 蔚藍水域
			border_color = Color(0.35, 0.60, 0.85, 0.5)
		TileType.GRASS:
			fill_color = Color(0.38, 0.60, 0.28, 1.0)  # 翠綠草地
		TileType.FARMLAND:
			fill_color = Color(0.68, 0.54, 0.28, 1.0)  # 金黃耕地
		TileType.ROAD:
			fill_color = Color(0.55, 0.52, 0.45, 1.0)  # 石子寨道
		TileType.BUILDING:
			fill_color = Color(0.75, 0.32, 0.25, 1.0)  # 聚義廳朱紅地基
		TileType.PALISADE:
			fill_color = Color(0.48, 0.38, 0.22, 1.0)  # 木鹿角
		TileType.WATCHTOWER:
			fill_color = Color(0.60, 0.45, 0.30, 1.0)  # 哨塔
		_:
			fill_color = Color(0.4, 0.5, 0.3, 1.0)
			
	# 繪製菱形多邊形
	draw_colored_polygon(points, fill_color)
	
	# 繪製地塊邊界線
	draw_polyline(PackedVector2Array([p_top, p_right, p_bottom, p_left, p_top]), border_color, 1.0)
	
	# 繪製 2.5D 特殊裝飾物（如哨塔立柱、聚義堂屋簷、木鹿角）
	if type == TileType.BUILDING:
		# 聚義堂大殿
		var roof_pts := PackedVector2Array([
			center + Vector2(0, -HALF_H - 24),
			center + Vector2(HALF_W, -24),
			center + Vector2(0, HALF_H - 24),
			center + Vector2(-HALF_W, -24)
		])
		draw_colored_polygon(roof_pts, Color(0.85, 0.2, 0.15, 1.0))
		draw_polyline(PackedVector2Array([roof_pts[0], roof_pts[1], roof_pts[2], roof_pts[3], roof_pts[0]]), Color(1.0, 0.85, 0.2, 1.0), 1.5)
	elif type == TileType.WATCHTOWER:
		# 哨塔立體木樁
		draw_line(center + Vector2(-8, 0), center + Vector2(-8, -28), Color(0.35, 0.22, 0.12, 1.0), 3.0)
		draw_line(center + Vector2(8, 0), center + Vector2(8, -28), Color(0.35, 0.22, 0.12, 1.0), 3.0)
		draw_rect(Rect2(center.x - 12, center.y - 34, 24, 8), Color(0.6, 0.2, 0.1, 1.0))
	elif type == TileType.PALISADE:
		# 鹿角木樁叉
		draw_line(center + Vector2(-6, 4), center + Vector2(6, -12), Color(0.45, 0.30, 0.15, 1.0), 2.5)
		draw_line(center + Vector2(-6, -12), center + Vector2(6, 4), Color(0.45, 0.30, 0.15, 1.0), 2.5)

## 繪製地塊高亮
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
				selected_grid = clicked
				tile_clicked.emit(clicked, grid_data[clicked])
				queue_redraw()
