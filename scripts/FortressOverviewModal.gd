# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 1:1 光榮經典要塞一覽表格對話框 (Pop-up Modal)
class_name FortressOverviewModal
extends PanelContainer

var fortress_list: Array[Dictionary] = [
	{"name": "飲馬川", "region": "河北", "hero": "裴宣", "leader": "裴宣", "heroes_cnt": 3, "soldiers": 260, "pop": 800, "vitality": 69, "satisfaction": 50},
	{"name": "高唐州", "region": "河北", "hero": "高俅", "leader": "高廉", "heroes_cnt": 5, "soldiers": 360, "pop": 300, "vitality": 70, "satisfaction": 50},
	{"name": "北京",   "region": "河北", "hero": "高俅", "leader": "梁世傑", "heroes_cnt": 8, "soldiers": 600, "pop": 700, "vitality": 69, "satisfaction": 50},
	{"name": "東昌府", "region": "河北", "hero": "高俅", "leader": "張清", "heroes_cnt": 3, "soldiers": 260, "pop": 420, "vitality": 69, "satisfaction": 50},
	{"name": "凌州",   "region": "河北", "hero": "高俅", "leader": "關勝", "heroes_cnt": 5, "soldiers": 390, "pop": 1060, "vitality": 70, "satisfaction": 50},
	{"name": "青州",   "region": "山東", "hero": "高俅", "leader": "慕容彥達", "heroes_cnt": 7, "soldiers": 540, "pop": 620, "vitality": 70, "satisfaction": 50},
	{"name": "桃花山", "region": "山東", "hero": "李忠", "leader": "李忠", "heroes_cnt": 2, "soldiers": 180, "pop": 620, "vitality": 69, "satisfaction": 49},
	{"name": "清風山", "region": "山東", "hero": "燕順", "leader": "燕順", "heroes_cnt": 3, "soldiers": 260, "pop": 620, "vitality": 70, "satisfaction": 51},
	{"name": "二龍山", "region": "山東", "hero": "鄧龍", "leader": "鄧龍", "heroes_cnt": 1, "soldiers": 100, "pop": 820, "vitality": 69, "satisfaction": 50},
	{"name": "瓦罐寺", "region": "山東", "hero": "崔道成", "leader": "崔道成", "heroes_cnt": 2, "soldiers": 150, "pop": 300, "vitality": 70, "satisfaction": 50},
	{"name": "東平府", "region": "山東", "hero": "高俅", "leader": "陳文昭", "heroes_cnt": 3, "soldiers": 230, "pop": 1000, "vitality": 69, "satisfaction": 50},
	{"name": "梁山泊", "region": "山東", "hero": "林沖", "leader": "林沖", "heroes_cnt": 12, "soldiers": 1200, "pop": 3500, "vitality": 85, "satisfaction": 80}
]

func _ready() -> void:
	custom_minimum_size = Vector2(530, 390)
	build_table_ui()

func build_table_ui() -> void:
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

	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 4)

	# 1. 視窗標題列
	var title_panel := PanelContainer.new()
	var title_style := StyleBoxFlat.new()
	title_style.bg_color = Color(0.0, 0.12, 0.45, 1.0)
	title_style.set_content_margin_all(3.0)
	title_panel.add_theme_stylebox_override("panel", title_style)
	
	var title_box := HBoxContainer.new()
	var title_lbl := Label.new()
	title_lbl.text = " 要塞一覽"
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
	main_vbox.add_child(title_panel)

	# 2. 九大表格欄位標題 (要塞 | 地區 | 好漢 | 首領 | 好漢數 | 士兵數 | 人口 | 活力 | 滿足度)
	var header_panel := PanelContainer.new()
	var header_style := StyleBoxFlat.new()
	header_style.bg_color = Color(0.80, 0.80, 0.78, 1.0)
	header_style.set_content_margin_all(2.0)
	header_panel.add_theme_stylebox_override("panel", header_style)

	var header_box := HBoxContainer.new()
	var col_widths := [65, 55, 65, 65, 50, 55, 55, 45, 50]
	var col_names := ["要塞", "地區", "好漢", "首領", "好漢數", "士兵數", "人口", "活力", "滿足度"]

	for i in range(col_names.size()):
		var clbl := Label.new()
		clbl.text = col_names[i]
		clbl.custom_minimum_size = Vector2(col_widths[i], 0)
		clbl.add_theme_color_override("font_color", Color.BLACK)
		header_box.add_child(clbl)

	header_panel.add_child(header_box)
	main_vbox.add_child(header_panel)

	# 3. 滾動資料列清單 (Scrollable Rows)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var rows_vbox := VBoxContainer.new()
	rows_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	for idx in range(fortress_list.size()):
		var f := fortress_list[idx]
		var row_panel := PanelContainer.new()
		var r_style := StyleBoxFlat.new()
		r_style.bg_color = Color.WHITE if (idx % 2 == 0) else Color(0.95, 0.95, 0.95, 1.0)
		r_style.set_content_margin_all(2.0)
		row_panel.add_theme_stylebox_override("panel", r_style)

		var r_box := HBoxContainer.new()
		var values := [
			f["name"], f["region"], f["hero"], f["leader"],
			str(f["heroes_cnt"]), str(f["soldiers"]), str(f["pop"]),
			str(f["vitality"]), str(f["satisfaction"])
		]

		for c in range(values.size()):
			var vlbl := Label.new()
			vlbl.text = values[c]
			vlbl.custom_minimum_size = Vector2(col_widths[c], 0)
			vlbl.add_theme_color_override("font_color", Color.BLACK)
			r_box.add_child(vlbl)

		row_panel.add_child(r_box)
		rows_vbox.add_child(row_panel)

	scroll.add_child(rows_vbox)
	main_vbox.add_child(scroll)

	# 4. 底部操作按鈕 (關閉 / 切換)
	var bottom_box := HBoxContainer.new()
	var close_btm_btn := Button.new()
	close_btm_btn.text = "   關閉   "
	close_btm_btn.pressed.connect(func(): hide())
	bottom_box.add_child(close_btm_btn)

	var btm_spacer := Control.new()
	btm_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_box.add_child(btm_spacer)

	var switch_btn := Button.new()
	switch_btn.text = "   切換   "
	bottom_box.add_child(switch_btn)

	main_vbox.add_child(bottom_box)
	add_child(main_vbox)
