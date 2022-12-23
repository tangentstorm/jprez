class_name OrgPrezStepper extends WindowDialog

signal orgprez_line_changed(scene, cmd)

var script_engine: Node

var org : OrgNode setget set_org
const OT = Org.Track
var sync_pending = false
var playing = false
var step_ready = false
var old_slide = 0
var tracks: Array
var ready: Array
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
	tracks = []; ready = []
	for t in Org.Track.values():
		tracks.push_back(OrgCursor.new(org))
		tracks[t].find_next(t)
		ready.push_back(true) # everything's ready to go at the start
	this_audio_chunk = tracks[OT.AUDIO].this_chunk()
	next_audio_chunk = tracks[OT.AUDIO].next_chunk()
	show_debug_state()

func _on_audio_finished():
	ready[OT.AUDIO] = true
	this_audio_chunk = next_audio_chunk
	next_audio_chunk = tracks[OT.AUDIO].find_next(OT.AUDIO)

func _on_script_finished(_id, _result):
	ready[OT.EVENT] = true
	tracks[OT.EVENT].find_next(OT.EVENT)

func _on_macro_finished():
	ready[OT.MACRO] = true

func track_to_step():
	# find the hindmost cursor:
	var hindmost_index = next_audio_chunk.index if next_audio_chunk else INF
	var hindmost_track = null
	for track in OT.values():
		if ready[track]:
			var chunk = this_audio_chunk if track == OT.AUDIO else tracks[track].this_chunk()
			if not chunk: continue
			if chunk.index < hindmost_index:
				hindmost_track = track
				hindmost_index = chunk.index
	# if hindmost_track != null: print("hindmost track:", OT.keys()[hindmost_track])
	return hindmost_track

func _process(_dt):
	# no stepping past @sync until all tracks are ready:
	# (this generally means wait for the audio to finish before starting next step)
	if sync_pending:
		sync_pending = false
		for track in OT.values():
			if not ready[track]: sync_pending = true
	# only one step per frame:
	if playing or step_ready:
		step_ready = playing
		match track_to_step():
			OT.EVENT: process_event_track()
			OT.MACRO: process_macro_track()
			OT.AUDIO: process_audio_track()
			null: step_ready = true
		show_debug_state()

func show_debug_state():
	# draw the cursors on the tree control
	ChunkList.clear_highlights()
	ChunkList.highlight_chunk(tracks[OT.EVENT].this_chunk(), Color.royalblue)
	ChunkList.highlight_chunk(tracks[OT.MACRO].this_chunk(), Color.darkslategray)
	ChunkList.highlight_chunk(this_audio_chunk, Color.goldenrod if ready[OT.AUDIO] else Color.darkgoldenrod)
	ChunkList.highlight_chunk(next_audio_chunk, Color.sienna)

func process_event_track():
	if ready[OT.EVENT] and ready[OT.MACRO]:
		var event_chunk = tracks[OT.EVENT].this_chunk()
		if not event_chunk: return
		if this_audio_chunk == null or event_chunk.index < this_audio_chunk.index:
			var script:String = tracks[OT.EVENT].this_chunk().lines_to_string()
			if script == '@sync':
				# we handle this one separately from script_engine because it's really about the stepper.
				sync_pending = true
				tracks[OT.EVENT].find_next(OT.EVENT)
			elif script_engine:
				script_engine.execute(0, script)
				ready[OT.EVENT] = false

func process_audio_track():
	if ready[OT.AUDIO] and ready[OT.MACRO] and ready[OT.EVENT]:
		if this_audio_chunk:
			if this_audio_chunk.file_exists(org.get_dir()):
				ready[OT.AUDIO] = false
				var sample : AudioStreamSample = load(org.get_dir() + this_audio_chunk.suggest_path())
				$AudioStreamPlayer.stream = sample
				$AudioStreamPlayer.play()
				if this_audio_chunk.jpxy.x > old_slide:
					slide_just_changed = true
					Outline.get_node("Tree").get_selected().get_next().select(0)
				old_slide = this_audio_chunk.jpxy.x

func process_macro_track():
	if ready[OT.MACRO] and ready[OT.EVENT]:
		# fire if that chunk comes before the *next* audio track.
		var macro_chunk = tracks[OT.MACRO].this_chunk()
		if not macro_chunk: return
		if next_audio_chunk == null or macro_chunk.index < next_audio_chunk.index:
			ready[OT.MACRO] = false
			var ix = macro_chunk.jpxy
			emit_signal('orgprez_line_changed', ix.x, ix.y)
			var next_macro = tracks[OT.MACRO].find_next(OT.MACRO)
			if not next_macro: ready[OT.MACRO] = false

func _on_PlayButton_pressed():
	playing = not playing

func _on_StepButton_pressed():
	step_ready = true

func reset_ready_flags():
	ready[OT.AUDIO] = true
	ready[OT.EVENT] = true
	ready[OT.MACRO] = true

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
	var ix = chunk.jpxy
	emit_signal('orgprez_line_changed', ix.x, ix.y)
	show_debug_state()
