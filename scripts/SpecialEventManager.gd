# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 特殊事件系統 (Special Events System)
# 基於論壇貼文提示實施: https://forum.gamer.com.tw/C.php?bsn=3550&snA=85
class_name SpecialEventManager
extends RefCounted

# Special event types based on forum tips
enum SpecialEventType:
    THIRD_SCRIPT_SELECT = 0          # 選擇第三劇本技巧
    INFINITE_TREASURE = 1            # 無限寶物技巧
    SONG_JIANG_STAR_LORD = 2         # 星主事件 (宋江)
    EVENT_108_STARS_OATH = 3         # 108星結義
    EVENT_DU_QIAN_CHAO_GAI = 4       # 杜遷水寨大並火,晁蓋梁山小奪泊
    EVENT_MARRIAGE = 5               # 結婚事件
    EVENT_DIVORCE = 6                # 離婚事件
    EVENT_RECRUIT_RELATIVE = 7       # 登用親人事件
    EVENT_RECRUIT_RUFFIAN_TAVERN = 8 # 登用無賴漢事件 (酒場)
    EVENT_ABANDONMENT = 9            # 離棄事件
    EVENT_MARKET_TREASURE_OFFER = 10 # 民心所向事件 (實際是市場獻寶物)
    EVENT_TREASURE_UNDER_FACILITY = 11 # 發現設施底下的寶物
    EVENT_MARTIAL_ARTS_TOURNAMENT = 12 # 武術大會
    EVENT_NINE_HEAVENS_MYSTERIOUS_WOMAN = 13 # 九天玄女授天書
    EVENT_POPULAR_WILL = 14          # 民心所向事件

