extends Node

signal tick
signal catchup_started
signal catchup_progress(remaining_ticks: int)
signal catchup_finished
signal civilization_points_changed

var timer: Timer
var tick_rate: float = 1.0
var stored_ticks: int = 0
var offline_tick_spend_rate: int = 1000
var is_catching_up: bool = false
var player_click_power: int = 1
var civilization_points: Dictionary[CountableObject.ObjectType, int] = {
	CountableObject.ObjectType.CULTURE: 0,
	CountableObject.ObjectType.TECHNOLOGY: 0,
	CountableObject.ObjectType.ASCENSION: 0
}

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = tick_rate
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	if stored_ticks > 0:
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
		return
	tick.emit()

func add_civilization_points(point_type: CountableObject.ObjectType, amount: int) -> void:
	if not civilization_points.has(point_type):
		push_warning("Invalid civilization point type ", point_type)
		return
	civilization_points[point_type] += amount
	civilization_points_changed.emit()

func get_points(point_type: CountableObject.ObjectType) -> int:
	return civilization_points.get(point_type, 0)
