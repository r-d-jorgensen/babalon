extends VBoxContainer

@onready var economy_button: Button = $TopTabs/EconomyButton
@onready var civilization_button: Button = $TopTabs/CivilizationButton
@onready var pages: TabContainer = $MainViews
@onready var stored_ticks_label: Label = $TopTabs/StoredTicksLabel
@onready var normal_speed_button: Button = $TopTabs/NormalSpeedButton1
@onready var speed_up_button_2 : Button = $TopTabs/SpeedUpButton2
@onready var speed_up_button_5 : Button = $TopTabs/SpeedUpButton5

func _ready() -> void:
	pages.tabs_visible = false
	economy_button.pressed.connect(func()->void: select_tab(0))
	civilization_button.pressed.connect(func()->void: select_tab(1))
	normal_speed_button.pressed.connect(func() -> void:
		PlayerManager.set_timer_speed(1)
		update_speed_buttons(1)
	)
	speed_up_button_2.pressed.connect(func() -> void:
		PlayerManager.set_timer_speed(2)
		update_speed_buttons(2)
	)
	speed_up_button_5.pressed.connect(func() -> void:
		PlayerManager.set_timer_speed(5)
		update_speed_buttons(5)
	)
	PlayerManager.tick.connect(_update_stored_ticks_label)
	
	select_tab(0)
	update_speed_buttons(1)
	_update_stored_ticks_label()

func select_tab(tab: int) -> void:
	pages.current_tab = tab
	economy_button.disabled = tab == 0
	civilization_button.disabled = tab == 1

func update_speed_buttons(speed: int) -> void:
	normal_speed_button.disabled = speed == 1
	speed_up_button_2.disabled = speed == 2
	speed_up_button_5.disabled = speed == 5

func _update_stored_ticks_label() -> void:
	stored_ticks_label.text = "Stored Ticks: %d" % PlayerManager.stored_ticks
