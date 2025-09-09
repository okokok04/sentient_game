extends CharacterBody2D

var bullet = preload ("res://Bullet.tscn")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var muzzle : Marker2D = $Muzzle

const GRAVITY = 1000
const SPEED = 200
const JUMP = -500
const JUMP_HORIZONTAL = 110

@export var jump : int = -450
@export var jump_horizontal_speed : int = 1000
@export var max_jump_horizontal_speed: int = 250

enum State { Idle, Run, Jump, Shoot }

var current_state : State
var muzzle_position

func _ready():
	current_state = State.Idle
	muzzle_position = muzzle.position

func _physics_process(delta):
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)
	
	player_muzzle_position()
	player_shooting(delta)
	
	move_and_slide()
	
	player_animations()
	
	#print("State: ", State.keys()[current_state])


func player_falling(delta):
	if !is_on_floor():
		velocity.y += GRAVITY * delta


func player_idle(delta):
	if is_on_floor():
		current_state = State.Idle


func player_run(delta):
	if !is_on_floor():
		return
	
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if direction != 0:
		current_state = State.Run
		animated_sprite_2d.flip_h = false if direction > 0 else true


func player_jump(delta : float):
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump
		current_state = State.Jump
		
	if !is_on_floor() and current_state == State.Jump:
		var direction = input_movement()
		velocity.x += direction * jump_horizontal_speed * delta
		velocity.x = clamp(velocity.x, -max_jump_horizontal_speed, max_jump_horizontal_speed)
		animated_sprite_2d.flip_h = false if direction > 0 else true
func input_movement():
	var direction : float = Input.get_axis("move_left", "move_right")
	
	return direction
	
func player_shooting(delta : float):
	var direction = input_movement()
	
	if direction != 0 and Input.is_action_just_pressed("Shoot"):
		var bullet_instance = bullet.instantiate() as Node2D
		bullet_instance.direction = direction
		bullet_instance.global_position = muzzle.global_position
		get_parent().add_child(bullet_instance)
		current_state = State.Shoot
		

func player_muzzle_position():
	var direction = input_movement()
	if direction > 0:
		muzzle.position.x = muzzle_position.x
	elif  direction < 0:
		muzzle.position.x = -muzzle_position.x

func player_animations():
	if current_state == State.Idle:
		animated_sprite_2d.play("idle")
	elif  current_state == State.Run and animated_sprite_2d.animation != "Shoot":
		animated_sprite_2d.play("run")
	elif current_state == State.Jump:
		animated_sprite_2d.play("jump")
	elif current_state == State.Shoot:
		animated_sprite_2d.play("Shoot")
