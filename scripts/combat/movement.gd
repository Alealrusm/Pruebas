## NPC con IA de persecución: detecta al jugador en rango, lo sigue y al contacto inicia combate.
extends CharacterBody2D

@export_category("Configuración Base")
@export var Name : String = "Control"
@export var Text : String = "¡Te sabes el rap de la ciberseguridad?"
@export var es_jefe_combate : bool = false
@export var enemigo_id : String = "control"

@export_category("IA de Persecución")
@export var velocidad_persecucion : float = 75.0
@export var rango_deteccion : float = 180.0       

var dialog : Dialog
var anim : AnimatedSprite2D
var jugador_objetivo : Player = null
var combate_iniciado : bool = false

## Configura colisiones, busca nodos del padre (dialog, sprite) y activa la IA.
func _ready() -> void:
	collision_layer = 2     
	collision_mask = 1 | 2  
	
	if has_node("CollisionShape2D"):
		var col_propia = $CollisionShape2D as CollisionShape2D
		var forma_circulo = CircleShape2D.new()
		forma_circulo.radius = 14.0 
		col_propia.shape = forma_circulo
		col_propia.scale = Vector2.ONE 
		col_propia.position = Vector2.ZERO

	var padre = get_parent()
	if padre:
		if padre.has_node("CollisionShape2D"):
			padre.get_node("CollisionShape2D").queue_free()
		if padre.has_node("CollisionShape2D2"):
			padre.get_node("CollisionShape2D2").queue_free()
			
		if padre.has_node("CanvasLayer2/Dialog"):
			dialog = padre.get_node("CanvasLayer2/Dialog") as Dialog
		
		if padre.has_node("AnimatedSprite2D2"):
			anim = padre.get_node("AnimatedSprite2D2") as AnimatedSprite2D
		elif padre.has_node("AnimatedSprite2D"):
			anim = padre.get_node("AnimatedSprite2D") as AnimatedSprite2D
			
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("default"):
		anim.play("default")
		
	_configurar_deteccion_ia()
	_configurar_contacto_fisico()

## Mueve el NPC hacia el jugador si está en rango; si no, se queda quieto.
func _physics_process(_delta: float) -> void:
	if combate_iniciado:
		return
		
	if jugador_objetivo and is_instance_valid(jugador_objetivo):
		var direccion = (jugador_objetivo.global_position - global_position).normalized()
		velocity = direccion * velocidad_persecucion
		
		if anim:
			if anim.sprite_frames.has_animation("walk"):
				if anim.animation != "walk": 
					anim.play("walk")
			else:
				if not anim.is_playing(): 
					anim.play("default")
			
			if velocity.x != 0:
				anim.flip_h = velocity.x < 0
	else:
		velocity = Vector2.ZERO
		if anim and anim.sprite_frames and anim.sprite_frames.has_animation("default"):
			anim.play("default")
		
	move_and_slide()
	
	var padre = get_parent()
	if padre and anim:
		anim.global_position = global_position

## Crea un Area2D circular que detecta al Player para iniciar la persecución.
func _configurar_deteccion_ia() -> void:
	var area_vision = Area2D.new()
	var collision = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	
	circle.radius = rango_deteccion
	collision.shape = circle
	area_vision.add_child(collision)
	add_child(area_vision)
	
	area_vision.collision_layer = 0
	area_vision.collision_mask = 1 
	
	area_vision.body_entered.connect(func(body):
		if body is Player:
			jugador_objetivo = body
	)
	
	area_vision.body_exited.connect(func(body):
		if body == jugador_objetivo:
			jugador_objetivo = null
	)

## Crea un Area2D de contacto que dispara el encuentro al tocar al jugador.
func _configurar_contacto_fisico() -> void:
	var area_choque = Area2D.new()
	var collision = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	
	circle.radius = 26.0
	collision.shape = circle
	area_choque.add_child(collision)
	add_child(area_choque)
	
	area_choque.collision_layer = 0
	area_choque.collision_mask = 1 

	area_choque.body_entered.connect(func(body):
		if body is Player and not combate_iniciado:
			combate_iniciado = true
			velocity = Vector2.ZERO
			_procesar_encuentro()
	)

## Muestra el diálogo y luego inicia el combate al cerrarlo.
func _procesar_encuentro() -> void:
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
		
	if dialog:
		dialog.show_text_name(Text, Name)
		await dialog.cerrado
	
	_iniciar_combate()

## Carga combat.tscn en un CanvasLayer sobre el mapa y pausa el mundo.
func _iniciar_combate() -> void:
	Global.enemigo_actual = enemigo_id
	Global.escena_origen = get_tree().current_scene.scene_file_path

	Global.enemigo_a_eliminar = get_parent()

	var capa_combate = CanvasLayer.new()
	capa_combate.layer = 100
	
	var escena_combate = load("res://scenes/combat/combat.tscn").instantiate()
	capa_combate.add_child(escena_combate)
	get_tree().root.add_child(capa_combate)
	
	if get_parent():
		get_parent().hide()
	
	## Desactiva el procesado del mapa mientras dura el combate.
	var mapa_actual = get_tree().current_scene
	if mapa_actual:
		mapa_actual.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
