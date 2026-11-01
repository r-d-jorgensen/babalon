extends VBoxContainer

@onready var materials_list: VBoxContainer = $MaterialsList
const MATERIAL_ROW_SCENE: PackedScene = preload("res://scenes/components/MaterialRow.tscn")

func _ready() -> void:
	build_materials_ui()

func build_materials_ui() -> void:
	for child: Node in materials_list.get_children():
		child.queue_free()
	for material_data: MaterialDefinition in MaterialManager.materials_list:
		var row: MaterialRow = MATERIAL_ROW_SCENE.instantiate()
		row.mat = material_data
		materials_list.add_child(row)
