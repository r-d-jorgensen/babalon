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
	save.total_workers = WorkerManager.total_workers
	save.materials = _pack_materials(MaterialManager.materials)
	save.created = _pack_materials(MaterialManager.created)
	save.created_all_time = _pack_materials(MaterialManager.created_all_time)
	save.player = _pack_player()
	save.upgrades = _pack_upgrades()
	save.states = _pack_states()
	var err : Error = ResourceSaver.save(save, SAVE_PATH)
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
	_apply_core_state(save)
	_rebuild_all_effects()
	_emit_all_update_signals()

func _apply_core_state(save: SaveGameData) -> void:
	var offline_time: int = max(0, floori(Time.get_unix_time_from_system()) - save.last_save_time)
	var offline_ticks: int = floori(offline_time / PlayerManager.tick_rate)
	PlayerManager.stored_ticks = save.stored_ticks + offline_ticks

	PlayerManager.currencies.clear()
	for id: String in save.player.currencies:
		PlayerManager.currencies[id] = save.player.currencies[id]

	UpgradeManager.upgrades.clear()
	for id: String in save.upgrades.upgrade_states:
		var def:UpgradeDefinition = UpgradeManager.upgrade_lookup.get(id)
		if def == null:
			push_warning("Unknown upgrade id: %s" % id)
			continue
		var state:UpgradeState = UpgradeState.new(def)
		state.level = save.upgrades.upgrade_states[id]
		UpgradeManager.upgrades[def.id] = state

	_unpack_materials(MaterialManager.materials, save.materials)
	_unpack_materials(MaterialManager.created, save.created)
	_unpack_materials(MaterialManager.created_all_time, save.created_all_time)
	WorkerManager.total_workers = save.total_workers

	ActionManager.states.clear()
	for s: SaveActionStateData in save.states:
		var action: ActionDefinition = ActionManager.get_action_by_id(s.action_id)
		if action == null:
			push_warning("Unknown action id: %s" % s.action_id)
			continue
		var state: ActionState = ActionState.new(action)
		state.action = action
		state.workers_assigned = s.workers_assigned
		state.progress = s.progress
		ActionManager.states[s.action_id] = state

func _rebuild_all_effects() -> void:
	#TODO rebiuld effects
	Manager.notify_manager(Manager.System.ALL)

func _emit_all_update_signals() -> void:
	UpgradeManager.upgrades_changed.emit()
	WorkerManager.total_workers_changed.emit()
	MaterialManager.inventory_changed.emit()
	PlayerManager.currencies_changed.emit()

func _pack_materials(map: MaterialMap) -> MaterialSaveData:
	var data: MaterialSaveData = MaterialSaveData.new()
	data.data = map.data.duplicate(true)
	return data

func _unpack_materials(map: MaterialMap, data: MaterialSaveData) -> void:
	map.data.clear()
	for key:String in data.data:
		map.data[key] = data.data[key]

func _pack_player() -> PlayerSaveData:
	var player: PlayerSaveData = PlayerSaveData.new()
	var packed: Dictionary[String, int] = {}
	for id: String in PlayerManager.currencies.keys():
		packed[id] = PlayerManager.currencies[id]
	player.currencies = packed
	return player

func _pack_upgrades() -> UpgradeSaveData:
	var save_data: UpgradeSaveData = UpgradeSaveData.new()
	for id: String in UpgradeManager.upgrades:
		save_data.upgrade_states[id] = UpgradeManager.upgrades[id].level
	return save_data

func _pack_states() -> Array[SaveActionStateData]:
	var out: Array[SaveActionStateData] = []
	for state: ActionState in ActionManager.states.values():
		var s: SaveActionStateData = SaveActionStateData.new()
		s.action_id = state.action.id
		s.workers_assigned = state.workers_assigned
		s.progress = state.progress
		out.append(s)
	return out
