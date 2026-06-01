extends RefCounted
class_name MaterialActionState

var action: MaterialAction
var workers_assigned: int = 0
var progress: float = 0.0


func tick() -> void:
	if action == null or workers_assigned <= 0 or not _can_consume_inputs():
		return
	progress += workers_assigned * action.base_conversion_rate * ActionManager.get_worker_efficiency()
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
	for mat:CountableObject in action.inputs:
		if MaterialManager.get_amount(mat) < action.inputs[mat]:
			return false
	return true

func _consume_inputs() -> void:
	for mat:CountableObject in action.inputs:
		MaterialManager.consume(mat, action.inputs[mat])

func _produce_outputs() -> void:
	for mat:CountableObject in action.outputs:
		MaterialManager.add(mat, action.outputs[mat])