# Event definitions with triggers and effects
const SPECIAL_EVENT_DEFINITIONS := [
    {
        "type": SpecialEventType.THIRD_SCRIPT_SELECT,
        "name": "選擇第三劇本",
        "description": "進入遊戲前讀取不存在的檔案即可選用第三個劇本",
        "trigger_type": "preload_cheat",  # Special trigger before game start
        "effect": "_apply_third_script_select_effect"
    },
    {
        "type": SpecialEventType.INFINITE_TREASURE,
        "name": "無限寶物技巧",
        "description": "在地圖左上角建陷井或柵, 再整地,便可得寶物!",
        "trigger_type": "facility_build",  # Triggered when building specific facilities at specific location
        "effect": "_apply_infinite_treasure_effect"
    },
    {
        "type": SpecialEventType.SONG_JIANG_STAR_LORD,
        "name": "星主事件 (宋江)",
        "description": "選宋江遊戲時,令宋江一人出戰,被敵人擊敗,便會發生情節,九天玄女賜予力量",
        "trigger_type": "hero_defeat_solo",  # Triggered when specific hero defeated alone in battle
        "hero_id": "SongJiang",
        "effect": "_apply_song_jiang_star_lord_effect"
    },
    {
        "type": SpecialEventType.EVENT_108_STARS_OATH,
        "name": "108星結義",
        "description": "當一個要塞的無賴漢達到108個以上時，便會發生。這時人氣度會達到1000，無賴漢忠誠100，跟著徽宗會降旨征討高俅。",
        "trigger_type": "ruffian_count_threshold",
        "threshold": 108,
        "effect": "_apply_108_stars_oath_effect"
    },
    {
        "type": SpecialEventType.EVENT_DU_QIAN_CHAO_GAI,
        "name": "杜遷水寨大並火,晁蓋梁山小奪泊",
        "description": "第一個時期，50%幾率發生。1101年9月1日，杜遷殺掉王倫，擁立晁蓋為梁山泊的頭領，重現小說的一幕。",
        "trigger_type": "date_specific",  # September 1, 1101
        "year": 1101,
        "month": 9,
        "day": 1,
        "chance": 0.5,
        "effect": "_apply_du_qian_chao_gai_effect"
    },
    {
        "type": SpecialEventType.EVENT_MARRIAGE,
        "name": "結婚事件",
        "description": "將一無妻狀態男無賴漢和一無夫狀態女無賴漢置一設施工作，或配置於同一地點，他們就會日久生情，結為夫婦。",
        "trigger_type": "cohabitation",  # Triggered when male/female ruffians work/live together
        "effect": "_apply_marriage_effect"
    },
    {
        "type": SpecialEventType.EVENT_DIVORCE,
        "name": "離婚事件",
        "description": "條件不明。發生時有三種情況,一種夫婦離婚；一種是第三者插足，一方與第三者離開要塞，一起去尋找“新生活”；一種是潘金蓮式毒殺親夫。",
        "trigger_type": "marriage_stress",  # Triggered by various marital stress factors
        "effect": "_apply_divorce_effect"
    },
    {
        "type": SpecialEventType.EVENT_RECRUIT_RELATIVE,
        "name": "登用親人事件",
        "description": "當好漢手下無賴漢的父母，夫妻，兄弟，子女流浪到要塞時,100%會發生登用事件,但必須他們是無主狀態。",
        "trigger_type": "relative_arrival",  # Triggered when ruffian's relatives arrive as vagrants
        "effect": "_apply_recruit_relative_effect"
    },
    {
        "type": SpecialEventType.EVENT_RECRUIT_RUFFIAN_TAVERN,
        "name": "登用無賴漢事件 (酒場)",
        "description": "如果你的要塞有在野無賴漢正在酒場或盛り場,恰好又有無賴漢正在該處宴會或休養,就會隨機發生。發生時,休養的無賴漢與在野無賴漢興趣相投（精神值相近）,介紹在野無賴漢加入我方。",
        "trigger_type": "tavern_interaction",  # Triggered by specific tavern/resting combinations
        "effect": "_apply_recruit_ruffian_tavern_effect"
    },
    {
        "type": SpecialEventType.EVENT_ABANDONMENT,
        "name": "離棄事件",
        "description": "當你的無賴漢中有些無賴漢有親戚,但親戚有不是你的手下,有時他會提出去探望親人。如果放他去的話,從此就會一去不回。如果不答應,他的忠誠就會劇降。",
        "trigger_type": "relative_visit_request",  # Triggered when ruffian with external relatives wants to visit
        "effect": "_apply_abandonment_effect"
    },
    {
        "type": SpecialEventType.EVENT_MARKET_TREASURE_OFFER,
        "name": "市場獻寶物",
        "description": "你的要塞內建有市場,隨機發生。發生時,商人獻上寶物。",
        "trigger_type": "market_present",  # Triggered when fortress has a market facility
        "chance_per_month": 0.15,
        "effect": "_apply_market_treasure_offer_effect"
    },
    {
        "type": SpecialEventType.EVENT_TREASURE_UNDER_FACILITY,
        "name": "發現設施底下的寶物",
        "description": "要塞正在建設設施,有時會有無賴漢報告發現某類設施下發現寶物。你只有拆除這類設施,就會發現某設施下的寶物",
        "trigger_type": "facility_construction",  # Triggered during facility construction
        "chance_per_construction": 0.2,
        "effect": "_apply_treasure_under_facility_effect"
    },
    {
        "type": SpecialEventType.EVENT_MARTIAL_ARTS_TOURNAMENT,
        "name": "武術大會",
        "description": "偶數年7月1日,如果勢力數超過四個,徽宗就會召開比武大會。但高俅會在武術大會上搞事。有時會使用放麻藥等下三爛的手段,有時又會扣留比武大會的冠軍。不過冠軍可獲得一大筆錢,一件寶物,還會提升100人氣。",
        "trigger_type": "date_specific_even_year",  # July 1st of even years
        "month": 7,
        "day": 1,
        "year_condition": "even",
        "min_factions": 4,
        "effect": "_apply_martial_arts_tournament_effect"
    },
    {
        "type": SpecialEventType.EVENT_NINE_HEAVENS_MYSTERIOUS_WOMAN,
        "name": "九天玄女授天書",
        "description": "任意時期，宋江身份為好漢，只要宋江在戰鬥中，體力和兵力減至0時，即將被俘時，九天玄女就會出現授予宋江三卷天書，宋江的體力腕力，技量，知力都會升至100，並增加道士LV3職業。",
        "trigger_type": "hero_capture_imminent",  # Triggered when hero about to be captured in battle
        "hero_id": "SongJiang",
        "effect": "_apply_nine_heavens_mysterious_woman_effect"
    },
    {
        "type": SpecialEventType.EVENT_POPULAR_WILL,
        "name": "民心所向事件",
        "description": "當一個要塞的生活達到A，且人口數多，設施多，就會發生民心所向事件。要塞內的民眾支持好漢，人氣加100。",
        "trigger_type": "living_standard_high",  # Triggered when living standard reaches A with sufficient pop/facilities
        "min_living_standard": "A",
        "min_population": 500,  # Example threshold
        "min_facilities": 10,   # Example threshold
        "effect": "_apply_popular_will_effect"
    }
]

# Track active special events
var active_special_events := []

# Marriage tracking
var marriages := {}  # Dictionary mapping husband_id -> wife_id

# Relative tracking for recruitment events
var relative_records := {}  # Dictionary mapping ruffian_id -> list of relative_ids

func _ready() -> void:
	# Initialize random seed
	randomize()
	
	# Load any saved marriage/relative data
	_load_persistent_data()

def update_monthly() -> void:
	# Check for monthly triggered events
	for event_def in SPECIAL_EVENT_DEFINITIONS:
		if event_def.has("chance_per_month"):
			if randf() < event_def["chance_per_month"]:
				trigger_special_event(event_def["type"])
	
	# Update existing event durations
	var i := 0
	while i < active_special_events.size():
		var event := active_special_events[i]
		event["remaining_months"] -= 1
		if event["remaining_months"] <= 0:
			active_special_events.remove_at(i)
		else:
			i += 1

