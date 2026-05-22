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
@export var upgrade_source: UpgradeSource = UpgradeSource.GAMEPLAY
@export var max_level: int = 1
@export var infinite_levels: bool = false
@export var auto_unlock: bool = false
@export var hidden_by_default: bool = true
@export var hidden_until_completed: bool = false

@export var requirements: Array[UpgradeRequirement]
@export var costs: Array[UpgradeCost]
@export var effects: Array[UpgradeEffect]
