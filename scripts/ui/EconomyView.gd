extends VBoxContainer

#@onready var actions_button: Button = $EconomyTabs/ActionsButton
#@onready var production_button: Button = $EconomyTabs/ProductionChainsButton
#@onready var materials_button: Button = $EconomyTabs/MaterialsButton
#@onready var pages: TabContainer = $EconomyPages
#@onready var action_list: VBoxContainer = $EconomyPages/ActionsPage/ActionList
#@onready var materials_list: VBoxContainer = $EconomyPages/MaterialsPage/MaterialsList
#
#var action_row_scene: PackedScene = preload("res://scenes/components/ActionRow.tscn")
#var material_row_scene: PackedScene = preload("res://scenes/components/MaterialRow.tscn")
#
#func _ready() -> void:
	#pages.tabs_visible = false
	#actions_button.pressed.connect(func()->void: select_tab(0))
	#production_button.pressed.connect(func()->void: select_tab(1))
	#materials_button.pressed.connect(func()->void: select_tab(2))
	#build_actions_ui()
	#build_materials_ui()
	#select_tab(0)
#
#func select_tab(tab: int) -> void:
	#pages.current_tab = tab
	#actions_button.disabled = tab == 0
	#production_button.disabled = tab == 1
	#materials_button.disabled = tab == 2
#
#func build_actions_ui() -> void:
	#for child: Node in action_list.get_children():
		#child.queue_free()
	#for action_data: ActionDefinition in ActionManager.actions:
		#var row: ActionRow = action_row_scene.instantiate()
		#row.node = action_data
		#action_list.add_child(row)
#
#func build_materials_ui() -> void:
	#for child:Node in materials_list.get_children():
		#child.queue_free()
	#for mat:MaterialDefinition in MaterialManager.materials_list:
		#var row: MaterialRow = material_row_scene.instantiate()
		#row.mat = mat
		#materials_list.add_child(row)
