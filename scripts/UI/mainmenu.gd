extends UI

func ready() -> void:
	$MarginContainer/HBoxContainer/VBoxContainer2/Buttons/test_btn.grab_focus()

func changeScene(file):
	set_process_input(false)
	var play = func play():
		get_tree().change_scene_to_file(file)
	$Sounds/Play.play()
	Global.transicion_fundido(5,play)

func _on_test_btn_pressed() -> void:
	changeScene("res://scenes/test.tscn")


func _on_exit_btn_pressed() -> void:
	get_tree().quit()


func _on_test_ii_btn_pressed() -> void:
	changeScene("res://scenes/map/dungeon.tscn")
