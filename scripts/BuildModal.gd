# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 設施營建與要塞開發對話框 (Build Modal)
class_name BuildModal
extends PanelContainer

const DataManagerScript = preload("res://scripts/DataManager.gd")

signal facility_chosen_to_build(facility_data: Dictionary)

var facilities_list: Array = []

func _ready() -> void:
	custom_minimum_size = Vector2(500, 400)
	build_ui()

func build_ui() -> void:
	for child in get_children():
		child.queue_free()

	# 外框 Windows 98 經典風格
	var win_style := StyleBoxFlat.new()
	win_style.bg_color = Color(0.86, 0.86, 0.84, 1.0)
	win_style.border_width_left = 3
	win_style.border_width_top = 3
	win_style.border_width_right = 3
	win_style.border_width_bottom = 3
	win_style.border_color = Color(0.95, 0.95, 0.95, 1.0)
	win_style.shadow_size = 6
	win_style.shadow_color = Color(0.0, 0.0, 0.0, 0.4)
	win_style.set_content_margin_all(3.0)
	add_theme_stylebox_override("panel", win_style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)

	# 1. 標題列
	var title_panel := PanelContainer.new()
	var title_style := StyleBoxFlat.new()
	title_style.bg_color = Color(0.0, 0.12, 0.45, 1.0)
	title_style.set_content_margin_all(3.0)
	title_panel.add_theme_stylebox_override("panel", title_style)

	var title_box := HBoxContainer.new()
	var title_lbl := Label.new()
	title_lbl.text = " 要塞營造開發 — 建造聚義設施"
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

	# 說明文字
	var hint_lbl := Label.new()
	hint_lbl.text = " 點選欲建造之設施，隨後在地圖草地或空地上點擊即可建造："
	hint_lbl.add_theme_color_override("font_color", Color.BLACK)
	vbox.add_child(hint_lbl)

	# 2. 設施列表
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var rows_vbox := VBoxContainer.new()
	rows_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var f_db: Dictionary = DataManagerScript.facilities_db
	var idx: int = 0
	for k in f_db.keys():
		var f: Dictionary = f_db[k]
		idx += 1

		var item_panel := PanelContainer.new()
		var item_style := StyleBoxFlat.new()
		item_style.bg_color = Color.WHITE if (idx % 2 == 0) else Color(0.95, 0.95, 0.95, 1.0)
		item_style.set_content_margin_all(4.0)
		item_panel.add_theme_stylebox_override("panel", item_style)

		var ibox := HBoxContainer.new()

		var name_lbl := Label.new()
		name_lbl.text = " 🏛️ %s" % f["name"]
		name_lbl.custom_minimum_size = Vector2(90, 0)
		name_lbl.add_theme_color_override("font_color", Color.BLACK)
		ibox.add_child(name_lbl)

		var cost_lbl := Label.new()
		cost_lbl.text = "金:%d 糧:%d" % [f["cost_gold"], f["cost_food"]]
		cost_lbl.custom_minimum_size = Vector2(100, 0)
		cost_lbl.add_theme_color_override("font_color", Color(0.7, 0.3, 0.0))
		ibox.add_child(cost_lbl)

		var desc_lbl := Label.new()
		desc_lbl.text = f["desc"]
		desc_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		desc_lbl.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
		ibox.add_child(desc_lbl)

		var build_btn := Button.new()
		build_btn.text = " 建造 "
		var fac_data: Dictionary = f
		build_btn.pressed.connect(func():
			facility_chosen_to_build.emit(fac_data)
			hide()
		)
		ibox.add_child(build_btn)

		item_panel.add_child(ibox)
		rows_vbox.add_child(item_panel)

	scroll.add_child(rows_vbox)
	vbox.add_child(scroll)

	# 底部
	var btm_box := HBoxContainer.new()
	var bclose := Button.new()
	bclose.text = "   取消   "
	bclose.pressed.connect(func(): hide())
	btm_box.add_child(bclose)
	vbox.add_child(btm_box)

	add_child(vbox)
