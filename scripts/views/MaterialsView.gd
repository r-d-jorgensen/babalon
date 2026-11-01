extends VBoxContainer

@onready var materials_list: VBoxContainer = $MaterialsList
var action_row_scene: PackedScene = preload("res://scenes/components/ActionRow.tscn")

func _ready() -> void:
	build_materials_ui()

func build_materials_ui() -> void:
	for child: Node in materials_list.get_children():
		child.queue_free()
	for action_data: ActionDefinition in ActionManager.actions:
		var row: ActionRow = action_row_scene.instantiate()
		row.node = action_data
		materials_list.add_child(row)
