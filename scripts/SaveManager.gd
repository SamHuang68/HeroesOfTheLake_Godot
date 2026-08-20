# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 存檔讀檔管理器 (Save Manager)
class_name SaveManager
extends RefCounted

const SAVE_DIR := "user://saves/"

static func get_save_dir() -> String:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	return SAVE_DIR

static func get_save_file_path(slot: int) -> String:
	return "%ssave_slot_%02d.json" % [get_save_dir(), slot]

static func save_game(slot: int, game_data: Dictionary) -> bool:
	var path := get_save_file_path(slot)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		return false

	var json_str := JSON.stringify(game_data, "\t")
	file.store_string(json_str)
	file.close()
	return true

static func load_game(slot: int) -> Dictionary:
	var path := get_save_file_path(slot)
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}

	var json_str := file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(json_str)
	if parsed is Dictionary:
		return parsed
	return {}

static func get_save_slots_info() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for slot in range(1, 6):
		var path := get_save_file_path(slot)
		if FileAccess.file_exists(path):
			var data := load_game(slot)
			result.append({
				"slot": slot,
				"exists": true,
				"year": data.get("year", 1101),
				"month": data.get("month", 6),
				"prestige": data.get("prestige", 350),
				"leader": data.get("leader", "林沖"),
				"gold": data.get("gold", 10000)
			})
		else:
			result.append({
				"slot": slot,
				"exists": false
			})
	return result