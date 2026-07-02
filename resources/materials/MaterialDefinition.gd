extends Definition
class_name MaterialDefinition

@export var build_effect_value: float = 0
@export var tick_effect_value: float = 0
@export var tick_effect_interval: int = 0
@export var tags: Array[TagDefinition] = []
@export var production_value: int = 1
@export var priority: int = 0

func get_total_build_value() -> int:
	return ceili(build_effect_value)

func get_total_tick_value() -> float:
	return tick_effect_value

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
