extends Definition
class_name EffectTypeDefinition

enum Operation {
	FLAT,
	MULTIPLY,
	PERCENT_ADD
}

@export var is_unlick: bool = false
@export var default_value: float = 0.0
@export var formula_controller: Manager.System = Manager.System.ALL
