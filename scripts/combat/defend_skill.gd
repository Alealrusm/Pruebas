## Habilidad defensiva: aumenta la defensa del usuario durante este turno.
class_name DefendSkill extends Skill

func ejecutar(usuario: Entity, objetivo: Entity) -> String:
	usuario.defensa = usuario.defensa_base + poder
	return "%s se defiende (+%d defensa este turno)" % [usuario.nombre, poder]
