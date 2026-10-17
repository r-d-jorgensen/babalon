extends Resource
class_name UpgradeState

@export var level: int = 0

var definition: UpgradeDefinition

func _init(upgrade: UpgradeDefinition = null) -> void:
	definition = upgrade

func get_id() -> String:
	if definition == null:
		return ""
	return definition.id

func get_max_level() -> int:
	if definition == null:
		return 0
	return definition.max_level

func is_maxed() -> bool:
	return level >= get_max_level()

func can_upgrade() -> bool:
	if is_maxed() or definition == null:
		return false
	for required_upgrade: UpgradeDefinition in definition.required_upgrades:
		if required_upgrade != null and UpgradeManager.get_level(required_upgrade.id) < definition.required_upgrades[required_upgrade]:
			return false
	for currency: Definition in definition.costs:
		if currency == null or PlayerManager.get_currency(currency.object_type) < definition.costs[currency]:
			return false
	return true
