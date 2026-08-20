# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 人事名冊與好漢管理對話框 (Personnel Modal)
class_name PersonnelModal
extends PanelContainer

const DataManagerScript = preload("res://scripts/DataManager.gd")

signal hero_inspect_requested(hero_data: Dictionary)
signal hero_rewarded(hero_id: String, gold_amount: int)

var search_filter: String = ""
var hero_list_cache: Array = []

func _ready() -> void:
	custom_minimum_size = Vector2(560, 420)
	build_personnel_ui()

func build_personnel_ui() -> void:
	for child in get_children():
		child.queue_free()

	# 外框 Windows 98 經典凸起風格 (Bevel Grey)
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

	# 1. 視窗標題列
	var title_panel := PanelContainer.new()
	var title_style := StyleBoxFlat.new()
	title_style.bg_color = Color(0.0, 0.12, 0.45, 1.0)
	title_style.set_content_margin_all(3.0)
	title_panel.add_theme_stylebox_override("panel", title_style)

	var title_box := HBoxContainer.new()
	var title_lbl := Label.new()
	title_lbl.text = " 人事名冊 — 梁山泊一百零八星"
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

	# 2. 搜尋過濾列與操作提示
	var search_box := HBoxContainer.new()
	var slbl := Label.new()
	slbl.text = " 搜尋好漢: "
	slbl.add_theme_color_override("font_color", Color.BLACK)
	search_box.add_child(slbl)

	var sinput := LineEdit.new()
	sinput.placeholder_text = "輸入姓名、綽號或星宿..."
	sinput.custom_minimum_size = Vector2(180, 0)
	sinput.text_changed.connect(func(new_text: String):
		search_filter = new_text
		refresh_table()
	)
	search_box.add_child(sinput)

	var count_lbl := Label.new()
	count_lbl.name = "CountLabel"
	count_lbl.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	search_box.add_child(count_lbl)

	vbox.add_child(search_box)

	# 3. 表格欄位標題
	var header_panel := PanelContainer.new()
	var header_style := StyleBoxFlat.new()
	header_style.bg_color = Color(0.80, 0.80, 0.78, 1.0)
	header_style.set_content_margin_all(2.0)
	header_panel.add_theme_stylebox_override("panel", header_style)

	var header_box := HBoxContainer.new()
	var col_widths := [60, 60, 65, 45, 45, 45, 45, 45, 75]
	var col_names := ["星宿", "稱號", "姓名", "體力", "臂力", "技能", "智力", "忠義", "操作"]

	for i in range(col_names.size()):
		var clbl := Label.new()
		clbl.text = col_names[i]
		clbl.custom_minimum_size = Vector2(col_widths[i], 0)
		clbl.add_theme_color_override("font_color", Color.BLACK)
		header_box.add_child(clbl)

	header_panel.add_child(header_box)
	vbox.add_child(header_panel)

	# 4. 滾動清單容器
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var rows_vbox := VBoxContainer.new()
	rows_vbox.name = "RowsContainer"
	rows_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(rows_vbox)
	vbox.add_child(scroll)

	# 5. 底部關閉按鈕
	var btm_box := HBoxContainer.new()
	var btm_close := Button.new()
	btm_close.text = "   關閉名冊   "
	btm_close.pressed.connect(func(): hide())
	btm_box.add_child(btm_close)

	vbox.add_child(btm_box)
	add_child(vbox)

	hero_list_cache = DataManagerScript.get_all_heroes()
	refresh_table()

func refresh_table() -> void:
	var rows_vbox: VBoxContainer = find_child("RowsContainer", true, false)
	if not rows_vbox:
		return

	for child in rows_vbox.get_children():
		child.queue_free()

	var col_widths := [60, 60, 65, 45, 45, 45, 45, 45, 75]
	var count: int = 0

	for h in hero_list_cache:
		var match_str := "%s %s %s" % [h["name"], h["title"], h["star"]]
		if not search_filter.is_empty() and not match_str.contains(search_filter):
			continue

		count += 1
		var row_panel := PanelContainer.new()
		var r_style := StyleBoxFlat.new()
		r_style.bg_color = Color.WHITE if (count % 2 == 0) else Color(0.95, 0.95, 0.95, 1.0)
		r_style.set_content_margin_all(2.0)
		row_panel.add_theme_stylebox_override("panel", r_style)

		var r_box := HBoxContainer.new()

		var values := [
			h["star"], h["title"], h["name"],
			str(int(h["vitality"])), str(int(h["might"])),
			str(int(h["skill"])), str(int(h["intel"])), str(int(h["loyalty"]))
		]

		for c in range(values.size()):
			var vlbl := Label.new()
			vlbl.text = values[c]
			vlbl.custom_minimum_size = Vector2(col_widths[c], 0)
			vlbl.add_theme_color_override("font_color", Color.BLACK)
			r_box.add_child(vlbl)

		# 操作按鈕
		var act_box := HBoxContainer.new()
		act_box.custom_minimum_size = Vector2(col_widths[8], 0)

		var view_btn := Button.new()
		view_btn.text = "詳情"
		var hero_data: Dictionary = h
		view_btn.pressed.connect(func():
			hero_inspect_requested.emit(hero_data)
		)
		act_box.add_child(view_btn)

		var reward_btn := Button.new()
		reward_btn.text = "賞"
		reward_btn.pressed.connect(func():
			hero_data["loyalty"] = mini(100, hero_data["loyalty"] + 5)
			hero_rewarded.emit(hero_data["id"], 50)
			refresh_table()
		)
		act_box.add_child(reward_btn)

		r_box.add_child(act_box)
		row_panel.add_child(r_box)
		rows_vbox.add_child(row_panel)

	var count_lbl: Label = find_child("CountLabel", true, false)
	if count_lbl:
		count_lbl.text = " (共 %d 位好漢)" % count
