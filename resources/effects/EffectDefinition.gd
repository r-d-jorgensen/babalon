@abstract
extends Resource
class_name EffectDefinition

@export var id: String
@export var display_name: String
@export var default_value: float = 0.0

@abstract
func apply_effect(manager: EffectManager, effect_value: float) -> void
