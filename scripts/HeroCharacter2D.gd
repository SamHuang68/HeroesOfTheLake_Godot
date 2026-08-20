# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 2D 等角好漢角色 (動畫狀態機、4視角 Sprite 與指派工作動態)
class_name HeroCharacter2D
extends Node2D

## 動畫狀態定義
enum AnimState {
	IDLE,  ## 原地待機/呼吸
	WALK,  ## 網格移動行走
	WORK   ## 設施勞作/建造/操練
}

## 4 個等角視向
enum IsoDirection {
	NE, ## 東北 (右上)
	SE, ## 東南 (右下)
	NW, ## 西北 (左上)
	SW  ## 西南 (左下)
}

@export var hero_name: String = "林沖"
@export var title_name: String = "豹子頭"
@export var current_stamina: int = 94
@export var max_stamina: int = 95
@export var current_energy: int = 47
@export var max_energy: int = 100
@export var grid_position: Vector2i = Vector2i(16, 16)
@export var move_speed: float = 80.0
@export var portrait_file: String = "portrait_linchong.jpg"

# 狀態機與動畫變數
var current_state: AnimState = AnimState.IDLE
var current_dir: IsoDirection = IsoDirection.SE
var assigned_job: String = "巡哨" # "巡哨", "打鐵", "農耕", "駐館", "操練"
var anim_timer: float = 0.0
var anim_frame: int = 0

var target_screen_pos: Vector2 = Vector2.ZERO
var is_moving: bool = false
var path_points: Array[Vector2i] = []

signal hero_selected(hero: Node2D)

func _ready() -> void:
	z_as_relative = true
	update_screen_position_instant()

## 立即同步網格位置至螢幕像素 (錨點 Pivot 設在雙腳底部 (0, 0))
func update_screen_position_instant() -> void:
	var map: Node2D = get_parent()
	if map and map.has_method("grid_to_screen"):
		position = map.call("grid_to_screen", grid_position.x, grid_position.y)

func _process(delta: float) -> void:
	anim_timer += delta
	if anim_timer >= 0.18:
		anim_timer = 0.0
		anim_frame = (anim_frame + 1) % 4

	# 移動邏輯
	if is_moving:
		current_state = AnimState.WALK
		var dir_vec := (target_screen_pos - position).normalized()
		update_facing_direction(dir_vec)

		position = position.move_toward(target_screen_pos, move_speed * delta)
		if position.distance_to(target_screen_pos) < 2.0:
			position = target_screen_pos
			if path_points.size() > 0:
				var next_grid: Vector2i = path_points.pop_front()
				grid_position = next_grid
				var map: Node2D = get_parent()
				if map and map.has_method("grid_to_screen"):
					target_screen_pos = map.call("grid_to_screen", next_grid.x, next_grid.y)
			else:
				is_moving = false
				current_state = AnimState.WORK if assigned_job != "巡哨" else AnimState.IDLE
	else:
		if assigned_job != "巡哨":
			current_state = AnimState.WORK
		else:
			current_state = AnimState.IDLE

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

func move_to_grid(new_grid: Vector2i) -> void:
	var map: Node2D = get_parent()
	if map and map.has_method("grid_to_screen"):
		grid_position = new_grid
		target_screen_pos = map.call("grid_to_screen", new_grid.x, new_grid.y)
		is_moving = true
		current_state = AnimState.WALK

func assign_work(job_name: String) -> void:
	assigned_job = job_name
	current_state = AnimState.WORK if job_name != "巡哨" else AnimState.IDLE
	queue_redraw()

func _draw() -> void:
	# 1. 繪製好漢影子 (腳底中心)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-11, 1), Vector2(0, -3), Vector2(11, 1), Vector2(0, 5)
	]), Color(0.0, 0.0, 0.0, 0.35))

	# 2. 依照動畫狀態與 4 視向繪製精靈 Sprite 幀動作
	draw_animated_hero_sprite()

	# 3. 頭頂懸浮微型數值標籤 (姓名、任務 Badge、體力氣力條)
	draw_overhead_badge()

