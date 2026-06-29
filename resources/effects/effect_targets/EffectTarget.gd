extends Definition
class_name EffectTarget

enum Operation {
	UNLOCK,
	FLAT,
	MULTIPLY,
	PERCENT_ADD
}

@export var effect: EffectDefinition
@export var target: int
@export var operation: Operation = Operation.FLAT
