tool class_name OrgNode extends Resource
# This is a recursive structure that represents
# the content of a jprez-flavored *.org file.

export var head : String
export var slide : String
export var steps : Array
export var children : Array

func _init(head='', slide='', steps=[], children=[]):
	self.head = head
	self.slide = slide
	self.steps = steps
	for child in children:
		self.children.append(child as OrgNode)

func add_child(node:OrgNode):
	self.children.append(node)

func add_to_tree(tree:Tree, parent:TreeItem):
	if parent == null: # then we're the root
		parent = null
	var item = tree.create_item(parent)
	item.set_text(0, self.head)
	item.set_metadata(0, self)
	for child in self.children:
		child.add_to_tree(tree, item)
