# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 2.5D 等角沙盤要塞小地圖雷達 (Minimap Window)
class_name MinimapWindow
extends PanelContainer

var map_ref: Node2D = null
var camera_ref: Camera2D = null

func _ready() -> void:
	custom_minimum_size = Vector2(180, 200)
	build_minimap_ui()

func _process(_delta: float) -> void:
	var radar: Control = find_child("MinimapRadar", true, false)
	if radar:
		radar.queue_redraw()

func build_minimap_ui() -> void:
	for child in get_children():
		child.queue_free()

	# 外框 Windows 98 凸起風格
	var win_style := StyleBoxFlat.new()
	win_style.bg_color = Color(0.86, 0.86, 0.84, 1.0)
	win_style.border_width_left = 3
	win_style.border_width_top = 3
	win_style.border_width_right = 3
	win_style.border_width_bottom = 3
	win_style.border_color = Color(0.95, 0.95, 0.95, 1.0)
	win_style.shadow_size = 4
	win_style.shadow_color = Color(0.0, 0.0, 0.0, 0.3)
	win_style.set_content_margin_all(2.0)
	add_theme_stylebox_override("panel", win_style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)

	# 1. 標題列
	var title_panel := PanelContainer.new()
	var title_style := StyleBoxFlat.new()
	title_style.bg_color = Color(0.0, 0.12, 0.45, 1.0)
	title_style.set_content_margin_all(2.0)
	title_panel.add_theme_stylebox_override("panel", title_style)

	var title_box := HBoxContainer.new()
	var title_lbl := Label.new()
	title_lbl.text = " 要塞全圖 [地]"
	title_lbl.add_theme_color_override("font_color", Color.WHITE)
	title_box.add_child(title_lbl)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_child(spacer)

	var close_btn := Button.new()
	close_btn.text = " - "
	close_btn.pressed.connect(func(): hide())
	title_box.add_child(close_btn)

	title_panel.add_child(title_box)
	vbox.add_child(title_panel)

	# 2. 縮圖繪製核心區
	var radar := Control.new()
	radar.name = "MinimapRadar"
	radar.custom_minimum_size = Vector2(174, 165)
	radar.draw.connect(_on_draw_radar.bind(radar))
	radar.gui_input.connect(_on_radar_gui_input.bind(radar))
	vbox.add_child(radar)

	add_child(vbox)

func _on_draw_radar(radar: Control) -> void:
	var r_size := radar.size
	# 繪製雷達底色 (深色山寨全景)
	radar.draw_rect(Rect2(Vector2.ZERO, r_size), Color(0.08, 0.10, 0.15, 1.0))

	if not map_ref:
		return

	var g_data: Dictionary = map_ref.get("grid_data")
	var r_grid: Dictionary = map_ref.get("road_grid")
	if not g_data:
		return

	var center := Vector2(r_size.x / 2.0, r_size.y / 2.0)
	var scale_factor: float = 2.4

	# 繪製真實等角網格地貌
	for pos in g_data.keys():
		var gx: int = pos.x
		var gy: int = pos.y
		var sx: float = (gx - gy) * (scale_factor * 1.0) + center.x
		var sy: float = (gx + gy) * (scale_factor * 0.5) + 18.0

		var type: int = g_data[pos]
		var col := Color(0.35, 0.60, 0.25, 1.0)
		match type:
			0: col = Color(0.20, 0.45, 0.70, 1.0) # 水泊
			1: col = Color(0.35, 0.60, 0.25, 1.0) # 草地
			2: col = Color(0.70, 0.55, 0.22, 1.0) # 農田
			4: col = Color(0.72, 0.60, 0.45, 1.0) # 聚義基底
			5: col = Color(0.20, 0.42, 0.18, 1.0) # 密林苔原

		if r_grid and r_grid.get(pos, false):
			col = Color(0.65, 0.58, 0.48, 1.0) # 道路

		radar.draw_rect(Rect2(sx - 1.5, sy - 1.0, 3.0, 2.0), col)

	# 繪製設施標記
	var facs_container: Node2D = map_ref.get_node_or_null("Facilities")
	if facs_container:
		for f in facs_container.get_children():
			var gpos: Vector2i = f.get("grid_coord")
			var f_sx: float = (gpos.x - gpos.y) * (scale_factor * 1.0) + center.x
			var f_sy: float = (gpos.x + gpos.y) * (scale_factor * 0.5) + 18.0
			var ftype: String = f.get("facility_type")

			if ftype == "MainHall":
				radar.draw_rect(Rect2(f_sx - 4, f_sy - 3, 8, 6), Color(0.95, 0.20, 0.15, 1.0))
			elif ftype == "Shipyard":
				radar.draw_rect(Rect2(f_sx - 3, f_sy - 2, 6, 4), Color(0.2, 0.75, 0.95, 1.0))
			else:
				radar.draw_rect(Rect2(f_sx - 2, f_sy - 2, 4, 4), Color(1.0, 0.85, 0.25, 1.0))

	# 繪製好漢角色位置 (綠點)
	var chars_container: Node2D = map_ref.get_node_or_null("Characters")
	if chars_container:
		for c in chars_container.get_children():
			var c_gpos: Vector2i = c.get("grid_position")
			var c_sx: float = (c_gpos.x - c_gpos.y) * (scale_factor * 1.0) + center.x
			var c_sy: float = (c_gpos.x + c_gpos.y) * (scale_factor * 0.5) + 18.0
			radar.draw_circle(Vector2(c_sx, c_sy), 2.5, Color(0.3, 1.0, 0.4, 1.0))

	# 繪製攝影機視野框
	if camera_ref:
		var cam_pos: Vector2 = camera_ref.position
		var cam_grid: Vector2i = map_ref.call("screen_to_grid", cam_pos)
		var cam_sx: float = (cam_grid.x - cam_grid.y) * (scale_factor * 1.0) + center.x
		var cam_sy: float = (cam_grid.x + cam_grid.y) * (scale_factor * 0.5) + 18.0
		radar.draw_rect(Rect2(cam_sx - 16, cam_sy - 10, 32, 20), Color.WHITE, false, 1.5)

func _on_radar_gui_input(event: InputEvent, radar: Control) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var r_size := radar.size
		var center := Vector2(r_size.x / 2.0, r_size.y / 2.0)
		var click_pos: Vector2 = event.position
		var scale_factor: float = 2.4

		var rx: float = (click_pos.x - center.x) / (scale_factor * 1.0)
		var ry: float = (click_pos.y - 18.0) / (scale_factor * 0.5)

		var gx: float = (rx + ry) / 2.0
		var gy: float = (ry - rx) / 2.0

		if map_ref and camera_ref:
			var target_screen: Vector2 = map_ref.call("grid_to_screen", gx, gy)
			camera_ref.position = target_screen
