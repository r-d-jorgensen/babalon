extends Manager

#var effects: Dictionary[String, EffectState] = {}
#
func formula_changed() -> void:
	pass

#func get_effect_value(id: String) -> Variant:
	#var state: EffectState = effects.get(id)
	#if state == null:
		#return null
	#return state.get_total_value()
#
#func load_effects() -> void:
	#effects.clear()
	#GlobalResourceLoader.recursive_load(
		#"res://resources/effects/",
		#func(res: Resource, path: String) -> void:
			#var effect: EffectDefinition = res
			#if effect.id.is_empty():
				#push_error("Effect missing id: %s" % path)
				#return
			#var state: EffectState = EffectState.new(effect)
			#effects[effect.id] = state,
		#[".tres"],
		#EffectDefinition
	#)
