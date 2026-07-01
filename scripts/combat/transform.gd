## Cinemática de cambio de fase: muestra la animación de transformación del enemigo y vuelve a combat.tscn.
extends Control

@onready var enemy_sprite: AnimatedSprite2D = $EnemySprite
@onready var flash: ColorRect = $Flash
@onready var nombre_label: Label = $NombreLabel

func _ready() -> void:
	var datos_fase2 = Global.datos_fase2_pendiente

	## Carga el sprite de fase 2; usa anim_transform si existe, si no usa anim_idle.
	var frames = load(datos_fase2["sprite"])
	if frames:
		enemy_sprite.sprite_frames = frames
		var anim_a_usar = datos_fase2["anim_transform"] if datos_fase2.has("anim_transform") and frames.has_animation(datos_fase2["anim_transform"]) else datos_fase2["anim_idle"]
		enemy_sprite.play(anim_a_usar)

	## Flash blanco rápido seguido de un zoom del sprite hacia afuera.
	var tween = create_tween()
	tween.tween_property(flash, "color:a", 0.8, 0.15)
	tween.tween_property(flash, "color:a", 0.0, 0.3)

	enemy_sprite.scale = enemy_sprite.scale * 0.5
	var tween_zoom = create_tween()
	tween_zoom.tween_property(enemy_sprite, "scale", enemy_sprite.scale * 2.0, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(0.4).timeout
	nombre_label.text = "¡%s ha despertado!" % datos_fase2["nombre"]

	await get_tree().create_timer(1.8).timeout

	_aplicar_fase2(datos_fase2)
	
	## Instancia combat.tscn en el mismo padre y se destruye a sí misma.
	var capa_padre = get_parent()
	if capa_padre:
		var nueva_fase_combate = load("res://scenes/combat/combat.tscn").instantiate()
		capa_padre.add_child(nueva_fase_combate)
	queue_free()

## Activa el flag de fase 2 en Global para que combat.tscn cargue los datos correctos.
func _aplicar_fase2(f2: Dictionary) -> void:
	Global.fase2_activa = true
	Global.datos_fase2_pendiente = {}
