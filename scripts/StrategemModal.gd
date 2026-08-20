# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 計謀策論與奇門妖術面板 (Strategem Modal)
class_name StrategemModal
extends PanelContainer

signal strategem_executed(strat_name: String, target_city: String, cost_gold: int)

var strategem_log: Array[String] = []

func _ready() -> void:
	custom_minimum_size = Vector2(560, 420)
	build_ui()

func build_ui() -> void:
	for child in get_children():
		child.queue_free()

	var win_style := StyleBoxFlat.new()
	win_style.bg_color = Color(0.86, 0.86, 0.84, 1.0)
	win_style.border_width_left = 3
	win_style.border_width_top = 3
	win_style.border_width_right = 3
	win_style.border_width_bottom = 3
	win_style.border_color = Color(0.4, 0.1, 0.5, 1.0) # 紫色玄門邊框
	win_style.shadow_size = 6
	win_style.shadow_color = Color(0.0, 0.0, 0.0, 0.4)
	win_style.set_content_margin_all(3.0)
	add_theme_stylebox_override("panel", win_style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)

	# 1. 標題列
	var title_panel := PanelContainer.new()
	var title_style := StyleBoxFlat.new()
	title_style.bg_color = Color(0.25, 0.05, 0.35, 1.0)
	title_style.set_content_margin_all(3.0)
	title_panel.add_theme_stylebox_override("panel", title_style)

	var title_box := HBoxContainer.new()
	var title_lbl := Label.new()
	title_lbl.text = " 🔮 計謀策論與奇門妖術 — 吳用·公孫勝策論"
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
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

	# 2. 計謀列表
	var strat_panel := PanelContainer.new()
	var sp_style := StyleBoxFlat.new()
	sp_style.bg_color = Color.WHITE
	sp_style.set_content_margin_all(6.0)
	strat_panel.add_theme_stylebox_override("panel", sp_style)

	var svbox := VBoxContainer.new()
	var strats := [
		{"name": "⚡ 呼風喚雨 (五雷妖術)", "cost": 300, "desc": "入雲龍公孫勝設壇作法，改變戰場天候為狂風大雨，重創敵軍！"},
		{"name": "📜 偽報誘敵", "cost": 150, "desc": "智多星吳用發出偽造軍令，引誘敵軍先鋒陷入沼澤埋伏！"},
		{"name": "🔥 暗夜燒糧", "cost": 200, "desc": "鼓上蚤時遷夜潛敵營糧倉，火燒十萬斛軍糧，削弱敵軍士氣！"},
		{"name": "🎭 離間反間計", "cost": 250, "desc": "散佈謠言使敵將與朝廷奸臣高俅生疑，大幅降低敵將忠誠度！"},
		{"name": "🗣️ 煽動民變", "cost": 180, "desc": "於敵方州府張貼安民榜文，降低敵府治安並引導義民投奔梁山！"}
	]

	for st in strats:
		var row := HBoxContainer.new()

		var nlbl := Label.new()
		nlbl.text = st["name"]
		nlbl.custom_minimum_size = Vector2(170, 0)
		nlbl.add_theme_color_override("font_color", Color(0.3, 0.0, 0.4))
		row.add_child(nlbl)

		var clbl := Label.new()
		clbl.text = "耗金 %d" % st["cost"]
		clbl.custom_minimum_size = Vector2(70, 0)
		clbl.add_theme_color_override("font_color", Color(0.7, 0.3, 0.0))
		row.add_child(clbl)

		var dlbl := Label.new()
		dlbl.text = st["desc"]
		dlbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		dlbl.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
		row.add_child(dlbl)

		var ex_btn := Button.new()
		ex_btn.text = " 施行 "
		var sname: String = st["name"]
		var scost: int = st["cost"]
		ex_btn.pressed.connect(func():
			strategem_log.append("【計謀成功】成功發動【%s】！敵軍震動！" % sname)
			strategem_executed.emit(sname, "祝家莊", scost)
			build_ui()
		)
		row.add_child(ex_btn)

		svbox.add_child(row)

	strat_panel.add_child(svbox)
	vbox.add_child(strat_panel)

	# 3. 計謀日誌
	var lscroll := ScrollContainer.new()
	lscroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var lvbox := VBoxContainer.new()
	for log_item in strategem_log:
		var llbl := Label.new()
		llbl.text = log_item
		llbl.add_theme_color_override("font_color", Color(0.1, 0.1, 0.5))
		lvbox.add_child(llbl)
	lscroll.add_child(lvbox)
	vbox.add_child(lscroll)

	# 底部
	var btm_box := HBoxContainer.new()
	var bclose := Button.new()
	bclose.text = "   關閉計謀面板   "
	bclose.pressed.connect(func(): hide())
	btm_box.add_child(bclose)
	vbox.add_child(btm_box)

	add_child(vbox)
