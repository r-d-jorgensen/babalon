extends VBoxContainer

@onready var culture_label: Label = $CivilizationHeaders/CultureLabel
@onready var technology_label: Label = $CivilizationHeaders/TechnologyLabel
@onready var prestige_label: Label = $CivilizationHeaders/PrestigeLabel
@onready var tabs: TabContainer = $CivilizationPages
@onready var culture_button: Button = $CivilizationTabs/CultureButton
@onready var technology_button: Button = $CivilizationTabs/TechnologyButton
@onready var discovery_button: Button = $CivilizationTabs/DiscoveryButton
@onready var prestige_button: Button = $CivilizationTabs/PrestigeButton


func _ready() -> void:
	tabs.tabs_visible = false
	culture_button.pressed.connect(func()->void: select_tab(0))
	technology_button.pressed.connect(func()->void: select_tab(1))
	discovery_button.pressed.connect(func()->void: select_tab(2))
	prestige_button.pressed.connect(func()->void: select_tab(3))
	update_display()
	PlayerManager.civilization_points_changed.connect(update_display)
	select_tab(0)

func select_tab(tab: int) -> void:
	tabs.current_tab = tab
	culture_button.disabled = tab == 0
	technology_button.disabled = tab == 1
	discovery_button.disabled = tab == 2
	prestige_button.disabled = tab == 3

func update_display(_unused: Variant = null) -> void:
	culture_label.text = "Culture: %s" % PlayerManager.get_points(CountableObject.ObjectType.CULTURE)
	technology_label.text = "Technology: %s" % PlayerManager.get_points(CountableObject.ObjectType.TECHNOLOGY)
	prestige_label.text = "Prestige: %s" % PlayerManager.get_points(CountableObject.ObjectType.ASCENSION)
