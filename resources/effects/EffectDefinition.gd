extends Resource
class_name EffectDefinition

enum EffectCompound {
	FLAT,
	MULTIPLY,
	PERCENT_ADD
}

@export var id: String
@export var display_name: String
@export var default_value: float = 0.0
@export var formula_controller: Manager.FormulaController = Manager.FormulaController.ALL
@export var effect_compound: EffectCompound = EffectCompound.FLAT

func apply_effect(manager: EffectManager, effect_value: float) -> void:
	if not manager.effects.has(id):
		manager.effects[id] = default_value
	match effect_compound:
		EffectCompound.FLAT:
			manager.effects[id] += effect_value
		EffectCompound.MULTIPLY:
			manager.effects[id] *= effect_value
		EffectCompound.PERCENT_ADD:
			manager.effects[id] *= (1.0 + effect_value)
		_:
			push_warning("Unknown EffectCompound: %s" % effect_compound)
	manager.effects_changed.emit()
	Manager.notify_manager(formula_controller)
	
