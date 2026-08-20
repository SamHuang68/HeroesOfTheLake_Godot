# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 00~36 角色 3D/2.5D 模型視覺控制器與全動作狀態機 (Hero Visual Controller)
class_name HeroVisualController
extends Node2D

const CharacterModelDatabaseScript = preload("res://scripts/CharacterModelDatabase.gd")

## 18 大通用動畫狀態列舉
enum AnimState {
	# A. 通用移動與大地圖行為 (Movement)
	LOCOMOTION_IDLE,       ## 0: 原地呼吸、環視周圍
	LOCOMOTION_WALK,       ## 1: 標準等角行進步態
	LOCOMOTION_RUN,        ## 2: 戰鬥奔走步伐

	# B. 戰鬥與技能行為 (Combat & Tactical)
	COMBAT_ATTACK,         ## 3: 向前揮砍/突刺/射擊
	COMBAT_RAZE,           ## 4: 攻擊破壞地面工事
	COMBAT_MORALE_HIGH,    ## 5: 士氣高昂振臂歡呼
	COMBAT_CAST_SPELL,     ## 6: 施法結印光芒匯聚
	COMBAT_SEDUCE,         ## 7: 色誘 (女性專屬搖曳絲帕 / 男性 Fallback 至高昂)

	# C. 設施勞作與休閒行為 (Facility Work Loops)
	WORK_TAVERN,           ## 8: 喝酒 (酒館) - 仰頭痛飲擦嘴
	WORK_FARM,             ## 9: 種田 (耕地) - 彎腰翻土擦汗
	WORK_FISH,             ## 10: 捕魚 (魚場) - 持竿垂釣收竿
	WORK_MARKET,           ## 11: 買賣 (市場) - 撥算盤比劃推銷
	WORK_BLACKSMITH,       ## 12: 打鐵 (鐵匠鋪) - 掄錘重擊鐵砧帶火花
	WORK_SHIPYARD,         ## 13: 修船 (造船廠) - 推拉木工鋸修整船板
	WORK_TAOIST,           ## 14: 讀經 (道館) - 盤坐冥想誦念
	WORK_ALCHEMY,          ## 15: 煉丹 (藥鋪) - 藥杵搗藥扇爐火
	WORK_PLEASURE,         ## 16: 遊樂 (鬧市) - 拍手看戲拋銅錢
	WORK_RANCH             ## 17: 養馬 (牧場) - 乾草叉餵食撫摸馬頸
}

## 4 視向方向
enum IsoDirection { NE, SE, SW, NW }

@export var model_id: String = "00" # 00 ~ 36
@export var hero_name: String = "好漢"
@export var is_female: bool = false

var current_state: int = AnimState.LOCOMOTION_IDLE
var current_dir: int = IsoDirection.SW

var base_sprite_texture: Texture2D = null
var anim_timer: float = 0.0
var anim_frame: int = 0
var action_elapsed: float = 0.0

# 網格座標與螢幕座標
var grid_position: Vector2i = Vector2i(16, 16)
var target_screen_pos: Vector2 = Vector2.ZERO
var is_moving: bool = false
var move_speed: float = 120.0
var path_points: Array[Vector2i] = []

# 屬性數值
var current_stamina: int = 100
var max_stamina: int = 100
var assigned_facility_type: String = ""

# 掛載骨節 (Socket Nodes) 變數
var socket_r_item: String = "none"
var socket_l_item: String = "none"

signal action_state_changed(hero_inst, new_state: int)
signal character_clicked(hero_inst)

func _ready() -> void:
	z_as_relative = true
	setup_model_data()
	load_model_texture()
	update_screen_position_instant()

func setup_model_data() -> void:
	var info: Dictionary = CharacterModelDatabaseScript.get_model_info(model_id)
	is_female = info.get("is_female", false)
	socket_r_item = info.get("r_socket", "none")
	socket_l_item = info.get("l_socket", "none")

func load_model_texture() -> void:
	var path := "res://assets/sprites/characters_39/char_%s.png" % model_id
	if ResourceLoader.exists(path):
		base_sprite_texture = load(path)
	elif ResourceLoader.exists("res://assets/sprites/characters_39/char_00.png"):
		base_sprite_texture = load("res://assets/sprites/characters_39/char_00.png")

func update_screen_position_instant() -> void:
	var sx: float = (float(grid_position.x) - float(grid_position.y)) * 32.0
	var sy: float = (float(grid_position.x) + float(grid_position.y)) * 16.0
	position = Vector2(sx, sy)
	target_screen_pos = position

