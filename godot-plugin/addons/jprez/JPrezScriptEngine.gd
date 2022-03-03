class_name JPrezScriptEngine extends Node

signal script_finished(id, result)
var script_id:int
var script_result

var scene_title:Node setget set_scene_title

func set_scene_title(node):
	scene_title = node
	if node:
		print("making the connection")
		scene_title.connect("animation_finished", self, "_on_animation_finished")

func _on_animation_finished():
	print_debug("engine sees animation is finished")
	emit_signal("script_finished", script_id, script_result)

func execute(id:int, script:String):
	script_id = id
	script_result = null
	if script.begins_with("@title("):
		script = script.right(8).rstrip('")')
		if scene_title: scene_title.reveal(script)
	else: printerr("unrecognized event: ", script)
