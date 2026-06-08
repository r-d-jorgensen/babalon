extends RefCounted
class_name UpgradeState

var upgrade: UpgradeDefinition
var level: int = 0

func _init(upgrade_upgrade: UpgradeDefinition = null) -> void:
	upgrade = upgrade_upgrade

func is_purchased() -> bool:
	return level > 0

func is_maxed() -> bool:
	return upgrade == null or level >= upgrade.max_level

func can_purchase() -> bool:
	if upgrade == null:
		return false
	if is_maxed():
		return false
	for object: CountableObject in upgrade.costs:
		var cost:int = upgrade.costs[object]
		if get_countable_amount(object) < cost:
			return false
	return true

func purchase() -> bool:
	if not can_purchase():
		return false
	for object: CountableObject in upgrade.costs:
		var cost: int = upgrade.costs[object]
		if not change_countable_amount(object, -cost):
			return false
	level += 1
	for effect: UpgradeEffect in upgrade.upgrade_effects:
		effect.apply_effect()
	PlayerManager.upgrades_changed.emit()
	return true

func get_countable_amount(object: CountableObject) -> int:
	if object is MaterialDefinition:
		return MaterialManager.get_amount(object)
	if object is WorkerDefinition:
		return ActionManager.get_available_workers()
	return PlayerManager.get_currency(object.object_type)

func change_countable_amount(object: CountableObject, amount: int) -> bool:
	if object is MaterialDefinition:
		return MaterialManager.change_materials(object, amount)
	if object is WorkerDefinition:
		return ActionManager.get_available_workers()
	return PlayerManager.change_currency(object.object_type, amount)

func get_display_name() -> String:
	return upgrade.display_name if upgrade else "Unknown Upgrade"

func get_description() -> String:
	return upgrade.description if upgrade else ""
