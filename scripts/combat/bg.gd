extends Node2D
@export var colorI :Color 
@export var colorF :Color 
@export var time : float
@onready var bg : ColorRect = $CanvasLayer/bg
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bg.color = colorI
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(bg, "color", colorF,time)
	tween.tween_property(bg, "color", colorI,time)
	tween.set_loops()
