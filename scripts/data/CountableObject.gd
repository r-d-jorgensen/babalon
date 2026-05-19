extends Resource
class_name CountableObject

enum ObjectType {
	GENERAL,
	CONSUMABLE,
	CULTURE,
	TECHNOLOGY,
	DISCOVERY,
	ASCENSION
}

@export var display_name: String
@export var object_type: ObjectType = ObjectType.GENERAL
