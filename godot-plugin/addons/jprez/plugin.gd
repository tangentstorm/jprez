# jprez godot plugin
tool extends EditorPlugin

var jkvm

func _enter_tree():
	jkvm = preload("res://addons/jprez/jprez-plugin.tscn").instance()
	add_control_to_bottom_panel(jkvm, "jprez")


func _exit_tree():
	remove_control_from_bottom_panel(jkvm)
	jkvm.free()
