@abstract
extends Node
class_name Manager

enum FormulaController {
	ALL,
	ACTION,
	WORKER,
	MATERIAL,
	PLAYER,
	UPGRADE
}
static var manager_lookup: Dictionary[FormulaController, Manager] = {}

@abstract
func formula_changed() -> void

static func register_manager(controller: FormulaController, manager: Manager) -> void:
	assert(not manager_lookup.has(controller), "Manager already registered for controller %s" % controller)
	manager_lookup[controller] = manager

static func get_managers(controller: FormulaController) -> Array[Manager]:
	if controller == FormulaController.ALL:
		return manager_lookup.values()
	var manager: Manager = manager_lookup.get(controller)
	if manager == null:
		return []
	return [manager]

static func notify_manager(controller: FormulaController) -> void:
	if controller == FormulaController.ALL:
		for manager: Manager in manager_lookup.values():
			manager.formula_changed()
		return
	var manager: Manager = manager_lookup.get(controller)
	if manager:
		manager.formula_changed()
