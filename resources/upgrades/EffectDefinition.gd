extends Resource
class_name EffectDefinition

enum Effect {
	PRODUCTION,
	CONSUMPTION,
	WORKER_SPEED,
	WORKER_CAPACITY,
	ACTION_SPEED,
	ACTION_COST,
	OFFLINE_PRODUCTION,
	GLOBAL
}

enum Operation {
	ADD,
	MULTIPLY,
	SET
}

@export var effect: Effect = Effect.GLOBAL
@export var tags: Array[TagDefinition] = []
@export var operation: Operation = Operation.ADD
@export var amount: float = 0.0
