extends Resource
class_name Definition

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
@export var tags: Array[TagDefinition] = []

func has_tag(tag: TagDefinition) -> bool:
	return tag in tags

func has_any_tag(check_tags: Array[TagDefinition]) -> bool:
	for tag: TagDefinition in check_tags:
		if tag in tags:
			return true
	return false

func has_all_tags(check_tags: Array[TagDefinition]) -> bool:
	for tag: TagDefinition in check_tags:
		if tag not in tags:
			return false
	return true
