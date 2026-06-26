extends Resource
class_name Definition

@export var id: String:
	set(value):
		if not id.is_empty():
			push_warning("Attempt to change immutable id")
			return
		id = value
@export var display_name: String
