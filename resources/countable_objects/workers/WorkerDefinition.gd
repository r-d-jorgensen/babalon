extends CountableObject
class_name WorkerDefinition

@export var worker_currency_per_tick: int = 1
@export var consumption_time: int = 10
@export var consumption_requirements: Dictionary[MaterialDefinition.MaterialTag, int] = {}

func requires_tag(tag: MaterialDefinition.MaterialTag) -> bool:
	return consumption_requirements.has(tag)

func get_required_amount(tag: MaterialDefinition.MaterialTag) -> int:
	return consumption_requirements.get(tag, 0)
