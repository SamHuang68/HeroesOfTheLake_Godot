# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 2D 俯視像素縮圖雷達視窗 (Floating Minimap)
class_name MinimapWindow
extends PanelContainer

var map_ref: Node2D
var camera_ref: Camera2D

func _ready() -> void:
	custom_minimum_size = Vector2(180, 210)
	build_minimap_ui()

func build_minimap_ui() -> void:
	for child in get_children():
		child.queue_free()

	var win_style := StyleBoxFlat.new()
	win_style.bg_color = Color(0.86, 0.86, 0.84, 1.0)
	win_style.border_width_left = 2
	win_style.border_width_top = 2
	win_style.border_width_right = 2
	win_style.border_width_bottom = 2
	win_style.border_color = Color(0.95, 0.95, 0.95, 1.0)
	win_style.set_content_margin_all(2.0)
	add_theme_stylebox_override("panel", win_style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)

	# 標題列
	var title_panel := PanelContainer.new()
	var title_style := StyleBoxFlat.new()
	title_style.bg_color = Color(0.0, 0.12, 0.45, 1.0)
	title_style.set_content_margin_all(2.0)
	title_panel.add_theme_stylebox_override("panel", title_style)

	var title_box := HBoxContainer.new()
	var title_lbl := Label.new()
	title_lbl.text = " 要塞地圖"
	title_lbl.add_theme_color_override("font_color", Color.WHITE)
	title_box.add_child(title_lbl)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_child(spacer)

	var close_btn := Button.new()
	close_btn.text = " X "
	close_btn.pressed.connect(func(): hide())
	title_box.add_child(close_btn)

	title_panel.add_child(title_box)
	vbox.add_child(title_panel)

	# 2D 菱形雷達畫布
	var radar_canvas := Control.new()
	radar_canvas.name = "RadarCanvas"
	radar_canvas.custom_minimum_size = Vector2(170, 150)
	radar_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	radar_canvas.draw.connect(_on_radar_draw.bind(radar_canvas))
	vbox.add_child(radar_canvas)

	# 底部關閉按鈕
	var btm_btn := Button.new()
	btm_btn.text = " 關閉 "
	btm_btn.pressed.connect(func(): hide())
	vbox.add_child(btm_btn)

	add_child(vbox)

func _process(_delta: float) -> void:
	if visible:
		var canvas: Control = find_child("RadarCanvas", true, false)
		if canvas:
			canvas.queue_redraw()

func _on_radar_draw(canvas: Control) -> void:
	var size := canvas.size
	# 繪製雷達深綠色底色
	canvas.draw_rect(Rect2(Vector2.ZERO, size), Color(0.12, 0.22, 0.12, 1.0))
	
	# 繪製等角縮略菱形地景
	var center := size / 2.0
	var diamond_pts := PackedVector2Array([
		center + Vector2(0, -50),
		center + Vector2(70, 0),
		center + Vector2(0, 50),
		center + Vector2(-70, 0)
	])
	canvas.draw_colored_polygon(diamond_pts, Color(0.35, 0.50, 0.25, 0.9)) # 草地
	
	# 中心要塞聚義廳光點
	canvas.draw_rect(Rect2(center.x - 12, center.y - 8, 24, 16), Color(0.8, 0.3, 0.2, 1.0))
	
	# 好漢光點 (黃色光點)
	canvas.draw_circle(center + Vector2(-5, 0), 3.0, Color(1.0, 0.9, 0.2, 1.0))
	canvas.draw_circle(center + Vector2(8, -4), 3.0, Color(1.0, 0.9, 0.2, 1.0))
	canvas.draw_circle(center + Vector2(2, 6), 3.0, Color(1.0, 0.9, 0.2, 1.0))

	# 當前視口白色線框 (Viewport Rect)
	var vp_rect := Rect2(center.x - 28, center.y - 18, 56, 36)
	canvas.draw_rect(vp_rect, Color.WHITE, false, 1.5)
