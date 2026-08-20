# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 外交州府、市集通商與要塞沙盤視察面板 (Diplomacy & Fortress Inspection)
class_name DiplomacyModal
extends PanelContainer

const FortressDatabaseScript = preload("res://scripts/FortressDatabase.gd")

var diplomacy_targets := [
	{"id": "shaohua", "name": "少華山", "ruler": "史進", "relation": 85, "stance": "盟友", "distance": "近", "def": 550, "theme": "險峰盤山古寨"},
	{"id": "erlong", "name": "二龍山", "ruler": "魯智深", "relation": 90, "stance": "盟友", "distance": "中", "def": 700, "theme": "寶珠寺三道險關"},
	{"id": "zhujia", "name": "祝家莊", "ruler": "祝朝奉", "relation": 20, "stance": "敵對", "distance": "近", "def": 850, "theme": "獨龍岡盤陀路迷宮"},
	{"id": "zengtou", "name": "曾頭市", "ruler": "曾長官", "relation": 15, "stance": "敵對", "distance": "中", "def": 950, "theme": "塞外神駿商埠要塞"},
	{"id": "mangdang", "name": "芒碭山", "ruler": "樊瑞", "relation": 40, "stance": "中立", "distance": "中", "def": 480, "theme": "混世魔王八卦玄壇"},
	{"id": "taohua", "name": "桃花山", "ruler": "李忠", "relation": 75, "stance": "友好", "distance": "近", "def": 420, "theme": "打虎將青石木寨"},
	{"id": "daming", "name": "大名府", "ruler": "梁中書", "relation": 10, "stance": "敵對", "distance": "遠", "def": 1800, "theme": "大宋北都留守司"},
	{"id": "jiangzhou", "name": "江州", "ruler": "蔡九", "relation": 25, "stance": "中立", "distance": "遠", "def": 1200, "theme": "潯陽江水運重鎮"},
	{"id": "kaifeng", "name": "東京汴京", "ruler": "高俅", "relation": 0, "stance": "死敵", "distance": "極遠", "def": 3000, "theme": "大宋皇城殿帥府"}
]

var current_sub_tab: int = 0 # 0: 諸州府局勢, 1: 市集通商
var action_log: String = "請選擇各州府要塞進行遣使結盟、刺探防務或切換沙盤視察。"

signal fortress_inspect_requested(fortress_id: String)

func _ready() -> void:
	custom_minimum_size = Vector2(620, 480)
	build_diplomacy_ui()

func build_diplomacy_ui() -> void:
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
	win_style.set_content_margin_all(6.0)
	add_theme_stylebox_override("panel", win_style)

	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 6)

	# 1. 標題列
	var title_panel := PanelContainer.new()
	var title_style := StyleBoxFlat.new()
	title_style.bg_color = Color(0.0, 0.15, 0.45, 1.0)
	title_style.set_content_margin_all(4.0)
	title_panel.add_theme_stylebox_override("panel", title_style)

	var title_box := HBoxContainer.new()
	var title_lbl := Label.new()
	title_lbl.text = " 📜 天下諸州要塞局勢與通商貿易 [外交]"
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
	main_vbox.add_child(title_panel)

	# 2. 分頁按鈕
	var tab_bar := HBoxContainer.new()
	var btn_tab0 := Button.new()
	btn_tab0.text = " 🏰 諸州府要塞地圖視察 "
	btn_tab0.pressed.connect(func(): current_sub_tab = 0; build_diplomacy_ui())
	tab_bar.add_child(btn_tab0)

	var btn_tab1 := Button.new()
	btn_tab1.text = " ⚖️ 鬧市集市物資通商 "
	btn_tab1.pressed.connect(func(): current_sub_tab = 1; build_diplomacy_ui())
	tab_bar.add_child(btn_tab1)

	main_vbox.add_child(tab_bar)

	# 3. 內容分頁
	if current_sub_tab == 0:
		build_fortress_list_tab(main_vbox)
	else:
		build_market_trade_tab(main_vbox)

	# 4. 底部狀態列
	var log_lbl := Label.new()
	log_lbl.text = "📢 密報: " + action_log
	log_lbl.add_theme_color_override("font_color", Color(0.1, 0.35, 0.15, 1.0))
	main_vbox.add_child(log_lbl)

	add_child(main_vbox)