func _process(delta: float) -> void:
	anim_timer += delta
	action_elapsed += delta

	# 動畫幀率更新 (30 FPS)
	if anim_timer >= 0.08:
		anim_timer = 0.0
		anim_frame = (anim_frame + 1) % 60

	# 移動狀態邏輯
	if is_moving:
		current_state = AnimState.LOCOMOTION_WALK
		var dir_vec := (target_screen_pos - position).normalized()
		update_facing_direction(dir_vec)

		position = position.move_toward(target_screen_pos, move_speed * delta)
		if position.distance_to(target_screen_pos) < 2.0:
			position = target_screen_pos
			if path_points.size() > 0:
				var next_grid: Vector2i = path_points.pop_front()
				grid_position = next_grid
				var sx: float = (float(next_grid.x) - float(next_grid.y)) * 32.0
				var sy: float = (float(next_grid.x) + float(next_grid.y)) * 16.0
				target_screen_pos = Vector2(sx, sy)
			else:
				is_moving = false
				# 抵達目的地後切換回設施工作或待機
				if assigned_facility_type != "":
					play_facility_work(assigned_facility_type)
				else:
					current_state = AnimState.LOCOMOTION_IDLE

	queue_redraw()

func update_facing_direction(dir_vec: Vector2) -> void:
	if dir_vec.x >= 0 and dir_vec.y < 0:
		current_dir = IsoDirection.NE
	elif dir_vec.x >= 0 and dir_vec.y >= 0:
		current_dir = IsoDirection.SE
	elif dir_vec.x < 0 and dir_vec.y < 0:
		current_dir = IsoDirection.NW
	else:
		current_dir = IsoDirection.SW

## 依據設施類型切換為無縫工作動畫循環
func play_facility_work(facility_type: String) -> void:
	assigned_facility_type = facility_type
	match facility_type:
		"tavern", "Tavern", "酒館":
			current_state = AnimState.WORK_TAVERN
			socket_r_item = "wine_bowl"
		"farmland", "farm", "Farm", "農田", "耕地":
			current_state = AnimState.WORK_FARM
			socket_r_item = "hoe"
		"fishery", "fish", "魚場", "水泊":
			current_state = AnimState.WORK_FISH
			socket_r_item = "rod"
		"market", "Market", "市場", "集市":
			current_state = AnimState.WORK_MARKET
			socket_r_item = "abacus"
		"blacksmith", "Smithy", "鐵匠鋪":
			current_state = AnimState.WORK_BLACKSMITH
			socket_r_item = "hammer"
		"shipyard", "Shipyard", "造船廠", "碼頭":
			current_state = AnimState.WORK_SHIPYARD
			socket_r_item = "saw"
		"taoist_temple", "Daoist", "道館":
			current_state = AnimState.WORK_TAOIST
			socket_r_item = "scroll"
		"pharmacy", "Pharmacy", "藥鋪":
			current_state = AnimState.WORK_ALCHEMY
			socket_r_item = "pestle"
		"downtown", "Pleasure", "鬧市":
			current_state = AnimState.WORK_PLEASURE
			socket_r_item = "coin"
		"pasture", "Pasture", "牧場":
			current_state = AnimState.WORK_RANCH
			socket_r_item = "pitchfork"
		_:
			current_state = AnimState.LOCOMOTION_IDLE

	action_state_changed.emit(self, current_state)

## 觸發戰鬥技能與特殊行為 (含女性專屬色誘與男性 Fallback)
func play_skill(skill_type: String) -> void:
	match skill_type:
		"seduce", "色誘":
			if is_female:
				current_state = AnimState.COMBAT_SEDUCE
				socket_r_item = "silk"
			else:
				# 男性角色防呆 fallback 至士氣高昂
				current_state = AnimState.COMBAT_MORALE_HIGH
		"magic", "cast_spell", "施法":
			current_state = AnimState.COMBAT_CAST_SPELL
			socket_r_item = "whisk"
		"attack", "攻擊":
			current_state = AnimState.COMBAT_ATTACK
		"raze", "破壞":
			current_state = AnimState.COMBAT_RAZE
		"morale", "高昂":
			current_state = AnimState.COMBAT_MORALE_HIGH
		_:
			current_state = AnimState.LOCOMOTION_IDLE

	action_state_changed.emit(self, current_state)

func move_to_grid(new_grid: Vector2i) -> void:
	grid_position = new_grid
	var sx: float = (float(new_grid.x) - float(new_grid.y)) * 32.0
	var sy: float = (float(new_grid.x) + float(new_grid.y)) * 16.0
	target_screen_pos = Vector2(sx, sy)
	is_moving = true
	current_state = AnimState.LOCOMOTION_WALK

