extends Manager

signal tick
signal currencies_changed

var timer: Timer
var tick_rate: float = 1.0
var stored_ticks: int = 0
var catchup_speed_multiplier: int = 1
var player_click_power: int = 1
var currencies: Dictionary[String, int] = {}
var currency_lookup: Dictionary[Definition.ObjectType, Definition] = {}
var currency_id_lookup: Dictionary[String, Definition] = {}

func _ready() -> void:
	register_manager(System.PLAYER, self)
	load_currencies()
	_setup_timer()
	formula_changed()

func formula_changed() -> void:
	return

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

func change_currency(currency_type: Definition.ObjectType, amount: int) -> bool:
	var currency: Definition = currency_lookup.get(currency_type)
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

func get_currency(currency_type: Definition.ObjectType) -> int:
	var currency: Definition = currency_lookup.get(currency_type)
	if currency == null:
		return 0
	return currencies.get(currency.id, 0)

func load_currencies() -> void:
	currency_lookup.clear()
	currency_id_lookup.clear()
	GlobalResourceLoader.recursive_load(
		"res://resources/currencies/",
		func(res: Resource, path: String) -> void:
			var currency: Definition = res
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
		Definition
	)
	currencies_changed.emit()
