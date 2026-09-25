extends Resource
class_name EffectDefinition

enum System {
	GLOBAL,
	ACTION,
	WORKER,
	MATERIAL,
	PLAYER,
	UPGRADE,
	SPELL,
	PRESTIGE,
	EFFECT
}

enum Effect {
	COST,
	SPEED,
	PRODUCTION,
	CAPACITY,
	TICK_EFFECT
}

enum Operation {
	SET,
	ADD,
	SUBTRACT,
	MULTIPLY,
	DIVIDE
}

@export var system: System = System.GLOBAL
@export var effect: Effect = Effect.COST
@export var operation: Operation = Operation.ADD
@export var amount: float = 0.0

@export var tags: Array[TagDefinition] = []
@export var actions: Array[ActionDefinition] = []
@export var currencies: Array[Definition] = []
@export var workers: Array[WorkerDefinition] = []