def trigger_special_event(event_type: int, trigger_context: Dictionary = {}) -> void:
	var event_def := get_special_event_definition(event_type)
	if event_def == null:
		push_notification("錯誤: 未知的特殊事件類型 %d" % event_type)
		return
	
	# Check if trigger conditions are met (beyond just chance)
	if not _check_trigger_conditions(event_def, trigger_context):
		return
	
	var event_instance := {
		"type": event_type,
		"name": event_def["name"],
		"description": event_def["description"],
		"trigger_frame": OS.get_ticks_msec(),  # For frame-specific events
		"remaining_months": event_def.get("duration_months", 1)
	}
	
	active_special_events.append(event_instance)
	
	# Apply the event effect
	var effect_func := Callable(self, event_def["effect"])
	effect_func.call(trigger_context)
	
	# Notify player
	push_notification("特殊事件觸發: %s" % event_def["name"])
	
	# Save persistent data for marriage/relative tracking
	_save_persistent_data()

def get_special_event_definition(event_type: int) -> Dictionary:
	for event_def in SPECIAL_EVENT_DEFINITIONS:
		if event_def["type"] == event_type:
			return event_def
	return {}

def _check_trigger_conditions(event_def: Dictionary, trigger_context: Dictionary) -> bool:
	# Check specific trigger conditions based on trigger_type
	var trigger_type := event_def.get("trigger_type", "")
	
	match trigger_type:
		"preload_cheat":
			# This is handled outside normal gameplay - return false for monthly checks
			return false
			
		"facility_build":
			# Check if we're building specific facilities at specific location
			var facility_type := trigger_context.get("facility_type", "")
			var position := trigger_context.get("position", Vector2i(-1, -1))
			# Top-left corner exploit area (adjust based on your map coordinates)
			var exploit_area := Rect2i(0, 0, 5, 5)  # Example top-left 5x5 area
			return (facility_type in ["陷井", "柵欄"]) and position.has_point(exploit_area.position) and position.has_point(exploit_area.position + exploit_area.size)
			
		"hero_defeat_solo":
			# Check if specific hero was defeated alone in battle
			var hero_id := event_def.get("hero_id", "")
			var defeated_hero_id := trigger_context.get("defeated_hero_id", "")
			var solo_battle := trigger_context.get("solo_battle", false)
			return hero_id == defeated_hero_id and solo_battle
			
		"ruffian_count_threshold":
			# Check if ruffian count exceeds threshold
			var threshold := event_def.get("threshold", 0)
			var current_count := trigger_context.get("ruffian_count", 0)
			return current_count >= threshold
			
		"date_specific":
			# Check if current date matches specific date
			var year := event_def.get("year", 0)
			var month := event_def.get("month", 0)
			var day := event_def.get("day", 0)
			var chance := event_def.get("chance", 1.0)
			
			var current_year := trigger_context.get("current_year", 0)
			var current_month := trigger_context.get("current_month", 0)
			var current_day := trigger_context.get("current_day", 0)
			
			var date_match := (current_year == year and current_month == month and current_day == day)
			return date_match and (randf() < chance)
			
		"date_specific_even_year":
			# Check if current date matches specific date in even years
			var month := event_def.get("month", 0)
			var day := event_def.get("day", 0)
			var min_factions := event_def.get("min_factions", 0)
			
			var current_year := trigger_context.get("current_year", 0)
			var current_month := trigger_context.get("current_month", 0)
			var current_day := trigger_context.get("current_day", 0)
			var faction_count := trigger_context.get("faction_count", 0)
			
			var date_match := (current_month == month and current_day == day)
			var year_even := (current_year % 2 == 0)
			var sufficient_factions := (faction_count >= min_factions)
			
			return date_match and year_even and sufficient_factions
			
		"cohabitation":
			# Check if male/female ruffians are working/living together
			# This would be handled by the marriage system update
			return _check_marriage_conditions()
			
		"marriage_stress":
			# Check for marital stress factors
			return _check_divorce_conditions()
			
		"relative_arrival":
			# Check if relatives have arrived as vagrants
			return _check_relative_arrival()
			
		"tavern_interaction":
			# Check for tavern/resting combinations
			return _check_tavern_interaction()
			
		"relative_visit_request":
			# Check if ruffian with external relatives wants to visit
			return _check_relative_visit_request()
			
		"market_present":
			# Check if fortress has a market facility
			return _check_market_facility_present()
			
		"facility_construction":
			# Check during facility construction with chance
			var chance := event_def.get("chance_per_construction", 0.0)
			return randf() < chance
			
		"living_standard_high":
			# Check if living standard reaches A with sufficient pop/facilities
			var living_standard := trigger_context.get("living_standard", "")
			var population := trigger_context.get("population", 0)
			var facilities := trigger_context.get("facilities", 0)
			
			var min_living := event_def.get("min_living_standard", "")
			var min_pop := event_def.get("min_population", 0)
			var min_fac := event_def.get("min_facilities", 0)
			
			return (living_standard == min_living and 
					population >= min_pop and 
					facilities >= min_fac)
					
		"_":
			# Default: allow trigger
			return true
	
	return false

