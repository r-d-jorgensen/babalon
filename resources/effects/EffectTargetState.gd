class_name EffectTargetState

var key: int
var material_tags: Array[int] = []

var base_value: float = 0.0

var flat: float = 0.0
var mult: float = 1.0
var percent: float = 0.0

var dirty: bool = true
var cached_value: float = 0.0

func apply(value: float, op: int, level_delta: int) -> void:
	dirty = true
	match op:
		EffectTypeDefinition.Operation.FLAT:
			flat += value * level_delta
		EffectTypeDefinition.Operation.MULTIPLY:
			mult *= pow(value, level_delta)
		EffectTypeDefinition.Operation.PERCENT_ADD:
			percent += value * level_delta

func compute() -> float:
	if !dirty:
		return cached_value
	else:
		cached_value = (base_value + flat) * mult * (1.0 + percent)
	dirty = false
	return cached_value
