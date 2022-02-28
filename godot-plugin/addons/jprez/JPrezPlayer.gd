extends Node

export(Resource) var org setget set_org
onready var JI = $JLang # J interpreter

var org_path = ''
onready var cmd_label = $PanelContainer/CurrentCmd
var cursor : OrgCursor

enum S { ENTER, DESCEND, CHUNKS, RETURN, BREAK }
class OrgCursor:
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

func set_org(org:OrgNode):
	org_path = ProjectSettings.globalize_path(org.resource_path)
	cursor = OrgCursor.new(org)

var timer : Timer
func _ready():
	var hw = '45 220'
	print("J_HOME:", OS.get_environment('J_HOME'))
	JI.cmd("9!:7 [ (16+i.11){a.  NB. box drawing characters")
	JI.cmd("ARGV_z_=:,<''")
	JI.cmd("load 'tangentstorm/j-kvm/vid'")
	JI.cmd("coinsert 'kvm'")
	JI.cmd("1!:44 'd:/ver/jprez'")
	JI.cmd('gethw_vt_ =: {{ ' +hw+ '}}')
	JI.cmd("load 'jprez.ijs'")
	
	print("org path:", org_path)
	if org_path != '':
		JI.cmd("cocurrent'base'")
		JI.cmd("ORG_PATH =: '%s'" % [org_path])
		JI.cmd("reopen''")
		JI.cmd("goto 0")

	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.10
	timer.connect("timeout", self, '_timeout')
	timer.start()

func _process(dt):
	# we do this on every tick so we can watch macros play.
	JI.cmd("cocurrent'base'")
	JI.cmd("update__app''")
	var r = JI.cmd('R__repl * 2') # so it's not a boolean
	if not r: return
	var repl = get_node_or_null('jp-repl')
	if repl:
		repl.JI = JI
		repl.refresh()

func _timeout():
	var chunk = cursor.next_chunk()
	cmd_label.text = chunk.lines_to_string() if chunk else ''
	# advance, unless we're playing a macro.
	JI.cmd("advance^:(-.A__red)''")