# Specific effect handlers for each special event

func _apply_third_script_select_effect(trigger_context: Dictionary) -> void:
	# This would normally be handled at game startup
	# For now, just notify that the third script is available
	push_notification("第三劇本已解鎖! 重新啟動遊戲以選擇。")
	# In practice, this would modify available scenario selection

func _apply_infinite_treasure_effect(trigger_context: Dictionary) -> void:
	# Generate treasure when building pitfall/fence in top-left then cultivating
	var facility_type := trigger_context.get("facility_type", "")
	var action := trigger_context.get("action", "")
	
	if facility_type in ["陷井", "柵欄"] and action == "整地":
		# Generate random treasure
		var treasure := _generate_random_treasure()
		push_notification("發現寶物! 獲得: %s" % treasure["name"])
		# Add treasure to player resources/inventory
		_add_treasure_to_inventory(treasure)

func _apply_song_jiang_star_lord_effect(trigger_context: Dictionary) -> void:
	# Find Song Jiang hero and boost all stats to 100, change profession to Taoist L3
	var song_jiang_hero := _find_hero_by_id("SongJiang")
	if song_jiang_hero:
		# Boost stats to 100 (in our 0-1000 scale, this would be 1000)
		song_jiang_hero["strength"] = 1000
		song_jiang_hero["skill"] = 1000
		song_jiang_hero["intelligence"] = 1000
		song_jiang_hero["stamina_curr"] = song_jiang_hero["stamina_max"] = 1000
		song_jiang_hero["energy"] = 100  # Max energy
		
		# Change profession to Taoist Level 3
		song_jiang_hero["profession_1"] = ProfessionManager.TAOIST
		song_jiang_hero["profession_1_exp"] = ProfessionManager.get_exp_required_for_level(2)  # Level 3 exp
		
		push_notification("九天玄女現身! 宋江獲得神力，所有屬性提升至最大，職業變為道士Lv3!")
	else:
		push_notification("錯誤: 找不到宋江角色")

func _apply_108_stars_oath_effect(trigger_context: Dictionary) -> void:
	# Set popularity/fame to 1000, set all ruffian loyalty to 100, trigger emperor's edict
	push_notification("108星結義達成! 人氣達到1000，所有無賴漢忠誠為100，徽宗降旨征討高俅!")
	
	# Set fame to 1000 (would need access to game state)
	# This would typically be handled by setting a global fame variable
	
	# Set all ruffian loyalty to 100 (in our 0-100 scale)
	var all_heroes := DataManager.get_all_heroes()
	for hero in all_heroes:
		if hero.get("loyalty", 0) < 100:  # Only increase if not already max
			hero["loyalty"] = 100
	
	# Trigger emperor's edict (would trigger special game state)
	# This could set a flag for special victory conditions

func _apply_du_qian_chao_gai_effect(trigger_context: Dictionary) -> void:
	# Recreate the historical event: Du Qian kills Wang Lun, installs Chao Gai as leader
	push_notification("杜遷殺掉王倫，擁立晁蓋為梁山泊頭領!")
	
	# Find Du Qian and Wang Lun heroes
	var du_qian := _find_hero_by_id("DuQian")
	var wang_lun := _find_hero_by_id("WangLun")
	var chao_gai := _find_hero_by_id("ChaoGai")
	
	if du_qian and wang_lun and chao_gai:
		# Simulate Wang Lun being "removed" (could set status, decrease loyalty, etc.)
		wang_lun["loyalty"] = 0  # Wang Lun loses loyalty
		wang_lun["action"] = "被杜遷殺害"
		
		# Install Chao Gai as leader (increase his loyalty/status)
		chao_gai["loyalty"] = 100
		chao_gai["title"] = "梁山泊頭領"
		chao_gai["action"] = "梁山泊頭領"
		
		# Du Qian gains prestige
		du_qian["loyalty"] = 100
		du_qian["title"] = "提刑牧場都監"
		
		# Update any faction relationships
		# This would trigger a period change in the game

func _apply_marriage_effect(trigger_context: Dictionary) -> void:
	# Create marriage between two ruffians
	var husband_id := trigger_context.get("husband_id", "")
	var wife_id := trigger_context.get("wife_id", "")
	
	if husband_id and wife_id:
		marriages[husband_id] = wife_id
		# Optionally store reverse mapping
		# marriages[wife_id] = husband_id  # If bidirectional lookup needed
		
		push_notification("%s 與 %s 結為夫婦!" % [_get_hero_name(husband_id), _get_hero_name(wife_id)])
		
		# Apply marriage bonuses (increased loyalty, etc.)
		_apply_marriage_bonus(husband_id, wife_id)

