extends SimpleEnemy
@onready var lunge_timer = $LungeTimer

enum LUNGE_STATE {
	Moving,
	Paused,
	Lunging
}

var current_lunge_state = LUNGE_STATE.Moving

@export var base_speed : float = 200.0
@export var base_acceleration : float = 200.0

@export var lunge_speed : float = 1000.0
@export var lunge_friction : float = 100.0

@export var slowdown_speed : float = 700.0

func _ready():
	super._ready()
	velocity = Vector2.ZERO
	base_color = Color.ORANGE

func _physics_process(delta):
	pass
	#seek the target (player), move towards it until it gets to X distance away from the player.
	#var direction = get_linear_to_player()
	## set velocity 
	#if(current_lunge_state == LUNGE_STATE.Moving):
		#velocity = velocity.move_toward(direction * base_speed, base_acceleration * delta)
	#elif(current_lunge_state == LUNGE_STATE.Paused):
		#velocity = velocity.move_toward(Vector2.ZERO, slowdown_speed * delta)
	#else:
		##lunging slowdown
		#velocity = velocity.move_toward(Vector2.ZERO, lunge_friction * delta)
	#move_and_slide()
	
	#check our distance from the player, if we're close enough stop to lunge
