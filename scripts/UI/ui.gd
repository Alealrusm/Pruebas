@abstract
extends Control
class_name UI
@abstract func ready()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for a : Control in find_child("Buttons").get_children():
		if a.name != "continue_btn" || a.name != "btn_B":
			a.pressed.connect(_play_pressed)
		if a.name == "btn_B":
			a.pressed.connect(_play_deny)
			
		a.mouse_entered.connect(_play_hover)
		a.focus_entered.connect(_play_hover)
		ready()

func _play_hover():
	$Sounds/Select.play()

func _play_pressed():
	$Sounds/Accept.play()
	
	
func _play_deny():
	$Sounds/Deny.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
