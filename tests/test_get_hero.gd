extends SceneTree

func _init() -> void:
	var dm = load("res://scripts/DataManager.gd")
	dm.initialize()
	print("Hero LinChong: ", dm.get_hero("LinChong"))
	print("Hero 林沖: ", dm.get_hero("林沖"))
	print("Total heroes: ", dm.heroes_db.size())
	quit(0)
