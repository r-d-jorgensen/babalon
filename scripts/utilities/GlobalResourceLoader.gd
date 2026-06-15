class_name  GlobalResourceLoader

static func recursive_load(
	path: String,
	on_load: Callable,
	ext_filter: Array[String] = [],
	type_ref: Script = null
) -> void:
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var file: String = dir.get_next()
	while file != "":
		if file == "." or file == "..":
			file = dir.get_next()
			continue
		var full_path: String = path + "/" + file
		if dir.current_is_dir():
			recursive_load(full_path, on_load, ext_filter, type_ref)
		else:
			if ext_filter.size() > 0:
				var ok: bool = false
				for ext: String in ext_filter:
					if file.ends_with(ext):
						ok = true
						break
				if not ok:
					file = dir.get_next()
					continue
			var res: Resource = load(full_path)
			if res == null:
				file = dir.get_next()
				continue
			if type_ref != null and not is_instance_of(res, type_ref):
				file = dir.get_next()
				continue
			on_load.call(res, full_path)
		file = dir.get_next()
	dir.list_dir_end()
