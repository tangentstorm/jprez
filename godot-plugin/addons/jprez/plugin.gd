# jprez godot plugin
tool extends EditorPlugin

var jkvm
var org : OrgNode
var outln
var steps
var org_import

func _enter_tree():
	org_import = preload("res://addons/jprez/org_import.gd").new()
	add_import_plugin(org_import)

	outln = preload("res://addons/jprez/Outline.tscn").instance()
	add_control_to_dock(DOCK_SLOT_LEFT_UL, outln)

	steps = preload("res://addons/jprez/Steps.tscn").instance()
	add_control_to_dock(DOCK_SLOT_LEFT_BL, steps)

	jkvm = preload("res://addons/jprez/jprez-plugin.tscn").instance()
	add_control_to_bottom_panel(jkvm, "jprez")

	outln.connect("node_selected", steps, "set_org")

func handles(object):
	return object is OrgNode

func edit(org):
	outln.set_org(org)
	steps.set_org(org)

func _exit_tree():
	remove_import_plugin(org_import); org_import = null
	remove_control_from_bottom_panel(jkvm); jkvm.queue_free()
	remove_control_from_docks(outln); outln.queue_free()
