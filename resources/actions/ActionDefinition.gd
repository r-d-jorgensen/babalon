extends Definition
class_name ActionDefinition

enum ActionTag {
	SOURCE,
	SORT,
	COMBINE,
	PROCESS,
	REFINE,
	CHECK,
	FINISH
}

@export var duration: float = 2.0
@export var base_conversion_rate: float = 1.0
@export var inputs: Dictionary[Definition, int] = {}
@export var outputs: Dictionary[Definition, int] = {}

@export var is_clickable: bool = true
@export var is_workable: bool = true
