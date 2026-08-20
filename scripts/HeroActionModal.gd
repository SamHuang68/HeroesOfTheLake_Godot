# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 好漢快捷指令與工作調度面板 (Hero Action Modal)
class_name HeroActionModal
extends PanelContainer

signal hero_job_changed(hero: Node2D, job_name: String)
signal hero_reward_clicked(hero: Node2D, gold_cost: int)
signal hero_full_detail_requested(hero_name: String)

var current_hero: Node2D = null

func _ready() -> void:
	custom_minimum_size = Vector2(380, 320)
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
	win_style.set_content_margin_all(4.0)
	add_theme_stylebox_override("panel", win_style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)

	# 1. 標題列
	var title_panel := PanelContainer.new()
	var title_style := StyleBoxFlat.new()
	title_style.bg_color = Color(0.0, 0.12, 0.45, 1.0)
	title_style.set_content_margin_all(3.0)
	title_panel.add_theme_stylebox_override("panel", title_style)

	var title_box := HBoxContainer.new()
	var title_lbl := Label.new()
	var h_name: String = current_hero.get("hero_name")
	var h_title: String = current_hero.get("title_name")
	title_lbl.text = " 👤 好漢指令 — 【%s %s】" % [h_title, h_name]
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

	# 2. 狀態數值
	var stat_panel := PanelContainer.new()
	var sstyle := StyleBoxFlat.new()
	sstyle.bg_color = Color.WHITE
	sstyle.set_content_margin_all(6.0)
	stat_panel.add_theme_stylebox_override("panel", sstyle)

	var svbox := VBoxContainer.new()
	var stam: int = current_hero.get("current_stamina")
	var max_stam: int = current_hero.get("max_stamina")
	var energy: int = current_hero.get("current_energy")
	var job: String = current_hero.get("assigned_job")

	var stat_lbl := Label.new()
	stat_lbl.text = "當前體力：%d / %d  |  氣力：%d / 100\n目前指派職務：【%s】" % [stam, max_stam, energy, job]
	stat_lbl.add_theme_color_override("font_color", Color.BLACK)
	svbox.add_child(stat_lbl)

	stat_panel.add_child(svbox)
	vbox.add_child(stat_panel)

	# 3. 工作指派快捷按鈕 (巡哨 / 打鐵 / 農耕 / 駐館 / 操練)
	var job_title := Label.new()
	job_title.text = " 🛠️ 調度工作與勞作指派："
	job_title.add_theme_color_override("font_color", Color.BLACK)
	vbox.add_child(job_title)

	var jbox1 := HBoxContainer.new()
	var jobs := ["巡哨", "打鐵", "農耕", "駐館", "操練"]
	for j in jobs:
		var jbtn := Button.new()
		jbtn.text = " %s " % j
		var jname: String = j
		jbtn.pressed.connect(func():
			if current_hero.has_method("assign_work"):
				current_hero.call("assign_work", jname)
				hero_job_changed.emit(current_hero, jname)
				build_ui()
		)
		jbox1.add_child(jbtn)
	vbox.add_child(jbox1)

	# 4. 犒賞與詳細屬性按鈕
	var act_box := HBoxContainer.new()
	var reward_btn := Button.new()
	reward_btn.text = " 🎁 犒賞 50 黃金 (+5忠誠) "
	reward_btn.pressed.connect(func():
		hero_reward_clicked.emit(current_hero, 50)
	)
	act_box.add_child(reward_btn)

	var detail_btn := Button.new()
	detail_btn.text = " 📜 查看全屬性與列傳 "
	detail_btn.pressed.connect(func():
		hero_full_detail_requested.emit(h_name)
		hide()
	)
	act_box.add_child(detail_btn)

	vbox.add_child(act_box)

	# 底部
	var btm_box := HBoxContainer.new()
	var bclose := Button.new()
	bclose.text = "   關閉指令   "
	bclose.pressed.connect(func(): hide())
	btm_box.add_child(bclose)
	vbox.add_child(btm_box)

	add_child(vbox)