func _draw() -> void:
	# 1. 橢圓地面陰影 (Root Motion Projection)
	draw_ellipse_shadow()

	# 2. 角色身體精靈本體 (含動態姿態變換與 3D 傾斜)
	draw_character_body()

	# 3. 動態掛載骨節 (Socket Items: 武器、鋤頭、鐵鎚、酒碗等)
	draw_socket_items()

	# 4. 戰鬥與工作特效粒子 (火花、水波、愛心、符咒)
	draw_action_particles()

	# 5. 頭頂資訊浮動木牌 (Head Socket: 姓名與精力條)
	draw_head_socket_ui()

func draw_ellipse_shadow() -> void:
	var shadow_pts := PackedVector2Array()
	var breath_scale := 1.0 + sin(action_elapsed * 4.0) * 0.05
	for i in range(16):
		var angle := i * TAU / 16.0
		var px := cos(angle) * 14.0 * breath_scale
		var py := sin(angle) * 7.0 * breath_scale
		shadow_pts.append(Vector2(px, py))
	draw_colored_polygon(shadow_pts, Color(0.0, 0.0, 0.0, 0.35))

func draw_character_body() -> void:
	var offset := Vector2.ZERO
	var flip_h: bool = (current_dir in [IsoDirection.NW, IsoDirection.SW])

	# 依照 18 大動畫狀態計算動態位移與姿態
	match current_state:
		AnimState.LOCOMOTION_IDLE:
			offset.y = sin(action_elapsed * 3.5) * 1.5
		AnimState.LOCOMOTION_WALK:
			offset.y = -abs(sin(action_elapsed * 9.0)) * 4.0
		AnimState.LOCOMOTION_RUN:
			offset.y = -abs(sin(action_elapsed * 14.0)) * 6.0
		AnimState.COMBAT_ATTACK:
			var swing := sin(action_elapsed * 12.0)
			offset.x = swing * 8.0 if not flip_h else -swing * 8.0
			offset.y = -abs(swing) * 3.0
		AnimState.COMBAT_RAZE:
			var smash := sin(action_elapsed * 10.0)
			offset.y = smash * 6.0
		AnimState.COMBAT_MORALE_HIGH:
			offset.y = -abs(sin(action_elapsed * 8.0)) * 8.0
		AnimState.COMBAT_CAST_SPELL:
			offset.y = -6.0 + sin(action_elapsed * 6.0) * 3.0 # 懸浮
		AnimState.COMBAT_SEDUCE:
			offset.x = sin(action_elapsed * 5.0) * 4.0
			offset.y = cos(action_elapsed * 5.0) * 2.0
		AnimState.WORK_TAVERN:
			offset.y = sin(action_elapsed * 4.0) * 2.0
		AnimState.WORK_FARM:
			var hoe_swing := sin(action_elapsed * 6.0)
			offset.y = hoe_swing * 4.0
		AnimState.WORK_BLACKSMITH:
			var hammer_hit := sin(action_elapsed * 8.0)
			offset.y = hammer_hit * 5.0
		_:
			offset.y = sin(action_elapsed * 3.0) * 1.5

	if base_sprite_texture:
		var tex_w: float = 48.0
		var tex_h: float = 60.0
		var dest_rect := Rect2(-tex_w / 2.0 + offset.x, -tex_h + offset.y, tex_w, tex_h)
		if flip_h:
			dest_rect.position.x += tex_w
			dest_rect.size.x = -tex_w
		draw_texture_rect(base_sprite_texture, dest_rect, false)
	else:
		# Fallback 膠囊體繪製
		var body_col := Color(0.8, 0.3, 0.2) if not is_female else Color(0.9, 0.4, 0.7)
		draw_circle(Vector2(0, -32) + offset, 12.0, body_col)

