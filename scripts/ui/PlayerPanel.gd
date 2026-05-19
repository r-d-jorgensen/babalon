extends HBoxContainer

@onready var culture_label: Label = $CultureLabel
@onready var technology_label: Label = $TechnologyLabel
@onready var prestige_label: Label = $PrestigeLabel


func _ready() -> void:
	update_display()
	PlayerManager.civilization_points_changed.connect(update_display)

func update_display(_unused: Variant  = null) -> void:
	culture_label.text = "Culture: %s" % PlayerManager.get_points(CountableObject.ObjectType.CULTURE)
	technology_label.text = "Technology: %s" % PlayerManager.get_points(CountableObject.ObjectType.TECHNOLOGY)
	prestige_label.text = "Prestige: %s" % PlayerManager.get_points(CountableObject.ObjectType.ASCENSION)
