extends Definition
class_name UpgradeDefinition

const UPGRADE_DEFAULT_ICON: Texture2D = preload("res://assets/icons/upgrades/default.png")
enum UpgradeSource {
	GAMEPLAY,
	PREMIUM,
	REWARD,
	DEBUG
}

@export_multiline var description: String
@export var upgrade_source: UpgradeSource = UpgradeSource.GAMEPLAY

@export var hidden: bool = false
@export var costs: Dictionary[Definition, int] = {}
@export var required_upgrades: Dictionary[UpgradeDefinition, int] = {}

@export var max_level: int = 1
@export var cost_growth: float = 5.0
@export var effects: Array[EffectDefinition] = []

func get_default_icon() -> Texture2D:
	return UPGRADE_DEFAULT_ICON
