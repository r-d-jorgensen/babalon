extends Manager

signal actions_loaded

var actions: Array[MaterialAction] = []
var states: Dictionary[String, MaterialActionState] = {}
var actions_by_id: Dictionary[String, MaterialAction] = {}

func _ready() -> void:
	register_manager(FormulaController.ACTION, self)
	load_actions()
	formula_changed()

func formula_changed() -> void:
	return

func load_actions() -> void:
	actions.clear()
	actions_by_id.clear()
	GlobalResourceLoader.recursive_load(
		"res://resources/actions/",
		func(res: Resource, path: String) -> void:
			var action: MaterialAction = res
			if action.id.is_empty():
				push_error("Action missing id: %s" % path)
			elif actions_by_id.has(action.id):
				push_error("Duplicate action id: %s" % action.id)
			else:
				actions.append(action)
				actions_by_id[action.id] = action,
		[".tres"],
		MaterialAction
	)
	actions_loaded.emit()

func _register_action(res: Resource, path: String) -> void:
	var action: MaterialAction = res
	if action.id.is_empty():
		push_error("Action missing id: %s" % path)
	elif actions_by_id.has(action.id):
		push_error("Duplicate action id: %s" % action.id)
	else:
		actions.append(action)
		actions_by_id[action.id] = action

func get_action_by_id(id: String) -> MaterialAction:
	return actions_by_id.get(id)

func get_state(action: MaterialAction) -> MaterialActionState:
	var key: String = action.id
	if not states.has(key):
		var state: MaterialActionState = MaterialActionState.new(action)
		state.action = action
		states[key] = state
	return states[key]

func assign_worker(action: MaterialAction, amount: int = 1) -> void:
	if amount <= 0:
		return
	if WorkerManager.get_available_workers() < amount:
		return
	var state: MaterialActionState = get_state(action)
	state.workers_assigned += amount
	WorkerManager.workers_changed.emit(action)

func unassign_worker(action: MaterialAction, amount: int = 1) -> void:
	var state: MaterialActionState = get_state(action)
	state.workers_assigned -= min(amount, state.workers_assigned)
	WorkerManager.workers_changed.emit(action)
