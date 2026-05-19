extends VBoxContainer

@onready var economy_button: Button = $TopTabs/EconomyButton
@onready var civilization_button: Button = $TopTabs/CivilizationButton
@onready var pages: TabContainer = $MainViews

func _ready() -> void:
	pages.tabs_visible = false
	economy_button.text = "Economy"
	civilization_button.text = "Civilization"
	economy_button.pressed.connect(func()->void: select_tab(0))
	civilization_button.pressed.connect(func()->void: select_tab(1))
	select_tab(0)

func select_tab(tab: int) -> void:
	pages.current_tab = tab
	economy_button.disabled = tab == 0
	civilization_button.disabled = tab == 1
