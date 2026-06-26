extends Definition
class_name CountableDefinition

enum ObjectType {
	GENERAL,
	CONSUMABLE,
	CIVIC,
	TECHNOLOGY,
	EXPLORATION,
	ASCENSION
}

@export var object_type: ObjectType = ObjectType.GENERAL
