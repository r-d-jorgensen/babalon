@abstract
extends Node
class_name Manager

static var manager_lookup: Dictionary[EffectDefinition.System, Manager] = {}

enum TopLevelVariable {
	NA,
	TICK_RATE,
	CONSUMPTION_TICK_SPEED
}

@abstract
func formula_changed() -> void

static func register_manager(controller: EffectDefinition.System, manager: Manager) -> void:
	assert(not manager_lookup.has(controller), "Manager already registered for controller %s" % controller)
	manager_lookup[controller] = manager

static func get_managers(controller: EffectDefinition.System) -> Array[Manager]:
	if controller == EffectDefinition.System.GLOBAL:
		return manager_lookup.values()
	var manager: Manager = manager_lookup.get(controller)
	if manager == null:
		return []
	return [manager]

static func notify_manager(controller: EffectDefinition.System) -> void:
	if controller == EffectDefinition.System.GLOBAL:
		for manager: Manager in manager_lookup.values():
			manager.formula_changed()
		return
	var manager: Manager = manager_lookup.get(controller)
	if manager:
		manager.formula_changed()
