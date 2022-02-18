# importer for jprez-flavored .org files
# https://docs.godotengine.org/en/stable/tutorials/plugins/editor/import_plugins.html
tool extends EditorImportPlugin

func get_importer_name():
	return "org.jprez"

func get_visible_name():
	return "jprez screenplay (*.org)"

func get_recognized_extensions():
	return ["org"]

func get_save_extension():
	return "res"

func get_resource_type():
	return "Resource"

enum Presets { DEFAULT }

func get_preset_count():
	return Presets.size()

func get_preset_name(preset):
	match preset:
		Presets.DEFAULT: return "Default"
		_: return "Unknown"

func get_import_options(preset):
	return []

func get_option_visibility(opt, opts):
	return true

func import(source_file, save_path, options, r_platform_variants, r_gen_files):
	# TODO: error trapping
	var org:OrgNode = Org.from_path(source_file)
	var res = ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], org)
	return res
