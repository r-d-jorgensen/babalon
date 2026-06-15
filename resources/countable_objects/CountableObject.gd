extends Resource
class_name CountableObject

enum ObjectType {
	GENERAL,
	CONSUMABLE,
	CIVIC,
	TECHNOLOGY,
	EXPLORATION,
	ASCENSION
}

@export var id: String:
	set(value):
		if not id.is_empty():
			push_warning("Attempt to change immutable id")
			return
		id = value
@export var display_name: String
@export var object_type: ObjectType = ObjectType.GENERAL
