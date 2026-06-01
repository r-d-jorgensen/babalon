extends RefCounted
class_name UpgradeState

var definition: UpgradeDefinition
var level: int = 0

func is_purchased() -> bool:
	return level > 0

func is_maxed() -> bool:
	return definition == null or level >= definition.max_level

func can_purchase() -> bool:
	if definition == null:
		return false
	if is_maxed():
		return false
	return true

func purchase() -> bool:
	if not can_purchase():
		return false
	for currency: CountableObject in definition.costs:
		var cost: int = definition.costs[currency]
		if not PlayerManager.change_currency(currency.object_type, -cost):
			return false
	level += 1
	PlayerManager.player_click_power += definition.click_power_bonus
	PlayerManager.currencies_changed.emit()
	return true

func get_display_name() -> String:
	return definition.display_name if definition else "Unknown Upgrade"

func get_description() -> String:
	return definition.description if definition else ""
