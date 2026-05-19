extends HBoxContainer
class_name MaterialRow

@onready var name_label: Label = $NameLabel
@onready var amount_label: Label = $AmountLabel

var mat: MaterialDefinition

func _ready() -> void:
	MaterialManager.inventory_changed.connect(refresh)
	refresh()

func refresh() -> void:
	if mat == null:
		return
	name_label.text = mat.display_name
	var amount: int = MaterialManager.materials.get_value(mat.resource_path)
	amount_label.text = str(amount)