func _apply_divorce_effect(trigger_context: Dictionary) -> void:
	# Handle divorce scenarios
	var divorce_type := trigger_context.get("divorce_type", 0)  # 0=mutual, 1=third party, 2=poisoning
	var husband_id := trigger_context.get("husband_id", "")
	var wife_id := trigger_context.get("wife_id", "")
	var third_party_id := trigger_context.get("third_party_id", "")
	
	push_notification("發生離婚事件!")
	
	match divorce_type:
		0:  # Mutual divorce
			if husband_id in marriages:
				marriages.erase(husband_id)
			if wife_id in marriages:
				marriages.erase(wife_id)
			push_notification("%s 與 %s 協議離婚" % [_get_hero_name(husband_id), _get_hero_name(wife_id)])
			_apply_divorce_penalty(husband_id, wife_id)
			
		1:  # Third party interference
			if husband_id in marriages and marriages[husband_id] == wife_id:
				marriages.erase(husband_id)
				push_notification("%s 與 %s 因 %s 而離婚" % [_get_hero_name(husband_id), _get_hero_name(wife_id), _get_hero_name(third_party_id)])
				_apply_divorce_penalty(husband_id, wife_id, third_party_id)
				# The third party and one spouse leave together
				_remove_heroes_from_fortress([husband_id, third_party_id])  # Example
			
		2:  # Poisoning (Pan Jinlian style)
			if husband_id in marriages and marriages[husband_id] == wife_id:
				marriages.erase(husband_id)
				push_notification("%s 被 %s 毒殺！" % [_get_hero_name(wife_id), _get_hero_name(husband_id)])
				_apply_divorce_penalty(husband_id, wife_id, is_poisoning=true)
				# Husband dies or is removed
				_remove_hero_from_fortress(husband_id)

func _apply_recruit_relative_effect(trigger_context: Dictionary) -> void:
	# Recruit a ruffian's relative who has arrived as a vagrant
	var ruffian_id := trigger_context.get("ruffian_id", "")
	var relative_id := trigger_context.get("relative_id", "")
	
	if ruffian_id and relative_id:
		push_notification("%s 的親戒 %s 流浪至要塞，被登用!" % [_get_hero_name(ruffian_id), _get_hero_name(relative_id)])
		
		# Get the relative's data and add them to fortress
		var relative_data := DataManager.get_hero(relative_id)
		if relative_data.size() > 0:
			_add_hero_to_fortress(relative_data)
			
			# Set loyalty similar to the original ruffian
			var original_loyalty := DataManager.get_hero(ruffian_id).get("loyalty", 50)
			relative_data["loyalty"] = clamp(original_loyalty + randi() % 20 - 10, 0, 100)
			
			# Record the relationship
			if not relative_records.has(ruffian_id):
				relative_records[ruffian_id] = []
			if relative_id not in relative_records[ruffian_id]:
				relative_records[ruffian_id].append(relative_id)
		else:
			push_notification("錯誤: 找不到親戒角色資料")

func _apply_recruit_ruffian_tavern_effect(trigger_context: Dictionary) -> void:
	# Recruit ruffian through tavern interaction
	var introducer_id := trigger_context.get("introducer_id", "")  # The resting ruffian
	var target_id := trigger_context.get("target_id", "")         # The ruffian to recruit
	
	if introducer_id and target_id:
		push_notification("%s 介紹 %s 加入我方!" % [_get_hero_name(introducer_id), _get_hero_name(target_id)])
		
		# Get the target's data and add them to fortress
		var target_data := DataManager.get_hero(target_id)
		if target_data.size() > 0:
			_add_hero_to_fortress(target_data)
			
			# Set loyalty based on spirit similarity (as mentioned in tip)
			var introducer_spirit := DataManager.get_hero(introducer_id).get("intelligence", 50)  # Using intelligence as spirit proxy
			var target_spirit := DataManager.get_hero(target_id).get("intelligence", 50)
			var spirit_diff := abs(introducer_spirit - target_spirit)
			var loyalty_bonus := max(0, 50 - spirit_diff)  # Closer spirit = higher loyalty
			
			var base_loyalty := target_data.get("loyalty", 50)
			target_data["loyalty"] = clamp(base_loyalty + loyalty_bonus, 0, 100)
			
			# Record the relationship
			if not relative_records.has(introducer_id):
				relative_records[introducer_id] = []
			if target_id not in relative_records[introducer_id]:
				relative_records[introducer_id].append(target_id)
		else:
			push_notification("錯誤: 找不到目標角色資料")

func _apply_abandonment_effect(trigger_context: Dictionary) -> void:
	# Handle abandonment event when ruffian wants to visit external relatives
	var ruffian_id := trigger_context.get("ruffian_id", "")
	var choice := trigger_context.get("choice", 0)  # 0=allow to leave, 1=refuse
	
	if not ruffian_id:
		return
	
	var ruffian_name := _get_hero_name(ruffian_id)
	
	match choice:
		0:  # Allow to leave
			push_notification("%s 前去探望親人，從此一去不回!" % ruffian_name)
			_remove_hero_from_fortress(ruffian_id)
			# Could add to a "lost heroes" list for potential future events
			
		1:  # Refuse
			push_notification("%s 因不准探望親人而忠誠劇降!" % ruffian_name)
			var current_loyalty := DataManager.get_hero(ruffian_id).get("loyalty", 50)
			var new_loyalty := max(current_loyalty - 50, 0)  # Significant loyalty drop
			DataManager.get_hero(ruffian_id)["loyalty"] = new_loyalty

