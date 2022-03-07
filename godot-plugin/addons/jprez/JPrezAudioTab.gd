class_name JPrezAudioTab extends VBoxContainer

onready var wavepanel = find_node("WaveformPanel")
onready var chunklist = find_node("ChunkList")
onready var outline = find_node("Outline")
onready var editor = find_node("CodeEditor")
onready var prompter = find_node("Prompter")
onready var update_button = find_node("UpdateButton")

var org:OrgNode setget set_org
var current_chunk: OrgChunk

func set_org(o:OrgNode):
	org = o
	chunklist.org_dir = org.get_dir()
	chunklist.connect("audio_chunk_selected", self, "_on_audio_chunk_selected")
	outline.connect("node_selected", self, "_on_headline_selected")
	outline.set_org(org)

func _on_headline_selected(org):
	chunklist.set_org(org)
	if org != null: editor.text = org.slide_text()

func _on_audio_chunk_selected(chunk:OrgChunk):
	current_chunk = chunk
	prompter.text = chunk.lines_to_string()
	update_button.disabled = true
	wavepanel.edit_path(org.get_dir() + chunk.suggest_path())

func _on_Prompter_text_changed(new_text):
	update_button.disabled = false

func _on_UpdateButton_pressed():
	var chunk = current_chunk
	var old_path = chunk.suggest_path()
	chunk.lines = []
	for line in prompter.text.split("\n"):
		chunk.lines.push_back(line)
	var new_path = chunk.suggest_path()

	var d = Directory.new()
	assert(d.open(org.get_dir()) == OK, "couldn't open org directory %s ?!" % org.get_dir())
	if d.file_exists(old_path):
		if d.file_exists(new_path):
			print("old_path:", old_path)
			print("new_path:", new_path)
			printerr('both old and new paths already exist!')
		else: assert(d.rename(old_path, new_path) == OK, "couldn't rename %s to %s" % [old_path, new_path])
	org.save()
