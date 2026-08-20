# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 頂部經典 Windows 98 雙層選單與政略狀態列
class_name TopMenuBar
extends VBoxContainer

signal menu_item_selected(menu_name: String)
signal quick_action_triggered(action_name: String)
signal advance_month_clicked()

var current_year: int = 1101
var current_month: int = 6
var current_day: int = 1
var weather: String = "晴"
var wind: String = "強風↗"
var leader_name: String = "林沖"
var prestige: int = 350
var gold: int = 12500
var food: int = 8800
var arms: int = 6400
var soldiers: int = 5600

var status_lbl: Label

func _ready() -> void:
	custom_minimum_size = Vector2(0, 72)
	build_top_menu_ui()
	update_status_display()

func build_top_menu_ui() -> void:
	for child in get_children():
		child.queue_free()

	# 1. 深藍色 Windows 經典視窗標題列
	var title_panel := PanelContainer.new()
	var title_style := StyleBoxFlat.new()
	title_style.bg_color = Color(0.0, 0.12, 0.45, 1.0)
	title_style.set_content_margin_all(3.0)
	title_panel.add_theme_stylebox_override("panel", title_style)
	
	var title_box := HBoxContainer.new()
	var title_lbl := Label.new()
	title_lbl.text = "🏮「水滸傳·天導一〇八星」— 梁山泊"
	title_lbl.add_theme_color_override("font_color", Color.WHITE)
	title_box.add_child(title_lbl)
	
	var title_spacer := Control.new()
	title_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_child(title_spacer)
	
	var win_controls := Label.new()
	win_controls.text = "[ _ ]  [ 口 ]  [ X ]"
	win_controls.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	title_box.add_child(win_controls)
	
	title_panel.add_child(title_box)
	add_child(title_panel)

	# 2. 第一層 Windows 98 灰階文字選單列 (檔案/資訊/對外/我方勢力/要塞營運/人事/軍事/開發/設定)
	var menu_panel := PanelContainer.new()
	var menu_style := StyleBoxFlat.new()
	menu_style.bg_color = Color(0.82, 0.82, 0.80, 1.0)
	menu_style.set_content_margin_all(2.0)
	menu_panel.add_theme_stylebox_override("panel", menu_style)
	
	var menu_box := HBoxContainer.new()
	var menus := [
		{"text": "檔案(F)", "id": "file"},
		{"text": "資訊(I)", "id": "info"},
		{"text": "對外(O)", "id": "diplomacy"},
		{"text": "我方勢力(D)", "id": "faction"},
		{"text": "要塞營運(R)", "id": "fortress"},
		{"text": "人事(P)", "id": "personnel"},
		{"text": "軍事(M)", "id": "military"},
		{"text": "開發(W)", "id": "build"},
		{"text": "設定(S)", "id": "settings"}
	]
	
	for m in menus:
		var btn := Button.new()
		btn.text = m["text"]
		btn.flat = true
		btn.add_theme_color_override("font_color", Color.BLACK)
		btn.pressed.connect(func(): menu_item_selected.emit(m["id"]))
		menu_box.add_child(btn)
		
	menu_panel.add_child(menu_box)
	add_child(menu_panel)

	# 3. 第二層快捷操作與即時資源狀態列
	var quick_panel := PanelContainer.new()
	var quick_style := StyleBoxFlat.new()
	quick_style.bg_color = Color(0.90, 0.90, 0.88, 1.0)
	quick_style.set_content_margin_all(3.0)
	quick_panel.add_theme_stylebox_override("panel", quick_style)
	
	var quick_box := HBoxContainer.new()
	
	var quick_btns := ["全", "地", "寨", "土", "人"]
	for q in quick_btns:
		var qbtn := Button.new()
		qbtn.text = " [%s] " % q
		qbtn.pressed.connect(func(): quick_action_triggered.emit(q))
		quick_box.add_child(qbtn)

	var next_month_btn := Button.new()
	next_month_btn.text = " ▶ 次月 "
	next_month_btn.add_theme_color_override("font_color", Color(0.0, 0.55, 0.15))
	next_month_btn.pressed.connect(func(): advance_month_clicked.emit())
	quick_box.add_child(next_month_btn)
	
	var pause_lbl := Label.new()
	pause_lbl.text = "  好漢: [ 林沖 ▼ ]  設施: [ 忠義堂 ▼ ]  【暫停中】  "
	pause_lbl.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	quick_box.add_child(pause_lbl)
	
	var spacer2 := Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quick_box.add_child(spacer2)
	
	# 即時狀態數據標籤
	status_lbl = Label.new()
	status_lbl.name = "LiveStatusLabel"
	status_lbl.add_theme_color_override("font_color", Color.BLACK)
	quick_box.add_child(status_lbl)
	
	quick_panel.add_child(quick_box)
	add_child(quick_panel)

func update_status_display() -> void:
	if status_lbl:
		status_lbl.text = "%d年 %d月%d日  天氣:%s  風:%s  首領:%s  聲望:%d  金:%d  糧食:%d  軍械:%d  兵力:%d" % [
			current_year, current_month, current_day,
			weather, wind, leader_name, prestige,
			gold, food, arms, soldiers
		]

func advance_time(days: int = 30) -> void:
	current_day += days
	while current_day > 30:
		current_day -= 30
		current_month += 1
		if current_month > 12:
			current_month = 1
			current_year += 1
			
	# 月度產能結算
	gold += 1250
	food += 900
	arms += 480
	update_status_display()
