extends Definition
class_name MaterialDefinition

const MATERIAL_DEFAULT_ICON: Texture2D = preload("res://assets/icons/materials/default.png")

@export var build_effect_value: float = 0
@export var tick_effect_value: float = 0
@export var tick_effect_interval: int = 0
@export var production_value: int = 1
@export var priority: int = 0

func get_total_build_value() -> int:
	return ceili(build_effect_value)

func get_total_tick_value() -> float:
	return tick_effect_value

func get_default_icon() -> Texture2D:
	return MATERIAL_DEFAULT_ICON
