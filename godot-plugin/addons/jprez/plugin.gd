# jprez godot plugin
tool extends EditorPlugin

var jkvm
var outln

func _enter_tree():
	outln = preload("res://addons/jprez/Outline.tscn").instance()
	add_control_to_dock(DOCK_SLOT_LEFT_UL, outln)

	jkvm = preload("res://addons/jprez/jprez-plugin.tscn").instance()
	add_control_to_bottom_panel(jkvm, "jprez")


func _exit_tree():
	remove_control_from_bottom_panel(jkvm); jkvm.queue_free()
	remove_control_from_docks(outln); outln.queue_free()
