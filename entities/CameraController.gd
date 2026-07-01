extends Camera2D


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	zoom = Vector2(2,2)
	var tweenO : Tween = create_tween()
	tweenO.set_ease(Tween.EASE_OUT)
	tweenO.set_trans(Tween.TRANS_SINE)
	tweenO.tween_property(self, "zoom", Vector2.ONE,2)

func closeup():
	var tweenI : Tween = create_tween()
	tweenI.set_ease(Tween.EASE_OUT)
	tweenI.set_trans(Tween.TRANS_SINE)
	tweenI.tween_property(self, "zoom", Vector2(1.5,1.5),1)

func return_to_base():
	var tweenO : Tween = create_tween()
	tweenO.set_ease(Tween.EASE_OUT)
	tweenO.set_trans(Tween.TRANS_SINE)
	tweenO.tween_property(self, "zoom", Vector2.ONE,1)
