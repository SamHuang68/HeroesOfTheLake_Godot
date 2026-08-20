# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 存檔讀檔管理器 (Save Manager)
class_name SaveManager
extends RefCounted

# Constants for save file format
const SAVE_FILE_EXTENSION := ".sk2"
const SAVE_FILE_PREFIX := "User"
const MAX_SAVE_SLOTS := 10

# Hero data offsets in save file (based on Suikoden II format)
const HERO_DATA_START := 0x0000
const HERO_DATA_SIZE := 0x0060  # 96 bytes per hero
const MAX_HEROES := 108

# Game state offsets
const GAME_STATE_OFFSET := 0x4200  # After hero data
const FAME_OFFSET := GAME_STATE_OFFSET + 0x00
const MONTH_OFFSET := GAME_STATE_OFFSET + 0x02
const DAY_OFFSET := GAME_STATE_OFFSET + 0x03
const YEAR_OFFSET := GAME_STATE_OFFSET + 0x04

func initialize() -> void:
	# Ensure save directory exists
	var save_dir := "user://saves/"
	if not DirectoryAccess.dir_exists(save_dir):
		var dir := DirectoryAccess.create()
		dir.make_dir(save_dir)

func get_save_file_path(slot: int) -> String:
	return "user://saves/%s%02d%s" % [SAVE_FILE_PREFIX, slot, SAVE_FILE_EXTENSION]

func save_game(slot: int, game_data: Dictionary) -> Error:
	var file := FileAccess.open(get_save_file_path(slot), FileAccess.WRITE)
	if not file:
		return FAILED
	
	# Save hero data (108 heroes * 96 bytes each = 10368 bytes)
	var heroes_data := game_data.get("heroes", [])
	for i in range(MAX_HEROES):
		if i < heroes_data.size():
			var hero := heroes_data[i]
			# Write hero data in Suikoden II format
			file.store_32(hero.get("strength", 0))        # 0x00-0x03
			file.store_32(hero.get("skill", 0))           # 0x04-0x07
			file.store_32(hero.get("intelligence", 0))    # 0x08-0x0B
			file.store_8(hero.get("energy", 0))           # 0x0C
			file.store_8(hero.get("loyalty", 0))          # 0x0D
			file.store_8(hero.get("benevolence", 0))      # 0x0E
			file.store_8(hero.get("courage", 0))          # 0x0F
			file.store_8(hero.get("allegiance", 0))       # 0x10
			file.store_16(hero.get("stamina_max", 0))     # 0x11-0x12
			file.store_16(hero.get("stamina_curr", 0))    # 0x13-0x14
			file.store_16(hero.get("troops", 0))          # 0x15-0x16
			file.store_8(hero.get("profession_1", 0))     # 0x17
			file.store_8(hero.get("profession_1_exp", 0)) # 0x18
			file.store_8(hero.get("profession_2", 0))     # 0x19
			file.store_8(hero.get("profession_2_exp", 0)) # 0x1A
			file.store_8(hero.get("sworn_brothers", 0))   # 0x1B
			file.store_8(hero.get("infantry_ability", 0)) # 0x1C
			file.store_8(hero.get("cavalry_ability", 0))  # 0x1D
			file.store_8(hero.get("naval_ability", 0))    # 0x1E
			file.store_8(hero.get("weapon", 0))           # 0x1F
			file.store_8(hero.get("armor", 0))            # 0x20
			file.store_8(hero.get("mount", 0))            # 0x21
			file.store_8(hero.get("special_tech", 0))     # 0x22
			# Skip reserved bytes (0x23-0x3F)
			file.seek(file.get_position() + 0x3E - 0x22)
		else:
			# Write empty hero data
			file.seek(file.get_position() + HERO_DATA_SIZE)
	
	# Save game state
	file.store_16(game_data.get("fame", 0))        # Fame
	file.store_8(game_data.get("month", 1))        # Month (1-12)
	file.store_8(game_data.get("day", 1))          # Day (1-30)
	file.store_16(game_data.get("year", 1101))     # Year
	
	# Save resources
	file.store_32(game_data.get("gold", 0))
	file.store_32(game_data.get("food", 0))
	file.store_32(game_data.get("arms", 0))
	file.store_32(game_data.get("horses", 0))
	file.store_32(game_data.get("ships", 0))
	file.store_32(game_data.get("ideals", 0))
	file.store_32(game_data.get("talisman", 0))
	
	file.close()
	return OK

