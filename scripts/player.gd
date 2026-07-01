extends CharacterBody2D
class_name Player
@export var speed = 300
const reach = 70
var run_scale = 1.5
var cur_speed : float
var facing : Vector2
var running = false
var dialog : Dialog
var interact : RayCast2D
var walking = false
@onready var sprite = $Sprite
@onready var camera = $Camera2D
@onready var transition : ColorRect = $CanvasLayer/ColorRect
## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var play = func play():
		transition.hide()
		set_process_input(true)
	set_process_input(false)
	transition.show()
	dialog = $CanvasLayer/Dialog
	interact = $Interact
	get_tree().paused = false
	facing = Vector2.ZERO
	$Footsteps.stop()
	walking = false
	var tweenI : Tween = create_tween()
	tweenI.set_ease(Tween.EASE_OUT)
	tweenI.set_trans(Tween.TRANS_LINEAR)
	tweenI.tween_property(transition, "modulate", Color.TRANSPARENT, 1)
	tweenI.tween_callback(play.call)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("Check"):
		check()
		get_viewport().set_input_as_handled()
	if Input.is_action_just_released("Menu"):
		open_menu()
		get_viewport().set_input_as_handled()


func get_input():
	var cur_scale = 1
	var input_direction = Input.get_vector("Left","Right","Up","Down")
	if(input_direction != Vector2.ZERO):
		facing = input_direction
		interact.target_position = facing*reach
	if running:
		cur_scale = run_scale
	$Footsteps.pitch_scale = cur_scale
	sprite.speed_scale = cur_scale
	cur_speed = speed * cur_scale
	running = Input.is_action_pressed("Run")
	velocity = input_direction * cur_speed
	
func calc_animation():
	if(velocity == Vector2.ZERO):
		sprite.play("idle")
		$Footsteps.stop()
		sprite.flip_h = false
		walking = false
	else:
		if(!walking):
			$Footsteps.play()
			walking = true
			sprite.flip_h = false
		if(velocity.x>0 && velocity.y<0):
			sprite.play("uright")
			sprite.flip_h = false
		elif(velocity.x<0 && velocity.y<0):
			sprite.play("uleft")
			sprite.flip_h = false
		elif(velocity.x>0 && velocity.y ==0):
			sprite.play("right")
			sprite.flip_h = false
		elif(velocity.x<0 && velocity.y==0):
			sprite.play("right")
			sprite.flip_h = true
		elif(velocity.x>0 && velocity.y>0):
			sprite.play("dright")
			sprite.flip_h = false
		elif(velocity.x<0 && velocity.y>0):
			sprite.play("dright")
			sprite.flip_h = true
		elif(velocity.y>0 && velocity.x==0):
			sprite.play("front")
			sprite.flip_h = false
		elif(velocity.y<0 && velocity.x == 0):
			sprite.play("back")
			sprite.flip_h = false

func _physics_process(delta: float) -> void:
	get_input()
	calc_animation()
	move_and_collide(velocity * delta)
	
func open_menu():
	if(!get_tree().paused):
		get_tree().paused = true
		$CanvasLayer/PauseMenu.on_show()

func check():
	if(interact.is_colliding()):
		var collider: Node2D = interact.get_collider()
		if(collider is Interactable):
			camera.closeup()
			var interactable : Interactable = collider
			collider._on_interact()
			await collider.finish
			camera.return_to_base()
		else:
			dialog.show_text("Aquí no hay nada")
	else:
		dialog.show_text("Aquí no hay nada")
		
func set_camera_limit(limitleft : int, limitright: int, limitup : int, limitdown : int):
	camera.limit_enabled = true
	camera.limit_left = limitleft
	camera.limit_right = limitright
	camera.limit_top = limitup
	camera.limit_bottom = limitdown
