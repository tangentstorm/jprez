class_name JPrezScriptEngine extends Node

signal script_finished(id, result)
var script_id:int
var script_result
var JI

var scene_title:Node setget set_scene_title

func set_scene_title(node):
	scene_title = node
	if node:
		scene_title.connect("animation_finished", self, "_on_animation_finished")

func _on_animation_finished():
	emit_signal("script_finished", script_id, script_result)

func show_editor(cursorline):
	var node = $"../JPrezScene/jp-editor"
	node.fake_focus = true
	node.show()
	JI.cmd("curxy__editor 0 %d" % cursorline)
	call_deferred("_on_animation_finished")

func execute(id:int, script:String):
	script_id = id
	script_result = null
	if script.begins_with("@title("):
		script = script.right(8).rstrip('")')
		if scene_title: scene_title.reveal(script)
	elif script.begins_with("@show-editor"):
		var tokens = script.split(' ')
		var cursorline = int(tokens[1]) if len(tokens)>1 else 0
		show_editor(cursorline)
	else: printerr("JPrezScriptEngine: unrecognized event: ", script)
