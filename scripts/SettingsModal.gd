# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 系統檔案與存讀檔管理器對話框 (Settings & Save/Load Modal)
class_name SettingsModal
extends PanelContainer

const SaveManagerScript = preload("res://scripts/SaveManager.gd")

signal game_save_requested(slot: int)
signal game_load_requested(slot: int)

var status_message: String = ""

func _ready() -> void:
	custom_minimum_size = Vector2(480, 360)
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
	vbox.add_theme_constant_override("separation", 6)

	# 1. 標題列
	var title_panel := PanelContainer.new()
	var title_style := StyleBoxFlat.new()
	title_style.bg_color = Color(0.0, 0.12, 0.45, 1.0)
	title_style.set_content_margin_all(3.0)
	title_panel.add_theme_stylebox_override("panel", title_style)

	var title_box := HBoxContainer.new()
	var title_lbl := Label.new()
	title_lbl.text = " 💾 系統設定與存檔讀檔 — 梁山泊檔案庫"
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

	# 2. 存檔槽位列表 (Slot 1 ~ 5)
	var slots_panel := PanelContainer.new()
	var sp_style := StyleBoxFlat.new()
	sp_style.bg_color = Color.WHITE
	sp_style.set_content_margin_all(6.0)
	slots_panel.add_theme_stylebox_override("panel", sp_style)

	var svbox := VBoxContainer.new()
	var slots_info: Array[Dictionary] = SaveManagerScript.get_save_slots_info()

	for slot_idx in range(1, 6):
		var s_data: Dictionary = slots_info[slot_idx - 1] if (slot_idx - 1 < slots_info.size()) else {"exists": false}
		var row := HBoxContainer.new()

		var slot_lbl := Label.new()
		if s_data.get("exists", false):
			slot_lbl.text = " 📁 槽位 %d: %d年%d月 | 首領: %s | 聲望: %d" % [slot_idx, s_data["year"], s_data["month"], s_data["leader"], s_data["prestige"]]
		else:
			slot_lbl.text = " 📁 槽位 %d: [ 空白記錄檔 ]" % slot_idx
		slot_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot_lbl.add_theme_color_override("font_color", Color.BLACK)
		row.add_child(slot_lbl)

		var cur_slot: int = slot_idx
		var save_btn := Button.new()
		save_btn.text = " 儲存 "
		save_btn.pressed.connect(func():
			game_save_requested.emit(cur_slot)
			status_message = "✅ 成功將山寨進度儲存至【槽位 %d】！" % cur_slot
			build_ui()
		)
		row.add_child(save_btn)

		var load_btn := Button.new()
		load_btn.text = " 讀取 "
		load_btn.disabled = not s_data.get("exists", false)
		load_btn.pressed.connect(func():
			game_load_requested.emit(cur_slot)
			status_message = "✅ 成功載入【槽位 %d】之山寨存檔！" % cur_slot
			build_ui()
		)
		row.add_child(load_btn)

		svbox.add_child(row)

	slots_panel.add_child(svbox)
	vbox.add_child(slots_panel)

	# 3. 狀態提示訊息
	if not status_message.is_empty():
		var stat_lbl := Label.new()
		stat_lbl.text = status_message
		stat_lbl.add_theme_color_override("font_color", Color(0.1, 0.45, 0.1))
		vbox.add_child(stat_lbl)

	# 底部
	var btm_box := HBoxContainer.new()
	var bclose := Button.new()
	bclose.text = "   關閉檔案面板   "
	bclose.pressed.connect(func(): hide())
	btm_box.add_child(bclose)
	vbox.add_child(btm_box)

	add_child(vbox)
