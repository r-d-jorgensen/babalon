extends Definition
class_name WorkerDefinition

@export var base_optimal_worker_limit: int = 30
@export var consumption_time: int = 10
@export var consumption_requirements: Dictionary[TagDefinition, int] = {}
@export var worker_currency_per_tick: Dictionary[Definition, float] = {
	preload("res://resources/currencies/Culture.tres"): 0.0,
	preload("res://resources/currencies/Research.tres"): 0.0,
	preload("res://resources/currencies/Discovery.tres"): 0.0,
	preload("res://resources/currencies/Truth.tres"): 0.0,
	preload("res://resources/currencies/Favor.tres"): 0.0
}

func requires_tag(tag: int) -> bool:
	return consumption_requirements.has(tag)

func get_required_amount(tag: TagDefinition) -> int:
	return consumption_requirements.get(tag, 0)

func get_currency_per_tick(currency: Definition) -> float:
	return worker_currency_per_tick.get(currency, 0.0)
