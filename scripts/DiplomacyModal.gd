# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 對外外交與十四州府策論對話框 (Diplomacy & Fortress Modal)
class_name DiplomacyModal
extends PanelContainer

signal resources_traded(gold_delta: int, food_delta: int, arms_delta: int)
signal fortress_relation_changed(fortress_name: String, relation_status: String)

var diplomacy_log: Array[String] = []

var fortresses: Array[Dictionary] = [
	{"name": "少華山", "leader": "史進 · 朱武", "troops": 1500, "status": "盟友 🤝", "relation": 90},
	{"name": "二龍山", "leader": "魯智深 · 武松", "troops": 2500, "status": "友好 🕊️", "relation": 85},
	{"name": "芒碭山", "leader": "樊瑞 · 項充", "troops": 1800, "status": "中立 ⚪", "relation": 50},
	{"name": "祝家莊", "leader": "祝朝奉 · 欒廷玉", "troops": 3500, "status": "敵對 ⚔️", "relation": 15},
	{"name": "曾頭市", "leader": "史文恭 · 蘇定", "troops": 4200, "status": "敵對 ⚔️", "relation": 10},
	{"name": "高唐州", "leader": "高廉 (知府)", "troops": 3000, "status": "死敵 ☠️", "relation": 5},
	{"name": "大名府", "leader": "梁中書 · 索超", "troops": 5000, "status": "朝廷 官府", "relation": 20},
	{"name": "江州府", "leader": "蔡九知府", "troops": 2800, "status": "朝廷 官府", "relation": 30},
	{"name": "汴京城", "leader": "高俅 · 蔡京", "troops": 15000, "status": "朝廷 核心", "relation": 0}
]

func _ready() -> void:
	custom_minimum_size = Vector2(600, 440)
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
	title_lbl.text = " 對外外交與集市通商 — 天下十四州府局勢"
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

	# 2. 市集物資買賣區
	var trade_panel := PanelContainer.new()
	var tstyle := StyleBoxFlat.new()
	tstyle.bg_color = Color.WHITE
	tstyle.set_content_margin_all(4.0)
	trade_panel.add_theme_stylebox_override("panel", tstyle)

	var tvbox := VBoxContainer.new()
	var tlbl := Label.new()
	tlbl.text = " 🛒 要塞市集貿易 (糧草軍械買賣)："
	tlbl.add_theme_color_override("font_color", Color.BLACK)
	tvbox.add_child(tlbl)

	var tbox1 := HBoxContainer.new()
	var btn_buy_food := Button.new()
	btn_buy_food.text = " 🌾 買入 500 糧 (耗金 1,000) "
	btn_buy_food.pressed.connect(func():
		resources_traded.emit(-1000, 500, 0)
		diplomacy_log.append("從江州商隊採購 500 糧食入庫！")
		build_ui()
	)
	tbox1.add_child(btn_buy_food)

	var btn_sell_food := Button.new()
	btn_sell_food.text = " 🌾 賣出 500 糧 (得金 800) "
	btn_sell_food.pressed.connect(func():
		resources_traded.emit(800, -500, 0)
		diplomacy_log.append("售出 500 糧食換取 800 黃金！")
		build_ui()
	)
	tbox1.add_child(btn_sell_food)

	var btn_buy_arms := Button.new()
	btn_buy_arms.text = " ⚔️ 採購 300 軍械 (耗金 1,200) "
	btn_buy_arms.pressed.connect(func():
		resources_traded.emit(-1200, 0, 300)
		diplomacy_log.append("採購 300 件精鋼軍械配發三軍！")
		build_ui()
	)
	tbox1.add_child(btn_buy_arms)
	tvbox.add_child(tbox1)
	trade_panel.add_child(tvbox)
	vbox.add_child(trade_panel)

	# 3. 諸要塞州府外交列表
	var fscroll := ScrollContainer.new()
	fscroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var fvbox := VBoxContainer.new()
	fvbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	for f in fortresses:
		var fp := PanelContainer.new()
		var fps := StyleBoxFlat.new()
		fps.bg_color = Color(0.96, 0.96, 0.96, 1.0)
		fps.set_content_margin_all(3.0)
		fp.add_theme_stylebox_override("panel", fps)

		var frow := HBoxContainer.new()

		var fname_lbl := Label.new()
		fname_lbl.text = " 🚩 %s" % f["name"]
		fname_lbl.custom_minimum_size = Vector2(90, 0)
		fname_lbl.add_theme_color_override("font_color", Color.BLACK)
		frow.add_child(fname_lbl)

		var fleader_lbl := Label.new()
		fleader_lbl.text = "首領: %s" % f["leader"]
		fleader_lbl.custom_minimum_size = Vector2(140, 0)
		fleader_lbl.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
		frow.add_child(fleader_lbl)

		var fstatus_lbl := Label.new()
		fstatus_lbl.text = "關係: %s (%d)" % [f["status"], f["relation"]]
		fstatus_lbl.custom_minimum_size = Vector2(130, 0)
		fstatus_lbl.add_theme_color_override("font_color", Color(0.0, 0.3, 0.7))
		frow.add_child(fstatus_lbl)

		# 外交按鈕 (遣使結盟 / 宣戰 / 刺探)
		var f_data: Dictionary = f
		var ally_btn := Button.new()
		ally_btn.text = "遣使親善"
		ally_btn.pressed.connect(func():
			f_data["relation"] = mini(100, f_data["relation"] + 15)
			f_data["status"] = "同盟 🤝"
			diplomacy_log.append("遣使前往【%s】，贈送禮物，雙方關係提升至 %d！" % [f_data["name"], f_data["relation"]])
			fortress_relation_changed.emit(f_data["name"], "同盟")
			build_ui()
		)
		frow.add_child(ally_btn)

		var scout_btn := Button.new()
		scout_btn.text = "刺探防務"
		scout_btn.pressed.connect(func():
			diplomacy_log.append("神行太保戴宗回報：【%s】城防堅固，駐兵 %d 人，糧草充足！" % [f_data["name"], f_data["troops"]])
			build_ui()
		)
		frow.add_child(scout_btn)

		fp.add_child(frow)
		fvbox.add_child(fp)

	fscroll.add_child(fvbox)
	vbox.add_child(fscroll)

	# 4. 外交日誌
	var lscroll := ScrollContainer.new()
	lscroll.custom_minimum_size = Vector2(0, 70)
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
	bclose.text = "   關閉外交面板   "
	bclose.pressed.connect(func(): hide())
	btm_box.add_child(bclose)
	vbox.add_child(btm_box)

	add_child(vbox)
