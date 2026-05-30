extends Node

signal actions_loaded
signal total_workers_changed
signal workers_changed(action: MaterialAction)

var actions: Array[MaterialAction] = []
var total_workers: int = 0
var optimal_worker_limit: int = 30
var worker_race: WorkerDefinition = preload("res://resources/workers/Human.tres")
var states: Dictionary[String, MaterialActionState] = {}
var actions_by_id: Dictionary[String, MaterialAction] = {}
var _consumption_tick: int = 0
var need_fulfillment: Dictionary[int, float] = {}

func _ready() -> void:
	load_actions()
	PlayerManager.tick.connect(_on_tick)

func load_actions() -> void:
	actions.clear()
	actions_by_id.clear()
	var dir: DirAccess = DirAccess.open("res://resources/actions/")
	if dir == null:
		return
	dir.list_dir_begin()
	var file: String = dir.get_next()
	while file != "":
		if file.ends_with(".tres"):
			var action: MaterialAction = load("res://resources/actions/" + file)
			if action.id.is_empty():
				push_error("Action missing id: %s" % file)
			elif actions_by_id.has(action.id):
				push_error("Duplicate action id: %s" % action.id)
			else:
				actions.append(action)
				actions_by_id[action.id] = action
		file = dir.get_next()
	dir.list_dir_end()
	actions_loaded.emit()

func _on_tick() -> void:
	for state: MaterialActionState in states.values():
		state.tick()
	_consumption_tick += 1
	if _consumption_tick >= worker_race.consumption_time:
		_consumption_tick = 0
		_consume_worker_resources()

func add_workers(amount: int) -> void:
	total_workers += amount
	total_workers_changed.emit()

func get_total_assigned() -> int:
	var total: int = 0
	for state: MaterialActionState in states.values():
		total += state.workers_assigned
	return total

func get_available_workers() -> int:
	return total_workers - get_total_assigned()

func get_action_by_id(id: String) -> MaterialAction:
	return actions_by_id.get(id)

func get_state(action: MaterialAction) -> MaterialActionState:
	var key: String = action.id
	if not states.has(key):
		var state: MaterialActionState = MaterialActionState.new()
		state.action = action
		states[key] = state
	return states[key]

func assign_worker(action: MaterialAction, amount: int = 1) -> void:
	if get_available_workers() < amount: return
	var state: MaterialActionState = get_state(action)
	state.workers_assigned += amount
	workers_changed.emit(state.action)

func unassign_worker(action: MaterialAction, amount: int = 1) -> void:
	var state: MaterialActionState = get_state(action)
	state.workers_assigned -= min(amount, state.workers_assigned)
	workers_changed.emit(state.action)

func get_total_demand() -> Dictionary[int, int]:
	var total: Dictionary[int, int] = {}
	var active_workers: int = get_total_assigned()
	for tag: MaterialDefinition.MaterialTag in worker_race.consumption_requirements:
		var amount: int = worker_race.consumption_requirements[tag]
		total[tag] = amount * active_workers
	return total

func get_worker_efficiency() -> float:
	var need_efficiency: float = 1.0
	if not need_fulfillment.is_empty():
		var total_needs: float = need_fulfillment.size()
		if total_needs > 0:
			need_efficiency = 0.0
			var contribution: float = 1.0 / total_needs
			for ratio: float in need_fulfillment.values():
				need_efficiency += ratio * contribution
	need_efficiency = clamp(need_efficiency, 0.01, 1.0)
	var capacity_efficiency: float = 1.0
	if total_workers > optimal_worker_limit:
		capacity_efficiency = float(optimal_worker_limit) / float(total_workers)
	return need_efficiency * capacity_efficiency

func _consume_worker_resources() -> void:
	need_fulfillment.clear()
	var active_workers: int = get_total_assigned()
	if active_workers <= 0: return
	for tag: MaterialDefinition.MaterialTag in worker_race.consumption_requirements:
		var total_required: int = worker_race.get_required_amount(tag) * active_workers
		var consumed: int = _consume_tag_resources(tag, total_required)
		var fulfillment: float = 1.0
		if total_required > 0:
			fulfillment = float(consumed) / float(total_required)
		need_fulfillment[tag] = clamp(fulfillment, 0.0, 1.0)
	MaterialManager._bump()

func _consume_tag_resources(tag: int, amount: int) -> int:
	var remaining: int = amount
	var consumed: int = 0
	var valid_materials: Array[MaterialDefinition] = []
	for mat: MaterialDefinition in MaterialManager.materials_list:
		if mat.craft_stage == MaterialDefinition.CraftingStage.FINISH and mat.has_tag(tag):
			valid_materials.append(mat)
	valid_materials.sort_custom(func(a: MaterialDefinition, b: MaterialDefinition) -> bool:
		return a.production_value < b.production_value
	)
	for mat: MaterialDefinition in valid_materials:
		if remaining <= 0: break
		var available_items: int = MaterialManager.get_amount(mat)
		if available_items <= 0: continue
		var total_value: int = available_items * mat.production_value
		if total_value <= remaining:
			MaterialManager.consume(mat, available_items)
			remaining -= total_value
			consumed += total_value
		else:
			var items_needed: int = ceil(remaining / float(mat.production_value))
			var consumed_value: int = items_needed * mat.production_value
			MaterialManager.consume(mat, items_needed)
			consumed += min(remaining, consumed_value)
			remaining = 0
	return consumed
