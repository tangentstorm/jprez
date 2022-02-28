# jprez godot plugin
tool extends EditorPlugin

var jprez
var org : OrgNode
var outln
var chunks
var org_import
var org_dir = 'res://'

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
	chunks.connect("audio_chunk_selected", self, "_on_audio_chunk_selected")

func handles(object):
	return object is OrgNode

func edit(org):
	org_dir = org.resource_path.get_base_dir()
	if not org_dir.ends_with('/'): org_dir += '/'
	chunks.org_dir = org_dir
	chunks.set_org(org) # outln will override this with first node (if one exists)
	outln.set_org(org)
	jprez.set_org(org)

func _exit_tree():
	remove_import_plugin(org_import); org_import = null
	remove_control_from_bottom_panel(jprez); jprez.queue_free()
	remove_control_from_docks(outln); outln.queue_free()

func edit_sample(path):
	var samp:AudioStreamSample = ResourceLoader.load(path)
	get_editor_interface().edit_resource(samp)

func _on_audio_chunk_selected(chunk:OrgChunk):
	var path = org_dir + chunk.suggest_path()
	if ResourceLoader.exists(path): edit_sample(path)
	else:
		# !! make a stub resource and edit that instead. this is so we don't
		# have to make some hard-coded reference to the godot-waveform plugin,
		# though I admit it still feels rather clunky.
		var samp = AudioStreamSample.new()
		samp.resource_path = path
		samp.format = AudioStreamSample.FORMAT_16_BITS
		samp.stereo = true
		get_editor_interface().edit_resource(samp)
