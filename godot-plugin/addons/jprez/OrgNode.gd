tool class_name OrgNode extends Resource
# This is a recursive structure that represents
# the content of a jprez-flavored *.org file.

export var depth : int
export var head : String
export(Array,String) var slide
export var chunks : Array
export var children : Array

func _init(depth=0, head='', slide=[], chunks=[], children=[]):
	self.depth = depth
	self.head = head
	self.slide = slide
	self.chunks = chunks
	for child in children:
		self.children.append(child as OrgNode)

func get_dir():
	var dir = resource_path.get_base_dir()
	if not dir.ends_with('/'): dir += '/'
	return  dir

func get_global_path():
	return ProjectSettings.globalize_path(resource_path)

func add_child(node:OrgNode):
	self.children.append(node)

func add_to_tree(tree:Tree, parent:TreeItem):
	var item = tree.create_item(parent)
	item.set_text(0, self.head)
	item.set_metadata(0, self)
	for child in self.children:
		child.add_to_tree(tree, item)

func slide_text()->String:
	var res = ''
	for line in slide:
		res += line + '\n'
	return res

func dump():
	print(to_string())

func to_string():
	var res = ''
	if depth == 0: res += "#+title:%s\n\n" % head
	else: res += "*".repeat(depth) + head + '\n'
	if slide:
		res += "#+begin_src j\n"
		res += slide_text()
		res += "#+end_src\n"
		res += "\n"
	if self.children:
		for child in self.children:
			res += child.to_string()
	else:
		for chunk in self.chunks:
			res += chunk.to_string() + '\n\n'
	return res

func save():
	print("saving org to: ", resource_path)
	var f = File.new()
	f.open(resource_path, File.WRITE)
	f.store_string(to_string())
	f.close()
