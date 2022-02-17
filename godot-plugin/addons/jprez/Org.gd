class_name Org
# Represent emacs org-mode files as trees of objects.
# (The jprez file format is a subset of org syntax)
# https://orgmode.org/

class OrgNode:

	var headline : String
	var children : Array
	var slide : String
	var steps : Array

	func _init(title):
		self.headline = title
		self.children = []
		self.slide = ''
		self.steps = []

	func add_child(node:OrgNode):
		self.children.append(node)

	func add_to_tree(tree:Tree, parent:TreeItem):
		if parent == null: # then we're the root
			tree.clear()
			tree.set_hide_root(true)
			parent = null
		var item = tree.create_item(parent)
		item.set_text(0, self.headline)
		for child in self.children:
			child.add_to_tree(tree, item)

static func from_path(path:String):
	var org = OrgNode.new('')
	var f = File.new(); f.open(path, File.READ)
	var stack = [org]
	var i = -1
	for line in f.get_as_text().split("\n"):
		i += 1
		var cut = line.find(" ")
		var rest = line.right(cut)
		if line.begins_with('#+title:'):
			org.headline = rest
		elif line.begins_with("*"):
			if (cut-1) > len(stack):
				printerr("warning: too many asterisks on line ",i)
				continue
			var node = OrgNode.new(rest)
			stack[cut-1].add_child(node)
			if cut == len(stack): stack.push_back(node)
			else: stack[cut] = node
	return org
