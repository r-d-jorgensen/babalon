extends VBoxContainer

const TAB_ICON_SIZE: int = 24
const TAB_BUTTON_SIZE: Vector2 = Vector2(32, 32)

@onready var economy_button: Button = $TopTabs/EconomyButton
@onready var civilization_button: Button = $TopTabs/CivilizationButton
@onready var exploration_button: Button = $TopTabs/ExplorationButton
@onready var settings_button: Button = $TopTabs/SettingsButton
@onready var pages: TabContainer = $MainViews
#@onready var stored_ticks_label: Label = $TopTabs/StoredTicksLabel
#@onready var normal_speed_button: Button = $TopTabs/NormalSpeedButton
#@onready var speed_up_2x_button : Button = $TopTabs/SpeedUp2xButton
#@onready var speed_up_5x_button : Button = $TopTabs/SpeedUp5xButton

func _ready() -> void:
	pages.tabs_visible = false
	economy_button.add_theme_constant_override("icon_max_width", 24)
	exploration_button.add_theme_constant_override("icon_max_width", 24)
	civilization_button.add_theme_constant_override("icon_max_width", 24)
	settings_button.add_theme_constant_override("icon_max_width", 24)
	
	economy_button.pressed.connect(func()->void: select_tab(0))
	exploration_button.pressed.connect(func()->void: select_tab(1))
	civilization_button.pressed.connect(func()->void: select_tab(2))
	settings_button.pressed.connect(func()->void: select_tab(3))
	#normal_speed_button.pressed.connect(func() -> void:
		#PlayerManager.set_timer_speed(1)
		#update_speed_buttons(1)
	#)
	#speed_up_2x_button.pressed.connect(func() -> void:
		#PlayerManager.set_timer_speed(2)
		#update_speed_buttons(2)
	#)
	#speed_up_5x_button.pressed.connect(func() -> void:
		#PlayerManager.set_timer_speed(5)
		#update_speed_buttons(5)
	#)
	#PlayerManager.tick.connect(_update_stored_ticks_label)
	
	select_tab(0)
	#update_speed_buttons(1)
	#_update_stored_ticks_label()

func select_tab(tab: int) -> void:
	pages.current_tab = tab
	economy_button.disabled = tab == 0
	exploration_button.disabled = tab == 1
	civilization_button.disabled = tab == 2
	settings_button.disabled = tab == 3

#func update_speed_buttons(speed: int) -> void:
	#normal_speed_button.disabled = speed == 1
	#speed_up_2x_button.disabled = speed == 2
	#speed_up_5x_button.disabled = speed == 5

#func _update_stored_ticks_label() -> void:
	#stored_ticks_label.text = "Stored Ticks: %d" % PlayerManager.stored_ticks
