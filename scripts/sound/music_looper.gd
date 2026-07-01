extends Node
@export var loopStart : AudioStreamWAV
@export var loop : AudioStreamWAV
@export var thereIsStart : bool
## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Loop.stream = loop
	if thereIsStart:
		$LoopStart.stream = loopStart
		$LoopStart.play()
	else:
		$Loop.play()

func _on_loop_start_finished() -> void:
	$Loop.play()
