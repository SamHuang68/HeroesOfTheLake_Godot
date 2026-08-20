extends SceneTree

func _init() -> void:
	var dm = load("res://scripts/DataManager.gd")
	dm.initialize()
	var map = load("res://scripts/IsometricMap.gd").new()
	map._ready()
	
	print("\n=== GROUND TEXTURES VERIFICATION ===")
	print("Loaded ground textures: ", map.tile_textures.size())
	for k in map.tile_textures.keys():
		print("  TileType: ", k, " Texture: ", map.tile_textures[k])
	quit(0)
