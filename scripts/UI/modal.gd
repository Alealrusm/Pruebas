extends UI
@export var btn_A_text : String
@export var btn_B_text : String
@onready var btn_A : Button = $CenterContainer/Buttons/btn_A
@onready var btn_B : Button = $CenterContainer/Buttons/btn_B

func ready():
	btn_A.text = btn_A_text
	btn_B.text = btn_B_text

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
