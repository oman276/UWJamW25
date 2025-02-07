extends CharacterBody2D
@onready var movement_lock = $MovementLock
@onready var color_rect = $ColorRect

enum PLAYER_MOVE_STATE {
	Free,
	Slashing,
	Dodging,
	FreezeFrame,
}

enum PLAYER_DAMAGE_STATE {
	Vulnerable,
	Slashing,
	FreezeFrame,
}

@export var speed: float = 200.0
@export var acceleration: float = 800.0
@export var friction: float = 600.0

@export var slash_multiplier: float = 10.0
@export var slash_acceleration_multiplier = 10.0
@export var slash_friction_multiplier = 4.0

@export var speed_kept_on_bounce = 0.85

@export var dodge_multiplier: float = 3.0
@export var dodge_acceleration_multiplier = 3.0

var current_state: PLAYER_MOVE_STATE = PLAYER_MOVE_STATE.Free
var current_damage_state: 

var last_input_dir: Vector2 = Vector2(0, 0)
var last_slash_dir: Vector2 = Vector2(0, 0)
var last_dodge_dir: Vector2 = Vector2(0, 0)

func lock_movement_for(seconds: float):
	movement_lock.stop()
	movement_lock.wait_time = seconds
	movement_lock.start()

func slash_attack(dir: Vector2):
	velocity = Vector2.ZERO
	current_state = PLAYER_MOVE_STATE.Slashing
	lock_movement_for(0.1)
	last_slash_dir = dir

func dodge_attack():
	current_state = PLAYER_MOVE_STATE.Dodging
	lock_movement_for(0.2)
	velocity = velocity * dodge_multiplier
	

func _input(event: InputEvent) -> void:
	#input to only register if player is free
	if current_state == PLAYER_MOVE_STATE.Free:
		
		#Slash
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var global_mouse_position = get_global_mouse_position()
			var relative_mouse_position = (global_mouse_position - global_position).normalized()
			slash_attack(relative_mouse_position)
		
		#Dodge
		if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
			var global_mouse_position = get_global_mouse_position()
			var relative_mouse_position = (global_mouse_position - global_position).normalized()
			dodge_attack()
			

func _physics_process(delta: float) -> void:
	#handle input if free
	if(current_state == PLAYER_MOVE_STATE.Free):
		var input_vector = Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		).normalized()
		if input_vector != Vector2.ZERO:
			velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
		last_input_dir = input_vector
	elif (current_state == PLAYER_MOVE_STATE.Slashing):
		velocity = velocity.move_toward(last_slash_dir * speed * slash_multiplier, acceleration * delta * slash_acceleration_multiplier)
	elif (current_state == PLAYER_MOVE_STATE.Dodging):
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta * dodge_acceleration_multiplier)
		#velocity = velocity.move_toward(last_input_dir * speed * dodge_multiplier, acceleration * delta * dodge_acceleration_multiplier)
	
	var prev_velocity = velocity
	move_and_slide()
	
	#bounce if we've hit anything
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		if collision != null:
			var bounce_vel = prev_velocity.bounce(collision.get_normal()) * speed_kept_on_bounce
			if (bounce_vel.length() < speed):
				velocity = bounce_vel
			else:
				velocity = bounce_vel.normalized() * speed * 1.2


func _on_movement_lock_timeout():
	current_state = PLAYER_MOVE_STATE.Free
