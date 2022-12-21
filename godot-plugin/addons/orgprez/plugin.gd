# presentation tool for emacs org files
tool
extends EditorPlugin

var scene = preload('res://addons/orgprez/plugin.tscn')
var app # member variable holding instance of scene

func _enter_tree():
	app = scene.instance()
	get_editor_interface().get_editor_viewport().add_child(app)

func has_main_screen():
	return true

func get_plugin_name():
	return "OrgPrez" # used in top-level tab name

func get_plugin_icon():
	return get_editor_interface().get_base_control().get_icon("AutoKey", "EditorIcons")

func _exit_tree():
	if app: app.queue_free()

