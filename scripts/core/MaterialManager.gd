extends Node

signal inventory_changed()

var materials_list: Array[MaterialDefinition]
var materials: MaterialMap = MaterialMap.new()
var created: MaterialMap = MaterialMap.new()
var created_all_time: MaterialMap = MaterialMap.new()
var materials_by_id: Dictionary[String, MaterialDefinition] = {}

func _ready() -> void:
	_load_materials("res://resources/materials/")
	materials_list.sort_custom(func(a:MaterialDefinition, b:MaterialDefinition) -> bool:
		return a.resource_path < b.resource_path
	)

func _load_materials(path: String) -> void:
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
			_load_materials(full_path)
		elif file.ends_with(".tres"):
			var res : Resource = load(full_path)
			if res is MaterialDefinition:
				var material: MaterialDefinition = res
				materials_list.append(material)
				materials.set_value(material.id, 0)
				created.set_value(material.id, 0)
				created_all_time.set_value(material.id, 0)
				materials_by_id[material.id] = material
		file = dir.get_next()
	dir.list_dir_end()

func change_materials(object: CountableObject, amount: int) -> bool:
	if object is WorkerDefinition:
		if amount > 0:
			ActionManager.change_workers(amount)
			_bump()
			return true
		if amount < 0:
			if ActionManager.get_available_workers() < -amount:
				return false
			ActionManager.change_workers(amount)
			_bump()
			return true
		return false

	if object is MaterialDefinition:
		var material: MaterialDefinition = object as MaterialDefinition
		var key: String = _key(object)
		var current: int = materials.get_value(key)
		var next: int = current + amount
		if next < 0:
			return false
		materials.set_value(key, next)
		if amount > 0:
			created.add(key, amount)
			created_all_time.add(key, amount)
			if material.has_build_effect:
				PlayerManager.change_currency(material.object_type, amount * material.production_value)
		_bump()
		return true
	return false

func get_amount(object: CountableObject) -> int:
	return materials.get_value(_key(object))

func get_material_by_id(id: String) -> MaterialDefinition:
	return materials_by_id.get(id)

func _key(object: Variant) -> String:
	if object is String:
		return object
	if object is MaterialDefinition:
		return object.id
	return str(object)

func get_total_supply() -> Dictionary[int, int]:
	var supply: Dictionary[int, int] = {}
	for id:String in materials.data:
		var amount: int = materials.get_value(id)
		var material: MaterialDefinition = materials_by_id.get(id)
		if material == null:
			continue
		if amount <= 0:
			continue
		if material.craft_stage != MaterialDefinition.CraftingStage.FINISH:
			continue
		var production: int = amount * material.production_value
		for tag: MaterialDefinition.MaterialTag in material.tags:
			supply[tag] = supply.get(tag, 0) + production
	return supply

func _bump() -> void:
	inventory_changed.emit()
