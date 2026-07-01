## Habilidad de ataque: calcula daño (ataque + poder) y lo aplica al objetivo.
class_name AttackSkill extends Skill

func ejecutar(usuario: Entity, objetivo: Entity) -> String:
	var dano = usuario.ataque + poder
	objetivo.recibir_dano(dano)
	return "%s ataca a %s con %s (%d daño)" % [usuario.nombre, objetivo.nombre, nombre, dano]
