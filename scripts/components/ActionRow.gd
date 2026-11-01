extends HBoxContainer
class_name ActionRow

@export var node: ActionDefinition

@onready var action_button: Button = $ActionButton
@onready var progress_label: Label = $ProgressLabel
@onready var input_label: HBoxContainer = $InputLabel
@onready var output_label: HBoxContainer = $OutputLabel
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

	action_button.custom_minimum_size = Vector2(28, 28)
	action_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	minus_button.custom_minimum_size = Vector2(24, 24)
	plus_button.custom_minimum_size = Vector2(24, 24)
	input_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	output_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input_label.custom_minimum_size.x = 0
	output_label.custom_minimum_size.x = 0

	update_ui()

func _on_workers_changed(action: ActionDefinition) -> void:
	if action != node:
		return
	worker_label.text = str(ActionManager.get_state(node).workers_assigned)

func update_ui() -> void:
	var state: ActionState = ActionManager.get_state(node)
	action_button.text = ""
	action_button.icon = resize_icon(node.get_icon(), Vector2i(16, 16))
	action_button.expand_icon = false
	action_button.custom_minimum_size = Vector2(28, 28)
	action_button.tooltip_text = node.display_name
	action_button.disabled = not can_run()
	update_material_display(input_label, state.cost, true)
	update_material_display(output_label, state.production, false)
	worker_label.text = str(state.workers_assigned)
	progress_label.text = "%.2f / %.2f" % [state.progress, state.total_duration]

func resize_icon(texture: Texture2D, target_size: Vector2i) -> Texture2D:
	if texture == null:
		return null
	var image: Image = texture.get_image()
	if image == null or image.is_empty():
		return texture
	image.resize(target_size.x, target_size.y, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(image)

func update_material_display(container: HBoxContainer, materials: Dictionary, show_cost: bool) -> void:
	for child: Node in container.get_children():
		container.remove_child(child)
		child.queue_free()

	for mat: Definition in materials:
		var entry:HBoxContainer = HBoxContainer.new()
		entry.add_theme_constant_override("separation", 2)

		var icon_container:Control = Control.new()
		icon_container.custom_minimum_size = Vector2(12, 12)
		icon_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		icon_container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

		var icon:TextureRect = TextureRect.new()
		icon.texture = resize_icon(mat.get_icon(), Vector2i(12, 12))
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_container.add_child(icon)
		entry.add_child(icon_container)

		var label:Label = Label.new()
		if show_cost:
			label.text = "%.0f/%.0f" % [MaterialManager.get_amount(mat), materials[mat]]
		else:
			label.text = "%.0f" % MaterialManager.get_amount(mat)
		entry.add_child(label)

		container.add_child(entry)

func format_rate(state: ActionState) -> String:
	if state.workers_assigned <= 0 or state.total_duration <= 0:
		return ""
	var efficiency: float = WorkerManager.get_worker_efficiency()
	var cycles_per_tick: float = (
		state.workers_assigned
		* efficiency
		/ state.total_duration
	)
	var per_tick: Dictionary[Definition, float] = {}
	for mat: Definition in state.production:
		per_tick[mat] = state.production[mat] * cycles_per_tick
	for mat: Definition in state.cost:
		var amount: float = state.cost[mat] * cycles_per_tick
		per_tick[mat] = per_tick.get(mat, 0.0) - amount
	var parts: Array[String] = []
	for mat: Definition in per_tick:
		var rate: float = per_tick[mat]
		if abs(rate) < 0.001:
			continue
		var sign_value: String = "+"
		if rate < 0:
			sign_value = ""
		parts.append("%s%.2f/t %s" % [sign_value, rate, mat.display_name])
	return "[" + ", ".join(parts) + "]"

func can_run() -> bool:
	var state: ActionState = ActionManager.get_state(node)
	for mat: Definition in state.cost:
		if MaterialManager.get_amount(mat) < state.cost[mat]:
			return false
	return true

func _on_action_pressed() -> void:
	var state: ActionState = ActionManager.get_state(node)
	if not can_run():
		return
	state.progress += PlayerManager.player_click_power
	while state.progress >= state.total_duration:
		state.progress -= state.total_duration
		if not can_run():
			state.progress = 0
			break
		for mat: Definition in state.cost:
			MaterialManager.change_materials(mat, -state.cost[mat])
		for mat: Definition in state.production:
			MaterialManager.change_materials(mat, state.production[mat])
	update_ui()

func _on_minus_pressed() -> void:
	WorkerManager.unassign_worker(node)

func _on_plus_pressed() -> void:
	WorkerManager.assign_worker(node)
