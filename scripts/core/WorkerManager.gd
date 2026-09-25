extends Manager

signal total_workers_changed
signal workers_changed(action: ActionDefinition)

var worker_race: WorkerDefinition = preload("res://resources/workers/Human.tres")
var total_workers: int = 0
var total_optimal_worker_limit: int = 30
var total_worker_currency_per_tick: Dictionary[Definition, float] = {}
var total_worker_demand: Dictionary[TagDefinition, float] = {}
var _consumption_tick: float = 0.0
var _consumption_tick_speed: float = 1.0
var need_fulfillment: Dictionary[TagDefinition, float] = {}

func _ready() -> void:
	register_manager(EffectDefinition.System.WORKER, self)
	PlayerManager.tick.connect(_on_tick)
	formula_changed()

func formula_changed() -> void:
	total_optimal_worker_limit = floori(EffectManager.get_effect_value(
		worker_race.base_optimal_worker_limit,
		EffectManager.Formula.SET_ADD_MULTIPLY_DIVIDE,
		EffectDefinition.System.WORKER,
		EffectDefinition.Effect.CAPACITY,
		worker_race.tags
	))
	total_worker_currency_per_tick.clear()
	for currency: Definition in PlayerManager.currency_id_lookup.values():
		total_worker_currency_per_tick[currency] = EffectManager.get_effect_value(
			worker_race.get_currency_per_tick(currency),
			EffectManager.Formula.SET_ADD_MULTIPLY_DIVIDE,
			EffectDefinition.System.WORKER,
			EffectDefinition.Effect.TICK_EFFECT,
			[],
			[],
			[currency],
			[worker_race]
		)
	total_worker_demand.clear()
	for tag: TagDefinition in worker_race.consumption_requirements:
		total_worker_demand[tag] = EffectManager.get_effect_value(
			worker_race.get_required_amount(tag),
			EffectManager.Formula.SET_ADD_MULTIPLY_DIVIDE,
			EffectDefinition.System.WORKER,
			EffectDefinition.Effect.COST,
			[tag],
			[],
			[],
			[worker_race]
		)
	total_workers_changed.emit()

func _on_tick() -> void:
	for state: ActionState in ActionManager.states.values():
		state.tick()
	_consumption_tick += _consumption_tick_speed
	if _consumption_tick >= worker_race.consumption_time:
		_consumption_tick = 0
		_consume_worker_resources()
	var assigned_workers: float = float(get_total_assigned())
	var efficiency: float = get_worker_efficiency()
	for currency: Definition in total_worker_currency_per_tick:
		var currency_per_tick: float = (
			assigned_workers * efficiency *
			total_worker_currency_per_tick[currency]
		)
		if currency_per_tick > 0:
			PlayerManager.change_currency(currency.object_type, currency_per_tick)

func get_currency_per_tick(currency: Definition) -> float:
	return (
		float(get_total_assigned()) *
		total_worker_currency_per_tick.get(currency, 0.0) *
		get_worker_efficiency()
	)

func change_workers(amount: int) -> bool:
	if amount < 0:
		if get_available_workers() < -amount:
			return false
	total_workers += amount
	total_workers_changed.emit()
	return true

func get_total_assigned() -> int:
	var total: int = 0
	for state: ActionState in ActionManager.states.values():
		total += state.workers_assigned
	return total

func get_available_workers() -> int:
	return total_workers - get_total_assigned()

func assign_worker(action: ActionDefinition, amount: int = 1) -> void:
	if amount <= 0:
		return
	if get_available_workers() < amount:
		return
	var state: ActionState = ActionManager.get_state(action)
	state.workers_assigned += amount
	workers_changed.emit(action)

func unassign_worker(action: ActionDefinition, amount: int = 1) -> void:
	var state: ActionState = ActionManager.get_state(action)
	state.workers_assigned -= min(amount, state.workers_assigned)
	workers_changed.emit(action)

func get_total_demand() -> Dictionary[TagDefinition, int]:
	var total: Dictionary[TagDefinition, int] = {}
	var active_workers: int = get_total_assigned()
	for tag: TagDefinition in total_worker_demand:
		total[tag] = ceili(total_worker_demand[tag] * active_workers)
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
	if total_workers > total_optimal_worker_limit:
		capacity_efficiency = float(total_optimal_worker_limit) / float(total_workers)
	return need_efficiency * capacity_efficiency

func calculate_worker_consumption() -> Dictionary[String, int]:
	var consumption: Dictionary[String, int] = {}
	var active_workers: int = get_total_assigned()
	if active_workers <= 0:
		return consumption
	for tag: TagDefinition in total_worker_demand:
		_accumulate_tag_consumption(
			consumption,
			tag,
			ceili(total_worker_demand[tag] * active_workers)
		)
	return consumption

func _consume_worker_resources() -> void:
	need_fulfillment.clear()
	var active_workers: int = get_total_assigned()
	if active_workers <= 0:
		return
	for tag: TagDefinition in total_worker_demand:
		var total_required: int = ceili(total_worker_demand[tag] * active_workers)
		var consumed: int = _consume_tag_resources(tag, total_required)
		var fulfillment: float = 1.0
		if total_required > 0:
			fulfillment = float(consumed) / float(total_required)
		need_fulfillment[tag] = clamp(fulfillment, 0.01, 1.0)
	MaterialManager._bump()

func _accumulate_tag_consumption(consumption: Dictionary[String, int], tag: TagDefinition, amount: int) -> void:
	var remaining: int = amount
	var valid_materials: Array[MaterialDefinition] = []
	for mat: MaterialDefinition in MaterialManager.materials_list:
		if mat.has_tag(tag):
			valid_materials.append(mat)
	valid_materials.sort_custom(func(a: MaterialDefinition, b: MaterialDefinition) -> bool:
		return a.production_value < b.production_value
	)
	for mat: MaterialDefinition in valid_materials:
		if remaining <= 0:
			break
		var available_items: int = MaterialManager.get_amount(mat)
		if available_items <= 0:
			continue
		var total_value: int = available_items * mat.production_value
		if total_value <= remaining:
			consumption[mat.id] = consumption.get(mat.id, 0) + available_items
			remaining -= total_value
		else:
			var items_needed: int = ceili(remaining / float(mat.production_value))
			consumption[mat.id] = consumption.get(mat.id, 0) + items_needed
			remaining = 0

func _consume_tag_resources(tag: TagDefinition, amount: int) -> int:
	var remaining: int = amount
	var consumed: int = 0
	var valid_materials: Array[MaterialDefinition] = []
	for mat: MaterialDefinition in MaterialManager.materials_list:
		if mat.has_tag(tag):
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
			MaterialManager.change_materials(mat, -available_items)
			remaining -= total_value
			consumed += total_value
		else:
			var items_needed: int = ceil(remaining / float(mat.production_value))
			var consumed_value: int = items_needed * mat.production_value
			MaterialManager.change_materials(mat, -items_needed)
			consumed += min(remaining, consumed_value)
			remaining = 0
	return consumed
