class_name JPrezApp extends Control

var org: OrgNode
var org_path = 'res://wip/dealing-cards/dealing-cards.org'

onready var jprez_stepper = $JPrezStepper
onready var jprez_scene = find_node("JPrezScene")
onready var script_engine = $JPrezScriptEngine

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
	jprez_stepper.org = org
	jprez_stepper.script_engine = script_engine
	script_engine.scene_title = jprez_scene.find_node("SceneTitle")
	jprez_scene.set_org_path(org.get_global_path())
	find_node("OrgPath").text = org_path
	find_node("JPrezAudioTab").org = org


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

func _on_previewtab_pressed():
	$VBox/JPrezAudioTab.visible = false
	jprez_stepper.visible = true

func _on_audiotab_pressed():
	$VBox/JPrezAudioTab.visible = true
	jprez_stepper.visible = false

func _input(event):
	if event is InputEventKey and event.is_pressed():
		match event.scancode:
			KEY_F12: jprez_stepper.visible = not jprez_stepper.visible
			KEY_F11: $VBox.visible = not $VBox.visible

func _on_JPrezStepper_jprez_line_changed(scene, cmd):
	jprez_scene.goix(scene, cmd)

func _on_JPrezScriptEngine_script_finished(id, result):
	jprez_stepper._on_script_finished(id, result)
