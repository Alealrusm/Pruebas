class_name CombatManager extends RefCounted

signal turno_iniciado(entidad)
signal log_mensaje(texto)
signal combate_terminado(victoria: bool)

var jugador: Character
var enemigo: Enemy
var orden: Array
var indice := 0

func _init(_jugador: Character, _enemigo: Enemy):
	jugador = _jugador
	enemigo = _enemigo
	orden = [jugador, enemigo] if jugador.velocidad >= enemigo.velocidad else [enemigo, jugador]

func iniciar() -> void:
	turno_iniciado.emit(orden[indice])
	if orden[indice] == enemigo:
		_turno_enemigo()

func atacar_jugador(skill: Skill) -> void:
	var mensaje = skill.ejecutar(jugador, enemigo)
	log_mensaje.emit(mensaje)
	_avanzar()

func _turno_enemigo() -> void:
	var accion = enemigo.elegir_accion([jugador])
	var mensaje = accion["skill"].ejecutar(enemigo, jugador)
	log_mensaje.emit(mensaje)
	_avanzar()

func _avanzar() -> void:
	if not jugador.esta_vivo():
		combate_terminado.emit(false)
		return
	if not enemigo.esta_vivo():
		combate_terminado.emit(true)
		return

	indice = (indice + 1) % orden.size()
	turno_iniciado.emit(orden[indice])
	if orden[indice] == enemigo:
		_turno_enemigo()
