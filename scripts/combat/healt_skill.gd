class_name HealSkill extends Skill

func ejecutar(usuario: Entity, objetivo: Entity) -> String:
	usuario.curar(poder)
	return "%s se cura %d HP" % [usuario.nombre, poder]
