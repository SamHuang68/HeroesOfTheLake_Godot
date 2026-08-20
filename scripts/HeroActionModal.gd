# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 00~36 好漢指令、設施勞作與戰鬥技能面板 (Hero Action Modal)
class_name HeroActionModal
extends PanelContainer

signal hero_job_changed(hero: Node2D, job_name: String)
signal hero_reward_clicked(hero: Node2D, gold_cost: int)
signal hero_full_detail_requested(hero_name: String)

var current_hero: Node2D = null

func _ready() -> void:
	custom_minimum_size = Vector2(460, 420)
	build_ui()

func display_hero(hero_node: Node2D) -> void:
	current_hero = hero_node
	build_ui()
	show()

func build_ui() -> void:
	for child in get_children():
		child.queue_free()

	if not current_hero:
		return

	var win_style := StyleBoxFlat.new()
	win_style.bg_color = Color(0.88, 0.86, 0.82, 1.0)
	win_style.border_width_left = 3
	win_style.border_width_top = 3
	win_style.border_width_right = 3
	win_style.border_width_bottom = 3
	win_style.border_color = Color(0.1, 0.2, 0.45, 1.0) # 深藍邊框
	win_style.shadow_size = 6
	win_style.shadow_color = Color(0.0, 0.0, 0.0, 0.4)
	win_style.set_content_margin_all(6.0)
	add_theme_stylebox_override("panel", win_style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)

	# 1. 標題列
	var title_panel := PanelContainer.new()
	var title_style := StyleBoxFlat.new()
	title_style.bg_color = Color(0.0, 0.12, 0.45, 1.0)
	title_style.set_content_margin_all(4.0)
	title_panel.add_theme_stylebox_override("panel", title_style)

	var title_box := HBoxContainer.new()
	var title_lbl := Label.new()
	var h_name: String = current_hero.get("hero_name")
	var h_title: String = current_hero.get("title_name") if current_hero.get("title_name") != null else "好漢"
	var m_id: String = current_hero.get("model_id") if current_hero.get("model_id") != null else "00"
	var is_fem: bool = current_hero.get("is_female") if current_hero.get("is_female") != null else false
	var gender_tag := " ♀ [女將]" if is_fem else " ♂ [男將]"

	title_lbl.text = " 👤 好漢指令 — 【%s %s】 (模型: %s)%s" % [h_title, h_name, m_id, gender_tag]
	title_lbl.add_theme_color_override("font_color", Color.WHITE)
	title_box.add_child(title_lbl)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_child(spacer)

	var close_btn := Button.new()
	close_btn.text = " ✕ "
	close_btn.pressed.connect(func(): hide())
	title_box.add_child(close_btn)

	title_panel.add_child(title_box)
	vbox.add_child(title_panel)

	# 2. 狀態與當前動作
	var stat_panel := PanelContainer.new()
	var sstyle := StyleBoxFlat.new()
	sstyle.bg_color = Color.WHITE
	sstyle.set_content_margin_all(6.0)
	stat_panel.add_theme_stylebox_override("panel", sstyle)

	var svbox := VBoxContainer.new()
	var stam: int = current_hero.get("current_stamina") if current_hero.get("current_stamina") != null else 100
	var max_stam: int = current_hero.get("max_stamina") if current_hero.get("max_stamina") != null else 100
	var job: String = current_hero.get("assigned_facility_type") if current_hero.get("assigned_facility_type") != null else "待命"

	var stat_lbl := Label.new()
	stat_lbl.text = "當前體力：%d / %d  |  指派動態狀態：【%s】" % [stam, max_stam, job]
	stat_lbl.add_theme_color_override("font_color", Color.BLACK)
	svbox.add_child(stat_lbl)
	stat_panel.add_child(svbox)
	vbox.add_child(stat_panel)

	# 3. 設施工作動作 (10 大設施工作循環)
	var work_lbl := Label.new()
	work_lbl.text = " 🔨 派遣至各設施工作 (即時觸發 3D 動態模型工作姿態)："
	work_lbl.add_theme_color_override("font_color", Color.BLACK)
	vbox.add_child(work_lbl)

	var w_grid := GridContainer.new()
	w_grid.columns = 5
	w_grid.add_theme_constant_override("h_separation", 4)
	w_grid.add_theme_constant_override("v_separation", 4)

	var work_items := [
		{"name": "🍺 豪飲", "type": "tavern"},
		{"name": "🌾 種田", "type": "farmland"},
		{"name": "🐟 捕魚", "type": "fishery"},
		{"name": "⚖️ 買賣", "type": "market"},
		{"name": "🔨 打鐵", "type": "blacksmith"},
		{"name": "⛵ 修船", "type": "shipyard"},
		{"name": "📜 讀經", "type": "taoist_temple"},
		{"name": "💊 煉丹", "type": "pharmacy"},
		{"name": "🎭 遊樂", "type": "downtown"},
		{"name": "🐎 養馬", "type": "pasture"}
	]

	for wi in work_items:
		var btn := Button.new()
		btn.text = wi["name"]
		var wtype: String = wi["type"]
		btn.pressed.connect(func():
			if current_hero.has_method("play_facility_work"):
				current_hero.call("play_facility_work", wtype)
			hero_job_changed.emit(current_hero, wtype)
			build_ui()
		)
		w_grid.add_child(btn)

	vbox.add_child(w_grid)

	# 4. 戰鬥與技能指令 (攻擊 / 破壞 / 高昂 / 施法 / 色誘)
	var skill_lbl := Label.new()
	skill_lbl.text = " ⚔️ 戰鬥與技能動作 (含女性專屬色誘與男性防呆轉換)："
	skill_lbl.add_theme_color_override("font_color", Color.BLACK)
	vbox.add_child(skill_lbl)

	var s_box := HBoxContainer.new()
	s_box.add_theme_constant_override("separation", 4)

	var skill_items := [
		{"name": "⚔️ 揮砍攻擊", "type": "attack"},
		{"name": "💥 攻擊破壞", "type": "raze"},
		{"name": "🚩 士氣高昂", "type": "morale"},
		{"name": "⚡ 奇門施法", "type": "magic"},
		{"name": "💋 絕技·色誘", "type": "seduce"}
	]

	for si in skill_items:
		var btn := Button.new()
		btn.text = si["name"]
		var stype: String = si["type"]
		btn.pressed.connect(func():
			if current_hero.has_method("play_skill"):
				current_hero.call("play_skill", stype)
			build_ui()
		)
		s_box.add_child(btn)

	vbox.add_child(s_box)

	# 5. 犒賞與列傳詳情
	var act_box := HBoxContainer.new()
	var reward_btn := Button.new()
	reward_btn.text = " 🎁 犒賞 50 黃金 (+5忠誠) "
	reward_btn.pressed.connect(func():
		hero_reward_clicked.emit(current_hero, 50)
	)
	act_box.add_child(reward_btn)

	var detail_btn := Button.new()
	detail_btn.text = " 📜 查看好漢全屬性與列傳 "
	detail_btn.pressed.connect(func():
		hero_full_detail_requested.emit(h_name)
		hide()
	)
	act_box.add_child(detail_btn)

	vbox.add_child(act_box)
	add_child(vbox)
