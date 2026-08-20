extends SceneTree

func _init() -> void:
	var scene = load("res://scenes/MainGame.tscn")
	var instance = scene.instantiate()
	print("Instance: ", instance)
	print_tree_recursive(instance, 0)
	quit(0)

func print_tree_recursive(node: Node, depth: int) -> void:
	var indent = ""
	for i in range(depth): indent += "  "
	print(indent, "- ", node.name, " (", node.get_class(), ") children: ", node.get_child_count())
	for child in node.get_children():
		print_tree_recursive(child, depth + 1)
