extends VBoxContainer

@onready var worker_label: Label = $EconomyHeader/WorkersLabel
@onready var consumption_label: Label = $EconomyHeader/ConsumptionLabel
@onready var actions_button: Button = $EconomyTabs/ActionsButton
@onready var production_button: Button = $EconomyTabs/ProductionChainsButton
@onready var materials_button: Button = $EconomyTabs/MaterialsButton
@onready var pages: TabContainer = $EconomyPages
@onready var action_list: VBoxContainer = $EconomyPages/ActionsPage/ActionList
@onready var materials_list: VBoxContainer = $EconomyPages/MaterialsPage/MaterialsList

var action_row_scene: PackedScene = preload("res://scenes/components/ActionRow.tscn")
var material_row_scene: PackedScene = preload("res://scenes/components/MaterialRow.tscn")

func _ready() -> void:
	pages.tabs_visible = false
	actions_button.pressed.connect(func()->void: select_tab(0))
	production_button.pressed.connect(func()->void: select_tab(1))
	materials_button.pressed.connect(func()->void: select_tab(2))
	build_actions_ui()
	build_materials_ui()
	update_worker_label()
	update_consumption_labels()
	MaterialManager.inventory_changed.connect(_on_worker_update)
	ActionManager.workers_changed.connect(_on_worker_update)
	ActionManager.total_workers_changed.connect(_on_worker_update)
	select_tab(0)

func select_tab(tab: int) -> void:
	pages.current_tab = tab
	actions_button.disabled = tab == 0
	production_button.disabled = tab == 1
	materials_button.disabled = tab == 2

func _on_worker_update(_action: MaterialAction = null) -> void:
	update_worker_label()
	update_consumption_labels()

func build_actions_ui() -> void:
	for child: Node in action_list.get_children():
		child.queue_free()
	for action_data: MaterialAction in ActionManager.actions:
		var row: ActionRow = action_row_scene.instantiate()
		row.node = action_data
		action_list.add_child(row)

func build_materials_ui() -> void:
	for child:Node in materials_list.get_children():
		child.queue_free()
	for mat:MaterialDefinition in MaterialManager.materials_list:
		var row: MaterialRow = material_row_scene.instantiate()
		row.mat = mat
		materials_list.add_child(row)

func update_worker_label(_action: Variant = null) -> void:
	var available: int = ActionManager.get_available_workers()
	var total: int = ActionManager.total_workers
	var optimal: int = ActionManager.optimal_worker_limit
	worker_label.text = "%s Workers: %d / %d (Optimal: %d) |" % [ActionManager.worker_race.display_name, available, total, optimal]

func update_consumption_labels() -> void:
	var supply: Dictionary[int, int] = MaterialManager.get_total_supply()
	var demand: Dictionary[int, int] = ActionManager.get_total_demand()
	var race: WorkerDefinition = ActionManager.worker_race
	var production: Dictionary[int, float] = {}
	for state: MaterialActionState in ActionManager.states.values():
		if state.workers_assigned <= 0:
			continue
		var action: MaterialAction = state.action
		for mat_obj:CountableObject in action.outputs:
			var mat: MaterialDefinition = mat_obj as MaterialDefinition
			var amount: float = (
				float(action.outputs[mat])
				* action.base_conversion_rate
				* state.workers_assigned
				* ActionManager.get_worker_efficiency()
				/ float(action.duration)
			)
			for tag: MaterialDefinition.MaterialTag in mat.tags:
				production[tag] = production.get(tag, 0.0) + (amount * mat.production_value)
	var parts: Array[String] = []
	for tag: MaterialDefinition.MaterialTag in race.consumption_requirements:
		var total_demand: int = demand.get(tag, 0)
		var consumption_per_tick: float = float(total_demand) / float(race.consumption_time)
		var production_per_tick: float = production.get(tag, 0.0)
		var net: float = production_per_tick - consumption_per_tick
		var supply_amount: int = supply.get(tag, 0)
		var sign_value: String = "+"
		if net < 0:
			sign_value = ""
		parts.append("%s %d %s%.2f/s" % [MaterialDefinition.tag_to_display(tag), supply_amount, sign_value, net])
	consumption_label.text = " | ".join(parts)
