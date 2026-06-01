class_name MaterialMap
extends RefCounted

var data: Dictionary[String, int] = {}

func set_value(key: String, value: int) -> void:
	data[key] = value

func get_value(key: String) -> int:
	return data.get(key, 0)

func add(key: String, amount: int) -> void:
	data[key] = data.get(key, 0) + amount

func has(key: String) -> bool:
	return data.has(key)

func keys() -> Array:
	return data.keys()
