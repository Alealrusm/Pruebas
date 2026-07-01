## Clase base de todas las entidades de combate (jugador y enemigos).
class_name Entity extends RefCounted

var nombre: String
var hp_max: int
var hp: int
var ataque: int
var defensa: int
var defensa_base: int  ## Defensa original, usada al resetear al inicio de cada turno.
var velocidad: int
var skills: Array = []

signal hp_changed(actual, maximo)
signal entity_died

func _init(_nombre := "", _hp := 10, _ataque := 1, _defensa := 0, _velocidad := 1):
	nombre = _nombre
	hp_max = _hp
	hp = _hp
	ataque = _ataque
	defensa = _defensa
	defensa_base = _defensa
	velocidad = _velocidad

## Aplica daño reducido por defensa (mínimo 1) y emite señales de cambio y muerte.
func recibir_dano(cantidad: int) -> void:
	var dano_real = max(1, cantidad - defensa)
	hp = max(0, hp - dano_real)
	hp_changed.emit(hp, hp_max)
	if hp == 0:
		entity_died.emit()

func esta_vivo() -> bool:
	return hp > 0

func curar(cantidad: int) -> void:
	hp = min(hp_max, hp + cantidad)
	hp_changed.emit(hp, hp_max)

## Restaura la defensa a su valor base al comenzar un nuevo turno.
func resetear_defensa() -> void:
	defensa = defensa_base
