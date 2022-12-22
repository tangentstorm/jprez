# presentation tool for emacs org files
tool
extends EditorPlugin

var scene = preload('res://addons/orgprez/plugin.tscn')
var app # member variable holding instance of scene

var org_import
func _enter_tree():
	app = scene.instance()
	get_editor_interface().get_editor_viewport().add_child(app)
	make_visible(false) # otherwise it shows up on-screen no matter what tab is active
	org_import = preload("res://addons/orgprez/org_import.gd").new()
	add_import_plugin(org_import)

func has_main_screen():
	return true

func get_plugin_name():
	return "OrgPrez" # used in top-level tab name

func get_plugin_icon():
	return get_editor_interface().get_base_control().get_icon("AutoKey", "EditorIcons")

func make_visible(x): # called at startup and when the tab is changed
	if app: app.visible = x

func _exit_tree():
	if app: app.queue_free()
	remove_import_plugin(org_import); org_import = null


