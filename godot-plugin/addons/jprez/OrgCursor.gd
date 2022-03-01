tool class_name OrgCursor extends Reference

enum S { ENTER, DESCEND, CHUNKS, NEXT, RETURN, BREAK }

# tool to iterate through the nodes
var node: OrgNode
var stack: Array
var count: int = 0 # global count through the whole tree
var step : int = 0 # local count within the current node
var state : int = S.ENTER
var head : String

func _init(root:OrgNode):
	self.stack = []
	self.node = root
	self.state = S.ENTER

func this_chunk()->OrgChunk:
	if not (state == S.NEXT or state == S.CHUNKS): return null
	return node.chunks[step] if step < len(node.chunks) else null

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
				res = this_chunk()
				if res:
					# yield before incrementing, so that this_chunk()
					# can use the counters to retrieve the current chunk.
					state = S.NEXT; break
				else: state = S.RETURN
			S.NEXT:
				step += 1; count += 1
				state = S.CHUNKS
			S.BREAK: break
	return res

func find_next(track)->OrgChunk:
	var res = next_chunk()
	while res and res.track != track:
		res = next_chunk()
	return res
