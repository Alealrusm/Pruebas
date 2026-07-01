## Controlador de lógica de combate por turnos, sin nodos de escena.
class_name CombatManager extends RefCounted

signal turno_iniciado(entidad)
signal log_mensaje(texto)
signal combate_terminado(victoria: bool)
signal cambio_de_fase(datos_fase2: Dictionary)

var jugador: Character
var enemigo: Enemy
var orden: Array   ## Define quién actúa primero según velocidad.
var indice := 0
var datos_enemigo: Dictionary
var en_fase2 := false

## Inicializa el combate y determina el orden de turnos por velocidad.
func _init(_jugador: Character, _enemigo: Enemy, _datos_enemigo: Dictionary):
	jugador = _jugador
	enemigo = _enemigo
	datos_enemigo = _datos_enemigo
	orden = [jugador, enemigo] if jugador.velocidad >= enemigo.velocidad else [enemigo, jugador]

## Comienza el combate emitiendo el turno del primer actor.
func iniciar() -> void:
	orden[indice].resetear_defensa()
	turno_iniciado.emit(orden[indice])

## Ejecuta la skill del jugador sobre el enemigo y avanza el turno.
func atacar_jugador(skill: Skill) -> void:
	var mensaje = skill.ejecutar(jugador, enemigo)
	log_mensaje.emit(mensaje)
	_avanzar()

## Ejecuta la acción del enemigo sobre el jugador y avanza el turno.
func ejecutar_turno_enemigo() -> void:
	var accion = enemigo.elegir_accion([jugador])
	var mensaje = accion["skill"].ejecutar(enemigo, jugador)
	log_mensaje.emit(mensaje)
	_avanzar()

## Revisa el estado del combate: derrota, fase 2 o siguiente turno.
func _avanzar() -> void:
	if not jugador.esta_vivo():
		combate_terminado.emit(false)
		return

	if not enemigo.esta_vivo():
		if not en_fase2 and datos_enemigo.has("fase2"):
			_iniciar_fase2()
			return
		combate_terminado.emit(true)
		return

	indice = (indice + 1) % orden.size()
	var actor = orden[indice]
	actor.resetear_defensa()
	turno_iniciado.emit(actor)

## Actualiza los stats del enemigo con los datos de fase 2 y emite la señal de cambio.
func _iniciar_fase2() -> void:
	en_fase2 = true
	var f2 = datos_enemigo["fase2"]

	enemigo.nombre = f2["nombre"]
	enemigo.hp_max = f2["vida_max"]
	enemigo.hp = f2["vida_max"]
	enemigo.ataque = f2["ataque"]
	enemigo.defensa = f2["defensa"]
	enemigo.defensa_base = f2["defensa"]
	enemigo.velocidad = f2["velocidad"]
	enemigo.skills.clear()
	for s in f2["skills"]:
		enemigo.skills.append(AttackSkill.new(s["nombre"], s["poder"]))

	enemigo.hp_changed.emit(enemigo.hp, enemigo.hp_max)
	log_mensaje.emit("¡%s ha entrado en su segunda fase!" % f2["nombre"])
	cambio_de_fase.emit(f2)
	return
