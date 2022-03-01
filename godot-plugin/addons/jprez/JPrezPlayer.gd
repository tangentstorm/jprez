										  extends Node

export(Resource) var org setget set_org
onready var JI = $JLang # J interpreter

var org_dir = ''
var org_path = ''
onready var cmd_label = $PanelContainer/CurrentCmd
onready var count_label = $counts

var tracks: Array
func set_org(org:OrgNode):
	org_dir = org.resource_path.get_base_dir() + '/'
	org_path = ProjectSettings.globalize_path(org.resource_path)
	tracks = []
	for t in Org.Track.values():
		tracks.push_back(OrgCursor.new(org))
		tracks[t].find_next(t)

var timer : Timer
func _ready():
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
		JI.cmd("MACROS_ONLY =: 1")
		JI.cmd("ORG_PATH =: '%s'" % [org_path])
		JI.cmd("reopen_base_=:reopen_outkeys_ f.")
		JI.cmd("reopen''")
		JI.cmd("goto 0")
	$AudioStreamPlayer.connect("finished", self, "_on_audio_finished")

const OT = Org.Track

var audio_ready = true
var jprez_ready = true

func _on_audio_finished():
	audio_ready = true

func _process(_dt):
	JI.cmd("cocurrent'base'")
	$jcmd.text = 'val_cmds =: ' + JI.cmd_s(">val__cmds''")
	var counts = []; var i = 0; var count_str=''
	for k in OT.keys():
		var c = tracks[i].count; counts.push_back(c)
		count_str += '  ' + k + ': ' + str(c); i+=1
	count_str += ' jprez_ready: ' + str(jprez_ready)
	count_str += ' audio_ready: ' + str(audio_ready)
	count_label.text = count_str

	# audio is the "main" cursor that controls everything else.
	# (except possibly animation events?)
	if audio_ready and jprez_ready:
		var chunk = tracks[OT.AUDIO].this_chunk()
		if chunk==null: audio_ready = false # no more audio
		else:
			if chunk.file_exists(org_dir):
				audio_ready = false
				var sample : AudioStreamSample = load(org_dir + chunk.suggest_path())
				$AudioStreamPlayer.stream = sample
				$AudioStreamPlayer.play()
			tracks[OT.AUDIO].find_next(OT.AUDIO)

	if jprez_ready:
		# which of the two jprez tracks is next to fire?
		var which = OT.MACRO if tracks[OT.MACRO].count < tracks[OT.INPUT].count else OT.INPUT
		# fire if that chunk comes before the next audio track.
		var which_count = tracks[which].count
		if which == OT.INPUT: which_count += 1
		if which_count < tracks[OT.AUDIO].count:
			jprez_ready = false
			JI.cmd("advance''")
			tracks[which].find_next(which)

	# we do this on every tick so we can watch macros play.
	JI.cmd("update__app''")
	if JI.cmd('R__repl * 2'): # so it's not a boolean (because j-rs-gd only does ints atm)
		var repl = get_node('jp-repl')
		repl.JI = JI
		repl.refresh()

	# we have to run update_app /before/ checking A__red
	if not jprez_ready:
		jprez_ready = not JI.cmd('A__red * 2') # TODO: return bools as ints
