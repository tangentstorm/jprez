extends Node

export(Resource) var org setget set_org
onready var JI = $JLang # J interpreter

var org_path = ''

func set_org(org:OrgNode):
	org_path = ProjectSettings.globalize_path(org.resource_path)

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
	
	print("org path:", org_path)
	if org_path != '':
		JI.cmd("cocurrent'base'")
		JI.cmd("ORG_PATH =: '%s'" % [org_path])
		JI.cmd("reopen''")
		JI.cmd("goto 0")

	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.25
	timer.connect("timeout", self, '_timeout')
	timer.start()

func _timeout():
	JI.cmd("cocurrent'base'")
	JI.cmd("advance''")
	JI.cmd("update__app''")
	var r = JI.cmd('R__repl * 2') # so it's not a boolean
	if not r: return
	var repl = get_node_or_null('jp-repl')
	if repl:
		repl.JI = JI
		repl.refresh()
