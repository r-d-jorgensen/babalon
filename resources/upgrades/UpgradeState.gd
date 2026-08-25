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
	return level < get_max_level()
