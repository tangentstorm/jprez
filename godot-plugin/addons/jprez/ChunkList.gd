tool extends VBoxContainer
# visual representation of OrgChunk list

enum Col { START, LENGTH, TEXT }

signal audio_step_selected(step)
signal macro_step_selected(step)
signal plain_step_selected(step)

func set_org(org:OrgNode):
	var tree : Tree = $Tree; tree.clear()
	var root = tree.create_item()
	for col in Col.values():
		tree.set_column_min_width(col, 70)
		tree.set_column_expand(col, false)
	tree.set_column_expand(Col.TEXT, true)
	if org == null: return
	for chunk in org.chunks:
		var item : TreeItem = tree.create_item(root)
		item.set_text(Col.START, '00:00'); item.set_custom_color(Col.START, Color.darkgray)
		item.set_text(Col.LENGTH, '00:00'); item.set_custom_color(Col.LENGTH, Color.darkgray)
		item.set_text(Col.TEXT, chunk.to_string())
		match chunk.track:
			Org.Track.EVENT: item.set_custom_color(Col.TEXT, Color.orangered)
			Org.Track.INPUT: item.set_custom_color(Col.TEXT, Color.aquamarine)
			Org.Track.MACRO: item.set_custom_color(Col.TEXT, Color.lightseagreen)
			Org.Track.TEXT: pass

func _on_Tree_item_selected():
	var tree : Tree = $Tree
	var text = tree.get_selected().get_text(Col.TEXT)
	if not text: return
	match text[0]:
		'#': emit_signal("audio_step_selected", text.right(2))
		':': emit_signal("macro_step_selected", text.right(2))
		_  : emit_signal("plain_step_selected", text)
