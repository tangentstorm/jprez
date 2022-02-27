tool class_name Org
# Represent emacs org-mode files as trees of objects.
# (The jprez file format is a subset of org syntax)
# https://orgmode.org/
# timespan syntax is borrowed from:
# https://en.wikipedia.org/wiki/SubRip

const TIME = "\\d{2}:\\d{2}:\\d{2}.\\d{3}"
const SPAN = "^(?<start>"+TIME+")( --> (?<end>"+TIME+"))?"

enum Track { TEXT, MACRO, INPUT, EVENT }

class OrgParser:
	var rx_timespan = RegEx.new()
	var root
	var node
	var stack
	var chunk

	func _init():
		rx_timespan.compile(SPAN)

	func end_chunk():
		if chunk: node.chunks.append(chunk)
		chunk = null

	func extend_chunk(line):
		if chunk == null:
			chunk = OrgNode.OrgChunk.new()
		chunk.lines.append(line)

	func new_slide(lno, cut, rest):
		if (cut-1) > len(stack):
			printerr("warning: too many asterisks on line ", lno)
		else:
			node = OrgNode.new(cut, rest)
			stack[cut-1].add_child(node)
			if cut == len(stack): stack.push_back(node)
			else: stack[cut] = node

	func new_chunk(_lno, line):
		var track = Track.TEXT
		if line.begins_with(": ."): track = Track.MACRO
		elif line.begins_with(": "): track = Track.INPUT
		chunk = OrgNode.OrgChunk.new()
		chunk.track = track
		chunk.lines = [line]

	func note_timespan(start, end):
		pass

	func note_waveform(path):
		pass

	func note_event(rest):
		pass

	func org_from_path(path:String):
		root = OrgNode.new(''); node = root; stack = [root]; chunk = null
		var f = File.new(); f.open(path, File.READ)
		var lno = -1
		for line in f.get_as_text().split("\n"):
			lno += 1
			var cut = line.find(" ")
			var rest = line.right(cut)
			if line == '': end_chunk()
			elif line.begins_with('#+title:'): root.head = rest
			elif line.begins_with('#+audio:'): note_waveform(rest)
			elif line.begins_with('#+event:'): note_event(rest)
			elif line[0] in [':','*']:
				end_chunk()
				if line[0] == '*': new_slide(lno, cut, rest)
				else: new_chunk(lno, line)
			else:
				var m = rx_timespan.search(line)
				if m: note_timespan(m.get_string("start"), m.get_string("end"))
				else: extend_chunk(line)
		end_chunk()
		return root

static func from_path(path:String)->OrgNode:
	var p = OrgParser.new()
	return p.org_from_path(path)
