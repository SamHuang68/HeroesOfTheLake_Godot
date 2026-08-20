# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 戰鬥系統 (Combat System)
class_name CombatManager
extends RefCounted

# Combat constants
const MAX_STAMINA_FOR_ACTION := 10  # Minimum stamina to act
const STAMINA_REST := 5             # Stamina recovered by resting
const STAMINA_DO_FU := 35           # Stamina recovered by using Tao Fu
const STAMINA_MORALE_BOOST := 40    # Stamina recovered by morale boost
const STAMINA_MORALE_BOOST_EXTRA := 1  # Extra action when morale boost

# Action stamina costs
const ACTION_COST := {
	"試探攻擊": 5,
	"頑強攻擊": 10,
	"圍攻": 15,
	"果斷突擊": 30,
	"單挑": 5,
	"普通射擊": 10,
	"連續射擊": 20,
	"狙擊": 30,
	"使用道符": 5,
	"使用妖術": 40,
	"落石": 10,
	"近鄰放火": 5
}

# Facility destruction loot tables (based on Suikoden II)
const FACILITY_LOOT_TABLES := {
	"民房": [
		{"item": "大秦硝子圖", "value": 20, "type": "loyalty"},
		{"item": "銀塊", "value": 25, "type": "loyalty"},
		{"item": "色目絨毯", "value": 30, "type": "loyalty"},
		{"item": "神昭運功石", "value": 35, "type": "loyalty"},
		{"item": "蔡京書", "value": 40, "type": "loyalty"},
		{"item": "金塊", "value": 45, "type": "loyalty"},
		{"item": "青瓷器", "value": 50, "type": "loyalty"},
		{"item": "丹書鐵券", "value": 55, "type": "loyalty"},
		{"item": "徽宗桃鳩圖", "value": 60, "type": "loyalty"}
	],
	"耕地": [
		{"item": "大秦硝子圖", "value": 20, "type": "loyalty"},
		{"item": "銀塊", "value": 25, "type": "loyalty"},
		{"item": "色目絨毯", "value": 30, "type": "loyalty"},
		{"item": "神昭運功石", "value": 35, "type": "loyalty"},
		{"item": "蔡京書", "value": 40, "type": "loyalty"},
		{"item": "金塊", "value": 45, "type": "loyalty"},
		{"item": "青瓷器", "value": 50, "type": "loyalty"},
		{"item": "丹書鐵券", "value": 55, "type": "loyalty"},
		{"item": "徽宗桃鳩圖", "value": 60, "type": "loyalty"}
	],
	"漁場": [
		{"item": "大秦硝子圖", "value": 20, "type": "loyalty"},
		{"item": "銀塊", "value": 25, "type": "loyalty"},
		{"item": "色目絨毯", "value": 30, "type": "loyalty"},
		{"item": "神昭運功石", "value": 35, "type": "loyalty"},
		{"item": "蔡京書", "value": 40, "type": "loyalty"},
		{"item": "金塊", "value": 45, "type": "loyalty"},
		{"item": "青瓷器", "value": 50, "type": "loyalty"},
		{"item": "丹書鐵券", "value": 55, "type": "loyalty"},
		{"item": "徽宗桃鳩圖", "value": 60, "type": "loyalty"}
	],
	"酒館": [
		{"item": "醉醒丹", "value": 0, "type": "cure"},
		{"item": "加忠誠物品", "value": 0, "type": "loyalty"},
		{"item": "金丹", "value": 0, "type": "cure"},
		{"item": "加能力丹藥", "value": 0, "type": "ability"}
	],
	"市場": [
		{"item": "加忠誠物品", "value": 0, "type": "loyalty"},
		{"item": "武器", "value": 0, "type": "equipment"},
		{"item": "孫子", "value": 0, "type": "scholar_item"},
		{"item": "鍛治繪圖", "value": 0, "type": "artisan_item"},
		{"item": "其他加職業等級物品", "value": 0, "type": "profession_item"},
		{"item": "防具", "value": 0, "type": "equipment"},
		{"item": "坐騎", "value": 0, "type": "mount"},
		{"item": "軍書", "value": 0, "type": "military_book"},
		{"item": "丹藥", "value": 0, "type": "medicine"}
	],
	"藥鋪": [
		{"item": "加忠誠物品", "value": 0, "type": "loyalty"},
		{"item": "金丹", "value": 0, "type": "cure"},
		{"item": "醫書", "value": 0, "type": "doctor_item"},
		{"item": "其他丹藥", "value": 0, "type": "medicine"}
	],
	"鬧市": [
		{"item": "加忠誠物品", "value": 0, "type": "loyalty"},
		{"item": "三國演義", "value": 0, "type": "entertainer_item"},
		{"item": "武器", "value": 0, "type": "equipment"},
		{"item": "防具", "value": 0, "type": "equipment"},
		{"item": "丹藥", "value": 0, "type": "medicine"}
	],
	"道觀": [
		{"item": "加忠誠物品", "value": 0, "type": "loyalty"},
		{"item": "天書三卷", "value": 0, "type": "taoist_item"},
		{"item": "丹藥", "value": 0, "type": "medicine"}
	],
	"牧場": [
		{"item": "加忠誠物品", "value": 0, "type": "loyalty"},
		{"item": "坐騎", "value": 0, "type": "mount"},
		{"item": "騎兵軍書", "value": 0, "type": "military_book"},
		{"item": "三晉地圖", "value": 0, "type": "mountain_item"}
	],
	"軍營": [
		{"item": "加忠誠物品", "value": 0, "type": "loyalty"},
		{"item": "武器", "value": 0, "type": "equipment"},
		{"item": "防具", "value": 0, "type": "equipment"}
	],
	"練兵場": [
		{"item": "加忠誠物品", "value": 0, "type": "loyalty"},
		{"item": "武器", "value": 0, "type": "equipment"},
		{"item": "防具", "value": 0, "type": "equipment"},
		{"item": "坐騎", "value": 0, "type": "mount"},
		{"item": "軍書", "value": 0, "type": "military_book"}
	],
	"鐵匠鋪": [
		{"item": "加忠誠物品", "value": 0, "type": "loyalty"},
		{"item": "武器", "value": 0, "type": "equipment"},
		{"item": "防具", "value": 0, "type": "equipment"},
		{"item": "鍛治繪圖", "value": 0, "type": "artisan_item"}
	],
	"造船廠": [
		{"item": "加忠誠物品", "value": 0, "type": "loyalty"},
		{"item": "水兵軍書", "value": 0, "type": "military_book"},
		{"item": "鍛治繪圖", "value": 0, "type": "artisan_item"}
	],
	"瞭望台": [
		{"item": "武器", "value": 0, "type": "equipment"},
		{"item": "加忠誠物品", "value": 0, "type": "loyalty"}
	],
	"水閘": [],  # No loot
	"柵欄": [],  # No loot
	"未建好之設施": []  # No loot
}

