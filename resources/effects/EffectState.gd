class_name EffectState

var definition: EffectDefinition

var targets: Dictionary[int, EffectTargetState] = {}

func _init(def: EffectDefinition) -> void:
	definition = def

func _make_key(domain: int, key: int) -> int:
	return (domain << 32) | (key & 0xFFFFFFFF)

func get_target(domain: int, id: int) -> EffectTargetState:
	var key: int = _make_key(domain, id)
	if !targets.has(key):
		var state: EffectTargetState = EffectTargetState.new()
		state.key = key
		state.base_value = definition.default_value
		targets[key] = state
	return targets[key]

func apply(
	domain: int,
	id: int,
	value: float,
	op: EffectTarget.Operation,
	level_delta: int
) -> void:
	get_target(domain, id).apply(value, op, level_delta)
