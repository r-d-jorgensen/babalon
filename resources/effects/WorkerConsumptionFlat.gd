extends EffectDefinition
class_name WorkerConsumptionFlat

func apply_effect(manager: EffectManager, effect_value: float) -> void:
	manager.effects[self.id] += effect_value
	WorkerManager.effects_changed.emit()
