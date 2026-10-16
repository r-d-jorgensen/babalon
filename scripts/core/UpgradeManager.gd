extends Manager

signal upgrades_changed

var upgrades: Dictionary[String, UpgradeState] = {}
var upgrade_lookup: Dictionary[String, UpgradeDefinition] = {}

func _ready() -> void:
	Manager.register_manager(EffectDefinition.System.UPGRADE, self)
	load_upgrades()

func load_upgrades() -> void:
	upgrades.clear()
	upgrade_lookup.clear()
	GlobalResourceLoader.recursive_load(
		"res://resources/upgrades/",
		func(res: Resource, path: String) -> void:
			var upgrade: UpgradeDefinition = res
			if upgrade.id.is_empty():
				push_error("Upgrade missing id: %s" % path)
				return
			if upgrade_lookup.has(upgrade.id):
				push_error("Duplicate upgrade id '%s': %s" % [upgrade.id, path])
				return
			upgrade_lookup[upgrade.id] = upgrade
			upgrades[upgrade.id] = UpgradeState.new(upgrade),
		[".tres"],
		UpgradeDefinition)
	upgrades_changed.emit()
	Manager.notify_manager(EffectDefinition.System.EFFECT)

func formula_changed() -> void:
	Manager.notify_manager(EffectDefinition.System.EFFECT)

func get_upgrade(upgrade_id: String) -> UpgradeDefinition:
	return upgrade_lookup.get(upgrade_id)

func get_upgrade_state(upgrade_id: String) -> UpgradeState:
	return upgrades.get(upgrade_id)

func get_level(upgrade_id: String) -> int:
	var state: UpgradeState = get_upgrade_state(upgrade_id)
	if state == null:
		return 0
	return state.level

func purchase(upgrade_id: String) -> bool:
	var state: UpgradeState = upgrades.get(upgrade_id)
	if state == null or state.definition == null or not state.can_upgrade():
		return false
	for required_upgrade: UpgradeDefinition in state.definition.required_upgrades:
		if get_level(required_upgrade.id) < state.definition.required_upgrades[required_upgrade]:
			return false
	for currency: Definition in state.definition.costs:
		if PlayerManager.get_currency(currency.object_type) < state.definition.costs[currency]:
			return false
	for currency: Definition in state.definition.costs:
		PlayerManager.change_currency(currency.object_type, -state.definition.costs[currency])
	state.level += 1
	upgrades_changed.emit()
	Manager.notify_manager(EffectDefinition.System.EFFECT)
	return true
