# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 事件系統 (Events System)
class_name EventManager
extends RefCounted

# Event types
enum EventType {
    TYPHOON = 0,
    PLAGUE = 1,
    PRIVATE_ACTION = 2,
    RECRUITMENT = 3,
    RESOURCE_BOON = 4
}

# Event definitions
const EVENT_DEFINITIONS := [
    {
        "type": EventType.TYPHOON,
        "name": "颶風",
        "description": "強烈的風暴吹襲要塞，隨機破壞設施",
        "chance_per_month": 0.05,  # 5% chance per month
        "effect": "_apply_typhoon_effect"
    },
    {
        "type": EventType.PLAGUE,
        "name": "瘟疫",
        "description": "傳染病在要塞中蔓延，減少設施人口數",
        "chance_per_month": 0.03,  # 3% chance per month
        "duration_months": 3,      # Lasts 3 months
        "effect": "_apply_plague_effect"
    },
    {
        "type": EventType.PRIVATE_ACTION,
        "name": "好漢私自行動",
        "description": "好漢可能自行離隊進行特殊行動",
        "chance_per_hero_per_month": 0.02,  # 2% chance per hero per month
        "effect": "_apply_private_action_effect"
    },
    {
        "type": EventType.RECRUITMENT,
        "name": "招募機會",
        "description": "有機會招募新好漢加入要塞",
        "chance_per_month": 0.15,  # 15% chance per month
        "effect": "_apply_recruitment_effect"
    },
    {
        "type": EventType.RESOURCE_BOON,
        "name": "資源豐收",
        "description": "設施額外產出資源",
        "chance_per_month": 0.10,  # 10% chance per month
        "effect": "_apply_resource_boon_effect"
    }
]

# Track active events
var active_events := []

func _ready() -> void:
	# Initialize random seed
	randomize()

def update_monthly() -> void:
	# Check for monthly events
	for event_def in EVENT_DEFINITIONS:
		if event_def.has("chance_per_month"):
			if randf() < event_def["chance_per_month"]:
				trigger_event(event_def["type"])
	
	# Update existing event durations
	var i := 0
	while i < active_events.size():
		var event := active_events[i]
		event["remaining_months"] -= 1
		if event["remaining_months"] <= 0:
			active_events.remove_at(i)
		else:
			i += 1

def trigger_event(event_type: int) -> void:
	var event_def := get_event_definition(event_type)
	if event_def == null:
		return
	
	var event_instance := {
		"type": event_type,
		"name": event_def["name"],
		"description": event_def["description"],
		"start_month": GameManager.get_current_month(),  # Would need GameManager
		"remaining_months": event_def.get("duration_months", 1)
	}
	
	active_events.append(event_instance)
	
	# Apply the event effect
	var effect_func := Callable(self, event_def["effect"])
	effect_func.call()
	
	# Notify player (in practice would show notification)
	print("事件觸發: %s" % event_def["name"])

def get_event_definition(event_type: int) -> Dictionary:
	for event_def in EVENT_DEFINITIONS:
		if event_def["type"] == event_type:
			return event_def
	return {}

def _apply_typhoon_effect() -> void:
	# Typhoon destroys random facilities
	print("颶風來襲！正在破壞隨機設施...")
	# In practice, would select random facility and apply destruction effects

def _apply_plague_effect() -> void:
	# Plague reduces facility population/effectiveness
	print("瘟疫爆發！設施人口數下降...")
	# In practice, would reduce facility output for duration

def _apply_private_action_effect() -> void:
	# Heroes may act independently
	print("有好漢私自行動！")
	# In practice, would check each hero for chance to leave temporarily

def _apply_recruitment_effect() -> void:
	# Opportunity to recruit new heroes
	print("有新好漢願意加入！")
	# In practice, would make a hero available for recruitment

def _apply_resource_boon_effect() -> void:
	# Facilities produce extra resources
	print("資源豐收！設施額外產出...")
	# In practice, would boost facility output for this month

def get_active_events() -> Array:
	return active_events.duplicate()

def is_event_active(event_type: int) -> bool:
	for event in active_events:
		if event["type"] == event_type:
			return true
	return false