tool extends VBoxContainer
# visual representation of OrgChunk list

enum Col { INDEX, JPXY, TEXT }

signal audio_chunk_selected(chunk)
signal macro_chunk_selected(chunk)
signal input_chunk_selected(chunk)
signal event_chunk_selected(chunk)
signal chunk_selected(chunk)

export var org_dir:String = 'res://'
onready var tree : Tree = $Tree
onready var track_names = Org.Track.keys()

func set_org(org:OrgNode):
	tree.clear()
	var root = tree.create_item()
	for col in Col.values():
		tree.set_column_min_width(col, 60)
		tree.set_column_expand(col, false)
	tree.set_column_min_width(Col.INDEX, 32)
	tree.set_column_expand(Col.TEXT, true)
	if not org: return
	for chunk in org.chunks:
		var item : TreeItem = tree.create_item(root)
		item.set_text(Col.INDEX, str(chunk.index))
		# item.set_text(Col.TRACK, track_names[chunk.track][0].to_lower())
		item.set_text(Col.JPXY, ' %d %d'%[chunk.jpxy.x, chunk.jpxy.y]); item.set_custom_color(Col.JPXY, Color.darkgray)
		for c in [Col.INDEX]: item.set_text_align(c, TreeItem.ALIGN_RIGHT)
		item.set_text(Col.TEXT, chunk.to_string())
		item.set_meta('chunk', chunk)
		var color = Color.white
		match chunk.track:
			Org.Track.AUDIO:
				if not chunk.file_exists(org_dir): color = Color.orangered
			Org.Track.MACRO: color = Color.lightseagreen
			Org.Track.INPUT: color = Color.aquamarine
			Org.Track.EVENT: color = Color.cornflower
		item.set_custom_color(Col.TEXT, color)

	var first = tree.get_root().get_children()
	if first: first.select(Col.TEXT)

func _on_Tree_item_selected():
	var chunk = tree.get_selected().get_meta('chunk')
	if not chunk: return
	match chunk.track:
		Org.Track.AUDIO: emit_signal("audio_chunk_selected", chunk)
		Org.Track.MACRO: emit_signal("macro_chunk_selected", chunk)
		Org.Track.INPUT: emit_signal("input_chunk_selected", chunk)
		Org.Track.EVENT: emit_signal("event_chunk_selected", chunk)
	emit_signal("chunk_selected", chunk)

func highlight(tracks:Array):
	# tracks is an array of OrgCursor instances (used by JPrezPlayer)
	var root = tree.get_root()
	if not root: return
	var item = root.get_children()
	while item != null:
		item.clear_custom_bg_color(0)
		item = item.get_next()
	for track in tracks:
		var track_chunk = track.this_chunk()
		if not track_chunk: continue
		item = tree.get_root().get_children()
		while item != null:
			var chunk = item.get_meta('chunk')
			if chunk.index == track_chunk.index:
				item.set_custom_bg_color(0, Color.steelblue)
				break
			item = item.get_next()
