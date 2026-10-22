
extends Control

@export_range(0.0, 1.0, 0.05) var motion_strength: float = 1.0

const LAYER_SETTINGS: Array[Dictionary] = [
	{"speed": 0.12, "x": 8.0, "y": 4.0, "phase": 0.0},
	{"speed": 0.18, "x": 14.0, "y": 7.0, "phase": 2.1},
	{"speed": 0.24, "x": 20.0, "y": 10.0, "phase": 4.2}
]
var elapsed: float = 0.0
var base_positions: Array[Vector2] = []
var base_sizes: Array[Vector2] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	resized.connect(_update_layout)
	_update_layout()

func _update_layout() -> void:
	base_positions.clear()
	base_sizes.clear()
	for child:Node in get_children():
		if child is TextureRect:
			var layer: TextureRect = child as TextureRect
			var overscan: Vector2 = size * 0.10
			layer.position = -overscan
			layer.size = size + overscan * 2.0
			base_positions.append(layer.position)
			base_sizes.append(layer.size)

func _process(delta: float) -> void:
	elapsed += delta
	var index: int = 0
	for child:Node in get_children():
		if child is TextureRect:
			var layer: TextureRect = child as TextureRect
			if index >= LAYER_SETTINGS.size():
				break
			var settings: Dictionary = LAYER_SETTINGS[index]
			var speed: float = settings["speed"]
			var phase: float = settings["phase"]
			var x_motion: float = settings["x"]
			var y_motion: float = settings["y"]
			layer.position = base_positions[index] + Vector2(
				sin(elapsed * speed + phase) * x_motion,
				cos(elapsed * speed * 0.8 + phase) * y_motion
			) * motion_strength
			index += 1
