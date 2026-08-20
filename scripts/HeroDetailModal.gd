# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 好漢詳細能力 1:1 風光立繪對話框 (Hero Detail Modal)
class_name HeroDetailModal
extends PanelContainer

const DataManagerScript = preload("res://scripts/DataManager.gd")

var current_hero: Dictionary = {}
var current_tab: int = 0 # 0:能力, 1:狀態, 2:關係, 3:士兵, 4:物品, 5:列傳

func _ready() -> void:
	custom_minimum_size = Vector2(430, 520)
	var default_hero := DataManagerScript.get_hero("LinChong")
	display_hero(default_hero)

func display_hero(hero_data: Dictionary) -> void:
	if hero_data.is_empty():
		return
	current_hero = hero_data
	build_hero_ui()
	show()

func build_hero_ui() -> void:
	for child in get_children():
		child.queue_free()

	# 外框 Windows 98 凸起邊框
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
	vbox.add_theme_constant_override("separation", 3)

	# 1. 頂部標題列
	var title_panel := PanelContainer.new()
	var title_style := StyleBoxFlat.new()
	title_style.bg_color = Color(0.0, 0.12, 0.45, 1.0)
	title_style.set_content_margin_all(3.0)
	title_panel.add_theme_stylebox_override("panel", title_style)

	var title_box := HBoxContainer.new()
	var title_lbl := Label.new()
	title_lbl.text = " 好漢情報 — %s %s" % [current_hero.get("title", "天雄星"), current_hero.get("name", "林沖")]
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

	# 2. 水泊風光橫幅與好漢立繪區
	var banner_panel := PanelContainer.new()
	banner_panel.custom_minimum_size = Vector2(0, 140)
	var banner_style := StyleBoxFlat.new()
	banner_style.bg_color = Color(0.15, 0.25, 0.35, 1.0)
	banner_panel.add_theme_stylebox_override("panel", banner_style)

	var banner_box := HBoxContainer.new()
	banner_box.add_theme_constant_override("separation", 10)

	# 左側立繪
	var portrait_rect := TextureRect.new()
	portrait_rect.custom_minimum_size = Vector2(100, 130)
	portrait_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	var p_file: String = current_hero.get("portrait", "")
	var p_path := "res://assets/portraits/%s" % p_file
	if ResourceLoader.exists(p_path):
		portrait_rect.texture = load(p_path)
	elif ResourceLoader.exists("res://assets/portraits/portrait_linchong.jpg"):
		portrait_rect.texture = load("res://assets/portraits/portrait_linchong.jpg")

	banner_box.add_child(portrait_rect)

	# 右側水泊風光詩詞與基本稱號
	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name_lbl := Label.new()
	name_lbl.text = "【%s】 %s" % [current_hero.get("star", "天雄星"), current_hero.get("name", "林沖")]
	name_lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	info_vbox.add_child(name_lbl)

	var title_desc := Label.new()
	title_desc.text = "稱號：%s  |  星宿：%s" % [current_hero.get("title", "豹子頭"), current_hero.get("star", "天雄星")]
	title_desc.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	info_vbox.add_child(title_desc)

	var status_quick := Label.new()
	status_quick.text = "體力: %d / %d  |  忠義: %d" % [current_hero.get("stamina_curr", 94), current_hero.get("stamina_max", 95), current_hero.get("loyalty", 90)]
	status_quick.add_theme_color_override("font_color", Color(0.6, 0.9, 0.6))
	info_vbox.add_child(status_quick)

	banner_box.add_child(info_vbox)
	banner_panel.add_child(banner_box)
	vbox.add_child(banner_panel)

	# 3. 六大分頁標籤按鈕 (能力 / 狀態 / 關係 / 士兵 / 物品 / 列傳)
	var tabs_box := HBoxContainer.new()
	var tab_names := ["能力", "狀態", "關係", "士兵", "物品", "列傳"]

	for i in range(tab_names.size()):
		var t_idx := i
		var t_btn := Button.new()
		t_btn.text = " %s " % tab_names[i]
		t_btn.flat = (current_tab != i)
		t_btn.pressed.connect(func():
			current_tab = t_idx
			build_hero_ui()
		)
		tabs_box.add_child(t_btn)

	vbox.add_child(tabs_box)

	# 4. 分頁詳細內容區
	var content_panel := PanelContainer.new()
	content_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var c_style := StyleBoxFlat.new()
	c_style.bg_color = Color.WHITE
	c_style.set_content_margin_all(6.0)
	content_panel.add_theme_stylebox_override("panel", c_style)

	match current_tab:
		0: content_panel.add_child(build_tab_ability())
		1: content_panel.add_child(build_tab_status())
		2: content_panel.add_child(build_tab_relations())
		3: content_panel.add_child(build_tab_military())
		4: content_panel.add_child(build_tab_items())
		5: content_panel.add_child(build_tab_biography())

	vbox.add_child(content_panel)

	# 5. 底部關閉
	var btm_box := HBoxContainer.new()
	var bclose := Button.new()
	bclose.text = "   關閉情報   "
	bclose.pressed.connect(func(): hide())
	btm_box.add_child(bclose)
	vbox.add_child(btm_box)

	add_child(vbox)

