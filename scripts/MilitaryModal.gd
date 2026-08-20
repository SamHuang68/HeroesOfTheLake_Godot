# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 軍事征伐與演武單挑對話框 (Military & Duel Modal)
class_name MilitaryModal
extends PanelContainer

const DataManagerScript = preload("res://scripts/DataManager.gd")

var current_mode: int = 0 # 0: 八大陣型, 1: 演武單挑

# 單挑狀態
var hero1_name: String = "林沖"
var hero1_hp: int = 100
var hero1_max_hp: int = 100
var hero1_stamina: int = 95
var hero1_might: int = 96

var hero2_name: String = "史文恭"
var hero2_hp: int = 100
var hero2_max_hp: int = 100
var hero2_stamina: int = 90
var hero2_might: int = 91

var battle_log: Array[String] = []

func _ready() -> void:
	custom_minimum_size = Vector2(580, 440)
	build_ui()

func build_ui() -> void:
	for child in get_children():
		child.queue_free()

	# 外框 Windows 98 風格
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
	title_lbl.text = " 軍事征伐與演武單挑 — 梁山八軍大演武"
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

	# 2. 分頁按鈕 (八大陣型 / 演武單挑)
	var tab_box := HBoxContainer.new()
	var btn_formation := Button.new()
	btn_formation.text = " ⚔️ 八大陣型出征 "
	btn_formation.pressed.connect(func():
		current_mode = 0
		build_ui()
	)
	tab_box.add_child(btn_formation)

	var btn_duel := Button.new()
	btn_duel.text = " 🥋 演武堂名將單挑 "
	btn_duel.pressed.connect(func():
		current_mode = 1
		reset_duel()
		build_ui()
	)
	tab_box.add_child(btn_duel)

	vbox.add_child(tab_box)

	# 3. 分頁內容
	var content_panel := PanelContainer.new()
	content_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL

	if current_mode == 0:
		content_panel.add_child(build_formation_view())
	else:
		content_panel.add_child(build_duel_view())

	vbox.add_child(content_panel)

	# 底部
	var btm_box := HBoxContainer.new()
	var bclose := Button.new()
	bclose.text = "   關閉軍事面板   "
	bclose.pressed.connect(func(): hide())
	btm_box.add_child(bclose)
	vbox.add_child(btm_box)

	add_child(vbox)

func build_formation_view() -> VBoxContainer:
	var fvbox := VBoxContainer.new()
	var formations := [
		{"name": "鋒矢陣 (Arrowhead)", "bonus": "突擊傷害 +30%, 突破敵軍中軍", "commander": "林沖 (馬軍主帥)"},
		{"name": "八卦陣 (Bagua)", "bonus": "全軍防禦 +25%, 免疫混亂妖術", "commander": "吳用 / 公孫勝 (軍師)"},
		{"name": "魚鱗陣 (Fish Scale)", "bonus": "步兵攻防均衡, 正面推進穩健", "commander": "武松 / 魯智深 (步軍)"},
		{"name": "雁形陣 (Wild Goose)", "bonus": "弓箭連射射程 +2, 齊射覆蓋全場", "commander": "花榮 / 燕青 (神射)"},
		{"name": "鶴翼陣 (Crane Wing)", "bonus": "左右兩翼包抄, 俘獲敵將機率提高", "commander": "呼延灼 / 關勝"},
		{"name": "偃月陣 (Crescent)", "bonus": "主將單挑觸發率 +50%, 暴擊倍率提升", "commander": "關勝 (大刀)"}
	]

	for f in formations:
		var p := PanelContainer.new()
		var p_style := StyleBoxFlat.new()
		p_style.bg_color = Color.WHITE
		p_style.set_content_margin_all(3.0)
		p.add_theme_stylebox_override("panel", p_style)

		var hbox := HBoxContainer.new()

		var nlbl := Label.new()
		nlbl.text = "🚩 %s" % f["name"]
		nlbl.custom_minimum_size = Vector2(160, 0)
		nlbl.add_theme_color_override("font_color", Color.BLACK)
		hbox.add_child(nlbl)

		var blbl := Label.new()
		blbl.text = f["bonus"]
		blbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		blbl.add_theme_color_override("font_color", Color(0.1, 0.4, 0.1))
		hbox.add_child(blbl)

		var clbl := Label.new()
		clbl.text = f["commander"]
		clbl.custom_minimum_size = Vector2(140, 0)
		clbl.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
		hbox.add_child(clbl)

		var sbtn := Button.new()
		sbtn.text = " 配屬出征 "
		sbtn.pressed.connect(func():
			battle_log.append("已指派【%s】為主陣型，集結 1,000 精銳部隊出征！" % f["name"])
		)
		hbox.add_child(sbtn)

		p.add_child(hbox)
		fvbox.add_child(p)

	return fvbox

