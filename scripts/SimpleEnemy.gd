class_name SimpleEnemy

extends CharacterBody2D
@onready var color_rect = $ColorRect
var base_color : Color = Color.RED
var frozen_color : Color = Color.AQUA

@export var speed := 100.0
@export var target: NodePath

@export var min_speed_percentage : float = 0.1
@export var slowdown_per_sec : float = 0.3
var current_speed_percent : float = 1.0

@export var regen_rate_per_sec : float = 0.05

func _ready():
	pass

func _process(delta):
	current_speed_percent += regen_rate_per_sec * delta
	if current_speed_percent > 1:
		current_speed_percent = 1
	
	#color lerp
	color_rect.color = base_color.lerp(frozen_color, 1 - current_speed_percent)

func slowdown(delta : float):
	current_speed_percent -= delta * slowdown_per_sec
	if current_speed_percent < min_speed_percentage:
		current_speed_percent = min_speed_percentage

func _physics_process(delta: float) -> void:
	var player = get_node_or_null(target)
	if player == null:
		return  
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed * current_speed_percent
	move_and_slide()

func _on_trigger_body_entered(body):
	if body is Player:
		if body.current_damage_state == Player.PLAYER_DAMAGE_STATE.Slashing:
			queue_free()
		else:
			body.knockback(global_position)
