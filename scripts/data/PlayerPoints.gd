class_name PlayerPoints
extends RefCounted

var data: Dictionary[CountableObject.ObjectType, int] = {}

func add(type: CountableObject.ObjectType, amount: int) -> void:
	data[type] = data.get(type, 0) + amount

func get_value(type: CountableObject.ObjectType) -> int:
	return data.get(type, 0)

func keys() -> Array:
	return data.keys()
