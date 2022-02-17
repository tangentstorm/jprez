tool extends VBoxContainer

export(String) var org_path = 'd:/ver/j-talks/s1/e4-mandelbrot/script.org' setget _set_org
export(bool) var go = false setget _go
func _go(checked:bool):
	if checked:
		self.reload_outline()
		self.set("go", false)

func _ready():
	reload_outline()

func _set_org(path):
	org_path = path
	reload_outline()

func reload_outline():
	var org = Org.from_path(org_path)
	org.add_to_tree($Tree, null)
	# extra line at the end so we can 'insert' before end
	var blank = $Tree.create_item($Tree.get_tree().root); blank.set_text(0, '')
