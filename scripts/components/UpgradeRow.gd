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
	if state.definition.hidden and not _requirements_met():
		hide()
		return
	show()
	name_label.text = state.definition.display_name
	level_label.text = "%d/%d" % [state.level, state.definition.max_level]
	cost_label.text = _get_cost_text()
	if state.is_maxed():
		buy_button.text = "MAX"
		buy_button.disabled = true
	else:
		buy_button.text = "Buy"
		buy_button.disabled = not state.can_upgrade()

func _requirements_met() -> bool:
	for required_upgrade: UpgradeDefinition in state.definition.required_upgrades:
		if required_upgrade == null:
			continue
		var required_level: int = state.definition.required_upgrades[required_upgrade]
		if UpgradeManager.get_level(required_upgrade.id) < required_level:
			return false
	return true

func _get_cost_text() -> String:
	var parts: Array[String] = []
	for currency: Definition in state.definition.costs:
		parts.append("%d %s" % [state.definition.costs[currency], currency.display_name])
	return ", ".join(parts)

func _on_buy_pressed() -> void:
	if state == null:
		return
	UpgradeManager.purchase(state.definition.id)
