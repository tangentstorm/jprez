tool extends VBoxContainer

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


export(String) var org_path = 'd:/ver/j-talks/s1/e4-mandelbrot/script.org' setget _set_org
export(bool) var go = false setget _go
func _go(checked:bool):
	if checked:
		self.reload_outline()
		self.set("go", false)

func _ready():
	reload_outline()

func _set_org(path):
	org_path = path
	reload_outline()

func reload_outline():
	var org = OrgNode.new('')
	var f = File.new(); f.open(self.org_path, File.READ)
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
				printerr("too many asterisks on line ",i)
				return
			var node = OrgNode.new(rest)
			stack[cut-1].add_child(node)
			if cut == len(stack): stack.push_back(node)
			else: stack[cut] = node

	org.add_to_tree($Tree, null)
	# extra line at the end so we can 'insert' before end
	var blank = $Tree.create_item(stack[0]); blank.set_text(0, '')
