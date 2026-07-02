extends Definition
class_name WorkerDefinition

@export var base_optimal_worker_limit: int = 30
@export var worker_currency_per_tick: int = 1
@export var consumption_time: int = 10
@export var consumption_requirements: Dictionary[TagDefinition, int] = {}

func requires_tag(tag: int) -> bool:
	return consumption_requirements.has(tag)

func get_required_amount(tag: TagDefinition) -> int:
	return consumption_requirements.get(tag, 0)
