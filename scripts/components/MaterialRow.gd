extends HBoxContainer
class_name MaterialRow

@onready var name_label: Label = $NameLabel
@onready var amount_label: Label = $AmountLabel
@onready var change_label: Label = $ChangeLabel

var mat: MaterialDefinition

func _ready() -> void:
	MaterialManager.inventory_changed.connect(refresh)
	refresh()

func refresh() -> void:
	if mat == null:
		return
	name_label.text = mat.display_name
	amount_label.text = str(MaterialManager.materials.get_value(mat.id))
	var delta: float = MaterialManager.material_delta_per_tick.get(mat.id, 0.0)
	if absf(delta) < 0.001:
		change_label.text = " +/- 0"
	else:
		change_label.text = "%+.2f/t" % delta