func build_duel_view() -> VBoxContainer:
	var dvbox := VBoxContainer.new()
	dvbox.add_theme_constant_override("separation", 6)

	# 1. 雙方血條與頭像狀態
	var vs_box := HBoxContainer.new()

	# 我方好漢
	var h1_box := VBoxContainer.new()
	h1_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var h1_lbl := Label.new()
	h1_lbl.text = "👤 我方：【%s】(臂力 %d)" % [hero1_name, hero1_might]
	h1_lbl.add_theme_color_override("font_color", Color(0.0, 0.2, 0.6))
	h1_box.add_child(h1_lbl)

	var h1_hp_lbl := Label.new()
	h1_hp_lbl.text = "氣血: %d / %d  體力: %d" % [hero1_hp, hero1_max_hp, hero1_stamina]
	h1_hp_lbl.add_theme_color_override("font_color", Color.BLACK)
	h1_box.add_child(h1_hp_lbl)
	vs_box.add_child(h1_box)

	var vs_lbl := Label.new()
	vs_lbl.text = "  ⚡ VS ⚡  "
	vs_lbl.add_theme_color_override("font_color", Color.RED)
	vs_box.add_child(vs_lbl)

	# 敵方名將
	var h2_box := VBoxContainer.new()
	h2_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var h2_lbl := Label.new()
	h2_lbl.text = "👤 敵方：【%s】(臂力 %d)" % [hero2_name, hero2_might]
	h2_lbl.add_theme_color_override("font_color", Color(0.7, 0.1, 0.1))
	h2_box.add_child(h2_lbl)

	var h2_hp_lbl := Label.new()
	h2_hp_lbl.text = "氣血: %d / %d  體力: %d" % [hero2_hp, hero2_max_hp, hero2_stamina]
	h2_hp_lbl.add_theme_color_override("font_color", Color.BLACK)
	h2_box.add_child(h2_hp_lbl)
	vs_box.add_child(h2_box)

	dvbox.add_child(vs_box)

	# 2. 戰鬥操作按鈕 (果斷突擊 / 普通攻擊 / 連續射擊 / 運功回氣)
	var act_box := HBoxContainer.new()
	
	var btn_atk := Button.new()
	btn_atk.text = " 🗡️ 普通攻擊 "
	btn_atk.pressed.connect(func(): perform_attack("普通攻擊", 18, 5))
	act_box.add_child(btn_atk)

	var btn_rush := Button.new()
	btn_rush.text = " 💥 果斷突擊 (耗體30) "
	btn_rush.pressed.connect(func(): perform_attack("果斷突擊", 38, 30))
	act_box.add_child(btn_rush)

	var btn_shoot := Button.new()
	btn_shoot.text = " 🏹 連續射擊 (耗體20) "
	btn_shoot.pressed.connect(func(): perform_attack("連續射擊", 28, 20))
	act_box.add_child(btn_shoot)

	var btn_rest := Button.new()
	btn_rest.text = " 🧘 運功回氣 (+25體) "
	btn_rest.pressed.connect(func():
		hero1_stamina = mini(95, hero1_stamina + 25)
		battle_log.append("【%s】深吸一口氣，氣沉丹田，體力恢復 25 點！" % hero1_name)
		enemy_counter_attack()
		build_ui()
	)
	act_box.add_child(btn_rest)

	dvbox.add_child(act_box)

	# 3. 戰鬥日誌 (Combat Log)
	var log_scroll := ScrollContainer.new()
	log_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var log_vbox := VBoxContainer.new()
	for log_msg in battle_log:
		var llbl := Label.new()
		llbl.text = log_msg
		llbl.add_theme_color_override("font_color", Color(0.15, 0.15, 0.15))
		log_vbox.add_child(llbl)
	log_scroll.add_child(log_vbox)
	dvbox.add_child(log_scroll)

	return dvbox

func perform_attack(skill_name: String, base_dmg: int, stamina_cost: int) -> void:
	if hero1_stamina < stamina_cost:
		battle_log.append("【%s】體力不足，無法發動【%s】！" % [hero1_name, skill_name])
		build_ui()
		return

	hero1_stamina -= stamina_cost
	var dmg: int = int(base_dmg * (hero1_might / 90.0) + randi() % 6)
	hero2_hp = maxi(0, hero2_hp - dmg)

	battle_log.append("【%s】使出一招【%s】，丈八長槍如游龍出海，重創【%s】造成 %d 點傷害！" % [hero1_name, skill_name, hero2_name, dmg])

	if hero2_hp <= 0:
		battle_log.append("🏆【大勝！】敵將【%s】力竭落馬，已被我軍生擒！" % hero2_name)
		build_ui()
		return

	enemy_counter_attack()
	build_ui()

func enemy_counter_attack() -> void:
	if hero2_hp <= 0: return

	var enemy_dmg: int = int(20 * (hero2_might / 90.0) + randi() % 8)
	hero1_hp = maxi(0, hero1_hp - enemy_dmg)
	battle_log.append("【%s】橫槍反擊，凌厲逼近，對【%s】造成 %d 點傷害！" % [hero2_name, hero1_name, enemy_dmg])

	if hero1_hp <= 0:
		battle_log.append("⚠️【危險！】我方【%s】氣血不支，退回本陣！" % hero1_name)

func reset_duel() -> void:
	hero1_hp = 100
	hero1_stamina = 95
	hero2_hp = 100
	hero2_stamina = 90
	battle_log = ["演武堂大比武開始！雙方名將橫刀立馬，凜然相對！"]
