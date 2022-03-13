class_name JPrezScriptEngine extends Node
# simple interpreter for the '@event(x,y,z) lines in presentations.
# these lines trigger the corresponding cmd_event(x,y,z) methods on this node.
# the methods return true if they trigger an animation,
# or false if they finish immediately
# ether way, they trigger the script_finished signal when done.

signal script_finished(id, result)
var script_id:int
var script_result
var JI
var tween:Tween
var timer:Timer

var scene_title:Node setget set_scene_title
func set_scene_title(node):
	scene_title = node
	if node:
		scene_title.connect("animation_finished", self, "_on_animation_finished")

func _ready():
	timer = Timer.new(); add_child(timer)
	timer.connect("timeout", self, "_on_timer_timeout")
	tween = Tween.new(); add_child(tween)
	tween.connect("tween_started", self, "_on_tween_started")
	tween.connect("tween_step", self, "_on_tween_step")
	tween.connect("tween_completed", self, "_on_tween_finished")

func _on_animation_finished():
	emit_signal("script_finished", script_id, script_result)

func _on_timer_timeout():
	_on_animation_finished()

func _on_tween_finished(obj, path):
	# print("tween finished", [obj, path])
	_on_animation_finished()

func _on_tween_started(obj, path):
	pass # print("tween finished", [obj, path])

func _on_tween_step(obj, key, elapsed:float, value):
	pass #print("tween_step", [obj, key, elapsed, value])

func execute(id:int, script:String):
	script_id = id
	script_result = null
	var e = Expression.new()
	assert(script.begins_with('@'), 'event lines must start with "@"')
	script = 'cmd_' + script.right(1)
	if OK == e.parse(script):
		var animated = e.execute([], self)
		if not animated: call_deferred("_on_animation_finished")
	else: printerr("JPrezScriptEngine parse error: ", script)

### helper methods ###########################################


func _tween(node:Node, prop:String, a, z, ms)->bool:
	if not node: return IMMEDIATE
	if ms==0: node.set(prop, z)
	else:
		print("tweening ", prop, ' ms:', ms)
		tween.interpolate_property(node, prop, a, z, ms*0.001, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
	return ANIMATED if ms > 0 else IMMEDIATE

func _find(node_path, cmd):
	var node = $"../JPrezScene/".get_node_or_null(node_path)
	if node == null: printerr('not found: @%s("%s"):' % [cmd, node_path])
	return node

### commands #################################################

const ANIMATED = true
const IMMEDIATE = false
const SHOW = Color(1,1,1,1)
const HIDE = Color.transparent

func cmd_editor_goxy(x,y, force_visible:bool=false):
	var node = $"../JPrezScene/jp-editor"
	if force_visible: node.show()
	print("editor_goxy: ", x, ", ", y)
	node.fake_focus = true
	JI.cmd("curxy__editor %d %d" % [x,y])
	return IMMEDIATE

func cmd_move(node_path:String, x, y, ms=0)->bool:
	var node = _find(node_path, 'show')
	if node == null: return IMMEDIATE
	var prop = 'rect_position' if node is Control else 'position'
	var xy0 = node.get(prop)
	var xy1 = Vector2(x, y)
	return _tween(node, prop, xy0, xy1, ms)

func cmd_show(node_path:String, ms=0)->bool:
	var node = _find(node_path, 'show')
	return _tween(node, 'modulate', HIDE, SHOW, ms)

func cmd_hide(node_path:String, ms=0)->bool:
	var node = _find(node_path, 'hide')
	return _tween(node, 'modulate', SHOW, HIDE, ms)

func cmd_title(text:String)->bool:
	if scene_title == null: return false
	scene_title.reveal(text)
	return ANIMATED

func cmd_pause(ms=0):
	timer.wait_time = ms * 0.001
	timer.one_shot = true
	timer.start()
	return ANIMATED
