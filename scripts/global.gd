extends Node

var enemigo_actual: String = ""
var jugador: Character
var habilidades_disponibles: Array = []
var habilidades_elegidas: Array = []
var abrir_pausa_al_volver: bool = false
const ESCENA_BATALLA = preload("res://scenes/combat/combat.tscn")
var instancia_batalla: Node = null
var mapa_referencia: Node = null # Para saber a qué congelar
var camara_jugador_referencia: Camera2D = null

func _ready() -> void:
	jugador = Character.new("Super Mechon", 19, 10, 2, 5)
	jugador.skills = [AttackSkill.new("Golpe", 10)]	
	habilidades_disponibles = [
		AttackSkill.new("Ataque Especial", 15),
		DefendSkill.new("Defensa", 5),
		HealSkill.new("Curar", 12)
	]
	
func start_battle():
	MusicLooper.stop()
	get_tree().paused = true
	if mapa_referencia:
		mapa_referencia.visible = false
	# 2. Instanciamos la escena de combate
	instancia_batalla = ESCENA_BATALLA.instantiate()
	if camara_jugador_referencia:
		camara_jugador_referencia.enabled = false
	# Opcional: Le pasas datos del enemigo a la escena de batalla (qué monstruos aparecen)
	# instancia_batalla.configurar_enemigos(enemigo_datos)
	
	# 3. La añadimos a la pantalla actual (encima de todo)
	get_tree().root.add_child(instancia_batalla)
	
func end_battle():
	instancia_batalla.queue_free()
	get_tree().paused = false
	if camara_jugador_referencia:
		camara_jugador_referencia.enabled = true
	if mapa_referencia:
		mapa_referencia.visible = true
		mapa_referencia.play()
	

var base_datos_enemigos = {
	"lizama_fantasma": {
		"nombre": "Lizama Fantasma",
		"vida_max": 25,
		"ataque": 6,
		"defensa": 2,
		"velocidad": 7,
		"sprite": "res://assets/sprites/Lizama/anim/lizama.tres",
		"skills": [
			{"nombre": "Mano fantasmal", "poder": 7},
			{"nombre": "Corrupción de Código", "poder": 9}
		]
	},
	"control":{
		"nombre": "Control",
		"vida_max": 25,
		"ataque": 6,
		"defensa": 6,
		"velocidad": 7,
		"sprite": "res://assets/sprites/Enemy/Control/anim/Control.tres",
		"skills": [
			{"nombre": "Error de arrastre", "poder": 10}
		]
	}
}
