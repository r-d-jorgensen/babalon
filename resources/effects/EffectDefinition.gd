extends Resource
class_name EffectDefinition

enum EffectCompound {
	BOOL,
	FLAT,
	MULTIPLY,
	PERCENT_ADD
}

@export var id: String
@export var display_name: String
@export var default_value: float = 0.0
@export var formula_controller: Manager.FormulaController = Manager.FormulaController.ALL

func apply_effect(manager: EffectManager, effect_value: float, effect_compound: EffectCompound, level_increase: int, notify: bool = true) -> void:
	if not manager.effects.has(id):
		push_warning("Effect not loaded correctly: %s" % id)
		return
	match effect_compound:
		EffectCompound.BOOL:
			manager.effects[id] = effect_value
		EffectCompound.FLAT:
			manager.effects[id] += effect_value * level_increase
		EffectCompound.MULTIPLY:
			manager.effects[id] *= pow(effect_value, level_increase)
		EffectCompound.PERCENT_ADD:
			manager.effects[id] *= pow((1.0 + effect_value), level_increase)
		_:
			push_warning("Unknown EffectCompound: %s" % effect_compound)
	if notify:
		Manager.notify_manager(formula_controller)
	
