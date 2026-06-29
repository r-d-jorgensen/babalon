extends Definition
class_name ActionDefinition

@export var duration: int = 2
@export var base_conversion_rate: float = 1.0
@export var inputs: Dictionary[Definition, int] = {}
@export var outputs: Dictionary[Definition, int] = {}

@export var is_clickable: bool = true
@export var is_workable: bool = true
