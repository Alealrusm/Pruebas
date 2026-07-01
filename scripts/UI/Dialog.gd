extends Control
class_name Dialog
signal cerrado
var rolling : bool
var queue : String
var showing_text : String
var i : int
var n : int
var charpersec = 25.0
var secperchar : float
var seccount = 0
@onready var objName : Label = $CenterContainer/Scale/Name
@onready var objText : Label = $CenterContainer/Scale/Text
@onready var scaler : Control = $CenterContainer/Scale
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	secperchar = 1/charpersec
	close_box()

func _input(event: InputEvent) -> void:
	if visible:
		if (Input.is_action_just_released("ui_accept")):
			get_viewport().set_input_as_handled()
			if rolling:
				while i<n:
					if queue[i] == "#":
						break
					else:
						showing_text += queue[i]
						objText.text = showing_text
						i+= 1
						if i == n:
							break
				rolling = false
				
			else:
				if i<n:
					$Sounds/Accept.play()
					showing_text = ""
					i += 1
					rolling = true
				else:
					$Sounds/Deny.play()
					close_box()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if rolling:
		seccount = seccount +  delta
		if(seccount >= secperchar):
			seccount = 0
			$Chat.play()
			if queue[i] == "#":
				rolling = false
			else:	
				showing_text += queue[i]
				objText.text = showing_text
				i+= 1
				if i == n:
					rolling = false

func show_text_name(text : String, name : String):
	objName.text = name
	show_text(text)
	

func show_text(text : String):
	show()
	get_tree().paused = true
	queue = text
	showing_text = ""
	n = queue.length()
	i = 0
	rolling = true
	var done = func done()->void:
		grab_focus()
	var tweenI : Tween = create_tween()
	scaler.modulate = Color.TRANSPARENT
	tweenI.set_ease(Tween.EASE_OUT)
	tweenI.set_trans(Tween.TRANS_SINE)
	tweenI.parallel().tween_property(scaler, "modulate", Color.WHITE,0.20)
	tweenI.tween_callback(done.call)
	

func close_box():
	var done = func done() -> void:
		hide()
		objName.text = ""
		objText.text = ""
		rolling = false
		queue = ""
		showing_text = ""
		get_tree().paused = false
		cerrado.emit()
	var tweenO : Tween = create_tween()
	scaler.modulate = Color.WHITE
	tweenO.set_ease(Tween.EASE_OUT)
	tweenO.set_trans(Tween.TRANS_SINE)
	tweenO.tween_property($CenterContainer/Scale, "scale", Vector2.ZERO ,0.20)
	tweenO.parallel().tween_property(scaler, "modulate", Color.TRANSPARENT,0.20)
	tweenO.tween_callback(done.call)
