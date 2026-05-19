extends Node

const SAVE_PATH: String = "user://savegame.tres"
const AUTOSAVE_INTERVAL: float = 300.0
const SAVE_VERSION: int = 0

var _autosave_timer: float = 0.0

func _ready() -> void:
	call_deferred("load_game")
	set_process(true)

func _process(delta: float) -> void:
	_autosave_timer += delta
	if _autosave_timer >= AUTOSAVE_INTERVAL:
		_autosave_timer = 0.0
		save_game()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST: save_game()

func save_game() -> void:
	var save: SaveGameData = SaveGameData.new()
	save.version = SAVE_VERSION
	save.last_save_time = floori(Time.get_unix_time_from_system())
	save.stored_ticks = PlayerManager.stored_ticks
	save.total_workers = ActionManager.total_workers
	save.materials = _pack_materials(MaterialManager.materials)
	save.created = _pack_materials(MaterialManager.created)
	save.created_all_time = _pack_materials(MaterialManager.created_all_time)
	save.player = _pack_player()
	save.states = _pack_states()
	var err: Error = ResourceSaver.save(save, SAVE_PATH)
	if err != OK:
		push_error("Failed to save game")

func load_game() -> void:
	if not ResourceLoader.exists(SAVE_PATH):
		return
	var save: SaveGameData = ResourceLoader.load(SAVE_PATH)
	if save == null:
		push_error("Failed to load save")
		return
	_apply_save(save)

func _apply_save(save: SaveGameData) -> void:
	PlayerManager.stored_ticks = save.stored_ticks + floori(Time.get_unix_time_from_system()) - save.last_save_time
	ActionManager.total_workers = save.total_workers
	_unpack_materials(MaterialManager.materials, save.materials)
	_unpack_materials(MaterialManager.created, save.created)
	_unpack_materials(MaterialManager.created_all_time, save.created_all_time)
	PlayerManager.civilization_points = save.player.civilization_points.duplicate()
	ActionManager.states.clear()
	for s:SaveActionStateData in save.states:
		var state: MaterialActionState = MaterialActionState.new()
		state.action = load(s.action_path)
		state.workers_assigned = s.workers_assigned
		ActionManager.states[s.action_path] = state
	MaterialManager._bump()
	ActionManager.total_workers_changed.emit()
	PlayerManager.civilization_points_changed.emit()

func _pack_materials(map: MaterialMap) -> MaterialSaveData:
	var data: MaterialSaveData = MaterialSaveData.new()
	data.data = map.data.duplicate()
	return data

func _unpack_materials(map: MaterialMap, data: MaterialSaveData) -> void:
	map.data = data.data.duplicate()

func _pack_player() -> PlayerSaveData:
	var player: PlayerSaveData = PlayerSaveData.new()
	player.civilization_points = PlayerManager.civilization_points.duplicate()
	return player

func _pack_states() -> Array[SaveActionStateData]:
	var out: Array[SaveActionStateData] = []
	for key:String in ActionManager.states:
		var state: MaterialActionState = ActionManager.states[key]
		var s: SaveActionStateData = SaveActionStateData.new()
		s.action_path = key
		s.workers_assigned = state.workers_assigned
		out.append(s)
	return out