# Facility destruction difficulty (approximate hit points)
const FACILITY_HP := {
	"民房": 1,
	"民房": 1,
	"耕地": 2,  # Variable based on strength
	"漁場": 2,
	"酒館": 3,
	"市場": 4,
	"藥鋪": 3,
	"鬧市": 4,
	"道觀": 3,
	"牧場": 3,
	"軍營": 5,  # Variable
	"練兵場": 4,
	"鐵匠鋪": 3,
	"造船廠": 3,
	"瞭望台": 2,
	"水閘": 0,
	"柵欄": 0,
	"未建好之設施": 0
}

func get_facility_destroy_chance(facility_type: String, attacker_strength: int) -> float:
	"""Get chance to destroy facility based on attacker strength and facility type"""
	var base_chance := 0.1  # 10% base chance
	var strength_factor := clamp(attacker_strength / 1000.0, 0.5, 2.0)  # Strength 500-2000 gives 0.5-2.0 modifier
	
	# Adjust for facility type (simplified)
	var type_modifier := 1.0
	match facility_type:
		"民房", "耕地", "漁場": type_modifier = 1.5  # Easier to destroy
		"酒館", "市場", "藥鋪", "鬧市", "道觀", "牧場": type_modifier = 1.0
		"軍營", "練兵場", "鐵匠鋪", "造船廠", "瞭望台": type_modifier = 0.7  # Harder to destroy
		"水閘", "柵欄", "未建好之設施": type_modifier = 0.0  # Cannot destroy
	
	return clamp(base_chance * strength_factor * type_modifier, 0.0, 0.9)  # Max 90% chance

def destroy_facility(facility_type: String, attacker: Dictionary) -> Array:
	"""Attempt to destroy a facility and return loot obtained"""
	var loot := []
	
	# Check if destruction is possible
	var chance := get_facility_destroy_chance(facility_type, attacker.get("strength", 0))
	if randf() > chance:
		return loot  # Failed to destroy
	
	# Destruction successful - get loot
	var loot_table := FACILITY_LOOT_TABLES.get(facility_type, [])
	if loot_table.size() > 0:
		# Select random item from loot table
		var index := randi() % loot_table.size()
		var selected_item := loot_table[index].duplicate()
		
		# Add quantity/variation based on luck
		var quantity := 1
		if selected_item["type"] in ["loyalty", "equipment", "mount"]:
			quantity := randi() % 3 + 1  # 1-3 items
		elif selected_item["type"] in ["cure", "medicine", "ability"]:
			quantity := randi() % 2 + 1  # 1-2 items
		
		selected_item["quantity"] = quantity
		loot.append(selected_item)
		
		# Sometimes get multiple items from same facility destruction
		if randf() < 0.3:  # 30% chance for second item
			var index2 := randi() % loot_table.size()
			if index2 != index:  # Different item
				var selected_item2 := loot_table[index2].duplicate()
				selected_item2["quantity"] = randi() % 2 + 1
				loot.append(selected_item2)
	
	return loot

def apply_facility_loot_to_game(loot: Array, game_manager: Object) -> void:
	"""Apply loot from facility destruction to game state"""
	for item in loot:
		match item["type"]:
			"loyalty":
				# Increase loyalty of random hero or overall faction loyalty
				var loyalty_gain := item["value"] * item.get("quantity", 1)
				# In practice would distribute to heroes
				print("獲得忠誠物品：%s x%d (忠誠+%d)" % [item["item"], item.get("quantity", 1), loyalty_gain])
				
			"cure":
				# Heal heroes or cure ailments
				print("獲得治療物品：%s x%d" % [item["item"], item.get("quantity", 1)])
				
			"ability":
				# Increase abilities
				print("獲得能力物品：%s x%d" % [item["item"], item.get("quantity", 1)])
				
			"equipment":
				# Equip heroes with weapons/armor
				print("獲得裝備：%s x%d" % [item["item"], item.get("quantity", 1)])
				
			"mount":
				# Obtain mounts
				print("獲得坐騎：%s x%d" % [item["item"], item.get("quantity", 1)])
				
			"scholar_item", "taoist_item", "doctor_item", "entertainer_item", "artisan_item", "military_book", "mountain_item", "profession_item":
				# Profession-specific items
				print("獲得職業物品：%s x%d" % [item["item"], item.get("quantity", 1)])
				
			"medicine":
				# Medicinal items
				print("獲得藥物：%s x%d" % [item["item"], item.get("quantity", 1)])