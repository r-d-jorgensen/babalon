extends HBoxContainer
class_name UpgradeRow

@onready var name_label: Label = $NameLabel
@onready var level_label: Label = $LevelLabel
@onready var cost_label: Label = $CostLabel
@onready var buy_button: Button = $BuyButton

var state: UpgradeState

func _ready() -> void:
	PlayerManager.currencies_changed.connect(refresh)
	UpgradeManager.upgrades_changed.connect(refresh)
	buy_button.pressed.connect(_on_buy_pressed)
	refresh()

func set_state(new_state: UpgradeState) -> void:
	state = new_state
	refresh()

func refresh() -> void:
	if state == null or state.definition == null:
		return
	name_label.text = state.definition.display_name
	level_label.text = "%d/%d" % [state.level, state.definition.max_level]
	cost_label.text = _get_cost_text()
	if state.is_maxed():
		buy_button.text = "MAX"
		buy_button.disabled = true
	else:
		buy_button.text = "Buy"
		buy_button.disabled = not state.can_upgrade()

func _get_cost_text() -> String:
	var parts: Array[String] = []
	for currency: Definition in state.definition.costs:
		parts.append("%d %s" % [state.definition.costs[currency], currency.display_name])
	return ", ".join(parts)

func _on_buy_pressed() -> void:
	if state == null:
		return
	UpgradeManager.purchase(state.definition.id)
