tool extends VBoxContainer

signal node_selected(org_node)

func set_org(org:OrgNode):
	$Tree.clear()
	org.add_to_tree($Tree, null)
	# extra line at the end so we can 'insert' before end
	var blank = $Tree.create_item($Tree.get_tree().root); blank.set_text(0, '')

func _on_Tree_item_selected():
	var tree : Tree = $Tree
	var org = tree.get_selected().get_metadata(0)
	emit_signal("node_selected", org)
