class_name ActionStateMap
extends RefCounted

var data: Dictionary[String, ActionState] = {}

func get_state(key: String) -> ActionState:
	if not data.has(key):
		push_error("No action id: %s" % key)
	return data[key]

func keys() -> Array:
	return data.keys()
