extends Control

func _ready() -> void:
	await get_tree().process_frame
