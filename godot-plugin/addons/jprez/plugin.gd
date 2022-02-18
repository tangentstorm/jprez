# jprez godot plugin
tool extends EditorPlugin

var jkvm
var org : Org.OrgNode
var outln
var steps

var org_path = 'd:/ver/j-talks/s1/e4-mandelbrot/script.org'

func _enter_tree():
	outln = preload("res://addons/jprez/Outline.tscn").instance()
	add_control_to_dock(DOCK_SLOT_LEFT_UL, outln)

	steps = preload("res://addons/jprez/Steps.tscn").instance()
	add_control_to_dock(DOCK_SLOT_LEFT_BL, steps)

	jkvm = preload("res://addons/jprez/jprez-plugin.tscn").instance()
	add_control_to_bottom_panel(jkvm, "jprez")

	org = Org.from_path(org_path)
	outln.set_org(org)
	steps.set_org(org)

	outln.connect("node_selected", steps, "set_org")

func _exit_tree():
	remove_control_from_bottom_panel(jkvm); jkvm.queue_free()
	remove_control_from_docks(outln); outln.queue_free()
