@abstract
extends Resource
class_name UpgradeEffect

@export var id: String
@export var display_name: String

@abstract
func apply_effect() -> void
