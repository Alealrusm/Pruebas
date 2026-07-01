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
var capa_transicion: CanvasLayer
var rect_negro: ColorRect

func _ready() -> void:
# 1. Creamos el CanvasLayer, layer 100 es suficiente
	capa_transicion = CanvasLayer.new()
	capa_transicion.layer = 100 
	capa_transicion.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# TRUCO: Lo añadimos directamente al viewport raíz para la máxima prioridad
	get_tree().root.call_deferred("add_child", capa_transicion)
	
	# 2. Creamos el rectángulo negro
	rect_negro = ColorRect.new()
	rect_negro.color = Color(0, 0, 0)
	rect_negro.modulate.a = 0.0 # Invisible al inicio

	# TRUCO 2: Z-index máximo para forzarlo sobre cualquier cosa en su CanvasLayer
	rect_negro.z_index = RenderingServer.CANVAS_ITEM_Z_MAX 
	rect_negro.z_as_relative = false # Forzar absoluto
	
	rect_negro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect_negro.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	
	capa_transicion.add_child(rect_negro)
	
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
	var play = func play()->void:
		instancia_batalla.queue_free()
		get_tree().paused = false
		if camara_jugador_referencia:
			camara_jugador_referencia.enabled = true
		if mapa_referencia:
			mapa_referencia.visible = true
			mapa_referencia.play()
	transicion_fundido(1.5,play.call)
	
## Transición de fundido utilizando opacidad en un ColorRect
func transicion_fundido(tiempo: float, accion_al_oscurecer: Callable) -> void:
	# Bloqueamos interacciones de mouse durante la transición
	rect_negro.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	
	# 1. Animamos la opacidad ('modulate.a') de 0 a 1 (completamente negro)
	tween.tween_property(rect_negro, "modulate:a", 1.0, tiempo / 2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	
	# 2. En el punto más oscuro, ejecutamos tu función de carga/cambio
	tween.tween_callback(accion_al_oscurecer)
	
	# 3. Animamos la opacidad de vuelta a 0 (transparente)
	tween.tween_property(rect_negro, "modulate:a", 0.0, tiempo / 2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
		
	# 4. Al finalizar todo, liberamos el filtro de mouse para poder jugar normalmente
	tween.tween_callback(func(): rect_negro.mouse_filter = Control.MOUSE_FILTER_IGNORE)
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
