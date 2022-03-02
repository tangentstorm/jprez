extends Node

export(Resource) var org setget set_org
onready var JI = $JLang # J interpreter

var org_dir = ''
var org_path = ''
onready var status_label = $PanelContainer/VBox/status
onready var scene_title = $SceneTitle

var tracks: Array
func set_org(x:OrgNode):
	org = x
	org_dir = org.resource_path.get_base_dir() + '/'
	org_path = ProjectSettings.globalize_path(org.resource_path)
	tracks = []
	for t in Org.Track.values():
		tracks.push_back(OrgCursor.new(org))
		tracks[t].find_next(t)

var timer : Timer
func _ready():
	$ChunkList.org_dir = org_dir
	$Outline.connect("node_selected", $ChunkList, "set_org")
	$Outline.set_org(org)
	var hw = '45 220'
	print("J_HOME:", OS.get_environment('J_HOME'))
	JI.cmd("9!:7 [ (16+i.11){a.  NB. box drawing characters")
	JI.cmd("ARGV_z_=:,<''")
	JI.cmd("load 'tangentstorm/j-kvm/vid'")
	JI.cmd("coinsert 'kvm'")
	JI.cmd("1!:44 'd:/ver/jprez'")
	JI.cmd('gethw_vt_ =: {{ ' +hw+ '}}')
	JI.cmd("load 'jprez.ijs'")
	if org_path != '':
		JI.cmd("cocurrent'base'")
		JI.cmd("MACROS_ONLY =: 0")
		JI.cmd("ORG_PATH =: '%s'" % [org_path])
		JI.cmd("reopen_base_=:reopen_outkeys_ f.")
		JI.cmd("reopen''")
		JI.cmd("goto 0")
	$AudioStreamPlayer.connect("finished", self, "_on_audio_finished")
	$SceneTitle.connect("animation_finished", self, "_on_title_animation_finished")

const OT = Org.Track

var playing = false
var step_ready = false
var audio_ready = true
var jprez_ready = true
var event_ready = true
var old_slide = 0

func _on_audio_finished():
	audio_ready = true

func _on_title_animation_finished():
	event_ready = true
	tracks[OT.EVENT].find_next(OT.EVENT)

func _process(_dt):
	JI.cmd("cocurrent'base'")
	show_debug_state()
	if playing or step_ready:
		step_ready = playing
		process_event_track()
		process_audio_track()
		process_input_and_macro_tracks()
	update_jprez()

func show_debug_state():
	var status_str=''
	status_str += ' jprez_ready: ' + str(jprez_ready)
	status_str += ' audio_ready: ' + str(audio_ready)
	status_str += ' event_ready: ' + str(event_ready)
	status_label.text = status_str
	# draw the cursors on the tree control
	$ChunkList.highlight(tracks)

func process_event_track():
	if event_ready:
		if tracks[OT.EVENT].count < tracks[OT.AUDIO].count:
			event_ready = false
			var script:String = tracks[OT.EVENT].this_chunk().lines_to_string()
			if script.begins_with("@title("):
				script = script.right(8).rstrip('")')
				scene_title.reveal(script)
			else: printerr("unrecognized event: ", script)

func process_audio_track():
	if audio_ready and jprez_ready and event_ready:
		var chunk = tracks[OT.AUDIO].this_chunk()
		if chunk==null: audio_ready = false # no more audio
		else:
			if chunk.file_exists(org_dir):
				audio_ready = false
				var sample : AudioStreamSample = load(org_dir + chunk.suggest_path())
				$AudioStreamPlayer.stream = sample
				$AudioStreamPlayer.play()
				if chunk.jpxy.x > old_slide:
					$Outline/Tree.get_selected().get_next().select(0)
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
			jprez_ready = false
			var ix = tracks[which].this_chunk().jpxy
			JI.cmd('goix %d %d' % [ix.x, ix.y])
			JI.cmd("advance''")
			tracks[which].find_next(which)

func update_jprez():
	# we do this on every tick so we can watch macros play.
	JI.cmd("update__app''")
	if JI.cmd('R__repl * 2'): # so it's not a boolean (because j-rs-gd only does ints atm)
		var repl = get_node('jp-repl')
		repl.JI = JI
		repl.refresh()
	# we have to run update_app /before/ checking A__red
	if not jprez_ready:
		jprez_ready = not JI.cmd('A__red * 2') # TODO: return bools as ints

func _on_PlayButton_pressed():
	playing = not playing

func _on_StepButton_pressed():
	step_ready = true

func _on_ChunkList_chunk_selected(chunk):
	for track in Org.Track.values():
		tracks[track].goto_index(chunk.index, track)
		var ix = chunk.jpxy
		JI.cmd('goix %d %d' % [ix.x, ix.y])
