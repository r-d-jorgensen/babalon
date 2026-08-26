extends Manager

#signal spells_changed

#var spells: Dictionary[String, SpellState] = {}
#var spell_lookup: Dictionary[String, SpellDefinition] = {}
#
#func _ready() -> void:
	#Manager.register_manager(Manager.System.SPELL,self)
	#load_spells()
#
#func load_spells() -> void:
	#spells.clear()
	#spell_lookup.clear()
	#GlobalResourceLoader.recursive_load(
		#"res://resources/spells/",
		#func(res: Resource, path: String) -> void:
			#var spell: SpellDefinition = res
			#if spell.id.is_empty():
				#push_error("Spell missing id: %s" % path)
				#return
			#spells[spell.id] = SpellState.new(spell)
			#spell_lookup[spell.id] = spell,
		#[".tres"],
		#SpellDefinition
	#)
	#spells_changed.emit()

func formula_changed() -> void:
	pass