func _apply_market_treasure_offer_effect(trigger_context: Dictionary) -> void:
	# Merchant offers treasure when market is present
	push_notification("市場內商人獻上寶物!")
	
	var treasure := _generate_random_treasure(is_valuable=true)  # More valuable treasures from market
	push_notification("獲得寶物: %s" % treasure["name"])
	_add_treasure_to_inventory(treasure)

func _apply_treasure_under_facility_effect(trigger_context: Dictionary) -> void:
	# Discover treasure under a facility during construction
	var facility_type := trigger_context.get("facility_type", "")
	var facility_position := trigger_context.get("position", Vector2i(-1, -1))
	
	push_notification("無賴漢報告: 在 %s 下發現寶物!" % [_get_facility_name(facility_type)])
	
	# Player must demolish the facility to get treasure
	# We'll mark this facility as having treasure
	var treasure_data := {
		"facility_type": facility_type,
		"position": facility_position,
		"has_treasure": true,
		"treasure": _generate_random_treasure(is_rare=true)  # rarer treasures underground
	}
	
	# Store this information somewhere the player can access
	# For now, we'll just notify and store in a temporary list
	if not hasattr(self, "treasure_under_facilities"):
		self.treasure_under_facilities = []
	self.treasure_under_facilities.append(treasure_data)
	
	push_notification("請拆除該設施以獲得寶物! (可使用存檔讀檔大法反複尋寶)")

func _apply_martial_arts_tournament_effect(trigger_context: Dictionary) -> void:
	# Handle martial arts tournament event
	var current_year := trigger_context.get("current_year", 0)
	push_notification("%d年7月1日武術大會開幕!" % current_year)
	
	# Gao Qiu interferes with underhanded tactics
	var interference_type := randi() % 2  # 0=drugs, 1=detain champion
	
	match interference_type:
		0:  # Use drugs
			push_notification("高俅使用放麻藥等下三爛手段!")
			# Apply penalties to participants
			_apply_tournament_drugs_effect()
			
		1:  # Detain champion
			push_notification("高俅扣留比武大會冠軍!")
			# Detain the would-be champion
			_apply_tournament_detain_champion_effect()
	
	# Determine actual winner (considering interference)
	var winner_id := _determine_tournament_winner(trigger_context)
	
	if winner_id:
		var winner_name := _get_hero_name(winner_id)
		push_notification("比武大會冠軍: %s!" % winner_name)
		
		# Champion rewards
		var gold_reward := 5000 + randi() % 5000  # Large sum of money
		var treasure := _generate_random_treasure(is_valuable=true)
		var fame_reward := 100  # +100 popularity
		
		push_notification("%s 獲得: %d 金錢, %s, +100 人氣!" % [winner_name, gold_reward, treasure["name"]])
		
		# Apply rewards
		_add_gold(gold_reward)
		_add_treasure_to_inventory(treasure)
		# Would add fame to global fame variable

func _apply_nine_heavens_mysterious_woman_effect(trigger_context: Dictionary) -> void:
	# Nine Heavens Mysterious Woman grants heavenly book to Song Jiang
	var song_jiang_hero := _find_hero_by_id("SongJiang")
	if song_jiang_hero:
		push_notification("九天玄女現身授予天書! 宋江所有屬性提升至最大，獲得道士Lv3職業!")
		
		# Boost all stats to maximum (100 in original scale = 1000 in our scale)
		song_jiang_hero["strength"] = 1000
		song_jiang_hero["skill"] = 1000
		song_jiang_hero["intelligence"] = 1000
		song_jiang_hero["stamina_curr"] = song_jiang_hero["stamina_max"] = 1000
		song_jiang_hero["energy"] = 100
		
		# Change profession to Taoist Level 3
		song_jiang_hero["profession_1"] = ProfessionManager.TAOIST
		song_jiang_hero["profession_1_exp"] = ProfessionManager.get_exp_required_for_level(2)  # Level 3 exp
		
		# Optional: Add heavenly book as special item
		var heavenly_book := {
			"name": "三卷天書",
			"type": "special_item",
			"description": "九天玄女授予的天書",
			"value": 1000
		}
		_add_special_item_to_inventory(heavenly_book)
	else:
		push_notification("錯誤: 找不到宋江角色")

func _apply_popular_will_effect(trigger_context: Dictionary) -> void:
	# Popular Will event: populace supports the ruffians, popularity increases by 100
	push_notification("民心所向事件發生! 要塞內民眾支持好漢，人氣增加100!")
	
	# Would add 100 to global fame variable
	# This would typically be handled by modifying a global fame value

# Helper functions

func _find_hero_by_id(hero_id: String) -> Dictionary:
	# Find hero in DataManager or in current fortress
	var hero_data := DataManager.get_hero(hero_id)
	if hero_data.size() > 0:
		return hero_data.duplicate()
	
	# Also check heroes currently in fortress
	for hero in _get_fortress_heroes():
		if hero.get("id", "") == hero_id:
			return hero.duplicate()
	
	return {}

