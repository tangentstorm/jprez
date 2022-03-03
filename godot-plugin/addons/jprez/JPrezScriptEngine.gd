class_name JPrezScriptEngine extends Node

onready var scene_title = $'/root/JPrezApp/JPrezScene/SceneTitle'

func execute(script):
	if script.begins_with("@title("):
		script = script.right(8).rstrip('")')
		if scene_title: scene_title.reveal(script)
	else: printerr("unrecognized event: ", script)
