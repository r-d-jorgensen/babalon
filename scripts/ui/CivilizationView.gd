extends VBoxContainer

@onready var civics_label: Label = $CivilizationHeaders/CivicsLabel
@onready var technology_label: Label = $CivilizationHeaders/TechnologyLabel
@onready var exploration_label: Label = $CivilizationHeaders/ExplorationLabel
@onready var truth_label: Label = $CivilizationHeaders/AscensionLabel

@onready var tabs: TabContainer = $CivilizationPages

@onready var civics_button: Button = $CivilizationTabs/CivicsButton
@onready var technology_button: Button = $CivilizationTabs/TechnologyButton
@onready var exploration_button: Button = $CivilizationTabs/ExplorationButton
@onready var truth_button: Button = $CivilizationTabs/AscensionButton

func _ready() -> void:
	tabs.tabs_visible = false
	civics_button.pressed.connect(func() -> void: select_tab(0))
	technology_button.pressed.connect(func() -> void: select_tab(1))
	exploration_button.pressed.connect(func() -> void: select_tab(2))
	truth_button.pressed.connect(func() -> void: select_tab(3))
	PlayerManager.currencies_changed.connect(update_display)
	update_display()
	select_tab(0)

func select_tab(tab: int) -> void:
	tabs.current_tab = tab
	civics_button.disabled = tab == 0
	technology_button.disabled = tab == 1
	exploration_button.disabled = tab == 2
	truth_button.disabled = tab == 3

func update_display(_unused: Variant = null) -> void:
	civics_label.text = "Culture: %s" % PlayerManager.get_currency(CountableObject.ObjectType.CIVIC)
	technology_label.text = "Research: %s" % PlayerManager.get_currency(CountableObject.ObjectType.TECHNOLOGY)
	exploration_label.text = "Discovery: %s" % PlayerManager.get_currency(CountableObject.ObjectType.EXPLORATION)
	truth_label.text = "Truth: %s" % PlayerManager.get_currency(CountableObject.ObjectType.ASCENSION)
