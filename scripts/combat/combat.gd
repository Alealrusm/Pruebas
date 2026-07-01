extends Node2D

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

func _ready() -> void:
	jugador = Global.jugador
	var ataque_basico = jugador.skills[0]
	if Global.enemigo_actual.is_empty():
		Global.enemigo_actual = "control"
	player_sprite.sprite_frames = load("res://assets/sprites/Player/anim/player_anim_batlle.tres")
	player_sprite.play("idle")
	
	var datos = Global.base_datos_enemigos[Global.enemigo_actual]
	var frames = load(datos["sprite"])
	if frames:
		enemy_sprite.sprite_frames = frames
		enemy_sprite.play(enemy_sprite.sprite_frames.get_animation_names()[0])
	
	enemigo = Enemy.new(
		datos["nombre"],
		datos["vida_max"],
		datos["ataque"],
		datos["defensa"],
		datos["velocidad"]
	)
	for s in datos["skills"]:
		enemigo.skills.append(AttackSkill.new(s["nombre"], s["poder"]))

	player_hp_bar.max_value = jugador.hp_max
	enemy_hp_bar.max_value = enemigo.hp_max
	player_hp_bar.value = jugador.hp
	enemy_hp_bar.value = enemigo.hp

	jugador.hp_changed.connect(func(actual, _maximo): player_hp_bar.value = actual)
	enemigo.hp_changed.connect(func(actual, _maximo): enemy_hp_bar.value = actual)

	btn_ataque.text = ataque_basico.nombre
	btn_ataque.pressed.connect(func(): _usar_skill(ataque_basico))

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

	manager = CombatManager.new(jugador, enemigo)
	manager.log_mensaje.connect(_on_log)
	manager.turno_iniciado.connect(_on_turno)
	manager.combate_terminado.connect(_on_fin)
	manager.iniciar()

func _usar_skill(skill: Skill) -> void:
	_deshabilitar_botones(true)
	manager.atacar_jugador(skill)

func _deshabilitar_botones(valor: bool) -> void:
	btn_ataque.disabled = valor
	btn_habilidad1.disabled = valor
	btn_habilidad2.disabled = valor

func _on_turno(entidad) -> void:
	if entidad == jugador:
		_deshabilitar_botones(false)
		btn_ataque.grab_focus()
		log_label.text += "\n▶ Tu turno."
	else:
		_deshabilitar_botones(true)
		log_label.text += "\n▶ Turno de %s." % entidad.nombre

func _on_log(texto: String) -> void:
	log_label.text += "\n" + texto

func _on_fin(victoria: bool) -> void:
	_deshabilitar_botones(true)
	if victoria:
		log_label.text += "\n\n¡Ganaste!"
	else:
		log_label.text += "\n\n¡Perdiste..."
		log_label.text += "\nResucitando en el campus..."
	Global.jugador.hp = Global.jugador.hp_max
	await get_tree().create_timer(2.5).timeout
	Global.end_battle()
