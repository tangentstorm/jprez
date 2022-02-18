tool extends VBoxContainer

const START = 0
const LENGTH = 1
const TEXT = 2

func set_org(org:OrgNode):
	var tree : Tree = $Tree
	tree.clear()
	for col in [START,LENGTH,TEXT]:
		tree.set_column_min_width(col, 70)
		tree.set_column_expand(col, false)
	tree.set_column_expand(TEXT, true)
	if org == null: return
	for step in org.steps:
		var item : TreeItem = tree.create_item()
		item.set_text(START, '00:00'); item.set_custom_color(START, Color.darkgray)
		item.set_text(LENGTH, '00:00'); item.set_custom_color(LENGTH, Color.darkgray)
		item.set_text(TEXT, step)
		if step.begins_with(":"):
			item.set_custom_color(TEXT,
				Color.lightseagreen if step.begins_with(': .') else Color.aquamarine)
