extends UI

func ready() -> void:
	$MarginContainer/HBoxContainer/VBoxContainer2/Buttons/load_btn.grab_focus()

func changeScene(file):
	set_process_input(false)
	var play = func play():
		get_tree().change_scene_to_file(file)
	$Sounds/Play.play()
	var tweenI = create_tween()
	tweenI.set_ease(Tween.EASE_OUT)
	tweenI.set_trans(Tween.TRANS_LINEAR)
	tweenI.tween_property($ColorRect, "modulate", Color.WHITE,3)
	tweenI.tween_callback(play.call)

func _on_test_btn_pressed() -> void:
	changeScene("res://scenes/test.tscn")


func _on_exit_btn_pressed() -> void:
	get_tree().quit()


func _on_test_ii_btn_pressed() -> void:
	changeScene("res://scenes/testII.tscn")
