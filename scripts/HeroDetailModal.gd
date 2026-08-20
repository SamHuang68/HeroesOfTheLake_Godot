# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 1:1 光榮經典好漢詳細能力與列傳對話框 (Pop-up Modal)
class_name HeroDetailModal
extends PanelContainer

var current_hero_data: Dictionary = {
	"name": "林沖",
	"title": "豹子頭",
	"action": "現在正在山東搜索",
	"portrait": "portrait_linchong.jpg",
	"might": 92.0,
	"skill": 85.0,
	"intel": 69.0,
	"stamina_curr": 95,
	"stamina_max": 95,
	"loyalty": 91,
	"benevolence": 82,
	"courage": 86,
	"allegiance": -1, # --
	"bio": "【天雄星 · 豹子頭 林沖】\n梁山馬軍五虎將之首，生得豹頭環眼、燕頷虎鬚，人稱小張飛。原為東京八十萬禁軍槍棒教頭，武藝高強，擅使丈八蛇矛。\n因遭太尉高俅陷害發配滄州，後於草料場風雪夜手刃陸謙、富安，上梁山大聚義，威震天下！"
}

var current_tab: int = 0 # 0: 能力, 1: 狀態, 2: 關係, 3: 士兵, 4: 物品, 5: 列傳
var content_container: VBoxContainer

func _ready() -> void:
	custom_minimum_size = Vector2(430, 520)
	build_window_ui()

func build_window_ui() -> void:
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
	main_vbox.add_theme_constant_override("separation", 6)

	# 1. 視窗標題列
	var title_panel := PanelContainer.new()
	var title_style := StyleBoxFlat.new()
	title_style.bg_color = Color(0.0, 0.12, 0.45, 1.0)
	title_style.set_content_margin_all(3.0)
	title_panel.add_theme_stylebox_override("panel", title_style)
	
	var title_box := HBoxContainer.new()
	var title_lbl := Label.new()
	title_lbl.text = " 流浪"
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

	# 2. 頂部好漢立繪與風光意境橫幅 (Scenic Hero Banner)
	var banner_panel := PanelContainer.new()
	banner_panel.custom_minimum_size = Vector2(0, 140)
	var banner_style := StyleBoxFlat.new()
	banner_style.bg_color = Color(0.35, 0.45, 0.50, 1.0)
	banner_style.border_color = Color(0.15, 0.15, 0.15, 1.0)
	banner_style.border_width_bottom = 2
	banner_panel.add_theme_stylebox_override("panel", banner_style)

	var banner_box := HBoxContainer.new()
	banner_box.set_anchors_preset(Control.PRESET_FULL_RECT)

	# 左側蘆葦湖畔風光文字
	var scenic_lbl := Label.new()
	scenic_lbl.text = " 🌾 水泊潯陽江畔 · 蘆花飄蕩\n 遠山疊翠 · 英雄雲集"
	scenic_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.85))
	banner_box.add_child(scenic_lbl)

	var banner_spacer := Control.new()
	banner_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	banner_box.add_child(banner_spacer)

	# 右側好漢立繪頭像 (Portrait TextureRect)
	var portrait_rect := TextureRect.new()
	portrait_rect.custom_minimum_size = Vector2(110, 130)
	portrait_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	
	# 嘗試載入轉移過來的 211 好漢頭像
	var portrait_path := "res://assets/portraits/%s" % current_hero_data["portrait"]
	if ResourceLoader.exists(portrait_path):
		portrait_rect.texture = load(portrait_path)
	banner_box.add_child(portrait_rect)

	banner_panel.add_child(banner_box)
	main_vbox.add_child(banner_panel)

	# 3. 好漢稱號、姓名與當前行動狀態
	var name_lbl := Label.new()
	name_lbl.text = " %s  %s" % [current_hero_data["title"], current_hero_data["name"]]
	name_lbl.add_theme_color_override("font_color", Color.BLACK)
	main_vbox.add_child(name_lbl)

	var action_lbl := Label.new()
	action_lbl.text = " %s" % current_hero_data["action"]
	action_lbl.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
	main_vbox.add_child(action_lbl)

	# 4. 六大分頁標籤導航 (能力 | 狀態 | 關係 | 士兵 | 物品 | 列傳)
	var tab_box := HBoxContainer.new()
	var tab_names := ["能力", "狀態", "關係", "士兵", "物品", "列傳"]
	for i in range(tab_names.size()):
		var tbtn := Button.new()
		tbtn.text = " %s " % tab_names[i]
		var idx := i
		tbtn.pressed.connect(func(): switch_tab(idx))
		tab_box.add_child(tbtn)
		
	main_vbox.add_child(tab_box)

	# 5. 屬性內容面板
	content_container = VBoxContainer.new()
	content_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(content_container)

	add_child(main_vbox)
	update_tab_content()

