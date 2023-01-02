<?xml version="1.0" encoding="utf-8"?>
<!-- Created by Leo: http://leoeditor.com/leo_toc.html -->
<leo_file xmlns:leo="http://leoeditor.com/namespaces/leo-python-editor/1.1" >
<leo_header file_format="2"/>
<globals/>
<preferences/>
<find_panel_settings/>
<vnodes>
<v t="tangentstorm.20221220215232.2"><vh>godot presentation tool  ("orgprez")</vh>
<v t="tangentstorm.20221220223801.1"><vh>creating a plugin</vh>
<v t="tangentstorm.20221220230106.2"><vh>@clean orgprez/plugin.cfg</vh></v>
</v>
<v t="tangentstorm.20221220223850.1"><vh>creating a new top-level tab in godot</vh>
<v t="tangentstorm.20221220233018.1"><vh>declare app and scene variables</vh></v>
<v t="tangentstorm.20221220233113.1"><vh>methods to place the tab label at top</vh></v>
<v t="tangentstorm.20221220233133.1"><vh>_enter_tree(): instantiate the editor tab's scene</vh></v>
<v t="tangentstorm.20221220233138.1"><vh>_exit_tree(): cleanup scene if plugin is uninstalled</vh></v>
</v>
<v t="tangentstorm.20221221195625.1"><vh>org file resources</vh>
<v t="tangentstorm.20221221195937.1"><vh>org importer</vh>
<v t="tangentstorm.20221221205248.1"><vh>declare org_importer plugin</vh></v>
<v t="tangentstorm.20221221204751.1"><vh>_enter_tree(): load the importer</vh></v>
<v t="tangentstorm.20221221205522.1"><vh>_exit_tree(): remove the importer</vh></v>
</v>
<v t="tangentstorm.20221221195809.1"><vh>click org file to edit</vh>
<v t="tangentstorm.20221221212948.1"><vh>handles() method lets plugin opt-in to editing a resource</vh></v>
<v t="tangentstorm.20221221213157.1"><vh>edit() says what to actually do when it's clicked</vh></v>
</v>
</v>
<v t="tangentstorm.20221221202409.1"><vh>TODO</vh>
<v t="tangentstorm.20221221195823.1"><vh>introduce decks and slides</vh></v>
<v t="tangentstorm.20221223114848.1"><vh>slides panel to manage editor text, linked scene</vh></v>
<v t="tangentstorm.20221221204336.1"><vh>restore nav panels (outline/chunklist)</vh></v>
<v t="tangentstorm.20221223114755.1"><vh>outline panel to manage headline tree</vh></v>
<v t="tangentstorm.20221223115029.1"><vh>preview panel in middle shows the linked scene?</vh></v>
<v t="tangentstorm.20221222011143.1"><vh>do some QA and make sure audio recorder actually works</vh></v>
<v t="tangentstorm.20221222011355.1"><vh>introduce the .wav subfolder to avoid clutter</vh></v>
<v t="tangentstorm.20221221195646.1"><vh>decouple from jprez repl</vh></v>
<v t="tangentstorm.20221222012013.1"><vh>move the "JPrezApp" to OrgPrezPlayer scene</vh></v>
<v t="tangentstorm.20221222011506.1"><vh>someday/maybe</vh></v>
<v t="tangentstorm.20221221195729.1"><vh>explain the editor tab</vh></v>
</v>
<v t="tangentstorm.20221222010757.1"><vh>how to use it</vh></v>
</v>
<v t="tangentstorm.20221220224342.1"><vh>@path addons</vh>
<v t="tangentstorm.20221220230106.4"><vh>@clean orgprez/plugin.gd</vh>
<v t="tangentstorm.20221221205119.1"><vh>declarations</vh>
<v t="tangentstorm.20221220233018.1"></v>
<v t="tangentstorm.20221221205248.1"></v>
</v>
<v t="tangentstorm.20221220233046.1"><vh>_enter_tree()</vh>
<v t="tangentstorm.20221220233133.1"></v>
<v t="tangentstorm.20221221204751.1"></v>
</v>
<v t="tangentstorm.20221220233113.1"></v>
<v t="tangentstorm.20221221212948.1"></v>
<v t="tangentstorm.20221221213157.1"></v>
<v t="tangentstorm.20221220233209.1"><vh>_exit_tree()</vh>
<v t="tangentstorm.20221220233138.1"></v>
<v t="tangentstorm.20221221205522.1"></v>
</v>
</v>
<v t="tangentstorm.20221220230106.2"></v>
<v t="tangentstorm.20221220232645.2"><vh>@clean orgprez/plugin.tscn</vh></v>
</v>
<v t="tangentstorm.20221221195916.1"><vh>notes</vh></v>
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
<t tx="tangentstorm.20221220233018.1">var scene = preload('res://addons/orgprez/OrgPrezAudioTab.tscn')
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
<t tx="tangentstorm.20221221195625.1"></t>
<t tx="tangentstorm.20221221195646.1">@
search for references to REPL
move this code into a signal
the repl can just register to receive those signals

