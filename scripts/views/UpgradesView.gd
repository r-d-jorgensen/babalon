
extends TabContainer

const UPGRADE_ROW_SCENE: PackedScene = preload("res://scenes/components/UpgradeRow.tscn")

@onready var civics_list: VBoxContainer = $Civics/CivicsList
@onready var technology_list: VBoxContainer = $Technology/TechnologyList
@onready var truth_list: VBoxContainer = $Truth/TruthList

func _ready() -> void:
	tabs_visible = true
	current_tab = 0

	UpgradeManager.upgrades_changed.connect(build_upgrades_ui)
	build_upgrades_ui()

func build_upgrades_ui() -> void:
	_clear_container(civics_list)
	_clear_container(technology_list)
	_clear_container(truth_list)

	for state: UpgradeState in UpgradeManager.upgrades.values():
		var row: UpgradeRow = UPGRADE_ROW_SCENE.instantiate()
		row.state = state

		match state.definition.object_type:
			UpgradeDefinition.ObjectType.CIVIC:
				civics_list.add_child(row)
			UpgradeDefinition.ObjectType.TECHNOLOGY:
				technology_list.add_child(row)
			UpgradeDefinition.ObjectType.ASCENSION:
				truth_list.add_child(row)
			_:
				row.queue_free()

func _clear_container(container: Node) -> void:
	for child: Node in container.get_children():
		container.remove_child(child)
		child.queue_free()
