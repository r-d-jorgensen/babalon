extends Manager

#signal prestiges_changed

#var prestiges: Dictionary[String, PrestigeState] = {}
#var prestige_lookup: Dictionary[String, PrestigeDefinition] = {}
#
#func _ready() -> void:
	#Manager.register_manager(Manager.System.PRESTIGE, self)
	#load_prestiges()
#
#func load_prestiges() -> void:
	#prestiges.clear()
	#prestige_lookup.clear()
	#GlobalResourceLoader.recursive_load(
		#"res://resources/prestige/",
		#func(res: Resource, path: String) -> void:
			#var prestige: PrestigeDefinition = res
			#if prestige.id.is_empty():
				#push_error("Prestige missing id: %s" % path)
				#return
			#prestiges[prestige.id] = PrestigeState.new(prestige)
			#prestige_lookup[prestige.id] = prestige,
		#[".tres"],
		#PrestigeDefinition
	#)
	#prestiges_changed.emit()

func formula_changed() -> void:
	pass
