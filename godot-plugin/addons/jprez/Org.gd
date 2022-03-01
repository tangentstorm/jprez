tool class_name Org
# Represent emacs org-mode files as trees of objects.
# (The jprez file format is a subset of org syntax)
# https://orgmode.org/
# timespan syntax is borrowed from:
# https://en.wikipedia.org/wiki/SubRip

const TIME = "\\d{2}:\\d{2}:\\d{2}.\\d{3}"
const SPAN = "^(?<start>"+TIME+")( --> (?<end>"+TIME+"))?"

enum Track { AUDIO, MACRO, INPUT, EVENT }

class OrgParser:
	var rx_timespan = RegEx.new()
	var root:OrgNode
	var node:OrgNode
	var stack:Array
	var chunk:OrgChunk
	var chunk_count: int = 0 # so each gets a unique id

	func _init():
		rx_timespan.compile(SPAN)

	func end_chunk():
		if chunk: node.chunks.append(chunk)
		chunk = null

	func extend_chunk(line):
		if chunk == null: new_chunk(line)
		else: chunk.lines.append(line)

	func new_slide(lno, cut, rest):
		if (cut-1) > len(stack):
			printerr("warning: too many asterisks on line ", lno)
		else:
			node = OrgNode.new(cut, rest)
			stack[cut-1].add_child(node)
			if cut == len(stack): stack.push_back(node)
			else: stack[cut] = node

	func new_chunk(line):
		var track = Track.AUDIO
		if line.begins_with(": ."): track = Track.MACRO
		elif line.begins_with(": "): track = Track.INPUT
		chunk = OrgChunk.new()
		chunk.track = track
		chunk.lines = [line]
		chunk.index = chunk_count
		chunk_count += 1

	func note_timespan(start, end):
		pass

	func note_audio(rest):
		chunk.file_path = rest

	func note_event(rest):
		pass

	func org_from_path(path:String):
		root = OrgNode.new(''); node = root; stack = [root]; chunk = null
		var f = File.new(); f.open(path, File.READ)
		var lno = -1; var in_src = false
		for line in f.get_as_text().split("\n"):
			lno += 1
			var cut = line.find(" ")
			var rest = line.right(cut)
			if in_src:
				if line == '#+end_src': in_src = false
				else: node.slide.append(line)
			elif line == '': end_chunk()
			elif line.begins_with('#+title:'): root.head = rest
			elif line.begins_with('#+audio:'): note_audio(rest)
			elif line.begins_with('#+event:'): note_event(rest)
			elif line.begins_with('#+begin_src j'): in_src = true
			elif line[0] in [':','*']:
				end_chunk()
				if line[0] == '*': new_slide(lno, cut, rest)
				else: new_chunk(line)
			else:
				var m = rx_timespan.search(line)
				if m: note_timespan(m.get_string("start"), m.get_string("end"))
				else: extend_chunk(line)
		end_chunk()
		return root

static func from_path(path:String)->OrgNode:
	var p = OrgParser.new()
	return p.org_from_path(path)
