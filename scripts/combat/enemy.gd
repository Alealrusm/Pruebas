class_name Enemy extends Entity

func elegir_accion(objetivos: Array) -> Dictionary:
	var vivos = objetivos.filter(func(e): return e.esta_vivo())
	if vivos.is_empty() or skills.is_empty():
		return {}
		
	var skill_aleatoria = skills.pick_random()
	
	return {
		"skill": skill_aleatoria,
		"objetivo": vivos[0]
	}
