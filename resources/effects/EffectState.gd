class_name EffectState

var definition: EffectDefinition

var targets: Dictionary = {}
# Dictionary[String, EffectTargetState]

func _init(def: EffectDefinition) -> void:
	definition = def

func _make_key(domain: int, key: int) -> int:
	return (domain << 32) | (key & 0xFFFFFFFF)

func _get_target(domain: int, key: int) -> EffectTargetState:
	var id: int = _make_key(domain, key)
	if !targets.has(id):
		var state: EffectTargetState = EffectTargetState.new()
		state.base_value = definition.default_value
		state.key = key
		targets[id] = state
	return targets[id]

func apply(domain: int, key: int, value: float, op: int, level_delta: int) -> void:
	_get_target(domain, key).apply(value, op, level_delta)
