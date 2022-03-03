class_name JPrezAudioTab extends VBoxContainer

onready var wavepanel = find_node("WaveformPanel")
onready var chunklist = find_node("ChunkList")
onready var outline = find_node("Outline")
onready var editor = find_node("CodeEditor")
onready var prompter = find_node("Prompter")

var org:OrgNode setget set_org

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
	prompter.text = chunk.lines_to_string()
	wavepanel.edit_path(org.get_dir() + chunk.suggest_path())
