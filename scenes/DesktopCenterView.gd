extends VBoxContainer

@onready var civics_label: Label = $CivilizationHeaders/CivicsLabel
@onready var technology_label: Label = $CivilizationHeaders/TechnologyLabel
@onready var truth_label: Label = $CivilizationHeaders/TruthLabel
@onready var worker_label: Label = $EconomyHeader/WorkersLabel
@onready var consumption_label: Label = $EconomyHeader/ConsumptionLabel

func _ready() -> void:
	update_civics_display()
	update_worker_label()
	update_consumption_labels()
	PlayerManager.currencies_changed.connect(update_civics_display)
	MaterialManager.inventory_changed.connect(_on_worker_update)
	WorkerManager.workers_changed.connect(_on_worker_update)
	WorkerManager.total_workers_changed.connect(_on_worker_update)

func update_civics_display(_unused: Variant = null) -> void:
	civics_label.text = "Culture: %s" % PlayerManager.get_currency(Definition.ObjectType.CIVIC)
	technology_label.text = "Research: %s" % PlayerManager.get_currency(Definition.ObjectType.TECHNOLOGY)
	truth_label.text = "Truth: %s" % PlayerManager.get_currency(Definition.ObjectType.ASCENSION)

func _on_worker_update(_action: ActionDefinition = null) -> void:
	update_worker_label()
	update_consumption_labels()

func update_worker_label(_action: Variant = null) -> void:
	var available: int = WorkerManager.get_available_workers()
	var total: int = WorkerManager.total_workers
	var optimal: int = WorkerManager.total_optimal_worker_limit
	worker_label.text = "%ss %d / %d / %d) |" % [WorkerManager.worker_race.display_name, available, total, optimal]

func update_consumption_labels() -> void:
	var supply: Dictionary[TagDefinition, int] = MaterialManager.get_total_supply()
	var demand: Dictionary[TagDefinition, int] = WorkerManager.get_total_demand()
	var race: WorkerDefinition = WorkerManager.worker_race
	var production: Dictionary[TagDefinition, float] = {}
	for state: ActionState in ActionManager.states.values():
		if state.workers_assigned <= 0:
			continue
		var action: ActionDefinition = state.action
		for mat_obj: Definition in action.outputs:
			var mat: MaterialDefinition = mat_obj as MaterialDefinition
			var amount: float = (
				float(action.outputs[mat])
				* action.base_conversion_rate
				* state.workers_assigned
				* WorkerManager.get_worker_efficiency()
				/ float(action.duration)
			)
			for tag: TagDefinition in mat.tags:
				production[tag] = production.get(tag, 0.0) + amount * mat.production_value

	var lowest_ticks: int = -1
	for tag: TagDefinition in race.consumption_requirements:
		var total_demand: int = demand.get(tag, 0)
		var consumption_per_tick: float = float(total_demand) / float(race.consumption_time)
		var production_per_tick: float = production.get(tag, 0.0)
		var net: float = production_per_tick - consumption_per_tick
		if net >= 0.0:
			continue
		var supply_amount: int = supply.get(tag, 0)
		var ticks: int = ceili(float(supply_amount) / -net)
		if lowest_ticks < 0 or ticks < lowest_ticks:
			lowest_ticks = ticks
	consumption_label.text = str(lowest_ticks) if lowest_ticks >= 0 else "∞"
