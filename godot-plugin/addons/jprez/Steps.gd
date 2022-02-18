tool extends VBoxContainer

func set_org(org:Org.OrgNode):
	$Tree.clear()
	if org == null: return
	for step in org.steps:
		var item = $Tree.create_item()
		item.set_text(0, step)
