class_name JPrezStepper extends WindowDialog
# This component works with an org-file. It knows nothing about J directly.

signal jprez_line_changed(scene, cmd)

var script_engine: Node

var org : OrgNode setget set_org
const OT = Org.Track
var playing = false
var step_ready = false
var audio_ready = true
var event_ready = true
var jprez_ready = true
var old_slide = 0

onready var ChunkList = find_node("ChunkList")
onready var Outline = find_node("Outline")

func _ready():
	Outline.connect("node_selected", ChunkList, "set_org")
	$AudioStreamPlayer.connect("finished", self, "_on_audio_finished")

var tracks: Array
func set_org(o:OrgNode):
	org = o
	ChunkList.org_dir = org.get_dir()
	Outline.set_org(org)
	tracks = []
	for t in Org.Track.values():
		tracks.push_back(OrgCursor.new(org))
		tracks[t].find_next(t)

func _on_audio_finished():
	audio_ready = true

func _on_script_finished(_id, _result):
	print_debug("jprez stepper _on_script_finished")
	event_ready = true
	tracks[OT.EVENT].find_next(OT.EVENT)

func _process(_dt):
	show_debug_state()
	if playing or step_ready:
		step_ready = playing
		process_script_track()
		process_audio_track()
		process_input_and_macro_tracks()

func show_debug_state():
	# draw the cursors on the tree control
	ChunkList.highlight(tracks)

func process_script_track():
	if event_ready:
		if tracks[OT.EVENT].count < tracks[OT.AUDIO].count:
			var script:String = tracks[OT.EVENT].this_chunk().lines_to_string()
			if script_engine:
				script_engine.execute(0, script)
				event_ready = false

func process_audio_track():
	if audio_ready and jprez_ready and event_ready:
		var chunk = tracks[OT.AUDIO].this_chunk()
		if chunk==null: audio_ready = false # no more audio
		else:
			if chunk.file_exists(org.get_dir()):
				audio_ready = false
				var sample : AudioStreamSample = load(org.get_dir() + chunk.suggest_path())
				$AudioStreamPlayer.stream = sample
				$AudioStreamPlayer.play()
				if chunk.jpxy.x > old_slide:
					Outline.get_node("Tree").get_selected().get_next().select(0)
				old_slide = chunk.jpxy.x
			tracks[OT.AUDIO].find_next(OT.AUDIO)

func process_input_and_macro_tracks():
	if jprez_ready:
		# which of the two jprez tracks is next to fire?
		var which = OT.MACRO if tracks[OT.MACRO].count < tracks[OT.INPUT].count else OT.INPUT
		# fire if that chunk comes before the next audio track.
		var which_count = tracks[which].count
		if which == OT.INPUT: which_count += 1
		if which_count < tracks[OT.AUDIO].count:
			var ix = tracks[which].this_chunk().jpxy
			emit_signal('jprez_line_changed', ix.x, ix.y)
			tracks[which].find_next(which)

func _on_PlayButton_pressed():
	playing = not playing

func _on_StepButton_pressed():
	step_ready = true

func _on_ChunkList_chunk_selected(chunk):
	if not tracks: return
	for track in Org.Track.values():
		tracks[track].goto_index(chunk.index, track)
		var ix = chunk.jpxy
		emit_signal('jprez_line_changed', ix.x, ix.y)