func switch_tab(tab_idx: int) -> void:
	current_tab = tab_idx
	update_tab_content()

func update_tab_content() -> void:
	if not content_container: return
	for child in content_container.get_children():
		child.queue_free()

	if current_tab == 0: # 能力 (Exact 1:1 KOEI Layout with Blue Segmented Bars)
		content_container.add_child(create_stat_row("臂力", current_hero_data["might"], 9, "忠義", current_hero_data["loyalty"], 9))
		content_container.add_child(create_stat_row("技能", current_hero_data["skill"], 9, "仁愛", current_hero_data["benevolence"], 8))
		content_container.add_child(create_stat_row("智力", current_hero_data["intel"], 7, "勇氣", current_hero_data["courage"], 9))
		content_container.add_child(create_stat_row("體力", current_hero_data["stamina_curr"], 10, "忠誠", current_hero_data["allegiance"], 0, true))
	elif current_tab == 5: # 列傳
		var bio_scroll := ScrollContainer.new()
		bio_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var bio_lbl := Label.new()
		bio_lbl.text = current_hero_data["bio"]
		bio_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		bio_lbl.add_theme_color_override("font_color", Color.BLACK)
		bio_scroll.add_child(bio_lbl)
		content_container.add_child(bio_scroll)
	else:
		var extra_lbl := Label.new()
		extra_lbl.text = "職業：槍棒教頭 | 兵種適性：騎兵(S) 步兵(A) 水軍(B) 弓弩(A)\n裝備神兵：丈八蛇矛 (+18 臂力) | 名駒：踢雪烏騅馬\n統率部隊：梁山第一先鋒軍 (統兵 1,000)"
		extra_lbl.add_theme_color_override("font_color", Color.BLACK)
		content_container.add_child(extra_lbl)

func create_stat_row(name1: String, val1: float, bar1_cnt: int, name2: String, val2: float, bar2_cnt: int, is_stamina: bool = false) -> HBoxContainer:
	var row := HBoxContainer.new()

	# 藍色段狀方塊條
	var bar1_str := ""
	for i in range(bar1_cnt): bar1_str += "■"
	for i in range(10 - bar1_cnt): bar1_str += "  "

	var bar2_str := ""
	for i in range(bar2_cnt): bar2_str += "■"
	for i in range(10 - bar2_cnt): bar2_str += "  "

	var val1_str := "%d/%d" % [int(val1), current_hero_data["stamina_max"]] if is_stamina else "%.2f" % val1
	var val2_str := "--" if val2 < 0 else "%d" % int(val2)

	# 左側屬性
	var l_name := Label.new()
	l_name.text = "%s: " % name1
	l_name.add_theme_color_override("font_color", Color.BLACK)
	row.add_child(l_name)

	var l_bar := Label.new()
	l_bar.text = bar1_str
	l_bar.add_theme_color_override("font_color", Color(0.2, 0.55, 0.95))
	row.add_child(l_bar)

	var l_val := Label.new()
	l_val.text = " %s" % val1_str
	l_val.add_theme_color_override("font_color", Color.BLACK)
	row.add_child(l_val)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)

	# 右側屬性
	var r_name := Label.new()
	r_name.text = "%s: " % name2
	r_name.add_theme_color_override("font_color", Color.BLACK)
	row.add_child(r_name)

	var r_bar := Label.new()
	r_bar.text = bar2_str
	r_bar.add_theme_color_override("font_color", Color(0.2, 0.55, 0.95))
	row.add_child(r_bar)

	var r_val := Label.new()
	r_val.text = " %s" % val2_str
	r_val.add_theme_color_override("font_color", Color.BLACK)
	row.add_child(r_val)

	return row

func display_hero(hero_data: Dictionary) -> void:
	current_hero_data = hero_data
	build_window_ui()
	show()