func draw_socket_items() -> void:
	var hand_pos := Vector2(16, -26) if current_dir in [IsoDirection.SE, IsoDirection.NE] else Vector2(-16, -26)

	match socket_r_item:
		"spear", "halberd":
			draw_line(hand_pos + Vector2(-6, 12), hand_pos + Vector2(10, -24), Color(0.6, 0.4, 0.2), 2.5)
			draw_line(hand_pos + Vector2(10, -24), hand_pos + Vector2(14, -30), Color(0.9, 0.9, 0.95), 3.0)
		"blade", "sword":
			draw_line(hand_pos, hand_pos + Vector2(12, -14), Color(0.85, 0.85, 0.9), 2.5)
		"axe":
			draw_line(hand_pos + Vector2(-4, 6), hand_pos + Vector2(8, -12), Color(0.5, 0.35, 0.2), 2.5)
			draw_circle(hand_pos + Vector2(8, -12), 5.0, Color(0.7, 0.7, 0.75))
		"hoe": # 種田鋤頭
			var swing_angle := sin(action_elapsed * 6.0) * 0.5
			var tip := hand_pos + Vector2(10, 10).rotated(swing_angle)
			draw_line(hand_pos, tip, Color(0.55, 0.38, 0.2), 2.5)
			draw_line(tip, tip + Vector2(4, 2), Color(0.4, 0.4, 0.45), 3.5)
		"hammer": # 打鐵鐵鎚
			var h_angle := sin(action_elapsed * 8.0) * 0.7
			var h_tip := hand_pos + Vector2(12, -8).rotated(h_angle)
			draw_line(hand_pos, h_tip, Color(0.6, 0.4, 0.2), 2.5)
			draw_circle(h_tip, 4.0, Color(0.3, 0.3, 0.35))
		"wine_bowl": # 喝酒大碗
			draw_circle(hand_pos + Vector2(0, -4), 4.0, Color(0.8, 0.7, 0.5))
			draw_circle(hand_pos + Vector2(0, -4), 2.5, Color(0.9, 0.3, 0.2))
		"rod": # 捕魚釣竿
			draw_line(hand_pos, hand_pos + Vector2(18, -26), Color(0.7, 0.5, 0.3), 1.5)
			draw_line(hand_pos + Vector2(18, -26), hand_pos + Vector2(24, 6), Color(0.9, 0.9, 1.0, 0.6), 1.0)
		"abacus": # 算盤
			draw_rect(Rect2(hand_pos.x, hand_pos.y - 4, 10, 8), Color(0.45, 0.3, 0.2), true)
		"silk": # 色誘絲帕
			var wave := sin(action_elapsed * 10.0) * 4.0
			draw_line(hand_pos, hand_pos + Vector2(8 + wave, 6), Color(1.0, 0.6, 0.8, 0.9), 3.0)

func draw_action_particles() -> void:
	match current_state:
		AnimState.WORK_BLACKSMITH: # 鐵匠打鐵火花
			if sin(action_elapsed * 8.0) > 0.6:
				for i in range(4):
					var sp_off := Vector2(randf_range(-10, 10), randf_range(-14, 0))
					draw_circle(Vector2(12, -10) + sp_off, 1.5, Color(1.0, 0.8, 0.2, 0.9))
		AnimState.COMBAT_SEDUCE: # 色誘粉紅愛心
			var h_y := -55.0 - (fmod(action_elapsed * 25.0, 30.0))
			draw_circle(Vector2(sin(action_elapsed * 6.0) * 8.0, h_y), 3.0, Color(1.0, 0.4, 0.7, 0.85))
		AnimState.COMBAT_CAST_SPELL: # 施法八卦太極光圈
			var r := 20.0 + sin(action_elapsed * 8.0) * 4.0
			draw_arc(Vector2(0, -25), r, 0, TAU, 16, Color(0.4, 0.8, 1.0, 0.6), 2.0)
		AnimState.WORK_TAVERN: # 豪飲酒滴
			draw_circle(Vector2(14, -20) + Vector2(0, fmod(action_elapsed * 30.0, 15.0)), 1.2, Color(0.9, 0.7, 0.4, 0.8))

func draw_head_socket_ui() -> void:
	# 1. 復古木牌底色
	var name_box := Rect2(-24, -72, 48, 14)
	draw_rect(name_box, Color(0.12, 0.10, 0.08, 0.85), true)
	draw_rect(name_box, Color(0.9, 0.75, 0.4, 0.9), false, 1.0)

	# 2. 綠色精力條
	var bar_bg := Rect2(-22, -56, 44, 4)
	draw_rect(bar_bg, Color(0.2, 0.2, 0.2, 0.8), true)
	var st_ratio: float = clampf(float(current_stamina) / float(max_stamina), 0.0, 1.0)
	var bar_fg := Rect2(-22, -56, 44.0 * st_ratio, 4)
	draw_rect(bar_fg, Color(0.2, 0.85, 0.3, 0.9), true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var local_mouse := to_local(event.position)
		if Rect2(-24, -65, 48, 65).has_point(local_mouse):
			character_clicked.emit(self)