func _get_hero_name(hero_id: String) -> String:
	var hero := DataManager.get_hero(hero_id)
	if hero.size() > 0:
		return hero.get("name", "未知")
	return "未知"

func _get_facility_name(facility_type: String) -> String:
	# Map facility type to readable name
	var facility_names := {
		"民房": "民房",
		"耕地": "耕地",
		"漁場": "漁場",
		"酒館": "酒館",
		"市場": "市場",
		"藥鋪": "藥鋪",
		"鬧市": "鬧市",
		"道觀": "道觀",
		"牧場": "牧場",
		"軍營": "軍營",
		"練兵場": "練兵場",
		"鐵匠鋪": "鐵匠鋪",
		"造船廠": "造船廠",
		"瞭望台": "瞭望台",
		"水閘": "水閘",
		"柵欄": "柵欄",
		"陷井": "陷井"
	}
	return facility_names.get(facility_type, facility_type)

func _generate_random_treasure(is_valuable: bool = false, is_rare: bool = false) -> Dictionary:
	# Generate a random treasure item based on facility loot tables
	# This is a simplified version - in practice would pull from CombatManager's FACILITY_LOOT_TABLES
	
	var treasure_pool := []
	
	if is_rare:
		# Rare treasures (from underground facilities)
		treasure_pool = [
			{"name": "大秦硝子圖", "value": 20, "type": "loyalty"},
			{"name": "金塊", "value": 45, "type": "loyalty"},
			{"name": "青瓷器", "value": 50, "type": "loyalty"},
			{"name": "丹書鐵券", "value": 55, "type": "loyalty"},
			{"name": "徽宗桃鳩圖", "value": 60, "type": "loyalty"},
			{"name": "神丹", "value": 0, "type": "ability"},  # Max ability
			{"name": "天書三卷", "value": 0, "type": "taoist_item"},
			{"name": "孫子", "value": 0, "type": "scholar_item"}
		]
	elif is_valuable:
		# Valuable treasures (from market offers)
		treasure_pool = [
			{"name": "金塊", "value": 45, "type": "loyalty"},
			{"name": "銀塊", "value": 25, "type": "loyalty"},
			{"name": "色目絨毯", "value": 30, "type": "loyalty"},
			{"name": "青瓷器", "value": 50, "type": "loyalty"},
			{"name": "徽宗桃鳩圖", "value": 60, "type": "loyalty"},
			{"name": "珊瑚", "value": 35, "type": "loyalty"},
			{"name": "瑪瑙", "value": 40, "type": "loyalty"}
		]
	else:
		# Regular treasures
		treasure_pool = [
			{"name": "大秦硝子圖", "value": 20, "type": "loyalty"},
			{"name": "銀塊", "value": 25, "type": "loyalty"},
			{"name": "色目絨毯", "value": 30, "type": "loyalty"},
			{"name": "神昭運功石", "value": 35, "type": "loyalty"},
			{"name": "蔡京書", "value": 40, "type": "loyalty"},
			{"name": "金塊", "value": 45, "type": "loyalty"},
			{"name": "青瓷器", "value": 50, "type": "loyalty"},
			{"name": "丹書鐵券", "value": 55, "type": "loyalty"},
			{"name": "徽宗桃鳩圖", "value": 60, "type": "loyalty"},
			{"name": "金丹", "value": 0, "type": "cure"},
			{"name": "醉醒丹", "value": 0, "type": "cure"},
			{"name": "銀丹", "value": 0, "type": "ability"},
			{"name": "黑丹", "value": 0, "type": "ability"}
		]
	
	if treasure_pool.size() == 0:
		return {"name": "未知寶物", "value": 0, "type": "unknown"}
	
	var index := randi() % treasure_pool.size()
	return treasure_pool[index].duplicate()

func _add_treasure_to_inventory(treasure: Dictionary) -> void:
	# Add treasure to player's inventory/resources
	# This would integrate with your resource management system
	var treasure_type := treasure.get("type", "")
	var value := treasure.get("value", 0)
	var name := treasure.get("name", "未知寶物")
	
	match treasure_type:
		"loyalty":
			# Could increase global loyalty or give loyalty items
			push_notification("獲得忠誠物品: %s" % name)
			# In practice: add to loyalty items inventory
			
		"cure":
			push_notification("獲得治療物品: %s" % name)
			# In practice: add to medicine inventory
			
		"ability":
			push_notification("獲得能力物品: %s" % name)
			# In practice: add to ability items inventory
			
		"taoist_item", "scholar_item", "doctor_item", "entertainer_item", "artisan_item", "military_book", "mountain_item", "profession_item":
			push_notification("獲得職業物品: %s" % name)
			# In practice: add to specific profession items inventory
			
		"unknown":
			push_notification("獲得未知物品: %s" % name)

