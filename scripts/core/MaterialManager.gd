extends Manager

signal inventory_changed()

var materials_list: Array[MaterialDefinition] = []
var tick_effect_materials: Dictionary[MaterialDefinition, int] = {}
var materials: MaterialMap = MaterialMap.new()
var created: MaterialMap = MaterialMap.new()
var created_all_time: MaterialMap = MaterialMap.new()
var materials_by_id: Dictionary[String, MaterialDefinition] = {}
var material_delta_per_tick: Dictionary[String, float] = {}

func _ready() -> void:
	register_manager(System.MATERIAL, self)
	load_materials() 
	PlayerManager.tick.connect(_on_tick)
	formula_changed()

func formula_changed() -> void:
	return

func load_materials() -> void:
	materials_list.clear()
	materials_by_id.clear()
	tick_effect_materials.clear()
	GlobalResourceLoader.recursive_load(
		"res://resources/countable_objects/materials/",
		func(res: Resource, path: String) -> void:
			var material: MaterialDefinition = res
			if material.id.is_empty():
				push_error("Material missing id: %s" % path)
			elif materials_by_id.has(material.id):
				push_error("Duplicate material id: %s" % material.id)
			else:
				materials_list.append(material)
				materials_by_id[material.id] = material
				materials.set_value(material.id, 0)
				created.set_value(material.id, 0)
				created_all_time.set_value(material.id, 0)
				if material.tick_effect_value > 0:
					tick_effect_materials[material] = 0,
		[".tres"],
		MaterialDefinition
	)
	materials_list.sort_custom(func(a: MaterialDefinition, b: MaterialDefinition) -> bool:
		return a.resource_path < b.resource_path
	)

func _on_tick() -> void:
	_process_tick_effects()
	calculate_material_deltas()

func _process_tick_effects() -> void:
	for material: MaterialDefinition in tick_effect_materials:
		tick_effect_materials[material] += 1
		if tick_effect_materials[material] < material.tick_effect_interval:
			continue
		tick_effect_materials[material] = 0
		var amount: int = materials.get_value(material.id)
		if amount <= 0:
			continue
		PlayerManager.change_currency(
			material.object_type,
			ceili(amount * material.get_total_tick_value())
		)

func calculate_material_deltas() -> void:
	material_delta_per_tick.clear()
	var worker_efficiency: float = WorkerManager.get_worker_efficiency()
	for state: ActionState in ActionManager.states.values():
		if state.workers_assigned <= 0:
			continue
		var action: ActionDefinition = state.action
		var cycles_per_tick: float = (
			float(state.workers_assigned)
			* action.base_conversion_rate
			* worker_efficiency
			/ float(action.duration)
		)
		for object: Definition in action.inputs:
			if object is MaterialDefinition:
				var material: MaterialDefinition = object
				material_delta_per_tick[material.id] = (
					material_delta_per_tick.get(material.id, 0.0)
					- action.inputs[object] * cycles_per_tick
				)
		for object: Definition in action.outputs:
			if object is MaterialDefinition:
				var material: MaterialDefinition = object
				material_delta_per_tick[material.id] = (
					material_delta_per_tick.get(material.id, 0.0)
					+ action.outputs[object] * cycles_per_tick
				)
	_add_worker_consumption_deltas()

func _add_worker_consumption_deltas() -> void:
	var consumption: Dictionary[String, int] = WorkerManager.calculate_worker_consumption()
	for id: String in consumption:
		material_delta_per_tick[id] = (
			material_delta_per_tick.get(id, 0.0)
			- float(consumption[id]) / float(WorkerManager.worker_race.consumption_time)
		)

func change_materials(object: Definition, amount: int) -> bool:
	if object is WorkerDefinition:
		if amount > 0:
			WorkerManager.change_workers(amount)
			_bump()
			return true
		if amount < 0:
			if WorkerManager.get_available_workers() < -amount:
				return false
			WorkerManager.change_workers(amount)
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
			if material.build_effect_value > 0:
				PlayerManager.change_currency(material.object_type, material.get_total_build_value())
		_bump()
		return true
	return false

func get_amount(object: Definition) -> int:
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
