extends Interactable
@export var Text : String
@onready var dialog : Dialog = $CanvasLayer/Dialog

func _on_interact():
	$InfoSound.play()
	dialog.show_text(Text)
	await dialog.cerrado 
	finish.emit()
