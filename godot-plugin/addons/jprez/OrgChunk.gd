tool class_name OrgChunk extends Resource
# this represensts one "chunk" (step/line) within a jprez slide

export(String) var file_path = ''
export(Resource) var time_start
export(Resource) var time_end
export var track : int = 0 # Org.Track.TEXT
export(Array, String) var lines

func lines_to_string():
	var res = ''
	for line in lines:
		res += ('\n' if res else '') + line
	return res

func to_string():
	# TODO: include the path and timing
	return lines_to_string()

func suggest_path()->String:
	if file_path: return file_path
	var txt = lines_to_string().to_lower()
	var md5 = txt.md5_text()
	var res = md5.left(4) + '-'
	for ch in txt:
		if ch in 'abcdefghijklmnopqrstuvwxyz0123456789': res += ch
		if len(res) == 32: break
	if len(res) < 32: res += md5.right(4).left(32-len(res))
	return res + '.wav'

func file_exists(dir_path)->bool:
	return File.new().file_exists(dir_path + suggest_path())
