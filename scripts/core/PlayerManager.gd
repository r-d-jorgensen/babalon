extends Node

signal tick
signal catchup_started
signal catchup_progress(remaining_ticks: int)
signal catchup_finished
signal currencies_changed

var timer: Timer

var tick_rate: float = 1.0
var stored_ticks: int = 0
var offline_tick_spend_rate: int = 1000
var is_catching_up: bool = false
var player_click_power: int = 1
var currencies: Dictionary[CountableObject, int] = {}
var currency_lookup: Dictionary[CountableObject.ObjectType, CountableObject] = {}

func _ready() -> void:
	_load_currencies()
	_setup_timer()

func _setup_timer() -> void:
	timer = Timer.new()
	timer.wait_time = tick_rate
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()

func _on_timer_timeout() -> void:
	if stored_ticks > 0:
		_process_offline_ticks()
		return
	tick.emit()

func _process_offline_ticks() -> void:
	if not is_catching_up:
		is_catching_up = true
		catchup_started.emit()
	var ticks_to_process: int = min(offline_tick_spend_rate, stored_ticks)
	for i:int in ticks_to_process:
		tick.emit()
	stored_ticks -= ticks_to_process
	catchup_progress.emit(stored_ticks)
	if stored_ticks <= 0:
		stored_ticks = 0
		is_catching_up = false
		catchup_finished.emit()

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
	for obj: CountableObject in PlayerManager.currencies.keys():
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
