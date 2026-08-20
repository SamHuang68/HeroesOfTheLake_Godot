# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 戰鬥系統與實時戰術戰意運算 (Combat Manager)
class_name CombatManager
extends RefCounted

const TACTIC_COSTS := {
	"普通攻擊": {"stamina": 5, "base_dmg": 18, "type": "melee"},
	"頑強攻擊": {"stamina": 10, "base_dmg": 24, "type": "melee"},
	"果斷突擊": {"stamina": 30, "base_dmg": 42, "type": "melee"},
	"連續射擊": {"stamina": 20, "base_dmg": 32, "type": "ranged"},
	"神射狙擊": {"stamina": 30, "base_dmg": 45, "type": "ranged"},
	"五雷妖術": {"stamina": 40, "base_dmg": 55, "type": "magic"},
	"使用道符": {"stamina": 5, "base_dmg": 0, "type": "heal"},
	"運功回氣": {"stamina": 0, "base_dmg": 0, "type": "recover"}
}

## 計算部隊戰鬥傷害 (依據武將五維、陣型、兵力與地形)
static func calculate_army_damage(attacker: Dictionary, defender: Dictionary, tactic_name: String, weather: String = "晴") -> Dictionary:
	var t_info: Dictionary = TACTIC_COSTS.get(tactic_name, TACTIC_COSTS["普通攻擊"])
	var base_dmg: float = float(t_info.get("base_dmg", 20))

	var atk_might: float = float(attacker.get("might", 80))
	var atk_skill: float = float(attacker.get("skill", 80))
	var atk_intel: float = float(attacker.get("intel", 70))
	var atk_troops: int = attacker.get("troops", 1000)

	var def_might: float = float(defender.get("might", 75))
	var def_skill: float = float(defender.get("skill", 75))
	var def_troops: int = defender.get("troops", 1000)

	var damage: float = 0.0
	var tactic_type: String = t_info.get("type", "melee")

	match tactic_type:
		"melee":
			damage = base_dmg * (atk_might / maxf(30.0, def_might * 0.8)) * (sqrt(atk_troops) / 25.0)
		"ranged":
			damage = base_dmg * (atk_skill / maxf(30.0, def_skill * 0.75)) * (sqrt(atk_troops) / 26.0)
			if weather == "強風" or weather == "大雨":
				damage *= 0.8 # 風雨降低箭術命中
		"magic":
			damage = base_dmg * (atk_intel / 50.0)
			if weather == "大雨" or weather == "狂風":
				damage *= 1.3 # 風雨助長道術妖術威力
		"heal", "recover":
			damage = 0.0

	var final_dmg: int = maxi(10, int(damage + randi() % 8))
	var new_def_troops: int = maxi(0, def_troops - final_dmg * 5)
	var is_confused: bool = (tactic_type == "magic" and randf() < 0.35)

	return {
		"damage": final_dmg,
		"def_troops_lost": final_dmg * 5,
		"def_troops_remaining": new_def_troops,
		"is_confused": is_confused,
		"stamina_cost": t_info.get("stamina", 5)
	}