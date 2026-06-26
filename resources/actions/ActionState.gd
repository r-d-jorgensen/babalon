extends RefCounted
class_name ActionState

var action: ActionDefinition
var workers_assigned: int = 0
var progress: float = 0.0
var total_conversion_rate: float = 0

func _init(base_action: ActionDefinition = ActionDefinition.new()) -> void:
	action = base_action
	total_conversion_rate = action.base_conversion_rate

func tick() -> void:
	if action == null or workers_assigned <= 0 or not _can_consume_inputs():
		return
	progress += workers_assigned * total_conversion_rate * WorkerManager.get_worker_efficiency()
	while progress >= action.duration:
		progress -= action.duration
		_complete_cycle()

func get_progress_ratio() -> float:
	if action == null or action.duration <= 0:
		return 0.0
	return progress / float(action.duration)

func _complete_cycle() -> void:
	if not _can_consume_inputs():
		return
	_consume_inputs()
	_produce_outputs()

func _can_consume_inputs() -> bool:
	for mat:CountableDefinition in action.inputs:
		if MaterialManager.get_amount(mat) < action.inputs[mat]:
			return false
	return true

func _consume_inputs() -> void:
	for mat:CountableDefinition in action.inputs:
		MaterialManager.change_materials(mat, -action.inputs[mat])

func _produce_outputs() -> void:
	for mat:CountableDefinition in action.outputs:
		MaterialManager.change_materials(mat, action.outputs[mat])
