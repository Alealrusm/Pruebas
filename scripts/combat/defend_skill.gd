class_name DefendSkill extends Skill

func ejecutar(usuario: Entity, objetivo: Entity) -> String:
	usuario.defensa += poder
	return "%s se defiende (+%d defensa)" % [usuario.nombre, poder]
