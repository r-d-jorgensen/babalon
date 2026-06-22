class_name ActionStateMap
extends RefCounted

var data: Dictionary[String, ActionState] = {}

func get_state(key: String) -> ActionState:
	if not data.has(key):
		var state: ActionState = ActionState.new()
		data[key] = state
	return data[key]

func keys() -> Array:
	return data.keys()
