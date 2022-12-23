tool
class_name OrgDeck extends Node

func add_child(node:Node, legible_unique_name:bool=false):
	.add_child(node, legible_unique_name)
	observe(node)
	show_only(node)

func _ready():
	for child in get_children():
		observe(child)

func observe(node):
	node.connect("visibility_changed", self, "on_child_visibility_changed", [node])

# TODO: if the visible slide is removed, 
#       and there is another slide, show one.
#func remove_child(node:Node):
#	if node.visible
#	.remove_child(node)

func on_child_visibility_changed(child):
	if child.visible:
		show_only(child)
	
func show_only(node:Node):
	for child in self.get_children():
		if node != child:
			child.visible = false
	if not node.visible:
		node.visible = true

