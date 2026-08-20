extends SceneTree

func _init() -> void:
	var main_scene = load("res://scenes/MainGame.tscn").instantiate()
	root.add_child(main_scene)
	
	# 等待 2 幀渲染
	await process_frame
	await process_frame
	await process_frame
	
	var image = root.get_texture().get_image()
	image.save_png("res://debug_screenshot.png")
	print("已截圖至 debug_screenshot.png")
	quit(0)
