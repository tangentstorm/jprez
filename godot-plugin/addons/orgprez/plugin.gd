# presentation tool for emacs org files
tool
extends EditorPlugin

const scene = preload('res://addons/orgprez/OrgPrezAudioTab.tscn')
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

func handles(object):
	return object is OrgNode

func edit(org):
	# remember directory for saving wave files
	# TODO: make this wav_dir
	# wav_dir = org.resource_path.get_base_dir()
	# if not wav_dir.ends_with('/'): wav_dir += '/'
	# chunks.org_dir = wav_dir  # !! only need for waves, so update chunks code
	# wav_dir += '.wav'

	# tell the app to load that org-file
	# chunks.set_org(org) # outln will override this with first node (if one exists)
	# outln.set_org(org)
	# jprez.set_org(org)

	app.set_org(org)

func _exit_tree():
	if app: app.queue_free()
	remove_import_plugin(org_import); org_import = null


