extends Resource
class_name MaterialAction

@export var id: String
@export var display_name: String

@export var duration: int = 2
@export var base_conversion_rate: float = 1.0
@export var inputs: Dictionary[CountableObject, int] = {}
@export var outputs: Dictionary[CountableObject, int] = {}

@export var is_clickable: bool = true
@export var is_workable: bool = true
