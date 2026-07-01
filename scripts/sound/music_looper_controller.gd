extends Node
@export var loopStart : AudioStreamWAV
@export var loop : AudioStreamWAV
@export var thereIsStart : bool
@export var musicID : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
