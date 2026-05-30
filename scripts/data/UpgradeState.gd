extends RefCounted
class_name UpgradeState

var definition: UpgradeDefinition
var level: int = 0

func is_purchased() -> bool:
	return level > 0

func is_maxed() -> bool:
	if definition == null:
		return true
	return level >= definition.max_level

func can_level_up() -> bool:
	if definition == null:
		return false
	return level < definition.max_level

func get_costs() -> Dictionary[CountableObject, int]:
	if definition == null:
		return {}
	return definition.costs

func get_required_upgrades() -> Dictionary[UpgradeDefinition, int]:
	if definition == null:
		return {}
	return definition.required_upgrades

func get_display_name() -> String:
	if definition == null:
		return "Unknown Upgrade"
	return definition.display_name

func get_description() -> String:
	if definition == null:
		return ""
	return definition.description
