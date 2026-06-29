class_name EffectState

var definition: EffectDefinition

var player_targets: Dictionary[int, EffectTargetState] = {}
var worker_targets: Dictionary[int, EffectTargetState] = {}
var material_targets: Dictionary[int, EffectTargetState] = {}
var action_targets: Dictionary[int, EffectTargetState] = {}

func _init(def: EffectDefinition) -> void:
	definition = def

func _get_target(map: Dictionary, key: int) -> EffectTargetState:
	if !map.has(key):
		var state: EffectTargetState = EffectTargetState.new()
		state.base_value = definition.default_value
		map[key] = state
		push_warning("EffectTargetState did not exist, %s, %s before requested", map, key)
	return map[key]

func apply(domain: int, key: int, value: float, op: int, level_delta: int) -> void:
	match domain:
		Manager.System.PLAYER:
			_apply(player_targets, key, value, op, level_delta)
		Manager.System.WORKER:
			_apply(worker_targets, key, value, op, level_delta)
		Manager.System.MATERIAL:
			_apply(material_targets, key, value, op, level_delta)
		Manager.System.ACTION:
			_apply(action_targets, key, value, op, level_delta)

func _apply(map: Dictionary, key: int, value: float, op: int, level_delta: int) -> void:
	var state: EffectTargetState = _get_target(map, key)
	state.apply(value, op, level_delta)
