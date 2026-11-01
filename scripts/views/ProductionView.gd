extends VBoxContainer

@onready var action_list: VBoxContainer = $ActionList
var action_row_scene: PackedScene = preload("res://scenes/components/ActionRow.tscn")

func _ready() -> void:
	build_actions_ui()

func build_actions_ui() -> void:
	for child: Node in action_list.get_children():
		child.queue_free()
	for action_data: ActionDefinition in ActionManager.actions:
		var row: ActionRow = action_row_scene.instantiate()
		row.node = action_data
		action_list.add_child(row)
