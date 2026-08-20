# Copyright (c) 2026 Sam Huang. All Rights Reserved.
extends SceneTree

const DataManagerScript = preload("res://scripts/DataManager.gd")

func _init() -> void:
	DataManagerScript.initialize()
	var main_scene = load("res://scenes/MainGame.tscn").instantiate()
	root.add_child(main_scene)
	
	var map = main_scene.get_node("World2D/IsometricMap")
	var facs = map.get_node("Facilities")
	var chars = map.get_node("Characters")
	var decs = map.get_node("Decorations")
	
	print("\n=== MAP RUNTIME INSPECTION ===")
	print("Map Position: ", map.position)
	print("Camera Position: ", main_scene.get_node("Camera2D").position)
	print("Facilities child count: ", facs.get_child_count())
	for f in facs.get_children():
		print("  Facility: ", f.get("display_name"), " Pos: ", f.position, " Tex: ", f.get("building_texture") != null)
	print("Characters child count: ", chars.get_child_count())
	for c in chars.get_children():
		print("  Character: ", c.get("hero_name"), " Pos: ", c.position, " Tex: ", c.get("hero_sprite_texture") != null)
	print("Decorations child count: ", decs.get_child_count())
	quit(0)
