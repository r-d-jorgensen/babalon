
extends Control

@export_range(0.0, 1.0, 0.05) var motion_strength: float = 1.0
@export var closest_layer_speed: float = 0.1

var layers: Array[TextureRect] = []
var base_positions: Array[Vector2] = []
var elapsed: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	for child: Node in get_children():
		if child is TextureRect:
			var layer: TextureRect = child as TextureRect
			layers.append(layer)
			base_positions.append(layer.position)

func _process(delta: float) -> void:
	elapsed += delta
	for i: int in range(layers.size()):
		var layer_speed: float = closest_layer_speed / pow(2.0, i)
		var amplitude_x: float = float(i * 10)
		var phase: float = float(i * 2)
		var offset_x: float = sin(elapsed * layer_speed + phase) * amplitude_x * motion_strength

		layers[i].position = base_positions[i] + Vector2(offset_x, 0.0)
