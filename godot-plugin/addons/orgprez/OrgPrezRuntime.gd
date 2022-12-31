class_name OrgPrezRuntime extends Control

var org: OrgNode
var org_path = ProjectSettings.get("global/default_org_file")
var user_scene
var org_deck : OrgDeck

onready var stepper:OrgPrezStepper = $OrgPrezStepper
onready var script_engine = $OrgPrezScriptEngine

const bytesPerSample = 2
const channels = 2
const mixRate = 44100.0
func hms(samples)->String:
	# time in seconds:
	var time = samples/(channels * bytesPerSample * mixRate)
	var mm = int(floor(time/60))
	var hh = int(floor(mm/60)); mm %= 60
	var ss = fmod(time,60)
	return "%02d:%02d:%02.3f" % [hh,mm,ss]

func _ready():
	org = Org.from_path(org_path)
	stepper.org = org
	stepper.script_engine = script_engine
	stepper.popup()

	var tscn = org_path.replace('.org','.tscn')
	if not ResourceLoader.exists(tscn):
		tscn = 'res://addons/jprez/JPrezPlayer.tscn' # !! todo: new default scene
	user_scene = load(tscn).instance()
	add_child(user_scene)
	if user_scene.has_method('set_org_path'):
		user_scene.set_org_path(org.get_global_path())
	script_engine.user_scene = user_scene

	var d = user_scene.get_node_or_null('OrgDeck')
	if not d:
		push_warning("couldn't find OrgDeck node")
		d = OrgDeck.new()
		user_scene.add_child(d)
	org_deck = d
	stepper.connect('orgprez_node_changed', self, '_on_orgnode_changed')
	_on_orgnode_changed(stepper.get_current_org_node())

func load_timeline():
	# visually show all the clips in a timeline view
	# (disabled for now because it's very slow)
	var i = 0
	var total = 0
	var cur = OrgCursor.new(org)
	var track_names = Org.Track.keys()
	while true:
		var chunk = cur.next_chunk()
		if chunk: print("chunk:", track_names[chunk.track])
		if chunk == null: break
		if chunk.track != Org.Track.AUDIO: continue
		if chunk.file_exists(org.get_dir()):
			var wav = org.get_dir()+chunk.suggest_path()
			var sam : AudioStreamSample = AudioLoader.loadfile(wav)
			var rect = Waveform.new()
			rect.color = Color.beige if i % 2 else Color.bisque; i += 1
			rect.rect_min_size = Vector2(sam.data.size() * 0.0005,64)
			if i < 10: rect.sample = sam
			rect.timeScale = 512
			# timeline.add_child(rect)
			total += sam.data.size()
			print(chunk.index, ' ', wav, ' ', hms(sam.data.size()))
		else: print("not there: ", chunk.suggest_path())

	var wav = Waveform.new()
	print("total size: ", total)
	var timeScale = 128
	var bytesPerSample = 4
	print("total length: ", hms(total))

func save_org_file():
	var f = File.new()
	f.open(org_path, File.WRITE)
	f.store_string(org.to_string())
	f.close()

func _input(event):
	if event is InputEventKey and event.is_pressed():
		match event.scancode:
			KEY_F12: stepper.visible = not stepper.visible

func _on_OrgPrezStepper_orgprez_line_changed(scene, cmd):
	if user_scene.has_method('goix'):
		user_scene.goix(scene, cmd)

func _on_OrgPrezScriptEngine_script_finished(id, result):
	stepper._on_script_finished(id, result)

func _on_JPrezScene_macro_finished():
	stepper._on_macro_finished()

func _on_orgnode_changed(orgNode):
	if orgNode: org_deck.show_slide(orgNode.scene)
	else: org_deck.hide_all()

