class_name JPrezPlayer extends Node
# This component renders jprez directly from the J interpreter.
# It knows nothing about org files except to pass the path to jprez.

signal macro_finished # when a macro finishes playing

onready var JI = $JLang # J interpreter
var jprez_ready = true # false when macro is playing

func goix(scene, cmd):
	jprez_ready = false
	JI.cmd("cocurrent'base'")
	JI.cmd('goix %d %d' % [scene, cmd])
	JI.cmd("advance''")

func _ready():
	$AudioStreamPlayer.connect("finished", self, "_on_audio_finished")
	# print("J_HOME:", OS.get_environment('J_HOME'))
	JI.cmd("9!:7 [ (16+i.11){a.  NB. box drawing characters")
	JI.cmd("ARGV_z_=:,<''")
	JI.cmd("load 'tangentstorm/j-kvm/vid'")
	JI.cmd("coinsert 'kvm'")
	JI.cmd("1!:44 'd:/ver/jprez'")
	JI.cmd('gethw_vt_ =: {{ 45 220 }}')  # TODO: parameterize this?
	JI.cmd("load 'jprez.ijs'")

func set_org_path(org_path):
	JI.cmd("cocurrent'base'")
	JI.cmd("MACROS_ONLY =: 0")
	JI.cmd("ORG_PATH =: '%s'" % [org_path])
	JI.cmd("reopen_base_=:reopen_outkeys_ f.")
	JI.cmd("reopen''")
	JI.cmd("goto 0")

func _process(_dt):
	# we do this on every tick so we can watch macros play.
	JI.cmd("update__app''")
	if JI.cmd('R__repl * 2'): # so it's not a boolean (because j-rs-gd only does ints atm)
		var repl = get_node('jp-repl')
		repl.JI = JI
		repl.refresh()
	# we have to run update_app /before/ checking A__red
	if not jprez_ready:
		jprez_ready = not JI.cmd('A__red * 2') # TODO: return bools as ints
		# signal on the next frame so that macro lines always take at least one frame.
		# (this is so the stepper doesn't play both an input line and an audio in one step)
		if jprez_ready: call_deferred('emit_signal', 'macro_finished')

func _on_JPrezStepper_cmdix_changed(scene, cmd):
	goix(scene, cmd)

