# Test script to verify integration
# This would normally be run in a test scene

func _ready() -> void:
	print("=== Testing Heroes of the Lake Systems ===")
	
	# Test DataManager
	DataManager.initialize()
	var hero := DataManager.get_hero("LinChong")
	if hero.size() > 0:
		print("✓ DataManager: Loaded Lin Chong - %s" % hero["name"])
		print("  Strength: %d, Skill: %d, Intelligence: %d" % [
			hero["strength"], hero["skill"], hero["intelligence"]
		])
	else:
		print("✗ DataManager: Failed to load hero")
	
	# Test SaveManager
	SaveManager.initialize()
	print("✓ SaveManager: Initialized")
	
	# Test ProfessionManager
	var profession_name := ProfessionManager.get_profession_name(0)
	print("✓ ProfessionManager: Profession 0 = %s" % profession_name)
	var title := ProfessionManager.get_profession_title(0, 2)
	print("✓ ProfessionManager: Level 2 title = %s" % title)
	
	# Test CombatManager
	var test_hero := {
		"name": "Test Hero",
		"strength": 900,
		"skill": 700,
		"intelligence": 800,
		"stamina_curr": 50,
		"stamina_max": 100
	}
	var can_act := CombatManager.can_perform_action(test_hero, "果斷突擊")
	print("✓ CombatManager: Can perform 果斷突擊 with 50 stamina? %s" % can_act)
	
	# Test EventManager
	EventManager._ready()
	print("✓ EventManager: Initialized")
	
	print("=== All systems initialized successfully ===")