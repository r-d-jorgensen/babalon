extends Definition
class_name EffectTarget

enum Operation {
	UNLOCK,
	FLAT,
	MULTIPLY,
	PERCENT_ADD
}

@export var target_definition: Definition
@export var operation: Operation = Operation.FLAT
