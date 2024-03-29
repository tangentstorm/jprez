@tool class_name JKVM extends Control

signal keypress(code, ch, fns)

@export var font : Font = preload("res://fonts/noto-font.tres")
@export var font_base : Vector2 = Vector2(1,12)
@export var font_size : int = 24

@export var jlang_nodepath = "../JLang"
@export var j_widget : String = "app"
@export var j_locale : String = "base"

@export var rng_seed : int = 82076 : set = _set_rng_seed
@export var grid_wh : Vector2 = Vector2(80, 25) : set = _set_grid_wh
@export var cell_wh : Vector2 = Vector2(12,14) : set = _set_cell_wh
@export var cursor_visible: bool = false : set = _set_cursor_visible
@export var fake_focus: bool = false

@onready var JI = get_node(jlang_nodepath)

var cursor_xy : Vector2 = Vector2.ZERO
var fg : Color = Color.GRAY
var panel : Color = Color.BLACK

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var FGB : PackedColorArray
var BGB : PackedColorArray
var CHB : PackedInt32Array # unicode code points

func _set_rng_seed(v):
	rng_seed = v
	rng.seed = v

func _set_cursor_visible(v):
	cursor_visible = v
	#if $cursor: $cursor.visible = v

func _set_grid_wh(v):
	grid_wh = v
	recalc_size()

func _set_cell_wh(v):
	cell_wh =v
	recalc_size()

func recalc_size():
	custom_minimum_size = grid_wh * cell_wh
	size = custom_minimum_size
	queue_redraw()

func _ready():
	focus_mode = FOCUS_CLICK
	var cursor = ColorRect.new()
	cursor.color = Color.TRANSPARENT
	cursor.size = cell_wh
	cursor.name = "cursor"
	add_child(cursor)
	_set_cursor_visible(cursor_visible)
	_reset()
	_cscr()
	if j_widget:
		call_deferred('refresh')

func _reset():
	fg = Color.GRAY
	panel = Color.BLACK

func _cscr():
	FGB = PackedColorArray()
	BGB = PackedColorArray()
	CHB = PackedInt32Array()
	for i in range(grid_wh.x * grid_wh.y):
		FGB.append(fg)
		BGB.append(panel)
		CHB.append(32)

func _rnd():
	# fill buffer with random colored characters
	# ("screen saver" for debugging / fps checks)
	for i in range(grid_wh.x * grid_wh.y):
		FGB[i] = 0x333333ff + (rng.randi_range(0, 0xcccccc) << 8)
		BGB[i] = Color.BLACK
		CHB[i] = rng.randi_range(33,126)
	queue_redraw()

func _draw():
	var w = 80; var h = 16	
	for y in range(grid_wh.y):
		for x in range(grid_wh.x):
			var xy = Vector2(x,y)*cell_wh
			var p = y * grid_wh.x + x
			draw_rect(Rect2(xy, cell_wh), BGB[p])
			draw_char(font, xy+font_base, char(CHB[p]), font_size, FGB[p])

@onready var pal : PackedColorArray = _make_palette()
func _make_palette():
	var res = PackedColorArray()
	var ansi = [ # -- ansi colors --
		0x000000, # black
		0xaa0000, # red
		0x00aa00, # green
		0xaaaa00, # dark yellow ( note: not vga brown! )
		0x0000aa, # blue
		0xaa00aa, # magenta
		0x00aaaa, # cyan
		0xaaaaaa, # gray
		0x555555, # dark gray
		0xff5555, # light red
		0x55ff55, # light green
		0xffff55, # yellow
		0x5555ff, # light blue
		0xff55ff, # light magenta
		0x55ffff, # light cyan
		0xffffff ]# white
	for a in ansi: res.append(Color(a * 0x100 + 0xff))

	# colors 16..231 are a color cube:
	var ramp = [ 0x00, 0x5F, 0x87, 0xAF, 0xD7, 0xFF ]
	for r in ramp:
		for g in ramp:
			for b in ramp:
				res.append(Color(((r << 16 ) + ( g << 8 ) + b) * 0x100 + 0xff))

	# 232..255 are a black to gray gradiant:
	var grays = [
		0x00, 0x12, 0x1C, 0x26, 0x30, 0x3A, 0x44, 0x4E,
		0x58, 0x62, 0x6C, 0x76, 0x80, 0x8A, 0x94, 0x9E,
		0xA8, 0xB2, 0xBC, 0xC6, 0xD0, 0xDA, 0xE4, 0xEE ]
	for v in grays:
		res.append(Color((( v << 16 ) + ( v << 8 ) + v) * 0x100 + 0xff))

	return res

func _gui_input(e):
	if e is InputEventKey and e.pressed:
		var code = e.keycode
		var ch = char(e.unicode)
		var fns = []
		if code >= 32 and code < 127:
			var fn = 'k'
			var asc = true
			if e.ctrl_pressed: fn +='c'
			if e.alt_pressed: fn += 'a'
			if e.alt_pressed or e.ctrl_pressed:
				asc = false
				ch = char(code).to_lower()
			match ch:
				"'": # need to escape this char in j
					fn += '_quote'; ch="''"
				' ': fn += '_space'
				'+': fn += '_plus'
				_: fn += '_' + ch
			fns.append(fn)
			if asc: fns.append('k_asc')
		else:
			match code:
				KEY_SHIFT, KEY_ALT, KEY_CTRL: return
				KEY_UP: fns.append('k_arup')
				KEY_DOWN: fns.append('k_ardn')
				KEY_RIGHT: fns.append('k_arrt')
				KEY_LEFT: fns.append('k_arlf')
				KEY_TAB: fns.append('k_tab')
				KEY_ENTER: fns.append('kc_m')
				KEY_BACKSPACE: fns.append('k_bsp')
		emit_signal('keypress', code, ch, fns)

func _to_colors(ints):
	var res = PackedColorArray()
	for i in ints:
		if i < 0: res.append(pal[-i])
		else: res.append(Color(i*0x100+0xFF))
	return res

func j_hw():
	return str(grid_wh.y) + ' ' + str(grid_wh.x)

func J(cmd:String):
	#print('  '+cmd)
	#print(JI.cmd_s(cmd))
	JI.cmd_s(cmd)

func Jv(cmd)->Variant:
	#print('  '+cmd)
	var res = JI.cmd(cmd)
	return res

func refresh():
	var vid = 'scratch'
	J("cocurrent '" + j_locale + "'")
	J(vid + "=: 'vid' conew~ |." + j_hw())
	J("pushterm_kvm_ "+ vid)
	J("'H__" + j_widget + " W__"+j_widget+"' =: "+j_hw())
	J("render__" + j_widget + " " + str(int(fake_focus or has_focus())))
	J("popterm_kvm_ ''")
	CHB = Jv("3 u:,CHB__" + vid)
	FGB = _to_colors(Jv(",FGB__" + vid))
	BGB = _to_colors(Jv(",BGB__" + vid))
	J('codestroy__' + vid + "''")
	queue_redraw()
