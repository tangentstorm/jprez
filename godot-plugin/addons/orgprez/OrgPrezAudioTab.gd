tool
class_name OrgPrezAudioTab extends VBoxContainer

onready var wavepanel = find_node("WaveformPanel")
onready var chunklist = find_node("ChunkList")
onready var outline = find_node("Outline")
onready var editor = find_node("CodeEditor")
onready var prompter:LineEdit = find_node("Prompter")
onready var update_button = find_node("UpdateButton")
onready var repl = find_node("REPL")

var org:OrgNode setget set_org
var current_chunk: OrgChunk
onready var current_track = Org.Track.AUDIO setget set_current_track
var last_caret_position = INF

func set_current_track(t):
	current_track = t
	#repl.visible = false; 
	wavepanel.visible = false
	match t:
		Org.Track.AUDIO: wavepanel.visible = true
		#Org.Track.MACRO: repl.visible = true

func set_org(o:OrgNode):
	org = o
	chunklist.org_dir = org.get_dir()
	chunklist.connect("audio_chunk_selected", self, "_on_audio_chunk_selected")
	chunklist.connect("macro_chunk_selected", self, "_on_macro_chunk_selected")
	chunklist.connect("chunk_selected", self, "_on_chunk_selected")
	outline.connect("node_selected", self, "_on_headline_selected")
	outline.set_org(org)

func _on_headline_selected(org):
	chunklist.set_org(org)
	if org != null: editor.text = org.slide_text()

func _on_chunk_selected(chunk:OrgChunk):
	current_chunk = chunk
	self.current_track = chunk.track
	prompter.text = chunk.lines_to_string()
	last_caret_position = INF
	update_button.disabled = true

func _on_audio_chunk_selected(chunk:OrgChunk):
	wavepanel.edit_path(org.get_dir() + chunk.suggest_path())

func _on_macro_chunk_selected(chunk:OrgChunk):
	return
	
	# !! almost jprezstepper.goix(), but don't advance. (TODO: merge the stepper with this view?)
	#repl.JI.cmd("goix %d %d" % [chunk.jpxy.x, chunk.jpxy.y])
	# except this version also triggers the macro debugger.
	# (code taken from edline'' in jprez)
	#repl.JI.cmd("setval__red ''")
	#repl.JI.cmd("notify__red =: instaplay @ (4&}. [ reset_rhist_base_@'')")

func _on_Prompter_text_changed(new_text):
	update_button.disabled = false

func _process(_dt):
	if current_track == Org.Track.MACRO:
		if prompter.caret_position != last_caret_position:
			# !! in jprez, modifying led notifies red to play the macro.
			if prompter.text.begins_with(": . "):
				var j = "notify__red '%s'" % prompter.text.left(prompter.caret_position).replace("'", "''")
				repl.JI.cmd(j)
				repl.refresh()
		last_caret_position = prompter.caret_position

func _on_UpdateButton_pressed():
	var chunk = current_chunk
	var old_path = chunk.suggest_path() if chunk.track == Org.Track.AUDIO else ''
	chunk.lines = []
	for line in prompter.text.split("\n"):
		chunk.lines.push_back(line)
	if current_track == Org.Track.AUDIO:
		var new_path = chunk.suggest_path()
		var d = Directory.new()
		assert(d.open(org.get_dir()) == OK, "couldn't open org directory %s ?!" % org.get_dir())
		if d.file_exists(old_path):
			if d.file_exists(new_path):
				print("old_path:", old_path)
				print("new_path:", new_path)
				printerr('both old and new paths already exist!')
			else: assert(d.rename(old_path, new_path) == OK, "couldn't rename %s to %s" % [old_path, new_path])
	else: pass
	org.save()

func _on_macro_track_selected(chunk:OrgChunk):
	self.current_track = Org.Track.MACRO
