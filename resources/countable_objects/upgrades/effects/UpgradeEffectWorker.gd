extends UpgradeEffect

var worker_race: WorkerDefinition
var increase_population_limit: int = 1
var lower_consumption_requirements_flat: Dictionary[CountableObject, int]
var lower_consumption_requirements_percent: Dictionary[CountableObject, int]

func apply_effect() -> void:
	return
