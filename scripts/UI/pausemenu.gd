extends UI
@onready var scaler : Control = $CenterContainer/Scale
# Called when the node enters the scene tree for the first time.
func ready() -> void:
	hide()
	if Global.abrir_pausa_al_volver:
		Global.abrir_pausa_al_volver = false
		on_show()
		get_tree().paused = true
	
func _input(event: InputEvent) -> void:
	if(Input.is_action_just_released("ui_menu") && visible):
		get_viewport().set_input_as_handled()
		_on_continue()
	
func on_show():
	get_tree().paused = true
	$Sounds/Accept.play()
	show()
	scaler.modulate = Color.TRANSPARENT
	var tweenI = create_tween()
	tweenI.set_ease(Tween.EASE_OUT)
	tweenI.set_trans(Tween.TRANS_SINE)
	tweenI.parallel().tween_property(scaler, "modulate", Color.WHITE,0.20)
	tweenI.tween_callback($CenterContainer/Scale/Buttons/continue_btn.grab_focus)


func _on_continue() -> void:
	$CenterContainer/Scale.scale = Vector2.ONE
	var done = func done()->void:
		get_tree().paused = false
		hide()
	$Sounds/Deny.play()
	var tweenO = create_tween()
	tweenO.set_ease(Tween.EASE_OUT)
	tweenO.set_trans(Tween.TRANS_SINE)
	tweenO.tween_property($CenterContainer/Scale, "scale", Vector2.ZERO ,0.20)
	tweenO.tween_callback(done.call)

func _on_habilidades_btn_pressed() -> void:
	get_tree().paused = false
	hide()
	get_tree().change_scene_to_file("res://scenes/ui/habilidades.tscn")

func _on_exit_btn_pressed() -> void:
	get_tree().quit()

func changeScene(file):
	get_tree().change_scene_to_file(file)

	
func _on_main_btn_pressed() -> void:
	Global.transicion_fundido(1,func(): changeScene("res://scenes/main.tscn"))
