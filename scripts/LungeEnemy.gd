extends SimpleEnemy
@onready var lunge_timer = $LungeTimer
@onready var pause_timer = $PauseTimer
@onready var cooldown_timer = $CooldownTimer

enum LUNGE_STATE {
	Moving,
	Paused,
	Lunging
}

var current_lunge_state = LUNGE_STATE.Moving

@export var base_speed : float = 200.0
@export var base_acceleration : float = 200.0
@export var distance_to_start_lunge : float = 10.0

@export var lunge_speed : float = 1000.0
@export var lunge_friction : float = 100.0

@export var slowdown_speed : float = 700.0

@export var pause_time : float = 0.5
@export var lunge_time : float = 0.3

@export var time_between_lunges : float = 7.0
var can_lunge : bool = true

var target_position : Vector2 = Vector2.ZERO

func _ready():
	super._ready()
	velocity = Vector2.ZERO

func activate_pause_state():
	current_lunge_state = LUNGE_STATE.Paused
	target_position = player.global_position
	
	pause_timer.stop()
	pause_timer.wait_time = pause_time
	pause_timer.start()

func _physics_process(delta):
	#Moving State
	if current_lunge_state == LUNGE_STATE.Moving:
		print("moving")
		var direction = to_local(nav_agent.get_next_path_position()).normalized()
		velocity = velocity.move_toward(direction * base_speed * current_speed_percent * delta, base_acceleration * delta)
		#check distance to player
		if (player != null and can_lunge and global_position.distance_to(player.global_position) < distance_to_start_lunge):
			activate_pause_state()
	#Paused State
	elif current_lunge_state == LUNGE_STATE.Paused:
		print("paused")
		velocity = velocity.move_toward(Vector2.ZERO, slowdown_speed * delta)
	#Lunge Slowdown State
	else:
		print("lunginf")
		velocity = velocity.move_toward(Vector2.ZERO, lunge_friction * delta)
	
	#move_and_slide()
	_base_enemy_move()
	#rotate_to_player()

func _on_pause_timer_timeout():
	current_lunge_state = LUNGE_STATE.Lunging
	velocity = (target_position - global_position).normalized() * lunge_speed
	can_lunge = false
	
	lunge_timer.stop()
	lunge_timer.wait_time = lunge_time
	lunge_timer.start()
	
	cooldown_timer.stop()
	cooldown_timer.wait_time = time_between_lunges
	cooldown_timer.start()

func _on_lunge_timer_timeout():
	current_lunge_state = LUNGE_STATE.Moving

func _on_cooldown_timer_timeout():
	can_lunge = true
