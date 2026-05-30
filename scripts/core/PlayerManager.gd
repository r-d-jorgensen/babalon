extends Node

signal tick
signal currencies_changed

var timer: Timer
var tick_rate: float = 1.0
var stored_ticks: int = 0
var catchup_speed_multiplier: int = 1
var player_click_power: int = 1
var currencies: Dictionary[CountableObject, int] = {}
var currency_lookup: Dictionary[CountableObject.ObjectType, CountableObject] = {}
var upgrades: Dictionary[String, UpgradeState] = {}
var upgrade_lookup: Dictionary[String, UpgradeDefinition] = {}

func _ready() -> void:
	_load_currencies()
	_load_upgrades("res://resources/upgrades/")
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

func _load_currencies() -> void:
	var dir: DirAccess = DirAccess.open("res://resources/currencies/")
	if dir == null:
		push_error("Failed to load currency directory")
		return
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var path: String = ("res://resources/currencies/" + file_name)
			var currency: CountableObject = load(path)
			if currency != null:
				currencies[currency] = 0
				currency_lookup[currency.object_type] = currency
		file_name = dir.get_next()
	dir.list_dir_end()

func _get_currency_by_id(id: String) -> CountableObject:
	for obj: CountableObject in PlayerManager.currencies:
		if obj.id == id:
			return obj
	return null

func add_currency(currency_type: CountableObject.ObjectType, amount: int) -> void:
	var currency: CountableObject = currency_lookup.get(currency_type)
	if currency == null:
		push_warning("Invalid currency type: ", currency_type)
		return
	if not currencies.has(currency):
		currencies[currency] = 0
	currencies[currency] += amount
	currencies_changed.emit()

func get_currency(currency_type: CountableObject.ObjectType) -> int:
	var currency: CountableObject = currency_lookup.get(currency_type)
	if currency == null:
		return 0
	return currencies.get(currency, 0)

func _load_upgrades(path: String) -> void:
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var file: String = dir.get_next()
	while file != "":
		if file == "." or file == "..":
			file = dir.get_next()
			continue
		var full_path: String = path + "/" + file
		if dir.current_is_dir():
			_load_upgrades(full_path)
		elif file.ends_with(".tres"):
			var res: UpgradeDefinition = load(full_path)
			if res is UpgradeDefinition:
				upgrades[res.id] = UpgradeState.new()
				upgrade_lookup[res.id] = res
		file = dir.get_next()
	dir.list_dir_end()
