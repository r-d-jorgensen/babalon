extends CountableObject
class_name MaterialDefinition

enum MaterialTag {
	WRITING,
	LIQUID,
	WATER,
	CHEMICAL,
	ALCOHOL,
	ORGANIC_FOOD,
	GRAIN,
	FUNGUS,
	FRUIT,
	MEAT,
	SEAFOOD,
	MINERAL,
	METAL,
	INGOT,
	GEM,
	WEAPON,
	TOOL
}

enum CraftingStage {
	SOURCE,
	SORT,
	COMBINE,
	PROCESS,
	REFINE,
	CHECK,
	FINISH
}

@export var craft_stage: CraftingStage = CraftingStage.SOURCE
@export var build_effect_value: float = 0
@export var tick_effect_value: float = 0
@export var tick_effect_interval: int = 0
@export var tags: Array[MaterialTag] = []
@export var production_value: int = 1
@export var priority: int = 0

func get_total_build_value() -> int:
	return ceili(build_effect_value)

func get_total_tick_value() -> float:
	return tick_effect_value

func has_tag(tag: MaterialTag) -> bool:
	return tag in tags

func has_any_tag(check_tags: Array[MaterialTag]) -> bool:
	for tag: MaterialTag in check_tags:
		if tag in tags:
			return true
	return false

func has_all_tags(check_tags: Array[MaterialTag]) -> bool:
	for tag: MaterialTag in check_tags:
		if tag not in tags:
			return false
	return true

static func tag_to_display(tag: int) -> String:
	match tag:
		MaterialTag.WATER:
			return "Drinkable Water"
		MaterialTag.ORGANIC_FOOD:
			return "Organic Food"
		_:
			var name: String = MaterialTag.keys()[tag]
			return name.capitalize()
