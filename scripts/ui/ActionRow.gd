extends HBoxContainer
class_name ActionRow

@export var node: ActionDefinition

@onready var action_button: Button = $ActionButton
@onready var progress_label: Label = $ProgressLabel
@onready var input_label: Label = $InputLabel
@onready var output_label: Label = $OutputLabel
@onready var minus_button: Button = $MinusButton
@onready var worker_label: Label = $WorkerLabel
@onready var plus_button: Button = $PlusButton

func _ready() -> void:
	if node == null:
		return
	action_button.pressed.connect(_on_action_pressed)
	minus_button.pressed.connect(_on_minus_pressed)
	plus_button.pressed.connect(_on_plus_pressed)
	WorkerManager.workers_changed.connect(_on_workers_changed)
	PlayerManager.tick.connect(update_ui)
	MaterialManager.inventory_changed.connect(update_ui)
	update_ui()

func _on_workers_changed(action: ActionDefinition) -> void:
	if action != node:
		return
	worker_label.text = str(ActionManager.get_state(node).workers_assigned)

func update_ui() -> void:
	var state: ActionState = ActionManager.get_state(node)
	action_button.text = node.display_name
	action_button.disabled = not can_run()
	input_label.text = format_io(node.inputs, true)
	var output_text: String = format_io(node.outputs, false)
	var rate_text: String = format_rate()
	if rate_text != "":
		output_text += "    " + rate_text
	output_label.text = output_text
	worker_label.text = str(state.workers_assigned)
	progress_label.text = "%d ticks remaining" % max(0, node.duration - int(state.progress))

func format_io(dict: Dictionary[CountableObject, int], is_input: bool) -> String:
	var parts: Array[String] = []
	for mat:CountableObject in dict:
		var value: int = dict[mat]
		var current: int = MaterialManager.get_amount(mat)
		if is_input:
			parts.append("| %s: %d / %d" % [mat.display_name, current, value])
		else:
			parts.append("%s: %d (+%d)" % [mat.display_name, current, value])
	return ", ".join(parts)

func format_rate() -> String:
	var state: ActionState = ActionManager.get_state(node)
	if state.workers_assigned <= 0:
		return ""
	var efficiency: float = WorkerManager.get_worker_efficiency()
	var per_tick: Dictionary[CountableObject, float] = {}
	for mat:CountableObject in node.outputs:
		var amount: float = (
			float(node.outputs[mat])
			* node.base_conversion_rate
			* state.workers_assigned
			* efficiency
			/ float(node.duration)
		)
		per_tick[mat] = per_tick.get(mat, 0.0) + amount
	for mat:CountableObject in node.inputs:
		var amount: float = (
			float(node.inputs[mat])
			* node.base_conversion_rate
			* state.workers_assigned
			* efficiency
			/ float(node.duration)
		)
		per_tick[mat] = per_tick.get(mat, 0.0) - amount
	var parts: Array[String] = []
	for mat:CountableObject in per_tick:
		var rate: float = per_tick[mat]
		if abs(rate) < 0.001:
			continue
		var sign_value: String = "+"
		if rate < 0:
			sign_value = ""
		parts.append(
			"%s%s/t %s" % [
				sign_value,
				snapped(rate, 0.01),
				mat.display_name
			]
		)
	return "[" + ", ".join(parts) + "]"

func can_run() -> bool:
	for mat:CountableObject in node.inputs:
		if MaterialManager.get_amount(mat) < node.inputs[mat]:
			return false
	return true

func _on_action_pressed() -> void:
	var state: ActionState = ActionManager.get_state(node)
	if not can_run():
		return
	state.progress += PlayerManager.player_click_power * node.base_conversion_rate
	while state.progress >= node.duration:
		state.progress -= node.duration
		for mat:CountableObject in node.inputs:
			if MaterialManager.get_amount(mat) < node.inputs[mat]:
				state.progress = 0
				break
			MaterialManager.change_materials(mat, -node.inputs[mat])
		for mat:CountableObject in node.outputs:
			MaterialManager.change_materials(mat, node.outputs[mat])
	update_ui()

func _on_minus_pressed() -> void:
	WorkerManager.unassign_worker(node)

func _on_plus_pressed() -> void:
	WorkerManager.assign_worker(node)
