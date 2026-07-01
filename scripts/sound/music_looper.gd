extends Node
@export var loopStart : AudioStreamWAV
@export var loop : AudioStreamWAV
@export var thereIsStart : bool
@export var musicID : int = 0
@onready var loopN : AudioStreamPlayer = $Loop
@onready var loopstartN : AudioStreamPlayer = $LoopStart

func play() -> void:
	loopN.stream = loop
	if thereIsStart:
		loopstartN.stream = loopStart
		loopstartN.play()
	else:
		loopN.play()

func _on_loop_start_finished() -> void:
	loopN.play()

func stop():
	loopN.stop()
	loopstartN.stop()