maybe that would be something that lives in a custom version of the main scene,
alongside the player object?

</t>
<t tx="tangentstorm.20221221195729.1">@

Here's the tutorial for editing these scenes:

https://docs.godotengine.org/en/stable/tutorials/plugins/editor/making_main_screen_plugins.html

Important is the Vertical Expand checkbox for the top level Control.

things i did in this step:

  - set up the default org file  (TODO: maybe change this when you open an org file)</t>
<t tx="tangentstorm.20221221195809.1">
</t>
<t tx="tangentstorm.20221221195823.1">each org file has one associated deck.
  (either specified or just same name but .tscn)
this gets loaded INTO the top-level jprez scene
  (so orgprez has some generic player logic and run-time debugging tools like the stepper)
  

</t>
<t tx="tangentstorm.20221221195916.1">@
For godot 4, maybe we just want to use the "keep" importer.
(we may not actually need a resource)

- probably get rid of timestamp sequence in org files (??)

- Org.gd has begin_src j... probably should just be begin_src
  OrgNode.gd has same in output
  


make_visible:
	#var efp = EditorFeatureProfile.new()
	#efp.set_disable_feature(EditorFeatureProfile.FEATURE_IMPORT_DOCK, not v)

_enter_tree:
	var efp = EditorFeatureProfile.new()
	efp.set_disable_feature(EditorFeatureProfile.FEATURE_3D, true)



res://wip/dealing-cards/dealing-cards.org
res://wip/mandelbrot/mandelbrot.org</t>
<t tx="tangentstorm.20221221195937.1">@
this works by loading an importer class from the plugin.gd
</t>
<t tx="tangentstorm.20221221202409.1"></t>
<t tx="tangentstorm.20221221204336.1">@
- the editor uses both
- consider making one panel for debugging animations in the editor
  (basically do as much of the "stepping" stuff as possible at edit time)

- merge into one panel (use dropdown to select the slide/section)
- should be used to control animations
- may or may not still directly edit.
</t>
<t tx="tangentstorm.20221221204751.1">org_import = preload("res://addons/orgprez/org_import.gd").new()
add_import_plugin(org_import)
</t>
<t tx="tangentstorm.20221221205119.1"></t>
<t tx="tangentstorm.20221221205248.1">var org_import
</t>
<t tx="tangentstorm.20221221205522.1">remove_import_plugin(org_import); org_import = null

</t>
<t tx="tangentstorm.20221221212948.1">func handles(object):
	return object is OrgNode

</t>
<t tx="tangentstorm.20221221213157.1">func edit(org):
	# remember directory for saving wave files
	# TODO: make this wav_dir
	# wav_dir = org.resource_path.get_base_dir()
	# if not wav_dir.ends_with('/'): wav_dir += '/'
	# chunks.org_dir = wav_dir  # !! only need for waves, so update chunks code
	# wav_dir += '.wav'

	# tell the app to load that org-file
	# chunks.set_org(org) # outln will override this with first node (if one exists)
	# outln.set_org(org)
	# jprez.set_org(org)

	app.set_org(org)

</t>
<t tx="tangentstorm.20221222010757.1">- for now still create and edit the org file in a text editor.


- set main scene to be the org player
- each org file should have a corresponding deck
- based on which org file you click to edit, the project setting is changed
- both the editor and main scene check the project settings to remember this decision
- keep all your talks in different directories in the same git repot
  (they can be but do not have to be separate godot projects)
  </t>
<t tx="tangentstorm.20221222011143.1"></t>
<t tx="tangentstorm.20221222011355.1"></t>
<t tx="tangentstorm.20221222011506.1">@
actually create org files and add headings and add/edit lines frOm godot
instead of using an outside editor.
</t>
<t tx="tangentstorm.20221222012013.1">this becomes the main scene for your project (as a user).
- need to move the Outline and Chunklist controls over
- rename them to OrgOutline and OrgChunklist (??)

</t>
<t tx="tangentstorm.20221223114755.1"></t>
<t tx="tangentstorm.20221223114848.1">@
could step through the animations as well?
</t>
<t tx="tangentstorm.20221223115029.1"></t>
</tnodes>
</leo_file>
