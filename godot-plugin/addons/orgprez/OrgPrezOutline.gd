tool
class_name OrgPrezOutline extends VBoxContainer

signal node_selected(org_node)

func set_org(org:OrgNode):
	$Tree.clear()
	org.add_to_tree($Tree, null)
	# extra line at the end so we can 'insert' before end
	var blank = $Tree.create_item(); blank.set_text(0, '')
	$Tree.get_root().get_children().select(0)

func get_org_tree()->Tree:
	var tree : Tree = $Tree
	return tree

func _on_Tree_item_selected():
	var org = get_org_tree().get_selected().get_metadata(0)
	emit_signal("node_selected", org)

func get_current_org_node() -> OrgNode:
	return get_org_tree().get_selected().get_metadata(0)
