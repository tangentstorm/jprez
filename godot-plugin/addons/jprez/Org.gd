tool class_name Org
# Represent emacs org-mode files as trees of objects.
# (The jprez file format is a subset of org syntax)
# https://orgmode.org/

static func from_path(path:String)->OrgNode:
	var root = OrgNode.new('')
	var node = root
	var stack = [root]
	var f = File.new(); f.open(path, File.READ)
	var i = -1; var para = ''
	for line in f.get_as_text().split("\n"):
		i += 1
		var cut = line.find(" ")
		var rest = line.right(cut)
		if line.begins_with('#+title:'):
			root.head = rest
		elif line == '' or line[0] in [':','*','#']:
			if para:
				node.steps.append(para); para = ''
			if line =='': continue
			if line[0]=='*':
				if (cut-1) > len(stack):
					printerr("warning: too many asterisks on line ",i)
					continue
				node = OrgNode.new(rest)
				stack[cut-1].add_child(node)
				if cut == len(stack): stack.push_back(node)
				else: stack[cut] = node
			else: node.steps.append(line)
		else: para += ('\n' if para else '') + line
	if para: node.steps.append(para)
	return root
