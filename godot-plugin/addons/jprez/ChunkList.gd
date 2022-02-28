tool extends VBoxContainer
# visual representation of OrgChunk list

enum Col { START, LENGTH, TEXT }

signal audio_chunk_selected(step)
signal macro_chunk_selected(step)
signal input_chunk_selected(step)
signal event_chunk_selected(step)

export var org_dir:String = 'res://'

func set_org(org:OrgNode):
	var tree : Tree = $Tree; tree.clear()
	var root = tree.create_item()
	for col in Col.values():
		tree.set_column_min_width(col, 70)
		tree.set_column_expand(col, false)
	tree.set_column_expand(Col.TEXT, true)
	if not org: return
	for chunk in org.chunks:
		var item : TreeItem = tree.create_item(root)
		item.set_text(Col.START, '00:00'); item.set_custom_color(Col.START, Color.darkgray)
		item.set_text(Col.LENGTH, '00:00'); item.set_custom_color(Col.LENGTH, Color.darkgray)
		item.set_text(Col.TEXT, chunk.to_string())
		item.set_meta('chunk', chunk)
		match chunk.track:
			Org.Track.AUDIO:
				if not chunk.file_exists(org_dir):
					item.set_custom_color(Col.TEXT, Color.orangered)
			Org.Track.MACRO: item.set_custom_color(Col.TEXT, Color.lightseagreen)
			Org.Track.INPUT: item.set_custom_color(Col.TEXT, Color.aquamarine)
			Org.Track.EVENT: item.set_custom_color(Col.TEXT, Color.cornflower)

	var first = tree.get_root().get_children()
	if first: first.select(Col.TEXT)

func _on_Tree_item_selected():
	var chunk = $Tree.get_selected().get_meta('chunk')
	if not chunk: return
	match chunk.track:
		Org.Track.AUDIO: emit_signal("audio_chunk_selected", chunk)
		Org.Track.MACRO: emit_signal("macro_chunk_selected", chunk)
		Org.Track.INPUT: emit_signal("input_chunk_selected", chunk)
		Org.Track.EVENT: emit_signal("event_chunk_selected", chunk)
