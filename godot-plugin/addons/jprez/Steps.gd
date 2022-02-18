tool extends VBoxContainer

const START = 0
const LENGTH = 1
const TEXT = 2

signal audio_step_selected(step)
signal macro_step_selected(step)
signal plain_step_selected(step)

func set_org(org:OrgNode):
	var tree : Tree = $Tree; tree.clear()
	var root = tree.create_item()
	for col in [START,LENGTH,TEXT]:
		tree.set_column_min_width(col, 70)
		tree.set_column_expand(col, false)
	tree.set_column_expand(TEXT, true)
	if org == null: return
	for step in org.steps:
		var item : TreeItem = tree.create_item(root)
		item.set_text(START, '00:00'); item.set_custom_color(START, Color.darkgray)
		item.set_text(LENGTH, '00:00'); item.set_custom_color(LENGTH, Color.darkgray)
		item.set_text(TEXT, step)
		if step.begins_with('#'): item.set_custom_color(TEXT, Color.orangered)
		elif step.begins_with(':'): item.set_custom_color(TEXT,
			Color.lightseagreen if step.begins_with(': .') else Color.aquamarine)


func _on_Tree_item_selected():
	var tree : Tree = $Tree
	var text = tree.get_selected().get_text(TEXT)
	if not text: return
	match text[0]:
		'#': emit_signal("audio_step_selected", text.right(2))
		':': emit_signal("macro_step_selected", text.right(2))
		_  : emit_signal("plain_step_selected", text)
