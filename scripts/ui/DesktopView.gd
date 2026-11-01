
extends HBoxContainer

enum TabSide { LEFT, RIGHT }

@onready var left_view: TabContainer = $LeftMarginContainer/LeftView
@onready var right_view: TabContainer = $RightMarginContainer/RightView

@onready var civics_label: Label = $CenterMarginContainer/CenterView/CivilizationHeaders/CivicsLabel
@onready var technology_label: Label = $CenterMarginContainer/CenterView/CivilizationHeaders/TechnologyLabel
@onready var truth_label: Label = $CenterMarginContainer/CenterView/CivilizationHeaders/TruthLabel
@onready var worker_label: Label = $CenterMarginContainer/CenterView/EconomyHeader/WorkersLabel
@onready var consumption_label: Label = $CenterMarginContainer/CenterView/EconomyHeader/ConsumptionLabel

const TABS: Array[Dictionary] = [
	{
		"name": "Actions",
		"scene": preload("res://scenes/views/ProductionView.tscn"),
		"side": TabSide.LEFT
	},
	{
		"name": "Exploration",
		"scene": preload("res://scenes/views/ExplorationView.tscn"),
		"side": TabSide.LEFT
	},
	{
		"name": "Materials",
		"scene": preload("res://scenes/views/MaterialsView.tscn"),
		"side": TabSide.RIGHT
	},
	{
		"name": "Upgrades",
		"scene": preload("res://scenes/views/UpgradesView.tscn"),
		"side": TabSide.RIGHT
	}
]

func _ready() -> void:
	populate_tabs()
	PlayerManager.currencies_changed.connect(update_civics_display)
	MaterialManager.inventory_changed.connect(_on_worker_update)
	WorkerManager.workers_changed.connect(_on_worker_update)
	WorkerManager.total_workers_changed.connect(_on_worker_update)
	update_civics_display()
	_on_worker_update()

func populate_tabs() -> void:
	add_tab("Actions", preload("res://scenes/views/ProductionView.tscn"), TabSide.LEFT, preload("res://assets/icons/ui/actions.png"))
	add_tab("Exploration", preload("res://scenes/views/ExplorationView.tscn"), TabSide.LEFT, preload("res://assets/icons/ui/exploration.png"))
	add_tab("Materials", preload("res://scenes/views/MaterialsView.tscn"), TabSide.RIGHT, preload("res://assets/icons/ui/materials.png"))
	add_tab("Upgrades", preload("res://scenes/views/UpgradesView.tscn"), TabSide.RIGHT, preload("res://assets/icons/ui/upgrades.png"))

func add_tab(tab_name: String, scene: PackedScene, side: TabSide, icon: Texture2D = null) -> void:
	var view: Control = scene.instantiate() as Control
	if view == null:
		return
	view.name = tab_name
	view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var container: TabContainer = left_view if side == TabSide.LEFT else right_view
	container.add_child(view)
	if icon != null:
		container.set_tab_icon(container.get_tab_count() - 1, icon)

func update_civics_display(_unused: Variant = null) -> void:
	civics_label.text = "Culture: %s" % PlayerManager.get_currency(Definition.ObjectType.CIVIC)
	technology_label.text = "Research: %s" % PlayerManager.get_currency(Definition.ObjectType.TECHNOLOGY)
	truth_label.text = "Truth: %s" % PlayerManager.get_currency(Definition.ObjectType.ASCENSION)

func _on_worker_update(_unused: Variant = null) -> void:
	update_worker_label()
	update_consumption_labels()

func update_worker_label() -> void:
	var available: int = WorkerManager.get_available_workers()
	var total: int = WorkerManager.total_workers
	var optimal: int = WorkerManager.total_optimal_worker_limit
	worker_label.text = "%s (%d / %d / %d) |" % [
		WorkerManager.worker_race.display_name,
		available,
		total,
		optimal
	]

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
			if mat == null:
				continue

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
