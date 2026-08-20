# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 對外外交與通商交易對話框 (Diplomacy & Trade Modal)
class_name DiplomacyModal
extends PanelContainer

signal resources_traded(gold_delta: int, food_delta: int, arms_delta: int)

var gold_rate_food: int = 2 # 1 糧 = 2 金
var gold_rate_arms: int = 4 # 1 軍械 = 4 金

var diplomacy_log: Array[String] = []

func _ready() -> void:
	custom_minimum_size = Vector2(540, 400)
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
	title_lbl.text = " 對外外交與集市通商 — 天下十四州策論"
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

	# 2. 市集買賣物資交易區 (Market Trading)
	var trade_panel := PanelContainer.new()
	var tstyle := StyleBoxFlat.new()
	tstyle.bg_color = Color.WHITE
	tstyle.set_content_margin_all(6.0)
	trade_panel.add_theme_stylebox_override("panel", tstyle)

	var tvbox := VBoxContainer.new()
	var tlbl := Label.new()
	tlbl.text = " 🛒 要塞市集物資買賣 (買賣糧食、軍械配備)："
	tlbl.add_theme_color_override("font_color", Color.BLACK)
	tvbox.add_child(tlbl)

	var tbox1 := HBoxContainer.new()
	var btn_buy_food := Button.new()
	btn_buy_food.text = " 🌾 買入 500 糧食 (耗金 1,000) "
	btn_buy_food.pressed.connect(func():
		resources_traded.emit(-1000, 500, 0)
		diplomacy_log.append("從江州商人處採購 500 糧食，充實山寨糧倉！")
		build_ui()
	)
	tbox1.add_child(btn_buy_food)

	var btn_sell_food := Button.new()
	btn_sell_food.text = " 🌾 賣出 500 糧食 (得金 800) "
	btn_sell_food.pressed.connect(func():
		resources_traded.emit(800, -500, 0)
		diplomacy_log.append("將 500 儲備糧食售予市集商隊，換取 800 黃金！")
		build_ui()
	)
	tbox1.add_child(btn_sell_food)
	tvbox.add_child(tbox1)

	var tbox2 := HBoxContainer.new()
	var btn_buy_arms := Button.new()
	btn_buy_arms.text = " ⚔️ 採購 300 兵器軍械 (耗金 1,200) "
	btn_buy_arms.pressed.connect(func():
		resources_traded.emit(-1200, 0, 300)
		diplomacy_log.append("購進 300 件精鋼朴刀與強弓，裝備先鋒營！")
		build_ui()
	)
	tbox2.add_child(btn_buy_arms)
	tvbox.add_child(tbox2)

	trade_panel.add_child(tvbox)
	vbox.add_child(trade_panel)

	# 3. 外交行動
	var dip_panel := PanelContainer.new()
	var dstyle := StyleBoxFlat.new()
	dstyle.bg_color = Color(0.95, 0.95, 0.95, 1.0)
	dstyle.set_content_margin_all(6.0)
	dip_panel.add_theme_stylebox_override("panel", dstyle)

	var dvbox := VBoxContainer.new()
	var dlbl := Label.new()
	dlbl.text = " 📜 諸州外交策論行動："
	dlbl.add_theme_color_override("font_color", Color.BLACK)
	dvbox.add_child(dlbl)

	var dbox1 := HBoxContainer.new()
	var btn_envoy := Button.new()
	btn_envoy.text = " 🕊️ 遣使少華山 (結為兄弟盟友) "
	btn_envoy.pressed.connect(func():
		diplomacy_log.append("遣神行太保戴宗前往少華山，與史進、朱武結為同盟，聲望 +20！")
		build_ui()
	)
	dbox1.add_child(btn_envoy)

	var btn_scout := Button.new()
	btn_scout.text = " 🔍 刺探高唐州 (獲取高廉防務) "
	btn_scout.pressed.connect(func():
		diplomacy_log.append("密探回報：高唐州高廉聚兵 360，正修築道壇準備妖術！")
		build_ui()
	)
	dbox1.add_child(btn_scout)
	dvbox.add_child(dbox1)

	dip_panel.add_child(dvbox)
	vbox.add_child(dip_panel)

	# 4. 外交日誌
	var lscroll := ScrollContainer.new()
	lscroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var lvbox := VBoxContainer.new()
	for log_item in diplomacy_log:
		var llbl := Label.new()
		llbl.text = log_item
		llbl.add_theme_color_override("font_color", Color.BLACK)
		lvbox.add_child(llbl)
	lscroll.add_child(lvbox)
	vbox.add_child(lscroll)

	# 底部
	var btm_box := HBoxContainer.new()
	var bclose := Button.new()
	bclose.text = "   關閉外交視窗   "
	bclose.pressed.connect(func(): hide())
	btm_box.add_child(bclose)
	vbox.add_child(btm_box)

	add_child(vbox)
