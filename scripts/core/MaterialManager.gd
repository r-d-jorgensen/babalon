extends Node

signal inventory_changed()

var materials_list: Array[MaterialDefinition]
var materials: MaterialMap = MaterialMap.new()
var created: MaterialMap = MaterialMap.new()
var created_all_time: MaterialMap = MaterialMap.new()

func _ready() -> void:
	init_materials()

func init_materials() -> void:
	var resource_list: Array[String] = ["source_materials","intermediate_materials","final_materials"]
	for folder:String in resource_list:
		var dir:DirAccess = DirAccess.open("res://resources/" + folder)
		if dir == null:
			continue
		dir.list_dir_begin()
		var file: String = dir.get_next()
		while file != "":
			if file.ends_with(".tres"):
				var path: String = "res://resources/" + folder + "/" + file
				var res: Resource = load(path)
				materials_list.append(res)
				materials.set_value(res.resource_path, 0)
				created.set_value(res.resource_path, 0)
				created_all_time.set_value(res.resource_path, 0)
			file = dir.get_next()
		dir.list_dir_end()
	materials_list.sort_custom(func(a:MaterialDefinition, b:MaterialDefinition) -> bool:
		return a.resource_path < b.resource_path
	)

func add(object: CountableObject, amount: int) -> void:
	var key: String = _key(object)
	if object is WorkerDefinition:
		ActionManager.add_workers(amount)
		_bump()
		return
	var material: MaterialDefinition = object as MaterialDefinition
	materials.add(key, amount)
	created.add(key, amount)
	created_all_time.add(key, amount)
	if material.has_build_effect:
		PlayerManager.add_currency(material.object_type, amount * material.production_value)
	_bump()

func consume(object: CountableObject, amount: int) -> bool:
	var key: String = _key(object)
	if materials.get_value(key) < amount:
		return false
	materials.add(key, -amount)
	_bump()
	return true

func get_amount(object: CountableObject) -> int:
	return materials.get_value(_key(object))

func _key(object: Variant) -> String:
	if object is String:
		return object
	if object is Resource:
		return object.resource_path
	return str(object)

func get_total_supply() -> Dictionary[int, int]:
	var supply: Dictionary[int, int] = {}
	for path:String in materials.data:
		var amount: int = materials.get_value(path)
		var material: MaterialDefinition = load(path)
		if amount <= 0 or material.craft_stage != MaterialDefinition.CraftingStage.FINISH:
			continue
		var production: int = amount * material.production_value
		for tag: MaterialDefinition.MaterialTag in material.tags:
			supply[tag] = supply.get(tag, 0) + production
	return supply

func _bump() -> void:
	inventory_changed.emit()
