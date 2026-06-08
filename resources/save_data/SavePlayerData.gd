extends Resource
class_name PlayerSaveData

@export var version: int = 0
@export var currencies: Dictionary[String, int] = {}
@export var upgrades: Dictionary[String, int] = {}
