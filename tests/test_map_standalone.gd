extends SceneTree

func _init() -> void:
	var map = load("res://scripts/IsometricMap.gd").new()
	print("Map instantiated standalone...")
	map._ready()
	print("Standalone map facilities: ", map.get_node("Facilities").get_child_count())
	print("Standalone map decors: ", map.get_node("Decorations").get_child_count())
	quit(0)