func load_game(slot: int) -> Dictionary:
	var file := FileAccess.open(get_save_file_path(slot), FileAccess.READ)
	if not file:
		return {}
	
	var game_data := {}
	var heroes_data := []
	
	# Load hero data
	for i in range(MAX_HEROES):
		var hero := {}
		hero["strength"] = file.get_32()        # 0x00-0x03
		hero["skill"] = file.get_32()           # 0x04-0x07
		hero["intelligence"] = file.get_32()    # 0x08-0x0B
		hero["energy"] = file.get_8()           # 0x0C
		hero["loyalty"] = file.get_8()          # 0x0D
		hero["benevolence"] = file.get_8()      # 0x0E
		hero["courage"] = file.get_8()          # 0x0F
		hero["allegiance"] = file.get_8()       # 0x10
		hero["stamina_max"] = file.get_16()     # 0x11-0x12
		hero["stamina_curr"] = file.get_16()    # 0x13-0x14
		hero["troops"] = file.get_16()          # 0x15-0x16
		hero["profession_1"] = file.get_8()     # 0x17
		hero["profession_1_exp"] = file.get_8() # 0x18
		hero["profession_2"] = file.get_8()     # 0x19
		hero["profession_2_exp"] = file.get_8() # 0x1A
		hero["sworn_brothers"] = file.get_8()   # 0x1B
		hero["infantry_ability"] = file.get_8() # 0x1C
		hero["cavalry_ability"] = file.get_8()  # 0x1D
		hero["naval_ability"] = file.get_8()    # 0x1E
		hero["weapon"] = file.get_8()           # 0x1F
		hero["armor"] = file.get_8()            # 0x20
		hero["mount"] = file.get_8()            # 0x21
		hero["special_tech"] = file.get_8()     # 0x22
		# Skip reserved bytes (0x23-0x3F)
		file.seek(file.get_position() + 0x3E - 0x22)
		
		# Only add hero if they have meaningful data
		if hero["strength"] > 0 or hero["skill"] > 0 or hero["intelligence"] > 0:
			heroes_data.append(hero)
	
	game_data["heroes"] = heroes_data
	
	# Load game state
	game_data["fame"] = file.get_16()         # Fame
	game_data["month"] = file.get_8()         # Month (1-12)
	game_data["day"] = file.get_8()           # Day (1-30)
	game_data["year"] = file.get_16()         # Year
	
	# Load resources
	game_data["gold"] = file.get_32()
	game_data["food"] = file.get_32()
	game_data["arms"] = file.get_32()
	game_data["horses"] = file.get_32()
	game_data["ships"] = file.get_32()
	game_data["ideals"] = file.get_32()
	game_data["talisman"] = file.get_32()
	
	file.close()
	return game_data

func get_save_info(slot: int) -> Dictionary:
	var file := FileAccess.open(get_save_file_path(slot), FileAccess.READ)
	if not file:
		return {}
	
	var info := {}
	info["exists"] = true
	
	# Try to read some basic info
	if file.get_length() >= GAME_STATE_OFFSET + 4:
		file.seek(GAME_STATE_OFFSET)
		info["fame"] = file.get_16()
		info["month"] = file.get_8()
		info["day"] = file.get_8()
		info["year"] = file.get_16()
		
		# Count heroes
		file.seek(HERO_DATA_START)
		var hero_count := 0
		for i in range(min(MAX_HEROES, int(file.get_left() / HERO_DATA_SIZE))):
			var strength := file.get_32()
			var skill := file.get_32()
			var intel := file.get_32()
			if strength > 0 or skill > 0 or intel > 0:
				hero_count += 1
			# Skip rest of hero data
			file.seek(file.get_position() + (HERO_DATA_SIZE - 12))
		
		info["hero_count"] = hero_count
	
	file.close()
	return info

func get_available_slots() -> Array:
	var slots := []
	for i in range(MAX_SAVE_SLOTS):
		var info := get_save_info(i)
		if info.size() > 0:
			info["slot"] = i
			slots.append(info)
	return slots