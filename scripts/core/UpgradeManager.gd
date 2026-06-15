extends EffectManager

signal upgrades_changed

var upgrades: Dictionary[String, UpgradeState] = {}
var upgrade_lookup: Dictionary[String, UpgradeDefinition] = {}

func _ready() -> void:
	load_effects()
	load_upgrades()

func get_upgrade(id: String) -> UpgradeState:
	return upgrades.get(id)

func get_upgrade_level(id: String) -> int:
	var upgrade: UpgradeState = upgrades.get(id)
	return upgrade.level if upgrade else 0

func has_upgrade(id: String) -> bool:
	return get_upgrade_level(id) > 0

func load_upgrades() -> void:
	upgrades.clear()
	upgrade_lookup.clear()
	GlobalResourceLoader.recursive_load(
		"res://resources/upgrades/",
		func(res: Resource, path: String) -> void:
			var upgrade: UpgradeDefinition = res
			if upgrade.id.is_empty():
				push_error("Upgrade missing id: %s" % path)
			elif upgrade_lookup.has(upgrade.id):
				push_error("Duplicate upgrade id: %s" % upgrade.id)
			else:
				upgrades[upgrade.id] = UpgradeState.new(upgrade)
				upgrade_lookup[upgrade.id] = upgrade,
		[".tres"],
		UpgradeDefinition
	)
	upgrades_changed.emit()
