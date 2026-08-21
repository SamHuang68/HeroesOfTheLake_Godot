# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 2.5D 自然地貌物件 (松樹、柳樹、銀杏、巨石、水泊蘆葦)
class_name IsometricDecor
extends Node2D

enum DecorType {
	PINE_TREE,    # 蒼勁青松 (高山密林)
	WILLOW_TREE,  # 垂柳 (水泊湖畔)
	GINKGO_TREE,  # 金黃銀杏
	BOULDER,      # 嶙峋巨石 / 碎岩
	WATER_REEDS   # 水泊蘆葦叢
}

@export var decor_type: DecorType = DecorType.PINE_TREE
@export var grid_coord: Vector2i = Vector2i(0, 0)

var decor_texture: Texture2D = null

func _ready() -> void:
	z_as_relative = true
	load_decor_texture()
	update_screen_position()

func load_decor_texture() -> void:
	var path_map := {
		DecorType.PINE_TREE: "res://assets/sprites/decorations/tree_pine.png",
		DecorType.WILLOW_TREE: "res://assets/sprites/decorations/tree_willow.png",
		DecorType.GINKGO_TREE: "res://assets/sprites/decorations/tree_ginkgo.png",
		DecorType.BOULDER: "res://assets/sprites/decorations/rock_boulder.png",
		DecorType.WATER_REEDS: "res://assets/sprites/decorations/reeds_water.png"
	}
	var tex_path: String = path_map.get(decor_type, "")
	if ResourceLoader.exists(tex_path):
		decor_texture = load(tex_path)

func update_screen_position() -> void:
	var sx: float = (float(grid_coord.x) - float(grid_coord.y)) * 32.0
	var sy: float = (float(grid_coord.x) + float(grid_coord.y)) * 16.0
	position = Vector2(sx, sy)
	z_index = int(position.y)

func _draw() -> void:
	# 1. 貼地橢圓陰影 (Drop Shadow)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-14, 0), Vector2(0, -6), Vector2(14, 0), Vector2(0, 6)
	]), Color(0.0, 0.0, 0.0, 0.35))

	# 2. 渲染 2.5D 精靈本體 (腳底固定釘在 (0, 0))
	if decor_texture:
		var tex_size := decor_texture.get_size()
		var dest_pos := Vector2(-tex_size.x / 2.0, -tex_size.y + 6.0)
		draw_texture(decor_texture, dest_pos)
