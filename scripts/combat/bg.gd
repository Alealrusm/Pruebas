## Fondo animado: hace un ciclo de interpolación de color entre colorI y colorF en bucle.
extends Node2D

@export var colorI :Color 
@export var colorF :Color 
@export var time : float
@onready var bg : ColorRect = $CanvasLayer/bg

func _ready() -> void:
	bg.color = colorI
	## Crea un tween en bucle que alterna entre los dos colores exportados.
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(bg, "color", colorF,time)
	tween.tween_property(bg, "color", colorI,time)
	tween.set_loops()
