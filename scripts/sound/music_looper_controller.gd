extends Node
@export var loopStart : AudioStreamWAV = null
@export var loop : AudioStreamWAV = null
@export var thereIsStart : bool  = false
@export var musicID : int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if musicID == -1:
		MusicLooper.stop()
		return
	if musicID == MusicLooper.musicID:
		return
	else:
		MusicLooper.stop()
		MusicLooper.loopStart = loopStart
		MusicLooper.loop = loop
		MusicLooper.musicID = musicID
		MusicLooper.thereIsStart = thereIsStart
		MusicLooper.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func stop():
	MusicLooper.stop()

func play():
	_ready()
