extends SceneTree

func _init() -> void:
	var dm = load("res://scripts/DataManager.gd")
	dm.initialize()
	
	var main_scene = load("res://scenes/MainGame.tscn").instantiate()
	root.add_child(main_scene)
	
	# 等待 1 幀讓 _ready() 全部執行
	await process_frame
	
	var map = main_scene.get_node("World2D/IsometricMap")
	var facs = map.get_node("Facilities")
	var chars = map.get_node("Characters")
	var decs = map.get_node("Decorations")
	
	print("\n=== AFTER READY FRAME ===")
	print("Facilities child count: ", facs.get_child_count())
	for f in facs.get_children():
		print("  Facility: ", f.get("display_name"), " Grid: ", f.get("grid_coord"), " Pos: ", f.position)
	print("Characters child count: ", chars.get_child_count())
	for c in chars.get_children():
		print("  Character: ", c.get("hero_name"), " Grid: ", c.get("grid_position"), " Pos: ", c.position)
	print("Decorations child count: ", decs.get_child_count())
	quit(0)