func build_tab_ability() -> VBoxContainer:
	var avbox := VBoxContainer.new()
	var stats := [
		{"name": "體力 (Vitality)", "val": current_hero.get("vitality", 94.0), "max": 100},
		{"name": "臂力 (Might)", "val": current_hero.get("might", 96.0), "max": 100},
		{"name": "技能 (Skill)", "val": current_hero.get("skill", 90.0), "max": 100},
		{"name": "智力 (Intellect)", "val": current_hero.get("intel", 70.0), "max": 100},
		{"name": "忠義 (Loyalty)", "val": current_hero.get("loyalty", 90), "max": 100},
		{"name": "仁德 (Benevolence)", "val": current_hero.get("benevolence", 85), "max": 100},
		{"name": "勇氣 (Courage)", "val": current_hero.get("courage", 95), "max": 100}
	]

	for st in stats:
		var row := HBoxContainer.new()
		var lbl := Label.new()
		lbl.text = "%s: %d" % [st["name"], int(st["val"])]
		lbl.custom_minimum_size = Vector2(160, 0)
		lbl.add_theme_color_override("font_color", Color.BLACK)
		row.add_child(lbl)

		var bar := ProgressBar.new()
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.max_value = st["max"]
		bar.value = st["val"]
		row.add_child(bar)
		avbox.add_child(row)

	return avbox

func build_tab_status() -> VBoxContainer:
	var svbox := VBoxContainer.new()
	var labels := [
		"所在要塞：梁山泊水泊總寨",
		"所屬陣營：梁山泊義軍 (宋江 · 林沖)",
		"指派職能：先鋒馬軍大都督 · 巡哨防衛",
		"月領俸祿：20 黃金 / 月",
		"身心狀態：精力充沛 · 鬥志昂揚",
		"聲望威名：威震山東八百里"
	]
	for txt in labels:
		var l := Label.new()
		l.text = "• " + txt
		l.add_theme_color_override("font_color", Color.BLACK)
		svbox.add_child(l)
	return svbox

func build_tab_relations() -> VBoxContainer:
	var rvbox := VBoxContainer.new()
	var rels := [
		"🤝 結拜義兄弟：【花和尚 魯智深】(生死之交)",
		"🤝 摯友至交：【行者 武松】、【小旋風 柴進】",
		"⚔️ 宿敵仇讎：【太尉 高俅】、【高衙內】、【陸謙】",
		"👥 麾下副將：【操刀鬼 曹正】、【摸著天 杜遷】"
	]
	for txt in rels:
		var l := Label.new()
		l.text = txt
		l.add_theme_color_override("font_color", Color(0.1, 0.2, 0.6))
		rvbox.add_child(l)
	return rvbox

func build_tab_military() -> VBoxContainer:
	var mvbox := VBoxContainer.new()
	var aptitudes := [
		{"name": "🐎 騎兵適性", "rank": "S (神級突破)", "val": 98},
		{"name": "🛡️ 步兵適性", "rank": "A (精通攻防)", "val": 88},
		{"name": "⛵ 水軍適性", "rank": "B (熟練水戰)", "val": 75},
		{"name": "🏹 弓弩適性", "rank": "A (善使強弓)", "val": 85}
	]
	for apt in aptitudes:
		var row := HBoxContainer.new()
		var l := Label.new()
		l.text = "%s: %s" % [apt["name"], apt["rank"]]
		l.custom_minimum_size = Vector2(170, 0)
		l.add_theme_color_override("font_color", Color.BLACK)
		row.add_child(l)

		var bar := ProgressBar.new()
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.max_value = 100
		bar.value = apt["val"]
		row.add_child(bar)
		mvbox.add_child(row)
	return mvbox

func build_tab_items() -> VBoxContainer:
	var ivbox := VBoxContainer.new()
	var items := [
		"🗡️ 裝備神兵：【丈八蛇矛】(臂力 +10, 附帶突擊連擊)",
		"🛡️ 護身寶甲：【烏油連環鎧】(防禦 +15, 抵禦弓矢)",
		"🐎 絕世坐騎：【照夜玉獅子】(行軍速度 +30%)",
		"📜 隨身寶典：【太玄經殘卷】(智力 +5)"
	]
	for item_txt in items:
		var l := Label.new()
		l.text = item_txt
		l.add_theme_color_override("font_color", Color(0.6, 0.3, 0.0))
		ivbox.add_child(l)
	return ivbox

func build_tab_biography() -> VBoxContainer:
	var bvbox := VBoxContainer.new()
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var bio_lbl := Label.new()
	bio_lbl.text = current_hero.get("bio", "梁山好漢生平列傳...")
	bio_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bio_lbl.add_theme_color_override("font_color", Color(0.15, 0.15, 0.15))
	scroll.add_child(bio_lbl)

	bvbox.add_child(scroll)
	return bvbox