func _add_special_item_to_inventory(item: Dictionary) -> void:
	# Add special items like heavenly book
	push_notification("獲得特殊物品: %s" % item.get("name", "未知"))

func _add_gold(amount: int) -> void:
	# Add gold to player's resources
	push_notification("獲得 %d 金錢!" % amount)
	# In practice: add to global gold resource

func _remove_hero_from_fortress(hero_id: String) -> void:
	# Remove hero from active fortress roster
	push_notification("%s 離開要塞" % _get_hero_name(hero_id))
	# In practice: remove from fortress heroes list

func _remove_heroes_from_fortress(hero_ids: Array) -> void:
	# Remove multiple heroes from fortress
	for hero_id in hero_ids:
		_remove_hero_from_fortress(hero_id)

func _add_hero_to_fortress(hero_data: Dictionary) -> void:
	# Add hero to active fortress roster
	var hero_name := hero_data.get("name", "未知")
	push_notification("%s 加入要塞!" % hero_name)
	# In practice: add to fortress heroes list

def _get_fortress_heroes() -> Array:
	# Get list of heroes currently in fortress
	# This would need to be implemented based on your fortress management system
	return []  # Placeholder

def _check_marriage_conditions() -> bool:
	# Check if there are eligible male/female ruffians cohabitating
	# This would check your fortress for male/female ruffians working/living together
	return false  # Placeholder

def _check_divorce_conditions() -> bool:
	# Check for marital stress factors
	return false  # Placeholder

def _check_relative_arrival() -> bool:
	# Check if relatives have arrived as vagrants
	return false  # Placeholder

def _check_tavern_interaction() -> bool:
	# Check for tavern/resting combinations that trigger recruitment
	return false  # Placeholder

def _check_relative_visit_request() -> bool:
	# Check if ruffian with external relatives wants to visit family
	return false  # Placeholder

def _check_market_facility_present() -> bool:
	# Check if fortress has a market facility
	return false  # Placeholder

def _apply_marriage_bonus(husband_id: String, wife_id: String) -> void:
	# Apply loyalty bonuses for married couples
	var husband_loyalty := DataManager.get_hero(husband_id).get("loyalty", 50)
	var wife_loyalty := DataManager.get_hero(wife_id).get("loyalty", 50)
	
	# Marriage increases loyalty slightly
	var bonus := 5
	DataManager.get_hero(husband_id)["loyalty"] = min(husband_loyalty + bonus, 100)
	DataManager.get_hero(wife_id)["loyalty"] = min(wife_loyalty + bonus, 100)

def _apply_divorce_penalty(husband_id: String, wife_id: String, third_party_id: String = "", is_poisoning: bool = false) -> void:
	# Apply loyalty penalties for divorce
	var husband_loyalty := DataManager.get_hero(husband_id).get("loyalty", 50)
	var wife_loyalty := DataManager.get_hero(wife_id).get("loyalty", 50)
	
	match third_party_id:
		"":
			# Mutual divorce
			var penalty := 20
			DataManager.get_hero(husband_id)["loyalty"] = max(husband_loyalty - penalty, 0)
			DataManager.get_hero(wife_id)["loyalty"] = max(wife_loyalty - penalty, 0)
		_:
			# Third party involved
			var penalty := 30
			DataManager.get_hero(husband_id)["loyalty"] = max(husband_loyalty - penalty, 0)
			DataManager.get_hero(wife_id)["loyalty"] = max(wife_loyalty - penalty, 0)
			if third_party_id:
				DataManager.get_hero(third_party_id)["loyalty"] = min(DataManager.get_hero(third_party_id).get("loyalty", 50) + 10, 100)
	
	if is_poisoning:
		# Poisoning case: victim dies or is severely punished
		DataManager.get_hero(husband_id)["loyalty"] = 0
		DataManager.get_hero(husband_id)["action"] = "被毒殺"

def _determine_tournament_winner(trigger_context: Dictionary) -> String:
	# Determine the actual winner of the martial arts tournament
	# This would consider all participating fighters and interference
	return ""  # Placeholder - would return hero ID of winner

def _apply_tournament_drugs_effect() -> void:
	# Apply effects of Gao Qiu's drugs in tournament
	push_notification("參賽者中藥物影響，發揮受阻!")
	# In practice: apply temporary stat penalties to tournament participants

def _apply_tournament_detain_champion_effect() -> void:
	# Detain the would-be champion
	push_notification("冠軍被扣留，無法領獎!")
	# In practice: mark the would-be champion as detained

def push_notification(message: String) -> void:
	# Simple notification - in a full implementation this would show a toast or UI element
	print("[特殊事件] %s" % message)

def _save_persistent_data() -> void:
	# Save marriage and relative data to persistent storage
	# This would integrate with your save system
	var save_data := {
		"marriages": marriages,
		"relative_records": relative_records
	}
	# In practice: save this data with your game save

def _load_persistent_data() -> void:
	# Load marriage and relative data from persistent storage
	# This would integrate with your save system
	pass  # Placeholder - would load saved data