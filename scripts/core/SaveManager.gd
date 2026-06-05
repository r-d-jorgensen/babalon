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
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()

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
	var offline_time: int = max(0, floori(Time.get_unix_time_from_system()) - save.last_save_time)
	PlayerManager.stored_ticks = save.stored_ticks + offline_time
	PlayerManager.currencies.clear()
	for id: String in save.player.currencies.keys():
		var obj: CountableObject = PlayerManager._get_currency_by_id(id)
		if obj != null:
			PlayerManager.currencies[obj] = save.player.currencies[id]
	PlayerManager.currencies_changed.emit()

	for state: UpgradeState in PlayerManager.upgrades.values():
		state.level = 0
	for id: String in save.player.upgrades.keys():
		var state: UpgradeState = PlayerManager.upgrades.get(id)
		if state == null:
			push_warning("Unknown upgrade id: %s" % id)
			continue
		state.level = save.player.upgrades[id]
	PlayerManager.upgrades_changed.emit()
	
	_unpack_materials(MaterialManager.materials, save.materials)
	_unpack_materials(MaterialManager.created, save.created)
	_unpack_materials(MaterialManager.created_all_time, save.created_all_time)
	MaterialManager._bump()
	
	ActionManager.total_workers = save.total_workers
	ActionManager.states.clear()
	for s: SaveActionStateData in save.states:
		var action: MaterialAction = ActionManager.get_action_by_id(s.action_id)
		if action == null:
			push_warning("Unknown action id: %s" % s.action_id)
			continue
		var state: MaterialActionState = MaterialActionState.new()
		state.action = action
		state.workers_assigned = s.workers_assigned
		ActionManager.states[s.action_id] = state

func _pack_materials(map: MaterialMap) -> MaterialSaveData:
	var data: MaterialSaveData = MaterialSaveData.new()
	data.data = map.data.duplicate()
	return data

func _unpack_materials(map: MaterialMap, data: MaterialSaveData) -> void:
	map.data = data.data.duplicate()

func _pack_player() -> PlayerSaveData:
	var player: PlayerSaveData = PlayerSaveData.new()
	var packed: Dictionary[String, int] = {}
	for obj: CountableObject in PlayerManager.currencies.keys():
		packed[obj.id] = PlayerManager.currencies[obj]
	player.currencies = packed
	
	var packed_upgrades: Dictionary[String, int] = {}
	for id: String in PlayerManager.upgrades.keys():
		var state: UpgradeState = PlayerManager.upgrades[id]
		packed_upgrades[id] = state.level
	player.upgrades = packed_upgrades
	return player

func _pack_states() -> Array[SaveActionStateData]:
	var out: Array[SaveActionStateData] = []
	for state: MaterialActionState in ActionManager.states.values():
		var s: SaveActionStateData = SaveActionStateData.new()
		s.action_id = state.action.id
		s.workers_assigned = state.workers_assigned
		out.append(s)
	return out
