tool extends Control

onready var JI = $JLang # J interpreter

func _ready():
	print("J_HOME:", OS.get_environment('J_HOME'))
	JI.cmd("ARGV_z_=:''")
	JI.cmd("load 'tangentstorm/j-kvm/vid'")
	JI.cmd("coinsert 'kvm'")
	JI.cmd("1!:44 'd:/ver/jprez'")
	JI.cmd("load 'repl.ijs'")
	JI.cmd("init_world_''")
	# --
	JI.cmd("repl =: 'UiRepl' conew~ ''")
	JI.cmd("B__ed__repl =: '+/\\p: i. 10 NB. running sum of first 10 primes'")
	JI.cmd("accept__repl''")
	JI.cmd("H__repl =: 25 [ W__repl =: 80")
	JI.cmd("C__repl =: '' conew 'vid' ")
	refresh_console()
	$JKVM.grab_focus()

func to_colors(ints):
	var res = PoolColorArray()
	for i in ints:
		if i < 0: res.append($JKVM.pal[-i])
		else: res.append(Color(i*0x100+0xFF))
	return res

func refresh_console():
	JI.cmd("sethw__C__repl 25 80")
	# JI.cmd("rnd__C__repl'.'") # draw some junk to make sure it's working
	JI.cmd("pushterm C__repl")
	JI.cmd("render__repl 1")
	JI.cmd("popterm''")
	$JKVM.cursor_visible = false
	$JKVM.CHB = JI.cmd("a.i.,CHB__C__repl")
	$JKVM.FGB = to_colors(JI.cmd(",FGB__C__repl"))
	$JKVM.BGB = to_colors(JI.cmd(",BGB__C__repl"))
	$JKVM.update()

func _on_JKVM_keypress(code, ch, fns):
	# print('keypress('+str({'code':code, 'ch':ch, 'fns':fns})+')')
	var s = ""
	for fn in fns: s += "'"+fn+"';"
	JI.cmd("fn =: > {. (#~ 3 = 4!:0) ,&'__ed__repl' L:0 ("+s+";'k_any')")
	JI.cmd("(fn~)'"+ch+"'")
	refresh_console()