func build_fortress_list_tab(parent: VBoxContainer) -> void:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(600, 310)

	var list_vbox := VBoxContainer.new()
	list_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	for target in diplomacy_targets:
		var row := PanelContainer.new()
		var r_style := StyleBoxFlat.new()
		r_style.bg_color = Color(0.92, 0.92, 0.90, 1.0)
		r_style.border_width_bottom = 1
		r_style.border_color = Color(0.75, 0.75, 0.70, 1.0)
		r_style.set_content_margin_all(4.0)
		row.add_theme_stylebox_override("panel", r_style)

		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)

		var name_lbl := Label.new()
		name_lbl.text = "【%s】首領: %s" % [target["name"], target["ruler"]]
		name_lbl.custom_minimum_size = Vector2(160, 24)
		name_lbl.add_theme_color_override("font_color", Color(0.1, 0.1, 0.2, 1.0))
		hbox.add_child(name_lbl)

		var rel_lbl := Label.new()
		rel_lbl.text = "態勢: %s (防務 %d)" % [target["stance"], target["def"]]
		rel_lbl.custom_minimum_size = Vector2(140, 24)
		rel_lbl.add_theme_color_override("font_color", Color(0.7, 0.2, 0.1, 1.0) if target["stance"] == "敵對" else Color(0.1, 0.5, 0.2, 1.0))
		hbox.add_child(rel_lbl)

		# 視察沙盤按鈕
		var inspect_btn := Button.new()
		inspect_btn.text = " 🔍 視察沙盤 "
		var tid: String = target["id"]
		var tname: String = target["name"]
		inspect_btn.pressed.connect(func():
			action_log = "已切換並載入【%s】之專屬沙盤地圖與設施格局！" % tname
			fortress_inspect_requested.emit(tid)
			build_diplomacy_ui()
		)
		hbox.add_child(inspect_btn)

		var ally_btn := Button.new()
		ally_btn.text = " 遣使結盟 "
		ally_btn.pressed.connect(func():
			target["relation"] = mini(100, target["relation"] + 15)
			action_log = "派遣智勇好漢前往 %s 結好修好，友好度提升！" % target["name"]
			build_diplomacy_ui()
		)
		hbox.add_child(ally_btn)

		row.add_child(hbox)
		list_vbox.add_child(row)

	# 亦提供梁山泊本營返回按鈕
	var ls_btn := Button.new()
	ls_btn.text = " 🏞️ 返回水泊梁山本營沙盤 "
	ls_btn.pressed.connect(func():
		action_log = "已返回水泊梁山本營！"
		fortress_inspect_requested.emit("liangshan")
		build_diplomacy_ui()
	)
	list_vbox.add_child(ls_btn)

	scroll.add_child(list_vbox)
	parent.add_child(scroll)

func build_market_trade_tab(parent: VBoxContainer) -> void:
	var trade_panel := PanelContainer.new()
	trade_panel.custom_minimum_size = Vector2(600, 310)

	var tvbox := VBoxContainer.new()
	tvbox.add_theme_constant_override("separation", 12)

	var info_lbl := Label.new()
	info_lbl.text = "🏛️ 梁山水泊鬧市大集市：可進行黃金、糧草、軍械之物資平準買賣。\n當前物價：100 糧草 = 60 黃金，100 軍械 = 120 黃金。"
	info_lbl.add_theme_color_override("font_color", Color(0.15, 0.2, 0.3, 1.0))
	tvbox.add_child(info_lbl)

	var trade_box := GridContainer.new()
	trade_box.columns = 2
	trade_box.add_theme_constant_override("h_separation", 15)
	trade_box.add_theme_constant_override("v_separation", 10)

	var b_buy_food := Button.new()
	b_buy_food.text = " 🌾 購買 1,000 糧草 (消耗 600 金) "
	b_buy_food.pressed.connect(func(): action_log = "成功自市集購入 1,000 糧草！")
	trade_box.add_child(b_buy_food)

	var b_sell_food := Button.new()
	b_sell_food.text = " 💰 出售 1,000 糧草 (獲得 500 金) "
	b_sell_food.pressed.connect(func(): action_log = "成功將 1,000 糧草售予過路商隊！")
	trade_box.add_child(b_sell_food)

	var b_buy_arms := Button.new()
	b_buy_arms.text = " ⚔️ 採購 500 軍械 (消耗 600 金) "
	b_buy_arms.pressed.connect(func(): action_log = "成功自塞外商隊採購 500 領精良軍械！")
	trade_box.add_child(b_buy_arms)

	var b_sell_arms := Button.new()
	b_sell_arms.text = " 💰 出售 500 軍械 (獲得 450 金) "
	b_sell_arms.pressed.connect(func(): action_log = "成功出售 500 領多餘軍械！")
	trade_box.add_child(b_sell_arms)

	tvbox.add_child(trade_box)
	trade_panel.add_child(tvbox)
	parent.add_child(trade_panel)
