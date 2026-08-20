# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 事件管理器 (Event Manager)
class_name EventManager
extends RefCounted

signal event_triggered(event_info: Dictionary)

enum EventType {
	RECRUIT_VISIT,    # 好漢來投
	BIRTHDAY_GIFT,    # 劫取生辰綱情報
	GOVERNMENT_RAID,  # 官軍進犯警報
	HARVEST_BOON,     # 水泊五穀豐收
	STORM_DISASTER,   # 梁山暴風雨
	MARKET_BOOM       # 江湖商隊大集市
}

static var event_history: Array[Dictionary] = []

static func check_monthly_events(month: int, prestige: int) -> Dictionary:
	var roll := randf()

	# 1. 好漢來投 (15% 機率)
	if roll < 0.18:
		var wandering_heroes := ["史進", "魯智深", "武松", "李逵", "花榮", "戴宗", "阮小二", "張順", "楊志", "秦明", "呼延灼", "公孫勝"]
		var chosen: String = wandering_heroes[randi() % wandering_heroes.size()]
		var ev := {
			"type": EventType.RECRUIT_VISIT,
			"title": "🏮 江湖豪傑慕名來投",
			"description": "【%s】久聞梁山泊替天行道之名，特前來水泊山寨聚義！" % chosen,
			"hero_name": chosen,
			"gold_delta": 0,
			"food_delta": 0,
			"prestige_delta": 15
		}
		event_history.append(ev)
		return ev

	# 2. 劫取生辰綱 / 商隊情報 (12% 機率)
	elif roll < 0.32:
		var ev := {
			"type": EventType.BIRTHDAY_GIFT,
			"title": "💰 探得生辰綱與押運金銀",
			"description": "密探回報：大名府梁中書搜刮十萬貫生辰綱，正經由黃泥岡押往汴京！我軍可發動劫取！",
			"gold_delta": 2000,
			"food_delta": 500,
			"prestige_delta": 25
		}
		event_history.append(ev)
		return ev

	# 3. 水泊五穀大豐收 (15% 機率，特別在秋季 8~10月)
	elif (month >= 8 and month <= 10) or roll < 0.50:
		var ev := {
			"type": EventType.HARVEST_BOON,
			"title": "🌾 梁山水泊五穀大豐收",
			"description": "天候調和，水泊八百里耕地良田喜獲豐收，糧倉充盈！",
			"gold_delta": 500,
			"food_delta": 1800,
			"prestige_delta": 10
		}
		event_history.append(ev)
		return ev

	# 4. 江湖商隊大集市 (12% 機率)
	elif roll < 0.65:
		var ev := {
			"type": EventType.MARKET_BOOM,
			"title": "🛒 南北客商雲集大鬧市",
			"description": "江南與中原商隊紛紛前來要塞市集貿易，黃金稅收大增！",
			"gold_delta": 1500,
			"food_delta": 0,
			"prestige_delta": 10
		}
		event_history.append(ev)
		return ev

	# 5. 官軍進犯警報 (若聲望大於 400，10% 機率)
	elif prestige > 400 and roll < 0.80:
		var ev := {
			"type": EventType.GOVERNMENT_RAID,
			"title": "⚔️ 官府兵馬逼近山寨",
			"description": "汴京高俅下令濟州府集結三千兵馬，正朝梁山泊水泊前進！全寨進入戒備狀態！",
			"gold_delta": -200,
			"food_delta": -300,
			"prestige_delta": 0
		}
		event_history.append(ev)
		return ev

	# 6. 暴風雨突襲 (8% 機率)
	elif roll < 0.90:
		var ev := {
			"type": EventType.STORM_DISASTER,
			"title": "⛈️ 梁山水泊暴風雨襲擊",
			"description": "狂風驟雨席捲水泊，部分鹿角防禦與屋簷受損，需消耗資源修繕！",
			"gold_delta": -300,
			"food_delta": -200,
			"prestige_delta": -5
		}
		event_history.append(ev)
		return ev

	return {}