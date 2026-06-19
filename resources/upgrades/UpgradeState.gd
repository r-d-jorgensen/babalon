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

func can_purchase(levels: int = 1) -> bool:
	if upgrade == null:
		return false
	if is_maxed():
		return false
	for required_upgrade: UpgradeDefinition in upgrade.required_upgrades:
		var required_level: int = upgrade.required_upgrades[required_upgrade]
		var state: UpgradeState = UpgradeManager.get_upgrade(required_upgrade.id)
		if state == null or state.level < required_level:
			return false
	for object: CountableObject in upgrade.costs:
		var cost:int = upgrade.costs[object]
		if get_countable_amount(object) < cost * levels: # TODO costs should scale
			return false
	return true

func purchase(levels: int = 1) -> bool:
	if not can_purchase(levels):
		return false
	for object: CountableObject in upgrade.costs:
		if not change_countable_amount(object, -upgrade.costs[object] * levels): # TODO costs should scale
			push_error("Failed to consume cost for upgrade: %s" % upgrade.id)
			return false
	level += levels
	for effect: EffectDefinition in upgrade.upgrade_effects:
		effect.apply_effect(UpgradeManager, upgrade.upgrade_effects[effect], levels)
	UpgradeManager.upgrades_changed.emit()
	return true

func get_countable_amount(object: CountableObject) -> int:
	if object is MaterialDefinition:
		return MaterialManager.get_amount(object)
	if object is WorkerDefinition:
		return WorkerManager.get_available_workers()
	return PlayerManager.get_currency(object.object_type)

func change_countable_amount(object: CountableObject, amount: int) -> bool:
	if object is MaterialDefinition:
		return MaterialManager.change_materials(object, amount)
	if object is WorkerDefinition:
		return true
	return PlayerManager.change_currency(object.object_type, amount)

func get_display_name() -> String:
	return upgrade.display_name if upgrade else "Unknown Upgrade"

func get_description() -> String:
	return upgrade.description if upgrade else ""
