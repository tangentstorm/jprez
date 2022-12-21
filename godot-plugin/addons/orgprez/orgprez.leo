<?xml version="1.0" encoding="utf-8"?>
<!-- Created by Leo: http://leoeditor.com/leo_toc.html -->
<leo_file xmlns:leo="http://leoeditor.com/namespaces/leo-python-editor/1.1" >
<leo_header file_format="2"/>
<globals/>
<preferences/>
<find_panel_settings/>
<vnodes>
<v t="tangentstorm.20221220215232.2"><vh>godot presentation tool  ("orgprez")</vh></v>
<v t="tangentstorm.20221220223801.1"><vh>setting up the plugin</vh>
<v t="tangentstorm.20221220230106.2"><vh>@clean plugin.cfg</vh></v>
<v t="tangentstorm.20221220223850.1"><vh>creating a new top-level tab in godot</vh>
<v t="tangentstorm.20221220233018.1"><vh>app and scene variables</vh></v>
<v t="tangentstorm.20221220233113.1"><vh>actually place the tab label at top</vh></v>
<v t="tangentstorm.20221220233133.1"><vh>create the scene in plugin's _enter_tree()</vh></v>
<v t="tangentstorm.20221220233138.1"><vh>_exit_tree() cleanup scene if plugin is uninstalled</vh></v>
</v>
</v>
<v t="tangentstorm.20221220224342.1"><vh>orgprez source code</vh>
<v t="tangentstorm.20221220230106.4"><vh>@clean plugin.gd</vh>
<v t="tangentstorm.20221220233018.1"></v>
<v t="tangentstorm.20221220233046.1"><vh>_enter_tree()</vh>
<v t="tangentstorm.20221220233133.1"></v>
</v>
<v t="tangentstorm.20221220233113.1"></v>
<v t="tangentstorm.20221220233209.1"><vh>_exit_tree()</vh>
<v t="tangentstorm.20221220233138.1"></v>
</v>
</v>
<v t="tangentstorm.20221220230106.2"></v>
<v t="tangentstorm.20221220232645.2"><vh>@clean plugin.tscn</vh></v>
</v>
</vnodes>
<tnodes>
<t tx="tangentstorm.20221220215232.2"></t>
<t tx="tangentstorm.20221220223801.1"></t>
<t tx="tangentstorm.20221220223850.1"></t>
<t tx="tangentstorm.20221220224342.1">@tabwidth 8</t>
<t tx="tangentstorm.20221220230106.2">@language config
[plugin]

name="orgprez"
description="Godot tool for creating presentations from emacs org-mode documents."
author="tangentstorm"
version="0.1"
script="plugin.gd"
</t>
<t tx="tangentstorm.20221220230106.4">@language gdscript
# presentation tool for emacs org files
tool
extends EditorPlugin

@others

</t>
<t tx="tangentstorm.20221220232645.2">@language unknown_language
[gd_scene load_steps=2 format=2]

[ext_resource path="res://addons/jprez/JPrezAudioTab.tscn" type="PackedScene" id=1]

[node name="Control" type="Control"]
anchor_right = 1.0
anchor_bottom = 1.0
margin_right = -1820.0
margin_bottom = -980.0
__meta__ = {
"_edit_use_anchors_": false
}

[node name="JPrezAudioTab" parent="." instance=ExtResource( 1 )]
margin_right = 1808.0
margin_bottom = 926.0
</t>
<t tx="tangentstorm.20221220233018.1">var scene = preload('res://addons/orgprez/plugin.tscn')
var app # member variable holding instance of scene

</t>
<t tx="tangentstorm.20221220233046.1">func _enter_tree():
	@others

</t>
<t tx="tangentstorm.20221220233113.1">func has_main_screen():
	return true

func get_plugin_name():
	return "OrgPrez" # used in top-level tab name

func get_plugin_icon():
	return get_editor_interface().get_base_control().get_icon("AutoKey", "EditorIcons")

func make_visible(x): # called at startup and when the tab is changed
	if app: app.visible = x

</t>
<t tx="tangentstorm.20221220233133.1">app = scene.instance()
get_editor_interface().get_editor_viewport().add_child(app)
make_visible(false) # otherwise it shows up on-screen no matter what tab is active
</t>
<t tx="tangentstorm.20221220233138.1">if app: app.queue_free()
</t>
<t tx="tangentstorm.20221220233209.1">func _exit_tree():
	@others
</t>
</tnodes>
</leo_file>
