extends EffectDefinition
class_name WorkerConsumptionPercent

func apply_effect(manager: EffectManager, effect_value: float) -> void:
	manager.effects[self.id] += effect_value
	WorkerManager.effects_changed.emit()
