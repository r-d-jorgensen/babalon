extends Control

const DESKTOP_SCENE: PackedScene = preload("res://scenes/DesktopUI.tscn")
const MOBILE_SCENE: PackedScene = preload("res://scenes/MobileUI.tscn")

@export var force_mobile: bool = false

func _ready() -> void:
	var is_mobile: bool = OS.has_feature("mobile") or force_mobile
	var scene: PackedScene = MOBILE_SCENE if is_mobile else DESKTOP_SCENE
	var ui: Control = scene.instantiate() as Control
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(ui)
