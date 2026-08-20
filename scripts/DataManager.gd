# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 全局數據庫管理器 (Data Manager)
class_name DataManager
extends RefCounted

static var heroes_db: Dictionary = {}
static var facilities_db: Dictionary = {}
static var is_initialized: bool = false

static func initialize() -> void:
	if is_initialized:
		return
	load_heroes_from_csv("res://data/Heroes/HeroDataTable.csv")
	load_facilities_from_csv("res://data/Facilities/FacilityDataTable.csv")
	is_initialized = true

static func load_heroes_from_csv(path: String) -> void:
	if not FileAccess.file_exists(path):
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return

	var header_line := file.get_line()
	var headers := header_line.split(",")

	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue

		var cols := parse_csv_line(line)
		if cols.size() < 10:
			continue

		var hero_id: String = cols[1].strip_edges()
		var display_name: String = cols[2].strip_edges()
		var nickname: String = cols[3].strip_edges()
		var star_type: String = cols[5].strip_edges()
		var vit: float = float(cols[6])
		var str_val: float = float(cols[7])
		var dex: float = float(cols[8])
		var intel: float = float(cols[9])
		var morale: float = float(cols[10]) if cols.size() > 10 else 80.0
		var aptitude_pri: String = cols[11].strip_edges() if cols.size() > 11 else "Warrior"
		var loyalty: int = int(cols[13]) if cols.size() > 13 else 90
		var portrait_file: String = "portrait_%s.jpg" % hero_id.to_lower()
		var bio: String = cols[18].strip_edges() if cols.size() > 18 else ""

		var hero_data := {
			"id": hero_id,
			"name": display_name,
			"title": nickname,
			"star": star_type,
			"vitality": vit,
			"might": str_val,
			"skill": dex,
			"intel": intel,
			"stamina_curr": int(vit),
			"stamina_max": int(vit),
			"loyalty": loyalty,
			"benevolence": int((vit + morale) * 0.45),
			"courage": int((str_val + morale) * 0.48),
			"allegiance": -1 if loyalty > 85 else loyalty,
			"aptitude": aptitude_pri,
			"portrait": portrait_file,
			"bio": "【%s · %s %s】\n%s" % [star_type, nickname, display_name, bio],
			"action": "在梁山泊駐防",
			"troops": int(morale * 10),
			"gold_salary": 20
		}

		heroes_db[hero_id] = hero_data
		heroes_db[display_name] = hero_data

	file.close()

static func load_facilities_from_csv(path: String) -> void:
	if not FileAccess.file_exists(path):
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return

	var _header := file.get_line()
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.is_empty():
			continue

		var cols := parse_csv_line(line)
		if cols.size() < 6:
			continue

		var f_type: String = cols[1].strip_edges()
		var f_name: String = cols[2].strip_edges()
		var desc: String = cols[3].strip_edges()
		var cost_gold: int = int(cols[4])
		var cost_food: int = int(cols[5])
		var turns: int = int(cols[6]) if cols.size() > 6 else 1
		var output: int = int(cols[8]) if cols.size() > 8 else 20

		facilities_db[f_type] = {
			"type": f_type,
			"name": f_name,
			"desc": desc,
			"cost_gold": cost_gold,
			"cost_food": cost_food,
			"turns": turns,
			"output": output
		}
	file.close()

static func parse_csv_line(line: String) -> Array[String]:
	var result: Array[String] = []
	var in_quotes: bool = false
	var current_field: String = ""

	for i in range(line.length()):
		var c: String = line[i]
		if c == "\"":
			in_quotes = !in_quotes
		elif c == "," and not in_quotes:
			result.append(current_field)
			current_field = ""
		else:
			current_field += c

	result.append(current_field)
	return result

static func get_hero(key: String) -> Dictionary:
	initialize()
	return heroes_db.get(key, {})

static func get_all_heroes() -> Array:
	initialize()
	var list: Array = []
	var seen: Dictionary = {}
	for k in heroes_db.keys():
		var h: Dictionary = heroes_db[k]
		if not seen.has(h["id"]):
			seen[h["id"]] = true
			list.append(h)
	return list

static func get_facility(key: String) -> Dictionary:
	initialize()
	return facilities_db.get(key, {})
