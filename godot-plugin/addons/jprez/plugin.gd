# jprez godot plugin
tool extends EditorPlugin

var jprez
var wav_dir = 'res://'

func _enter_tree():
	jprez = preload("res://addons/jprez/jprez-plugin.tscn").instance()
	add_control_to_bottom_panel(jprez, "jprez")

func _exit_tree():
	remove_control_from_bottom_panel(jprez); jprez.queue_free()

func edit_sample(path):
	var samp:AudioStreamSample = ResourceLoader.load(path)
	get_editor_interface().edit_resource(samp)

func _on_audio_chunk_selected(chunk:OrgChunk):
	var path = wav_dir + chunk.suggest_path()
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
