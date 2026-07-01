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
	if anim.sprite_frames and anim.sprite_frames.get_animation_names().size() > 0:
		anim.play(anim.sprite_frames.get_animation_names()[0])

func _on_interact():
	dialog.show_text_name(Text, Name)
	if es_jefe_combate:
		await dialog.cerrado  
		_iniciar_combate()
		queue_free()
		return
	await dialog.cerrado 
	finish.emit()

func _iniciar_combate():
	Global.enemigo_actual = enemigo_id
	Global.start_battle()
