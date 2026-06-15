class_name ActionStateMap
extends RefCounted

var data: Dictionary[String, MaterialActionState] = {}

func get_state(key: String) -> MaterialActionState:
	if not data.has(key):
		var state: MaterialActionState = MaterialActionState.new()
		data[key] = state
	return data[key]

func keys() -> Array:
	return data.keys()
