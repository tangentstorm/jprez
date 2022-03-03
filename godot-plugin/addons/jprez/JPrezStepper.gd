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
var tracks: Array
var this_audio_chunk
var next_audio_chunk
var slide_just_changed = false

onready var ChunkList = find_node("ChunkList")
onready var Outline = find_node("Outline")

func _ready():
	Outline.connect("node_selected", ChunkList, "set_org")
	$AudioStreamPlayer.connect("finished", self, "_on_audio_finished")

func set_org(o:OrgNode):
	org = o
	ChunkList.org_dir = org.get_dir()
	Outline.set_org(org)
	tracks = []
	for t in Org.Track.values():
		tracks.push_back(OrgCursor.new(org))
		tracks[t].find_next(t)
	this_audio_chunk = tracks[OT.AUDIO].this_chunk()
	next_audio_chunk = tracks[OT.AUDIO].next_chunk()

func _on_audio_finished():
	audio_ready = true
	this_audio_chunk = next_audio_chunk
	next_audio_chunk = tracks[OT.AUDIO].find_next(OT.AUDIO)

func _on_script_finished(_id, _result):
	event_ready = true
	tracks[OT.EVENT].find_next(OT.EVENT)

func _on_macro_finished():
	jprez_ready = true

func _process(_dt):
	show_debug_state()
	if playing or step_ready:
		step_ready = playing
		process_script_track()
		process_audio_track()
		process_macro_track()

func show_debug_state():
	# draw the cursors on the tree control
	ChunkList.clear_highlights()
	ChunkList.highlight_chunk(tracks[OT.EVENT].this_chunk(), Color.royalblue)
	ChunkList.highlight_chunk(tracks[OT.MACRO].this_chunk(), Color.darkslategray)
	ChunkList.highlight_chunk(this_audio_chunk, Color.goldenrod if audio_ready else Color.darkgoldenrod)
	ChunkList.highlight_chunk(next_audio_chunk, Color.sienna)

func process_script_track():
	if event_ready and jprez_ready:
		var event_chunk = tracks[OT.EVENT].this_chunk()
		if not event_chunk: return
		if this_audio_chunk == null or event_chunk.index < this_audio_chunk.index:
			var script:String = tracks[OT.EVENT].this_chunk().lines_to_string()
			if script_engine:
				script_engine.execute(0, script)
				event_ready = false

func process_audio_track():
	if audio_ready and jprez_ready and event_ready:
		if this_audio_chunk:
			if this_audio_chunk.file_exists(org.get_dir()):
				audio_ready = false
				var sample : AudioStreamSample = load(org.get_dir() + this_audio_chunk.suggest_path())
				$AudioStreamPlayer.stream = sample
				$AudioStreamPlayer.play()
				if this_audio_chunk.jpxy.x > old_slide:
					slide_just_changed = true
					Outline.get_node("Tree").get_selected().get_next().select(0)
				old_slide = this_audio_chunk.jpxy.x

func process_macro_track():
	if jprez_ready and event_ready:
		# fire if that chunk comes before the *next* audio track.
		var macro_chunk = tracks[OT.MACRO].this_chunk()
		if not macro_chunk: return
		if next_audio_chunk == null or macro_chunk.index < next_audio_chunk.index:
			jprez_ready = false
			var ix = tracks[OT.MACRO].this_chunk().jpxy
			emit_signal('jprez_line_changed', ix.x, ix.y)
			var next_macro = tracks[OT.MACRO].find_next(OT.MACRO)
			if not next_macro: jprez_ready = false

func _on_PlayButton_pressed():
	playing = not playing

func _on_StepButton_pressed():
	step_ready = true

func reset_ready_flags():
	audio_ready = true
	event_ready = true
	jprez_ready = true

func _on_ChunkList_chunk_selected(chunk):
	if slide_just_changed:
		slide_just_changed = false
		return
	if not tracks: return
	for track in Org.Track.values():
		reset_ready_flags()
		var track_chunk = tracks[track].goto_index(chunk.index, track)
		if track == OT.AUDIO:
			this_audio_chunk = track_chunk
			next_audio_chunk = tracks[track].find_next(track)
		old_slide = this_audio_chunk.jpxy.x
		if track == OT.MACRO:
			var ix = chunk.jpxy
			emit_signal('jprez_line_changed', ix.x, ix.y)