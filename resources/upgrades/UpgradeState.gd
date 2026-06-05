extends RefCounted
class_name UpgradeState

var definition: UpgradeDefinition
var level: int = 0

func _init(upgrade_definition: UpgradeDefinition = null) -> void:
	definition = upgrade_definition

func is_purchased() -> bool:
	return level > 0

func is_maxed() -> bool:
	return definition == null or level >= definition.max_level

func can_purchase() -> bool:
	if definition == null:
		return false
	if is_maxed():
		return false
	# TODO - Multiple cost types
	for currency: CountableObject in definition.costs:
		var cost: int = definition.costs[currency]
		if PlayerManager.get_currency(currency.object_type) < cost:
			return false
	return true

func purchase() -> bool:
	if not can_purchase():
		return false
	# TODO - Multiple cost types
	for currency: CountableObject in definition.costs:
		var cost: int = definition.costs[currency]
		if not PlayerManager.change_currency(currency.object_type, -cost):
			return false
	level += 1
	# TODO - Apply Effects
	PlayerManager.upgrades_changed.emit()
	return true

func get_display_name() -> String:
	return definition.display_name if definition else "Unknown Upgrade"

func get_description() -> String:
	return definition.description if definition else ""
