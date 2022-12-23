# OrgCommands for Jprez
extends Node

const ANIMATED = true
const IMMEDIATE = false

func cmd_editor_goxy(x,y, force_visible:bool=false):
	var node = $"../jp-editor"
	var JI = $"../JLang"
	if force_visible: node.show()
	print("editor_goxy: ", x, ", ", y)
	node.fake_focus = true
	JI.cmd("curxy__editor %d %d" % [x,y])
	return IMMEDIATE
