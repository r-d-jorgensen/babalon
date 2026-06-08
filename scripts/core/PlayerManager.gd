extends Node

signal tick
signal currencies_changed
signal upgrades_changed

var timer: Timer
var tick_rate: float = 1.0
var stored_ticks: int = 0
var catchup_speed_multiplier: int = 1
var player_click_power: int = 1
var currencies: Dictionary[String, int] = {}
var currency_lookup: Dictionary[CountableObject.ObjectType, CountableObject] = {}
var currency_id_lookup: Dictionary[String, CountableObject] = {}
var upgrades: Dictionary[String, UpgradeState] = {}
var upgrade_lookup: Dictionary[String, UpgradeDefinition] = {}

func _ready() -> void:
	load_currencies()
	load_upgrades()
	_setup_timer()

func _setup_timer() -> void:
	timer = Timer.new()
	timer.wait_time = tick_rate
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()

func _on_timer_timeout() -> void:
	if stored_ticks <= 0:
		catchup_speed_multiplier = 1
	if catchup_speed_multiplier > 1:
		if catchup_speed_multiplier >= 5:
			stored_ticks -= catchup_speed_multiplier - floori(catchup_speed_multiplier / 5.0)
		else:
			stored_ticks -= catchup_speed_multiplier
		for _tick:int in range(catchup_speed_multiplier):
			tick.emit()
	else:
		tick.emit()

func set_timer_speed(multiplier: int) -> void:
	if multiplier > 1 and stored_ticks > 0:
		catchup_speed_multiplier = max(1, multiplier)
	else:
		catchup_speed_multiplier = 1

func load_currencies() -> void:
	currency_lookup.clear()
	currency_id_lookup.clear()
	GlobalResourceLoader.recursive_load(
		"res://resources/countable_objects/currencies/",
		func(res: Resource, path: String) -> void:
			var currency: CountableObject = res
			if currency.id.is_empty():
				push_error("Currency missing id: %s" % path)
			elif currency_id_lookup.has(currency.id):
				push_error("Duplicate currency id: %s" % currency.id)
			else:
				currency_lookup[currency.object_type] = currency
				currency_id_lookup[currency.id] = currency
				if not currencies.has(currency.id):
					currencies[currency.id] = 0,
		[".tres"],
		CountableObject
	)
	currencies_changed.emit()

func change_currency(currency_type: CountableObject.ObjectType, amount: int) -> bool:
	var currency: CountableObject = currency_lookup.get(currency_type)
	if currency == null:
		push_warning("Invalid currency type: ", currency_type)
		return false
	var key: String = currency.id
	var current: int = currencies.get(key, 0)
	var next: int = current + amount
	if next < 0:
		return false
	currencies[key] = next
	currencies_changed.emit()
	return true

func get_currency_by_id(id: String) -> int:
	return currencies.get(id, 0)

func get_currency(currency_type: CountableObject.ObjectType) -> int:
	var currency: CountableObject = currency_lookup.get(currency_type)
	if currency == null:
		return 0
	return currencies.get(currency.id, 0)

func load_upgrades() -> void:
	upgrades.clear()
	upgrade_lookup.clear()
	GlobalResourceLoader.recursive_load(
		"res://resources/upgrades/",
		func(res: Resource, path: String) -> void:
			var upgrade: UpgradeDefinition = res

			if upgrade.id.is_empty():
				push_error("Upgrade missing id: %s" % path)
			elif upgrade_lookup.has(upgrade.id):
				push_error("Duplicate upgrade id: %s" % upgrade.id)
			else:
				upgrades[upgrade.id] = UpgradeState.new(upgrade)
				upgrade_lookup[upgrade.id] = upgrade,
		[".tres"],
		UpgradeDefinition
	)
	upgrades_changed.emit()
