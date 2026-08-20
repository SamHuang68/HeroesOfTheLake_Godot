# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 15大職業與技能修煉系統 (Profession Manager)
class_name ProfessionManager
extends RefCounted

const PROFESSIONS := {
	"無賴": {"desc": "江湖無賴，擅長市井打聽與煽動", "stat_bonus": "機敏 +5", "facility": "Tavern"},
	"豪傑": {"desc": "威震四方之名將，擅長統軍作戰與單挑", "stat_bonus": "臂力 +10, 統率 +10", "facility": "Barracks"},
	"軍師": {"desc": "運籌帷幄，擅長奇謀陣法與妖術策論", "stat_bonus": "智力 +15", "facility": "MainHall"},
	"官吏": {"desc": "精通政略文牘，提升要塞治安與稅收", "stat_bonus": "智力 +5, 黃金產出 +20%", "facility": "Market"},
	"僧侶": {"desc": "修持佛法，提升民心與傷兵恢復", "stat_bonus": "仁德 +10", "facility": "Temple"},
	"道士": {"desc": "通曉陰陽五行，能施展呼風喚雨妖術", "stat_bonus": "智力 +10, 妖術威力 +30%", "facility": "Temple"},
	"技工": {"desc": "善於修築要塞城寨與攻城器具", "stat_bonus": "建造速度 +50%", "facility": "Smithy"},
	"醫師": {"desc": "懸壺濟世，能醫治瘟疫與迅速恢復好漢體力", "stat_bonus": "傷病痊癒率 +100%", "facility": "Pharmacy"},
	"船夫": {"desc": "水泊蛟龍，水戰攻防能力翻倍", "stat_bonus": "水戰適性 +30", "facility": "Shipyard"},
	"商人": {"desc": "長於商賈貿易，集市買賣價格優惠", "stat_bonus": "交易利潤 +25%", "facility": "Market"},
	"獵人": {"desc": "百步穿楊，提升射擊命中率與山地行軍", "stat_bonus": "箭術 +15", "facility": "Ranch"},
	"農夫": {"desc": "深耕細作，極大提升農田糧食產量", "stat_bonus": "糧食產量 +40%", "facility": "Farm"},
	"鍛冶": {"desc": "神兵鑄造大師，打造絕世神兵軍械", "stat_bonus": "軍械產出 +50%", "facility": "Smithy"},
	"雜伎": {"desc": "酒館演藝與雜技，快速提升要塞繁榮度", "stat_bonus": "好漢忠誠不易下降", "facility": "Tavern"},
	"盜賊": {"desc": "神出鬼沒，擅長夜襲、伏兵與劫取敵資", "stat_bonus": "突襲成功率 +35%", "facility": "Watchtower"}
}

static func get_profession_level(exp_val: int) -> int:
	if exp_val >= 1000: return 5
	elif exp_val >= 600: return 4
	elif exp_val >= 300: return 3
	elif exp_val >= 100: return 2
	else: return 1

static func get_profession_title(level: int) -> String:
	match level:
		1: return "初學"
		2: return "熟練"
		3: return "精通"
		4: return "大師"
		5: return "神級"
		_: return "入門"

static func add_profession_exp(hero_dict: Dictionary, prof_name: String, exp_gain: int) -> Dictionary:
	var profs: Dictionary = hero_dict.get("professions", {})
	var curr_exp: int = profs.get(prof_name, 0)
	var new_exp: int = curr_exp + exp_gain
	profs[prof_name] = new_exp
	hero_dict["professions"] = profs
	return hero_dict