## Habilidad de curación: restaura HP al usuario según el valor de poder.
class_name HealSkill extends Skill

func ejecutar(usuario: Entity, objetivo: Entity) -> String:
	usuario.curar(poder)
	return "%s se cura %d HP" % [usuario.nombre, poder]
