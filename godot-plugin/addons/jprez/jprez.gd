tool extends Control

onready var JI = $JLang # J interpreter

func cmd(src):
	print("src: ", src)
	var res = JI.cmd(src)
	print("--> ", res)
	return res

func _ready():
	var hw = str($JKVM.grid_wh.y) + ' ' + str($JKVM.grid_wh.x)
	print("J_HOME:", OS.get_environment('J_HOME'))
	JI.cmd("ARGV_z_=:,<''")
	JI.cmd("load 'tangentstorm/j-kvm/vid'")
	JI.cmd("coinsert 'kvm'")
	JI.cmd("1!:44 'd:/ver/jprez'")
	JI.cmd('gethw_vt_ =: {{ ' +hw+ '}}')
	JI.cmd("load 'jprez.ijs'")
	#JI.cmd("show_editor''")
	print("xmax:", JI.cmd("xmax''"))
	JI.cmd("sethw__A__app "+hw)
	JI.cmd("sethw__B__app "+hw)
	# --
	$JKVM.refresh()
	$JKVM.grab_focus()


func _on_JKVM_keypress(code, ch, fns):
	# print('keypress('+str({'code':code, 'ch':ch, 'fns':fns})+')')
	var s = ""
	for fn in fns: s += "'"+fn+"';"
	JI.cmd("fn =: > {. (#~ 3 = 4!:0) ("+s+";'k_any')")
	JI.cmd("(fn~)'"+ch+"'")
	$JKVM.refresh()
