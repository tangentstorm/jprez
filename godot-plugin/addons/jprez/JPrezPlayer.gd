										  extends Node

export(Resource) var org setget set_org
onready var JI = $JLang # J interpreter

var org_dir = ''
var org_path = ''
onready var cmd_label = $PanelContainer/CurrentCmd
var cursor : OrgCursor



func set_org(org:OrgNode):
	org_dir = org.resource_path.get_base_dir() + '/'
	print("org_dir:", org_dir)
	org_path = ProjectSettings.globalize_path(org.resource_path)
	cursor = OrgCursor.new(org)

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
		JI.cmd("ORG_PATH =: '%s'" % [org_path])
		JI.cmd("reopen''")
		JI.cmd("goto 0")

	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.10
	timer.connect("timeout", self, '_timeout')
	timer.start()

	$AudioStreamPlayer.connect("finished", self, "next_chunk")
	next_chunk()

func next_chunk():
	var chunk = cursor.next_chunk()
	cmd_label.text = chunk.lines_to_string() if chunk else ''
	if not chunk: return
	if chunk.track == Org.Track.AUDIO:
		if chunk.file_exists(org_dir):
			var sample : AudioStreamSample = load(org_dir + chunk.suggest_path())
			$AudioStreamPlayer.stream = sample
			$AudioStreamPlayer.play()
			return
	# still here for any reason? just move on:
	call_deferred("next_chunk")

func _process(dt):
	# we do this on every tick so we can watch macros play.
	JI.cmd("cocurrent'base'")
	JI.cmd("update__app''")
	var r = JI.cmd('R__repl * 2') # so it's not a boolean
	if not r: return
	var repl = get_node_or_null('jp-repl')
	if repl:
		repl.JI = JI
		repl.refresh()

func _timeout():
	# advance, unless we're playing a macro.
	JI.cmd("advance^:(-.A__red)''")
