extends Manager

enum Formula {
	DEFAULT,
	SET_ADD_MULTIPLY_DIVIDE,
	MULTIPLY_ADD_SUBTRACT,
}

var _rebuilding: bool = false
var effects: Dictionary[String, EffectState] = {}

func _ready() -> void:
	Manager.register_manager(EffectDefinition.System.EFFECT, self)

func formula_changed() -> void:
	if _rebuilding:
		return
	_rebuilding = true
	rebuild_all_effects()
	_rebuilding = false

func rebuild_all_effects() -> void:
	effects.clear()
	var managers: Array[Manager] = Manager.get_managers(EffectDefinition.System.UPGRADE)
	if managers.is_empty():
		return
	var upgrade_manager: UpgradeManager = managers[0] as UpgradeManager
	if upgrade_manager == null:
		return

	var affected_systems: Array[EffectDefinition.System] = []
	for state: UpgradeState in upgrade_manager.upgrades.values():
		if state.level <= 0:
			continue
		for definition: EffectDefinition in state.definition.effects:
			_add_effect(definition, state.definition.id, state.level)
			if definition.system not in affected_systems:
				affected_systems.append(definition.system)

	for system: EffectDefinition.System in affected_systems:
		if system != EffectDefinition.System.EFFECT:
			Manager.notify_manager(system)

func _add_effect(definition: EffectDefinition, source_id: String, level: int) -> void:
	var effect_id: String = _get_effect_id(definition)
	print(
		"DURATION EFFECT\n",
		"  id: ", effect_id, "\n",
		"  system: ", EffectDefinition.System.keys()[definition.system], "\n",
		"  effect: ", EffectDefinition.Effect.keys()[definition.effect], "\n",
		"  operation: ", EffectDefinition.Operation.keys()[definition.operation], "\n",
		"  amount: ", definition.amount, "\n",
		"  source: ", source_id, "\n",
		"  level: ", level, "\n",
		"  tags: ", definition.tags, "\n",
		"  actions: ", definition.actions, "\n",
		"  currencies: ", definition.currencies, "\n",
		"  workers: ", definition.workers
	)
	var state: EffectState = effects.get(effect_id)
	if state == null:
		state = EffectState.new(definition)
		effects[effect_id] = state
	state.set_source(source_id, definition.amount * level)

func _get_effect_id(definition: EffectDefinition) -> String:
	var tag_ids: Array[String] = []
	for tag: TagDefinition in definition.tags:
		tag_ids.append(tag.id)
	tag_ids.sort()
	return "%s:%s:%s" % [
		EffectDefinition.System.keys()[definition.system],
		EffectDefinition.Effect.keys()[definition.effect],
		",".join(tag_ids)
	]

func get_effect_value(
	base_value: float,
	formula: Formula,
	system: EffectDefinition.System,
	effect: EffectDefinition.Effect,
	tags: Array[TagDefinition] = [],
	actions: Array[ActionDefinition] = [],
	currencies: Array[Definition] = [],
	workers: Array[WorkerDefinition] = []
) -> float:
	var effect_values: Dictionary = _get_effect_values(
		system,
		effect,
		tags,
		actions,
		currencies,
		workers
	)
	match formula:
		Formula.DEFAULT:
			return _formula_default(base_value, effect_values)
		Formula.SET_ADD_MULTIPLY_DIVIDE:
			return _formula_set_add_multiply_divide(base_value, effect_values)
		Formula.MULTIPLY_ADD_SUBTRACT:
			return _formula_multiply_add_subtract(base_value, effect_values)
	return base_value

func _get_effect_values(
	system: EffectDefinition.System,
	effect: EffectDefinition.Effect,
	tags: Array[TagDefinition],
	actions: Array[ActionDefinition],
	currencies: Array[Definition],
	workers: Array[WorkerDefinition]
) -> Dictionary:
	var values: Dictionary = {
		EffectDefinition.Operation.ADD: 0.0,
		EffectDefinition.Operation.SUBTRACT: 0.0,
		EffectDefinition.Operation.MULTIPLY: 1.0,
		EffectDefinition.Operation.DIVIDE: 1.0,
		EffectDefinition.Operation.SET: null
	}
	for state: EffectState in effects.values():
		var definition: EffectDefinition = state.definition
		if definition.system != system or definition.effect != effect:
			continue
		if not (
			(definition.tags.is_empty() and definition.actions.is_empty() and definition.currencies.is_empty() and definition.workers.is_empty())
			or (not definition.tags.is_empty() and definition.tags.any(func(tag: TagDefinition) -> bool: return tag in tags))
			or (not definition.actions.is_empty() and definition.actions.any(func(action: ActionDefinition) -> bool: return action in actions))
			or (not definition.currencies.is_empty() and definition.currencies.any(func(currency: Definition) -> bool: return currency in currencies))
			or (not definition.workers.is_empty() and definition.workers.any(func(worker: WorkerDefinition) -> bool: return worker in workers))
		):
			continue

		var value: float = state.get_total_value()
		match definition.operation:
			EffectDefinition.Operation.SET:
				values[EffectDefinition.Operation.SET] = value
			EffectDefinition.Operation.ADD:
				values[EffectDefinition.Operation.ADD] += value
			EffectDefinition.Operation.SUBTRACT:
				values[EffectDefinition.Operation.SUBTRACT] += value
			EffectDefinition.Operation.MULTIPLY:
				values[EffectDefinition.Operation.MULTIPLY] *= value
			EffectDefinition.Operation.DIVIDE:
				values[EffectDefinition.Operation.DIVIDE] *= value
	return values

func _formula_default(base: float, effect_values: Dictionary) -> float:
	var operation: Dictionary = EffectDefinition.Operation
	var value: float = base
	value += effect_values[operation.ADD]
	value -= effect_values[operation.SUBTRACT]
	value *= effect_values[operation.MULTIPLY]
	if effect_values[operation.DIVIDE] != 1.0:
		value /= effect_values[operation.DIVIDE]
	if effect_values[operation.SET] != null:
		value = effect_values[operation.SET]
	return value

func _formula_set_add_multiply_divide(base: float, effect_values: Dictionary) -> float:
	var operation: Dictionary = EffectDefinition.Operation
	var value: float = base
	if effect_values[operation.SET] != null:
		value = effect_values[operation.SET]
	value += effect_values[operation.ADD]
	value -= effect_values[operation.SUBTRACT]
	value *= effect_values[operation.MULTIPLY]
	if effect_values[operation.DIVIDE] != 1.0:
		value /= effect_values[operation.DIVIDE]
	return value

func _formula_multiply_add_subtract(base: float, effect_values: Dictionary) -> float:
	var operation: Dictionary = EffectDefinition.Operation
	var value: float = base
	value *= effect_values[operation.MULTIPLY]
	if effect_values[operation.DIVIDE] != 1.0:
		value /= effect_values[operation.DIVIDE]
	value += effect_values[operation.ADD]
	value -= effect_values[operation.SUBTRACT]
	if effect_values[operation.SET] != null:
		value = effect_values[operation.SET]
	return value
