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

func refresh() -> void:
	if state == null or state.upgrade == null:
		return
	name_label.text = state.get_display_name()
	level_label.text = "%d/%d" % [
		state.level,
		state.upgrade.max_level
	]
	cost_label.text = _get_cost_text()
	if state.is_maxed():
		buy_button.text = "MAX"
		buy_button.disabled = true
	else:
		buy_button.text = "Buy"
		buy_button.disabled = not state.can_purchase()

func _get_cost_text() -> String:
	var parts: Array[String] = []
	for currency: CountableObject in state.upgrade.costs:
		parts.append("%d %s" % [
			state.upgrade.costs[currency],
			currency.display_name
		])
	return ", ".join(parts)

func _on_buy_pressed() -> void:
	state.purchase()
