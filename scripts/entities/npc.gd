extends Interactable

@export var Name : String
@export var Text : String
@export var es_jefe_combate : bool = false
@export var enemigo_id : String = ""

var dialog : Dialog
var anim : AnimatedSprite2D

func _ready() -> void:
	dialog = $CanvasLayer/Dialog
	anim = $AnimatedSprite2D
	if anim.sprite_frames and anim.sprite_frames.has_animation("default"):
		anim.play("default")

func _on_interact():
	dialog.show_text_name(Text, Name)
	if es_jefe_combate:
		await dialog.cerrado
		_iniciar_combate()
		return
	await dialog.cerrado
	finish.emit()

func _iniciar_combate():
	Global.enemigo_actual = enemigo_id
	Global.escena_origen = get_tree().current_scene.scene_file_path
	
	Global.enemigo_a_eliminar = self
	
	var capa_combate = CanvasLayer.new()
	capa_combate.layer = 100
	var escena_combate = load("res://scenes/combat/combat.tscn").instantiate()
	capa_combate.add_child(escena_combate)
	get_tree().root.add_child(capa_combate)
	
	var mapa_actual = get_tree().current_scene
	if mapa_actual:
		mapa_actual.process_mode = PROCESS_MODE_DISABLED
