extends RefCounted
class_name EffectState

var definition: EffectDefinition
var sources: Dictionary[String, float] = {}

func _init(effect_definition: EffectDefinition) -> void:
	definition = effect_definition

func set_source(source_id: String, amount: float) -> void:
	sources[source_id] = amount

func remove_source(source_id: String) -> void:
	sources.erase(source_id)

func get_total_value() -> float:
	var total: float = 0.0
	for amount: float in sources.values():
		total += amount
	return total
