extends Manager

var effects: Dictionary[String, EffectState] = {}

func formula_changed() -> void:
	pass

func rebuild_all_effects() -> void:
	effects.clear()
	for state: UpgradeState in UpgradeManager.upgrades.values():
		if state.level <= 0:
			continue
		for definition: EffectDefinition in state.definition.effects:
			_add_effect(definition, state.definition.id, state.level)
	Manager.notify_manager(Manager.System.ALL)

func _add_effect(definition: EffectDefinition, source_id: String, level: int) -> void:
	var effect_id: String = _get_effect_id(definition)
	var state: EffectState = effects.get(effect_id)
	if state == null:
		state = EffectState.new(definition)
		effects[effect_id] = state
	state.set_source(source_id, definition.amount * level)

func _get_effect_id(definition: EffectDefinition) -> String:
	var tag_ids: Array[String] = []
	for tag: TagDefinition in definition.tags:
		tag_ids.append(tag.id)
	tag_ids.sort()
	return "%s:%s" % [EffectDefinition.Effect.keys()[definition.effect], ",".join(tag_ids)]

func get_effect_value(effect: EffectDefinition.Effect, tags: Array[TagDefinition]) -> float:
	var total: float = 0.0
	for state: EffectState in effects.values():
		if state.definition.effect != effect:
			continue
		if not state.definition.tags.is_empty():
			if not tags.any(func(tag: TagDefinition) -> bool: return tag in state.definition.tags):
				continue
		total += state.get_total_value()
	return total
