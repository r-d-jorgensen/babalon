extends RefCounted
class_name EffectState

var definition: EffectDefinition
var sources: Dictionary[String, float] = {}
var source_definitions: Dictionary[String, EffectDefinition] = {}

func _init(effect_definition: EffectDefinition) -> void:
	definition = effect_definition

func set_source(source_id: String, amount: float, source_definition: EffectDefinition) -> void:
	sources[source_id] = amount
	source_definitions[source_id] = source_definition

func remove_source(source_id: String) -> void:
	sources.erase(source_id)
	source_definitions.erase(source_id)

func get_source_value(source_id: String) -> float:
	return sources.get(source_id, 0.0)
