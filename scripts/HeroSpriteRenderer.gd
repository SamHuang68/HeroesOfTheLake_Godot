# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 8 方向 × 18 動作 × 8 影格 2.5D 等角動畫精靈渲染器 (Hero Sprite Renderer)
class_name HeroSpriteRenderer
extends Node2D

@export var model_id: String = "00"
@export var current_action: String = "Locomotion_Idle"
@export var current_dir: int = 1 # 0:S, 1:SW, 2:W, 3:NW, 4:N, 5:NE, 6:E, 7:SE
@export var fps: float = 10.0

var shadow_sprite: Sprite2D = null
var animated_sprite: AnimatedSprite2D = null
var current_spritesheet: Texture2D = null
var action_elapsed: float = 0.0
var current_frame_idx: int = 0

# 快取已載入之 SpriteSheet
var _sheet_cache: Dictionary = {}

func _init() -> void:
	_ensure_shadow_sprite()

func _ready() -> void:
	y_sort_enabled = true
	_ensure_shadow_sprite()
	_load_action_sheet(current_action)

func _ensure_shadow_sprite() -> void:
	if shadow_sprite == null:
		shadow_sprite = Sprite2D.new()
		shadow_sprite.name = "ShadowSprite"
		var shadow_tex_path := "res://assets/common/blob_shadow.png"
		if ResourceLoader.exists(shadow_tex_path):
			shadow_sprite.texture = load(shadow_tex_path)
		shadow_sprite.position = Vector2(0, 0)
		shadow_sprite.modulate = Color(0.0, 0.0, 0.0, 0.45)
		shadow_sprite.z_index = -1
		if get_node_or_null("ShadowSprite") == null:
			add_child(shadow_sprite)

func _load_action_sheet(action_name: String) -> void:
	current_action = action_name
	var sheet_path := "res://assets/sprites/animations_8dir/char_%s/%s.png" % [model_id, action_name]
	
	if _sheet_cache.has(sheet_path):
		current_spritesheet = _sheet_cache[sheet_path]
	elif ResourceLoader.exists(sheet_path):
		current_spritesheet = load(sheet_path)
		_sheet_cache[sheet_path] = current_spritesheet
	else:
		# Fallback 到 00 模型
		var fallback_path := "res://assets/sprites/animations_8dir/char_00/%s.png" % action_name
		if ResourceLoader.exists(fallback_path):
			current_spritesheet = load(fallback_path)
			_sheet_cache[fallback_path] = current_spritesheet

## 依視角 (0~7) 與動作名稱動態播放 8 幀動畫
func play_action_direction(action_name: String, dir_index: int) -> void:
	if current_action != action_name:
		_load_action_sheet(action_name)
	current_dir = clamp(dir_index, 0, 7)
	queue_redraw()

func _process(delta: float) -> void:
	action_elapsed += delta
	var frame_duration: float = 1.0 / fps
	var new_frame: int = int(fmod(action_elapsed / frame_duration, 8.0))
	if new_frame != current_frame_idx:
		current_frame_idx = new_frame
		queue_redraw()

func _draw() -> void:
	if current_spritesheet:
		# 從 512x512 SpriteSheet 中擷取當前方向 (row: current_dir) 與當前影格 (col: current_frame_idx)
		var src_rect := Rect2(current_frame_idx * 64, current_dir * 64, 64, 64)
		# 影格錨點 (Pivot) 強制固定於腳底接觸面正中心 (0.5, 0.92)
		var dest_pos := Vector2(-32, -59)
		draw_texture_rect_region(current_spritesheet, Rect2(dest_pos, Vector2(64, 64)), src_rect)
