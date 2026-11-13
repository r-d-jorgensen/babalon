extends VBoxContainer
class_name ActionRow

@export var node: ActionDefinition

@onready var action_icon: TextureRect = $Header/ActionIcon
@onready var action_name: Label = $Header/ActionName
@onready var progress_bar: ProgressBar = $Header/ProgressBar
@onready var collapsed_outputs: HBoxContainer = $Header/CollapsedOutputs
@onready var minimize_button: Button = $Header/MinimizeButton
@onready var content: VBoxContainer = $Content
@onready var inputs_list: VBoxContainer = $Content/Materials/InputsList
@onready var outputs_list: VBoxContainer = $Content/Materials/OutputsList
@onready var click_button: Button = $Content/ProductionControls/ClickButton
@onready var remove_worker_button: Button = $Content/ProductionControls/WorkerControls/WorkerButtons/RemoveWorkerButton
@onready var worker_count: Label = $Content/ProductionControls/WorkerControls/WorkerButtons/WorkerCount
@onready var add_worker_button: Button = $Content/ProductionControls/WorkerControls/WorkerButtons/AddWorkerButton

var minimized: bool = false

func _ready() -> void:
	if node == null: return
	click_button.pressed.connect(_on_action_pressed)
	remove_worker_button.pressed.connect(_on_minus_pressed)
	add_worker_button.pressed.connect(_on_plus_pressed)
	minimize_button.pressed.connect(_on_minimize_pressed)
	WorkerManager.workers_changed.connect(_on_workers_changed)
	PlayerManager.tick.connect(update_ui)
	MaterialManager.inventory_changed.connect(update_ui)
	action_icon.texture = node.get_icon()
	action_name.text = node.display_name
	update_ui()

func update_ui() -> void:
	if node == null: return
	var state: ActionState = ActionManager.get_state(node)
	update_progress(state)
	update_material_lists(state)
	update_collapsed_outputs(state)
	update_workers(state)
	click_button.disabled = not can_run()

func update_progress(state: ActionState) -> void:
	progress_bar.min_value = 0
	progress_bar.max_value = 100
	if state.total_duration > 0:
		progress_bar.value = (state.progress / state.total_duration) * 100.0
	else:
		progress_bar.value = 0

func update_workers(state: ActionState) -> void:
	worker_count.text = str(state.workers_assigned)

func get_cycles_per_tick(state: ActionState) -> float:
	if state.workers_assigned <= 0 or state.total_duration <= 0: return 0.0
	return state.workers_assigned * WorkerManager.get_worker_efficiency() / state.total_duration

func update_material_lists(state: ActionState) -> void:
	var cycles_per_tick: float = get_cycles_per_tick(state)
	build_material_list(inputs_list, state.cost, cycles_per_tick, true)
	build_material_list(outputs_list, state.production, cycles_per_tick, false)

func build_material_list(container: VBoxContainer, materials: Dictionary, cycles_per_tick: float, is_input: bool) -> void:
	for child: Node in container.get_children(): child.queue_free()
	for mat: Definition in materials:
		var amount: float = materials[mat]
		var automated: float = amount * cycles_per_tick
		var entry:HBoxContainer = HBoxContainer.new()
		entry.add_theme_constant_override("separation", 4)
		var icon:TextureRect = TextureRect.new()
		icon.texture = mat.get_icon()
		icon.custom_minimum_size = Vector2(16, 16)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		entry.add_child(icon)
		var name_label:Label = Label.new()
		name_label.text = mat.display_name
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		entry.add_child(name_label)
		var amount_label:Label = Label.new()
		amount_label.text = ("x%s / x%s/t" if is_input else "+%s / +%s/t") % [format_number(amount), format_number(automated)]
		entry.add_child(amount_label)
		container.add_child(entry)

func update_collapsed_outputs(state: ActionState) -> void:
	for child: Node in collapsed_outputs.get_children(): child.queue_free()
	var cycles_per_tick: float = get_cycles_per_tick(state)
	var count: int = 0
	for mat: Definition in state.production:
		if count >= 4: break
		var entry:HBoxContainer = HBoxContainer.new()
		entry.add_theme_constant_override("separation", 2)
		var icon:TextureRect = TextureRect.new()
		icon.texture = mat.get_icon()
		icon.custom_minimum_size = Vector2(16, 16)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		entry.add_child(icon)
		var amount_label:Label = Label.new()
		amount_label.text = format_number(state.production[mat] * cycles_per_tick)
		entry.add_child(amount_label)
		collapsed_outputs.add_child(entry)
		count += 1

func format_number(value: float) -> String:
	var rounded: float = round(value)
	if is_equal_approx(value, rounded): return str(int(rounded))
	return "%.2f" % value

func can_run() -> bool:
	if node == null: return false
	var state: ActionState = ActionManager.get_state(node)
	for mat: Definition in state.cost:
		if MaterialManager.get_amount(mat) < state.cost[mat]: return false
	return true

func _on_action_pressed() -> void:
	if not can_run(): return
	var state: ActionState = ActionManager.get_state(node)
	if state.total_duration <= 0: return
	state.progress += PlayerManager.player_click_power
	while state.progress >= state.total_duration:
		state.progress -= state.total_duration
		if not can_run():
			state.progress = 0
			break
		for mat: Definition in state.cost: MaterialManager.change_materials(mat, -state.cost[mat])
		for mat: Definition in state.production: MaterialManager.change_materials(mat, state.production[mat])
	update_ui()

func _on_workers_changed(action: ActionDefinition) -> void:
	if action == node: update_ui()

func _on_minus_pressed() -> void:
	WorkerManager.unassign_worker(node)
	update_ui()

func _on_plus_pressed() -> void:
	WorkerManager.assign_worker(node)
	update_ui()

func _on_minimize_pressed() -> void:
	minimized = not minimized
	content.visible = not minimized
	collapsed_outputs.visible = minimized
	minimize_button.text = "+" if minimized else "−"
