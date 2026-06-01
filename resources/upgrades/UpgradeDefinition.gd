extends Resource
class_name UpgradeDefinition

enum UpgradeCategory {
	CULTURE,
	TECHNOLOGY,
	DISCOVERY,
	ASCENSION,
	ACHIEVEMENT,
	MONETIZATION
}

enum UpgradeSource {
	GAMEPLAY,
	PREMIUM,
	REWARD,
	DEBUG
}

@export var id: String
@export var display_name: String
@export_multiline var description: String

@export var category: UpgradeCategory
@export var upgrade_source: UpgradeSource

@export var costs: Dictionary[CountableObject, int] = {} # Cost: CountableObject -> amount
@export var required_upgrades: Dictionary[UpgradeDefinition, int] = {} # Requirements: UpgradeDefinition -> required level

@export var max_level: int = 1

@export var click_power_bonus: int = 0
@export var global_production_multiplier: float = 1.0
@export var worker_capacity_bonus: int = 0
