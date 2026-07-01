## Escena principal de combate: inicializa la UI, conecta señales y gestiona los turnos.
extends Control

@onready var player_hp_bar: ProgressBar = $PlayerHPBar
@onready var enemy_hp_bar: ProgressBar = $EnemyHPBar
@onready var log_label: Label = $LogLabel
@onready var btn_ataque: Button = $Botones/BtnAtaque
@onready var btn_habilidad1: Button = $Botones/BtnHabilidad1
@onready var btn_habilidad2: Button = $Botones/BtnHabilidad2
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var enemy_sprite: AnimatedSprite2D = $EnemySprite

var manager: CombatManager
var jugador: Character
var enemigo: Enemy
var datos_enemigo: Dictionary

## Carga el jugador, enemigo y habilidades desde Global; crea el CombatManager y arranca el combate.
func _ready() -> void:
	if has_node("Background"):
		move_child($Background, 0)
		
	jugador = Global.jugador
	## Restaura la vida guardada si el jugador volvió de transform.tscn.
	if Global.vida_actual_jugador != -1:
		jugador.hp = Global.vida_actual_jugador

	var ataque_basico = jugador.skills[0]

	player_sprite.sprite_frames = load("res://assets/sprites/Player/anim/player_anim.tres")
	player_sprite.play("idle_fight")

	datos_enemigo = Global.base_datos_enemigos[Global.enemigo_actual]
	var frames = load(datos_enemigo["sprite"])
	if frames:
		enemy_sprite.sprite_frames = frames
		enemy_sprite.play(datos_enemigo["anim_idle"])
	
	## Si Global.fase2_activa está activo, reemplaza los datos con los de la fase 2.
	if Global.fase2_activa and datos_enemigo.has("fase2"):
		datos_enemigo = datos_enemigo["fase2"]
		Global.fase2_activa = false
	
	enemigo = Enemy.new(
		datos_enemigo["nombre"],
		datos_enemigo["vida_max"],
		datos_enemigo["ataque"],
		datos_enemigo["defensa"],
		datos_enemigo["velocidad"]
	)
	for s in datos_enemigo["skills"]:
		enemigo.skills.append(AttackSkill.new(s["nombre"], s["poder"]))

	player_hp_bar.max_value = jugador.hp_max
	enemy_hp_bar.max_value = enemigo.hp_max
	player_hp_bar.value = jugador.hp
	enemy_hp_bar.value = enemigo.hp

	jugador.hp_changed.connect(func(actual, _maximo): player_hp_bar.value = actual)
	enemigo.hp_changed.connect(func(actual, _maximo): enemy_hp_bar.value = actual)

	btn_ataque.text = ataque_basico.nombre
	btn_ataque.pressed.connect(func(): _usar_skill(ataque_basico))

	## Configura los botones de habilidad si el jugador las tiene equipadas.
	if Global.habilidades_elegidas.size() >= 1:
		btn_habilidad1.text = Global.habilidades_elegidas[0].nombre
		btn_habilidad1.pressed.connect(func(): _usar_skill(Global.habilidades_elegidas[0]))
	else:
		btn_habilidad1.disabled = true
		btn_habilidad1.text = "—"

	if Global.habilidades_elegidas.size() >= 2:
		btn_habilidad2.text = Global.habilidades_elegidas[1].nombre
		btn_habilidad2.pressed.connect(func(): _usar_skill(Global.habilidades_elegidas[1]))
	else:
		btn_habilidad2.disabled = true
		btn_habilidad2.text = "—"

	btn_ataque.grab_focus()

	manager = CombatManager.new(jugador, enemigo, datos_enemigo)
	manager.log_mensaje.connect(_on_log)
	manager.turno_iniciado.connect(_on_turno)
	manager.combate_terminado.connect(_on_fin)
	manager.cambio_de_fase.connect(_on_cambio_fase)
	manager.iniciar()

## Reproduce animación de ataque del jugador, espera 1s y pasa el turno al manager.
func _usar_skill(skill: Skill) -> void:
	_deshabilitar_botones(true)
	player_sprite.play("fight")
	await get_tree().create_timer(1.0).timeout
	player_sprite.play("idle_fight")
	manager.atacar_jugador(skill)

func _deshabilitar_botones(valor: bool) -> void:
	btn_ataque.disabled = valor
	btn_habilidad1.disabled = valor
	btn_habilidad2.disabled = valor

## Maneja el inicio de cada turno: habilita botones si es el jugador o ejecuta IA del enemigo.
func _on_turno(entidad) -> void:
	if entidad == jugador:
		_deshabilitar_botones(false)
		btn_ataque.grab_focus()
		log_label.text = "▶ Tu turno.\n" + log_label.text 
	else:
		_deshabilitar_botones(true)
		log_label.text = ("▶ Turno de %s.\n" % entidad.nombre) + log_label.text 
		enemy_sprite.play(datos_enemigo["anim_ataque"])
		await get_tree().create_timer(1.0).timeout
		enemy_sprite.play(datos_enemigo["anim_idle"])
		manager.ejecutar_turno_enemigo()

## Guarda los datos de fase 2 en Global y carga transform.tscn para la cinemática.
func _on_cambio_fase(datos_fase2: Dictionary) -> void:
	_deshabilitar_botones(true)
	Global.datos_fase2_pendiente = datos_fase2
	Global.fase2_activa = true
	
	var escena_transform = load("res://scenes/combat/transform.tscn").instantiate()
	get_parent().add_child(escena_transform)
	queue_free()
	
func _on_log(texto: String) -> void:
	log_label.text = texto + "\n" + log_label.text 

## Victoria: guarda HP del jugador, elimina el NPC del mapa y cierra la capa de combate.
## Derrota: restaura HP completo y vuelve a la escena de origen.
func _on_fin(victoria: bool) -> void:
	_deshabilitar_botones(true)
	
	if victoria:
		log_label.text = "¡Ganaste!\n\n" + log_label.text
		Global.vida_actual_jugador = jugador.hp 
		
		if Global.enemigo_a_eliminar != null and is_instance_valid(Global.enemigo_a_eliminar):
			Global.enemigo_a_eliminar.queue_free()
			Global.enemigo_a_eliminar = null
		
		await get_tree().create_timer(2.5).timeout
		
		var mapa = get_tree().current_scene
		if mapa:
			mapa.process_mode = PROCESS_MODE_INHERIT
			
		if get_parent() is CanvasLayer:
			get_parent().queue_free()
		else:
			queue_free()
		
	else:
		log_label.text = "¡Perdiste...\nResucitando en el campus...\n\n" + log_label.text
		
		Global.jugador.hp = Global.jugador.hp_max
		Global.vida_actual_jugador = Global.jugador.hp_max
		
		await get_tree().create_timer(2.5).timeout
		get_tree().change_scene_to_file(Global.escena_origen)
