# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 2D 等角好漢角色 (載入具體精靈圖、動畫狀態機、4視角 Sprite 與滑鼠互動)
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
@export var sprite_file: String = "linchong_sprite.png"

# 精靈貼圖快取
var hero_sprite_texture: Texture2D = null
var is_hovered: bool = false

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
	load_hero_sprite_texture()
	update_screen_position_instant()

func load_hero_sprite_texture() -> void:
	var name_map := {
		"林沖": "res://assets/sprites/characters/linchong_sprite.png",
		"武松": "res://assets/sprites/characters/wusong_sprite.png",
		"魯智深": "res://assets/sprites/characters/luzhishen_sprite.png",
		"李俊": "res://assets/sprites/characters/lijun_sprite.png",
		"花榮": "res://assets/sprites/characters/huarong_sprite.png",
		"宋江": "res://assets/sprites/characters/songjiang_sprite.png",
		"吳用": "res://assets/sprites/characters/wuyong_sprite.png",
		"湯隆": "res://assets/sprites/characters/tanglong_sprite.png"
	}
	var path: String = name_map.get(hero_name, "res://assets/sprites/characters/linchong_sprite.png")
	if ResourceLoader.exists(path):
		hero_sprite_texture = load(path)

func update_screen_position_instant() -> void:
	var sx: float = (float(grid_position.x) - float(grid_position.y)) * 32.0
	var sy: float = (float(grid_position.x) + float(grid_position.y)) * 16.0
	position = Vector2(sx, sy)
	target_screen_pos = position

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
				var sx: float = (float(next_grid.x) - float(next_grid.y)) * 32.0
				var sy: float = (float(next_grid.x) + float(next_grid.y)) * 16.0
				target_screen_pos = Vector2(sx, sy)
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
	grid_position = new_grid
	var sx: float = (float(new_grid.x) - float(new_grid.y)) * 32.0
	var sy: float = (float(new_grid.x) + float(new_grid.y)) * 16.0
	target_screen_pos = Vector2(sx, sy)
	is_moving = true
	current_state = AnimState.WALK

func assign_work(job_name: String) -> void:
	assigned_job = job_name
	current_state = AnimState.WORK if job_name != "巡哨" else AnimState.IDLE
	queue_redraw()

func _draw() -> void:
	# 1. 繪製好漢影子 (腳底中心)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-12, 1), Vector2(0, -3), Vector2(12, 1), Vector2(0, 5)
	]), Color(0.0, 0.0, 0.0, 0.35))

	# 2. 繪製具體好漢精靈貼圖 (帶待機呼吸/步態擺動動畫)
	if hero_sprite_texture:
		draw_tangible_hero_sprite()
	else:
		draw_animated_hero_sprite()

	# 3. 滑鼠懸停高亮
	if is_hovered:
		draw_circle(Vector2(0, -20), 22.0, Color(1.0, 0.9, 0.2, 0.25))

	# 4. 頭頂懸浮微型數值標籤 (姓名、任務 Badge、體力條 HP/MaxHP)
	draw_overhead_badge()

## 繪製具體真實好漢精靈貼圖
func draw_tangible_hero_sprite() -> void:
	var bob_y: float = 0.0
	if current_state == AnimState.WALK:
		bob_y = sin(anim_frame * PI / 2.0) * 2.5
	elif current_state == AnimState.WORK:
		bob_y = sin(anim_timer * 12.0) * 2.0
	else:
		bob_y = sin(anim_timer * 3.0) * 1.0

	var tex_size := hero_sprite_texture.get_size()
	var dest_rect := Rect2(-tex_size.x / 2.0, -tex_size.y + 12 + bob_y, tex_size.x, tex_size.y)

	# 依照 4 視向翻轉
	if current_dir in [IsoDirection.NW, IsoDirection.SW]:
		draw_set_transform(Vector2.ZERO, 0, Vector2(-1.0, 1.0))
		draw_texture(hero_sprite_texture, Vector2(-tex_size.x / 2.0, -tex_size.y + 12 + bob_y))
		draw_set_transform(Vector2.ZERO, 0, Vector2(1.0, 1.0))
	else:
		draw_texture(hero_sprite_texture, dest_rect.position)

func draw_animated_hero_sprite() -> void:
	var bob_y: float = sin(anim_timer * 3.0) * 0.8
	draw_circle(Vector2(0, -20 + bob_y), 8.0, Color(0.9, 0.8, 0.6, 1.0))

## 繪製頭頂懸浮微型數值標籤
func draw_overhead_badge() -> void:
	var badge_rect := Rect2(-34, -58, 68, 18)
	draw_rect(badge_rect, Color(0.06, 0.09, 0.18, 0.9), true)
	draw_rect(badge_rect, Color(0.85, 0.75, 0.35, 0.9), false, 1.0)

	var job_icon: String = "⚔️"
	match assigned_job:
		"打鐵": job_icon = "⚒️"
		"農耕": job_icon = "🌾"
		"駐館": job_icon = "🍺"
		"操練": job_icon = "🥋"
		_: job_icon = "🚩"

	var stat_text := "%s %s %d/%d" % [job_icon, hero_name, current_energy, current_stamina]
	var default_font := ThemeDB.fallback_font
	draw_string(default_font, Vector2(-32, -45), stat_text, HORIZONTAL_ALIGNMENT_CENTER, 64, 9, Color(1.0, 0.95, 0.7, 1.0))

	# 微型體力血條 (綠/紅漸變)
	var bar_ratio: float = clampf(float(current_stamina) / float(max_stamina), 0.0, 1.0)
	var bar_width: float = 62.0 * bar_ratio
	draw_rect(Rect2(-31, -43, 62, 2), Color(0.3, 0.1, 0.1, 0.8))
	draw_rect(Rect2(-31, -43, bar_width, 2), Color(0.2, 0.85, 0.3, 1.0))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var local_m := to_local(event.position)
		var hover_now: bool = (local_m.distance_to(Vector2(0, -20)) < 26.0)
		if hover_now != is_hovered:
			is_hovered = hover_now
			queue_redraw()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_local := to_local(event.position)
		if mouse_local.distance_to(Vector2(0, -20)) < 26.0:
			hero_selected.emit(self)
