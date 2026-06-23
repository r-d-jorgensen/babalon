@abstract
extends Manager
class_name EffectManager

var effects: Dictionary[String, float] = {}
var effects_lookup: Dictionary[String, EffectDefinition] = {}
#var worker_effects: Dictionary[WorkerDefinition, String] = {}
#var action_effects: Dictionary[ActionDefinition, String] = {}

func get_effect_value(id: String) -> Variant:
	return effects.get(id)

func load_effects() -> void:
	effects.clear()
	effects_lookup.clear()
	GlobalResourceLoader.recursive_load(
		"res://resources/effects/",
		func(res: Resource, path: String) -> void:
			var effect: EffectDefinition = res
			if effect.id.is_empty():
				push_error("Effect missing id: %s" % path)
			else:
				effects_lookup[effect.id] = effect
				effects[effect.id] = effect.default_value,
		[".tres"],
		EffectDefinition
	)
