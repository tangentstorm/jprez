tool extends Control

onready var JI = $JLang # J interpreter

func cmd(src):
	print("src: ", src)
	var res = JI.cmd(src)
	print("--> ", res)
	return res

func set_org(org:OrgNode):
	var org_path = ProjectSettings.globalize_path(org.resource_path)
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
	if Engine.editor_hint:
		var cmds = get_node_or_null("jp-cmds")
		if cmds:cmds.grab_focus()
	else:
		var repl = $"jp-repl"
		if repl: repl.grab_focus()

func _on_JKVM_keypress(code, ch, fns):
	# print('keypress('+str({'code':code, 'ch':ch, 'fns':fns})+')')
	var s = ""
	for fn in fns: s += "'"+fn+"';"
	s = "("+s+"'k_any')"
	JI.cmd("fn =: > {. (#~ 3 = 4!:0) "+s)
	JI.cmd("(fn~)'"+ch+"'")
	update_editor()

func update_editor():
	if Engine.editor_hint:
		for np in ['jp-cmds', 'jp-list']:
			var n = get_node_or_null(np)
			if n: n.refresh()

func refresh_repl():
	var root = get_tree().get_edited_scene_root()
	if not root: return
	var repl = root.get_node_or_null('jp-repl')
	if repl:
		repl.JI = JI
		repl.refresh()

func _process(_dt):
	if Engine.editor_hint:
		if not JI: return
		if not JI.has_method('cmd'): return
		JI.cmd("cocurrent'base'")
		JI.cmd("update__app''")
		var r = JI.cmd('R__repl * 2') # so it's not a boolean
		if r: refresh_repl()

func _on_jplist_focus_entered():
	JI.cmd("keymode'outkeys'")

func _on_jpcmds_focus_entered():
	JI.cmd("keymode'outkeys'")
