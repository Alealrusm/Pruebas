## Clase enemigo: hereda de Entity y agrega lógica de IA para elegir acción aleatoria.
class_name Enemy extends Entity

## Elige una skill aleatoria y la apunta al primer objetivo vivo de la lista.
func elegir_accion(objetivos: Array) -> Dictionary:
	var vivos = objetivos.filter(func(e): return e.esta_vivo())
	if vivos.is_empty() or skills.is_empty():
		return {}
		
	var skill_aleatoria = skills.pick_random()
	
	return {
		"skill": skill_aleatoria,
		"objetivo": vivos[0]
	}
