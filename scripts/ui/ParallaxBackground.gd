
extends Control

@export_range(0.0, 1.0, 0.05) var motion_strength: float = 1.0

const LAYER_SETTINGS: Array[Dictionary] = [
	{"speed": 0.08, "x": 20.0, "y": 3.0, "phase": 0.0},
	{"speed": 0.03, "x": 35.0, "y": 5.0, "phase": 2.1},
	{"speed": 0.01, "x": 50.0, "y": 7.0, "phase": 4.2}
]

var layers: Array[TextureRect] = []
var base_positions: Array[Vector2] = []
var elapsed: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true

	for layer_name in ["FarLayer", "MidLayer", "NearLayer"]:
		var layer := get_node_or_null(layer_name) as TextureRect
		if layer == null:
			push_error("Missing background layer: " + layer_name)
			continue

		layers.append(layer)
		base_positions.append(layer.position)

func _process(delta: float) -> void:
	elapsed += delta

	for i in range(mini(layers.size(), LAYER_SETTINGS.size())):
		var settings: Dictionary = LAYER_SETTINGS[i]
		var phase: float = settings["phase"]

		var offset_x := sin(
			elapsed * float(settings["speed"]) + phase
		) * float(settings["x"]) * motion_strength

		layers[i].position = base_positions[i] + Vector2(offset_x, 0.0)