## 繪製好漢 4 視向動畫 Sprite
func draw_animated_hero_sprite() -> void:
	# 待機呼吸 / 行走顛簸 / 勞作揮動
	var bob_y: float = 0.0
	var leg_swing: float = 0.0
	var arm_swing: float = 0.0

	if current_state == AnimState.WALK:
		bob_y = sin(anim_frame * PI / 2.0) * 2.0
		leg_swing = sin(anim_frame * PI / 2.0) * 3.5
	elif current_state == AnimState.WORK:
		arm_swing = sin(anim_timer * 15.0) * 8.0
	else: # IDLE
		bob_y = sin(anim_timer * 3.0) * 0.8

	var flip_x: float = -1.0 if (current_dir in [IsoDirection.NW, IsoDirection.SW]) else 1.0

	# 雙腿
	draw_line(Vector2(-3 * flip_x + leg_swing, 0 + bob_y), Vector2(-3 * flip_x, -7 + bob_y), Color(0.15, 0.15, 0.2, 1.0), 2.5)
	draw_line(Vector2(3 * flip_x - leg_swing, 0 + bob_y), Vector2(3 * flip_x, -7 + bob_y), Color(0.15, 0.15, 0.2, 1.0), 2.5)

	# 白袍長衫與戰甲
	draw_colored_polygon(PackedVector2Array([
		Vector2(-7 * flip_x, -6 + bob_y), Vector2(7 * flip_x, -6 + bob_y),
		Vector2(8 * flip_x, 1 + bob_y), Vector2(-8 * flip_x, 1 + bob_y)
	]), Color(0.88, 0.88, 0.85, 1.0)) # 白袍

	draw_colored_polygon(PackedVector2Array([
		Vector2(-6 * flip_x, -18 + bob_y), Vector2(6 * flip_x, -18 + bob_y),
		Vector2(7 * flip_x, -6 + bob_y), Vector2(-7 * flip_x, -6 + bob_y)
	]), Color(0.2, 0.35, 0.65, 1.0)) # 藍甲

	# 頭部與白氈笠
	draw_circle(Vector2(0, -23 + bob_y), 5.5, Color(0.95, 0.80, 0.65, 1.0))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-9 * flip_x, -26 + bob_y), Vector2(9 * flip_x, -26 + bob_y), Vector2(0, -32 + bob_y)
	]), Color(0.92, 0.90, 0.82, 1.0)) # 白氈大帽

	# 武器 / 勞作工具
	if current_state == AnimState.WORK:
		if assigned_job == "打鐵":
			# 鐵鎚揮擊
			draw_line(Vector2(4 * flip_x, -12 + bob_y), Vector2(10 * flip_x + arm_swing, -22 + bob_y - arm_swing), Color(0.4, 0.25, 0.15, 1.0), 2.5)
			draw_rect(Rect2(8 * flip_x + arm_swing, -26 + bob_y - arm_swing, 6, 4), Color(0.5, 0.5, 0.55, 1.0))
		elif assigned_job == "農耕":
			# 鋤頭
			draw_line(Vector2(4 * flip_x, -10 + bob_y), Vector2(12 * flip_x, 4 + bob_y + arm_swing * 0.5), Color(0.4, 0.25, 0.15, 1.0), 2.5)
		else:
			# 操練槍棒
			draw_line(Vector2(4 * flip_x, -10 + bob_y), Vector2(14 * flip_x + arm_swing, -34 + bob_y), Color(0.7, 0.5, 0.3, 1.0), 2.0)
	else:
		# 佩長槍
		draw_line(Vector2(4 * flip_x, 1 + bob_y), Vector2(12 * flip_x, -36 + bob_y), Color(0.7, 0.5, 0.3, 1.0), 2.0)
		draw_line(Vector2(12 * flip_x, -36 + bob_y), Vector2(14 * flip_x, -42 + bob_y), Color(0.9, 0.9, 0.9, 1.0), 2.5)

## 繪製頭頂懸浮微型數值標籤 (顯示姓名、體力條 HP/MaxHP、指派任務圖示)
func draw_overhead_badge() -> void:
	var badge_rect := Rect2(-32, -58, 64, 18)
	draw_rect(badge_rect, Color(0.06, 0.09, 0.18, 0.9), true)
	draw_rect(badge_rect, Color(0.85, 0.75, 0.35, 0.9), false, 1.0)

	# 任務圖示
	var job_icon: String = "⚔️"
	match assigned_job:
		"打鐵": job_icon = "⚒️"
		"農耕": job_icon = "🌾"
		"駐館": job_icon = "🍺"
		"操練": job_icon = "🥋"
		_: job_icon = "🚩"

	var stat_text := "%s %s %d/%d" % [job_icon, hero_name, current_energy, current_stamina]
	var default_font := ThemeDB.fallback_font
	draw_string(default_font, Vector2(-30, -45), stat_text, HORIZONTAL_ALIGNMENT_CENTER, 60, 9, Color(1.0, 0.95, 0.7, 1.0))

	# 微型體力血條 (綠/紅漸變)
	var bar_ratio: float = clampf(float(current_stamina) / float(max_stamina), 0.0, 1.0)
	var bar_width: float = 58.0 * bar_ratio
	draw_rect(Rect2(-29, -43, 58, 2), Color(0.3, 0.1, 0.1, 0.8))
	draw_rect(Rect2(-29, -43, bar_width, 2), Color(0.2, 0.85, 0.3, 1.0))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_local := to_local(event.position)
		if mouse_local.distance_to(Vector2(0, -20)) < 25.0:
			hero_selected.emit(self)
