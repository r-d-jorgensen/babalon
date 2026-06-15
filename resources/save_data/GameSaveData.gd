class_name SaveGameData
extends Resource

@export var version: int = 0
@export var last_save_time: int = 0
@export var stored_ticks: int = 0
@export var total_workers: int = 0
@export var materials: MaterialSaveData
@export var created: MaterialSaveData
@export var created_all_time: MaterialSaveData
@export var player: PlayerSaveData
@export var upgrades: UpgradeSaveData
@export var states: Array[SaveActionStateData] = []
