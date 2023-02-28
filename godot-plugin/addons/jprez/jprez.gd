@tool extends Control

@export var jlang_nodepath = 'JLang'
@onready var JI = get_node(jlang_nodepath) # J interpreter

func set_org(absolute_org_path): # :OrgNode):
	var org_path = ProjectSettings.globalize_path(absolute_org_path) # org.resource_path)
	JI.cmd("ORG_PATH =: '%s'" % [org_path])
	JI.cmd("reopen''")
	update_editor()

func _ready():
	var hw = '36 157'
	print("J_HOME:", OS.get_environment('J_HOME'))
	JI.cmd("9!:7 [ (16+i.11){a.  NB. box drawing characters")
	JI.cmd("ARGV_z_=:,<''")
	JI.cmd("load 'tangentstorm/j-kvm/vid'")
	JI.cmd("coinsert 'kvm'")
	JI.cmd("1!:44 'd:/ver/jprez'")
	JI.cmd('gethw_vt_ =: {{ ' +hw+ '}}')
	JI.cmd("load 'jprez.ijs'")
	if Engine.is_editor_hint():
		var cmds = get_node_or_null("jp-cmds")
		if cmds:cmds.grab_focus()
	else:
		var repl = $"jp-repl"
		if repl: repl.grab_focus()

func _on_JKVM_keypress(code, ch, fns):
	print('keypress('+str({'code':code, 'ch':ch, 'fns':fns})+')')
	var s = ""
	for fn in fns: s += "'"+fn+"';"
	s = "("+s+"'k_any')"
	JI.cmd("fn =: > {. (#~ 3 = 4!:0) "+s)
	JI.cmd("(fn~)'"+ch+"'")
	update_editor()

func update_editor():
	if true: # Engine.is_editor_hint():
		for np in ['jp-cmds', 'jp-list']:
			var n = get_node_or_null(np)
			if n: n.refresh()

func refresh_jkvm_node(node_path):
	var node = get_node_or_null(node_path)
	if node:
		node.refresh()

func refresh_repl():
	var r = JI.cmd('R__repl * 2') # so it's not a boolean
	if r: refresh_jkvm_node('jp-repl')
func refresh_editor():
	var r = JI.cmd('R__editor * 2') # so it's not a boolean
	if r: refresh_jkvm_node('jp-editor')

func _process(_dt):
	if true: #Engine.is_editor_hint():
		if not JI: return
		if not JI.has_method('cmd'): return
		JI.cmd("cocurrent'base'")
		JI.cmd("update__app''")
		refresh_repl()
		refresh_editor()

func _on_jplist_focus_entered():
	JI.cmd("keymode'outkeys'")

func _on_jpcmds_focus_entered():
	JI.cmd("keymode'outkeys'")

func _on_jprepl_focus_entered():
	JI.cmd("keymode'replkeys'")

func _on_jpeditor_focus_entered():
	JI.cmd("keymode'edkeys'")
