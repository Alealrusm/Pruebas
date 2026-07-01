## Autoload global: almacena el estado compartido entre escenas (jugador, enemigo, combate, fase 2).
extends Node

var enemigo_actual: String = ""       ## ID del enemigo en base_datos_enemigos.
var escena_origen: String = ""        ## Ruta de la escena a la que volver al terminar combate.
var jugador: Character
var habilidades_disponibles: Array = []
var habilidades_elegidas: Array = []
var abrir_pausa_al_volver: bool = false
var datos_fase2_pendiente: Dictionary = {}  ## Datos de fase 2 pasados a transform.tscn.
var fase2_activa: bool = false              ## Indica a combat.tscn que debe cargar la fase 2.
var vida_actual_jugador: int = -1           ## HP del jugador persistido entre escenas de combate.
var enemigo_a_eliminar: Node = null         ## Referencia al NPC a borrar del mapa al ganar.

## Inicializa el jugador y las habilidades disponibles al arrancar el juego.
func _ready() -> void:
	jugador = Character.new("Super Mechon", 500, 10, 50, 5)
	jugador.skills = [AttackSkill.new("Golpe", 10)]
	
	habilidades_disponibles = [
		AttackSkill.new("Ataque Especial", 15),
		DefendSkill.new("Defensa", 5),
		HealSkill.new("Curar", 12)
	]

## Base de datos de todos los enemigos del juego, incluyendo sus stats, sprites y fase 2 si aplica.
var base_datos_enemigos = {
	"lizama_fantasma": {
		"nombre": "Lizama Fantasma",
		"vida_max": 25,
		"ataque": 6,
		"defensa": 2,
		"velocidad": 7,
		"sprite": "res://assets/sprites/Lizama/anim/lizama.tres",
		"anim_idle": "combat_iddle_phase1",
		"anim_ataque": "attack_lizama_phase1",
		"skills": [
			{"nombre": "Mano fantasmal", "poder": 7},
			{"nombre": "Corrupción de Código", "poder": 9}
		],
		"fase2": {
			"nombre": "Lizama Fantasma Furioso",
			"vida_max": 35,
			"ataque": 10,
			"defensa": 4,
			"velocidad": 9,
			"sprite": "res://assets/sprites/Lizama/anim/lizama.tres",
			"anim_idle": "combat_iddle_phase2",
			"anim_ataque": "attack_lizama_phase2",
			"anim_transform": "phase_change",
			"skills": [
				{"nombre": "Grito Espectral", "poder": 14},
				{"nombre": "Overflow Crítico", "poder": 18}
			]
		}
	},
	"nico_torres": {
		"nombre": "Nico Torres",
		"vida_max": 25,
		"ataque": 7,
		"defensa": 3,
		"velocidad": 6,
		"sprite": "res://assets/sprites/Nico_Torres/anim/NicoTorres.tres",
		"anim_idle": "combat_iddle_phase1",
		"anim_ataque": "attack_nico_phase1",
		"skills": [
			{"nombre": "Ataque base Nico", "poder": 8}
		],
		"fase2": {
			"nombre": "Nico Torres Sobrecargado",
			"vida_max": 35,
			"ataque": 11,
			"defensa": 5,
			"velocidad": 8,
			"sprite": "res://assets/sprites/Nico_Torres/anim/NicoTorres.tres",
			"anim_idle": "combat_iddle_phase2",
			"anim_ataque": "attack_nico_phase2",
			"anim_transform": "phase_change",
			"skills": [
				{"nombre": "Ataque mejorado", "poder": 16}
			]
		}
	},
	"p_olivares": {
		"nombre": "P. Olivares",
		"vida_max": 25,
		"ataque": 7,
		"defensa": 3,
		"velocidad": 6,
		"sprite": "res://assets/sprites/P_Olivares/anim/p_olivares.tres",
		"anim_idle": "combat_iddle_phase1",
		"anim_ataque": "attack_patricio_phase1",
		"skills": [
			{"nombre": "Ataque base Olivares", "poder": 8}
		],
		"fase2": {
			"nombre": "P. Olivares Final",
			"vida_max": 35,
			"ataque": 12,
			"defensa": 5,
			"velocidad": 9,
			"sprite": "res://assets/sprites/P_Olivares/anim/p_olivares.tres",
			"anim_idle": "combat_iddle_phase2",
			"anim_ataque": "attack_patricio_phase2",
			"anim_transform": "phase_change",
			"skills": [
				{"nombre": "Ataque final", "poder": 17}
			]
		}
	},
	"control": {
		"nombre": "Control",
		"vida_max": 25,
		"ataque": 6,
		"defensa": 6,
		"velocidad": 7,
		"sprite": "res://assets/sprites/Enemy/Control/anim/Control.tres",
		"anim_idle": "idle",
		"anim_ataque": "attack",
		"skills": [
			{"nombre": "Error de arrastre", "poder": 10}
		]
	}
}
