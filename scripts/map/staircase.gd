extends Area2D

func _ready() -> void:
	# Conectamos la señal por código para que sea autosuficiente
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		activar_evento()

func activar_evento() -> void:
	get_tree().change_scene_to_file("res://scenes/map/dungeon.tscn")
