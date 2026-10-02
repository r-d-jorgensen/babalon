extends RefCounted
class_name ActionState

var action: ActionDefinition
var workers_assigned: int = 0
var progress: float = 0.0
var total_conversion_rate: float = 0.0
var total_speed: float = 1.0
var total_duration: float = 0.0
var production: Dictionary[Definition, float] = {}

func _init(base_action: ActionDefinition) -> void:
	action = base_action
	formula_changed()

func formula_changed() -> void:
	total_conversion_rate = EffectManager.get_effect_value(
		action.base_conversion_rate,
		EffectManager.Formula.SET_ADD_MULTIPLY_DIVIDE,
		EffectDefinition.System.ACTION,
		EffectDefinition.Effect.PRODUCTION,
		[],
		[action]
	)
	total_duration = EffectManager.get_effect_value(
		float(action.duration),
		EffectManager.Formula.SET_ADD_MULTIPLY_DIVIDE,
		EffectDefinition.System.ACTION,
		EffectDefinition.Effect.DURATION,
		[],
		[action]
	)
	production.clear()
	for mat: Definition in action.outputs:
		production[mat] = EffectManager.get_effect_value(
			float(action.outputs[mat]) * total_conversion_rate,
			EffectManager.Formula.SET_ADD_MULTIPLY_DIVIDE,
			EffectDefinition.System.ACTION,
			EffectDefinition.Effect.PRODUCTION,
			[],
			[action],
			[mat]
		)

func tick() -> void:
	if action == null or workers_assigned <= 0 or not _can_consume_inputs():
		return
	progress += total_speed * workers_assigned * WorkerManager.get_worker_efficiency()
	while progress >= total_duration:
		progress -= total_duration
		_complete_cycle()

func get_progress_ratio() -> float:
	if action == null or total_duration <= 0:
		return 0.0
	return progress / total_duration

func _complete_cycle() -> void:
	if not _can_consume_inputs():
		return
	_consume_inputs()
	_produce_outputs()

func _can_consume_inputs() -> bool:
	for mat: Definition in action.inputs:
		if MaterialManager.get_amount(mat) < action.inputs[mat]:
			return false
	return true

func _consume_inputs() -> void:
	for mat: Definition in action.inputs:
		MaterialManager.change_materials(mat, -action.inputs[mat])

func _produce_outputs() -> void:
	for mat: Definition in action.outputs:
		MaterialManager.change_materials(mat, floori(production[mat]))
