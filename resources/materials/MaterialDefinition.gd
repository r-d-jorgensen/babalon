extends Definition
class_name MaterialDefinition

@export var build_effect_value: float = 0
@export var tick_effect_value: float = 0
@export var tick_effect_interval: int = 0
@export var production_value: int = 1
@export var priority: int = 0

func get_total_build_value() -> int:
	return ceili(build_effect_value)

func get_total_tick_value() -> float:
	return tick_effect_value
