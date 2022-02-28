tool class_name OrgCursor extends Reference

enum S { ENTER, DESCEND, CHUNKS, RETURN, BREAK }

# tool to iterate through the nodes
var node: OrgNode
var stack: Array
var step : int = 0
var state : int = S.ENTER
var head : String

func _init(root:OrgNode):
	self.stack = []
	self.node = root
	self.state = S.ENTER

func next_chunk()->OrgChunk:
	var res = null
	while true:
		match state:
			S.ENTER:
				step = 0
				state = S.DESCEND if node.children else S.CHUNKS
			S.DESCEND:
				if step < len(node.children):
					stack.push_back([node, step+1, state])
					node = node.children[step]
					state = S.ENTER
				else: state = S.RETURN
			S.RETURN:
				if len(stack):
					var frame = stack.pop_back()
					node = frame[0]; step = frame[1]; state = frame[2]
				else: state = S.BREAK
			S.CHUNKS:
				if step < len(node.chunks):
					res = node.chunks[step]
					step += 1
					break
				else: state = S.RETURN
			S.BREAK: break
	return res
