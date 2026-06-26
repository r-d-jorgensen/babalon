extends VBoxContainer

@onready var civics_label: Label = $CivilizationHeaders/CivicsLabel
@onready var technology_label: Label = $CivilizationHeaders/TechnologyLabel
@onready var truth_label: Label = $CivilizationHeaders/TruthLabel

@onready var tabs: TabContainer = $CivilizationPages
@onready var civics_button: Button = $CivilizationTabs/CivicsButton
@onready var technology_button: Button = $CivilizationTabs/TechnologyButton
@onready var truth_button: Button = $CivilizationTabs/TruthButton

var upgrade_row_scene: PackedScene = preload("res://scenes/components/UpgradeRow.tscn")
@onready var civics_list: VBoxContainer = $CivilizationPages/CivicsPage/CivicsList
@onready var technology_list: VBoxContainer = $CivilizationPages/TechnologyPage/TechnologyList
@onready var truth_list: VBoxContainer = $CivilizationPages/TruthPage/TruthList

func _ready() -> void:
	tabs.tabs_visible = false
	civics_button.pressed.connect(func() -> void: select_tab(0))
	technology_button.pressed.connect(func() -> void: select_tab(1))
	truth_button.pressed.connect(func() -> void: select_tab(2))
	PlayerManager.currencies_changed.connect(update_display)
	UpgradeManager.upgrades_changed.connect(build_upgrades_ui)
	update_display()
	build_upgrades_ui()
	select_tab(0)

func select_tab(tab: int) -> void:
	tabs.current_tab = tab
	civics_button.disabled = tab == 0
	technology_button.disabled = tab == 1
	truth_button.disabled = tab == 2

func update_display(_unused: Variant = null) -> void:
	civics_label.text = "Culture: %s" % PlayerManager.get_currency(CountableDefinition.ObjectType.CIVIC)
	technology_label.text = "Research: %s" % PlayerManager.get_currency(CountableDefinition.ObjectType.TECHNOLOGY)
	truth_label.text = "Truth: %s" % PlayerManager.get_currency(CountableDefinition.ObjectType.ASCENSION)

func build_upgrades_ui() -> void:
	_clear_container(civics_list)
	_clear_container(technology_list)
	_clear_container(truth_list)
	for state: UpgradeState in UpgradeManager.upgrades.values():
		var row: UpgradeRow = upgrade_row_scene.instantiate()
		row.state = state
		match state.upgrade.category:
			UpgradeDefinition.UpgradeCategory.CULTURE:
				civics_list.add_child(row)
			UpgradeDefinition.UpgradeCategory.TECHNOLOGY:
				technology_list.add_child(row)
			UpgradeDefinition.UpgradeCategory.ASCENSION:
				truth_list.add_child(row)

func _clear_container(container: Node) -> void:
	for child: Node in container.get_children():
		child.queue_free()
