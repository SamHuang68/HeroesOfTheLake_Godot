# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 設施情報與升級派遣面板 (Facility Info Modal)
class_name FacilityInfoModal
extends PanelContainer

const DataManagerScript = preload("res://scripts/DataManager.gd")

signal facility_upgraded(facility: Node2D, cost_gold: int, cost_food: int)
signal hero_assigned_to_facility(facility: Node2D, hero_name: String)

var current_facility: Node2D = null

func _ready() -> void:
	custom_minimum_size = Vector2(420, 360)
	build_ui()

func display_facility(fac: Node2D) -> void:
	current_facility = fac
	build_ui()
	show()

func build_ui() -> void:
	for child in get_children():
		child.queue_free()

	if not current_facility:
		return

	# 外框經典木紋/古典風格 (Classic Wood-Grain Style)
	var win_style := StyleBoxFlat.new()
	win_style.bg_color = Color(0.88, 0.85, 0.80, 1.0)
	win_style.border_width_left = 3
	win_style.border_width_top = 3
	win_style.border_width_right = 3
	win_style.border_width_bottom = 3
	win_style.border_color = Color(0.45, 0.30, 0.18, 1.0) # 深胡桃木邊框
	win_style.shadow_size = 8
	win_style.shadow_color = Color(0.0, 0.0, 0.0, 0.5)
	win_style.set_content_margin_all(4.0)
	add_theme_stylebox_override("panel", win_style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)

	# 1. 標題列
	var title_panel := PanelContainer.new()
	var title_style := StyleBoxFlat.new()
	title_style.bg_color = Color(0.35, 0.22, 0.12, 1.0) # 木紋標題底色
	title_style.set_content_margin_all(3.0)
	title_panel.add_theme_stylebox_override("panel", title_style)

	var title_box := HBoxContainer.new()
	var title_lbl := Label.new()
	var fac_name: String = current_facility.get("display_name")
	var fac_lvl: int = current_facility.get("level")
	title_lbl.text = " 🏛️ %s (Lv.%d)" % [fac_name, fac_lvl]
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
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

	# 2. 設施基本情報與產能
	var info_panel := PanelContainer.new()
	var info_style := StyleBoxFlat.new()
	info_style.bg_color = Color.WHITE
	info_style.set_content_margin_all(6.0)
	info_panel.add_theme_stylebox_override("panel", info_style)

	var ivbox := VBoxContainer.new()
	
	var stars_str := ""
	for i in range(fac_lvl): stars_str += "★"
	var lvl_lbl := Label.new()
	lvl_lbl.text = "階層等級：%s (第 %d 階繁榮度)" % [stars_str, fac_lvl]
	lvl_lbl.add_theme_color_override("font_color", Color.BLACK)
	ivbox.add_child(lvl_lbl)

	var fac_type: String = current_facility.get("facility_type")
	var output_str := ""
	match fac_type:
		"Farm": output_str = "🌾 糧食收成：+ %d / 月" % (fac_lvl * 250)
		"Market": output_str = "💰 黃金稅收：+ %d / 月" % (fac_lvl * 350)
		"Smithy": output_str = "⚔️ 軍械鍛造：+ %d / 月" % (fac_lvl * 150)
		"Tavern": output_str = "🍺 流浪豪傑拜訪率：+ %d%% | 收益 + %d 金" % [fac_lvl * 20, fac_lvl * 200]
		"Barracks": output_str = "🥋 兵員募集訓練：+ %d 兵 / 月" % (fac_lvl * 120)
		_: output_str = "🏛️ 要塞繁榮度 + %d" % (fac_lvl * 10)

	var out_lbl := Label.new()
	out_lbl.text = output_str
	out_lbl.add_theme_color_override("font_color", Color(0.1, 0.45, 0.1))
	ivbox.add_child(out_lbl)

	info_panel.add_child(ivbox)
	vbox.add_child(info_panel)

	# 3. 進駐好漢列表
	var hero_panel := PanelContainer.new()
	var hstyle := StyleBoxFlat.new()
	hstyle.bg_color = Color(0.95, 0.95, 0.95, 1.0)
	hstyle.set_content_margin_all(6.0)
	hero_panel.add_theme_stylebox_override("panel", hstyle)

	var hvbox := VBoxContainer.new()
	var assigned: Array = current_facility.get("assigned_heroes")
	var htitle := Label.new()
	htitle.text = "👥 目前進駐好漢 (%d 位)：" % assigned.size()
	htitle.add_theme_color_override("font_color", Color.BLACK)
	hvbox.add_child(htitle)

	if assigned.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "（尚無好漢進駐，指派適性好漢可提升 50% 產能！）"
		empty_lbl.add_theme_color_override("font_color", Color(0.5, 0.2, 0.2))
		hvbox.add_child(empty_lbl)
	else:
		for h_name in assigned:
			var h_lbl := Label.new()
			h_lbl.text = "  👤 【%s】 (專注勞作中 · 產能加乘 +50%%)" % h_name
			h_lbl.add_theme_color_override("font_color", Color(0.1, 0.2, 0.6))
			hvbox.add_child(h_lbl)

	hero_panel.add_child(hvbox)
	vbox.add_child(hero_panel)

	# 4. 操作按鈕 (指派好漢 / 升級設施)
	var btn_box := HBoxContainer.new()

	# 指派林沖 / 武松 / 湯隆
	var assign_btn := Button.new()
	assign_btn.text = " 👤 指派好漢進駐 "
	assign_btn.pressed.connect(func():
		var candidates := ["林沖", "武松", "魯智深", "李俊", "湯隆", "花榮"]
		for cand in candidates:
			if not assigned.has(cand):
				assigned.append(cand)
				current_facility.set("assigned_heroes", assigned)
				hero_assigned_to_facility.emit(current_facility, cand)
				break
		build_ui()
	)
	btn_box.add_child(assign_btn)

	var upgrade_btn := Button.new()
	if fac_lvl < 3:
		var up_gold: int = fac_lvl * 250
		var up_food: int = fac_lvl * 150
		upgrade_btn.text = " 🔨 擴建升級 (金%d 糧%d) " % [up_gold, up_food]
		upgrade_btn.pressed.connect(func():
			if current_facility.has_method("upgrade_facility"):
				if current_facility.call("upgrade_facility"):
					facility_upgraded.emit(current_facility, up_gold, up_food)
					build_ui()
		)
	else:
		upgrade_btn.text = " 🏆 已達最高繁榮階層 "
		upgrade_btn.disabled = true
	btn_box.add_child(upgrade_btn)

	vbox.add_child(btn_box)

	# 底部
	var btm_box := HBoxContainer.new()
	var bclose := Button.new()
	bclose.text = "   關閉情報   "
	bclose.pressed.connect(func(): hide())
	btm_box.add_child(bclose)
	vbox.add_child(btm_box)

	add_child(vbox)
