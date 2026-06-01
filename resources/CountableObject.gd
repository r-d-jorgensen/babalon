extends Resource
class_name CountableObject

enum ObjectType {
	GENERAL,
	CONSUMABLE,
	CIVIC,
	TECHNOLOGY,
	EXPLORATION,
	ASCENSION,
	PREMIUM
}

@export var id: String
@export var display_name: String
@export var object_type: ObjectType = ObjectType.GENERAL
