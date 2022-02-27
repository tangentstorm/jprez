# jprez godot plugin
tool extends EditorPlugin

var jprez
var org : OrgNode
var outln
var chunks
var org_import

func _enter_tree():
	org_import = preload("res://addons/jprez/org_import.gd").new()
	add_import_plugin(org_import)

	outln = preload("res://addons/jprez/Outline.tscn").instance()
	add_control_to_dock(DOCK_SLOT_LEFT_UL, outln)

	chunks = preload("res://addons/jprez/jp-chunklist.tscn").instance()
	add_control_to_dock(DOCK_SLOT_LEFT_BL, chunks)

	jprez = preload("res://addons/jprez/jprez-plugin.tscn").instance()
	add_control_to_bottom_panel(jprez, "jprez")

	outln.connect("node_selected", chunks, "set_org")
	chunks.connect("audio_step_selected", self, "_on_audio_step_selected")

func handles(object):
	return object is OrgNode

func edit(org):
	outln.set_org(org)
	chunks.set_org(org)
	jprez.set_org(org)

func _exit_tree():
	remove_import_plugin(org_import); org_import = null
	remove_control_from_bottom_panel(jprez); jprez.queue_free()
	remove_control_from_docks(outln); outln.queue_free()

func _on_audio_step_selected(path):
	var ed = get_editor_interface()
	var samp : AudioStreamSample
	if not ResourceLoader.exists(path):
		print("DOESNT EXIST SO CREATING")
		samp = AudioStreamSample.new()
		samp.format = AudioStreamSample.FORMAT_16_BITS
		samp.stereo = true
		samp.save_to_wav(path)
		ed.get_resource_filesystem().scan()
	samp = ResourceLoader.load(path)
	ed.edit_resource(samp)
