class_name SimpleEnemy

extends CharacterBody2D

@onready var nav_agent = $NavigationAgent2D
@onready var color_rect = $ColorRect

var base_color : Color
var frozen_color : Color = Color.SKY_BLUE

@export var speed := 100.0
@export var target: NodePath

@export var min_speed_percentage : float = 0.1
@export var slowdown_per_sec : float = 0.3
var current_speed_percent : float = 1.0

@export var regen_rate_per_sec : float = 0.05
var next_path_pos_dir : Vector2 = Vector2.ZERO

var player : Node2D

func _ready():
	base_color = $Sprites.modulate
	player = get_node_or_null(target)
	if player == null:
		player = get_node("../Player")
		if player == null:
			print("fuck")


func _process(delta):
	current_speed_percent += regen_rate_per_sec * delta
	if current_speed_percent > 1:
		current_speed_percent = 1
	
	$Sprites.modulate = base_color.lerp(frozen_color, 1 - current_speed_percent)
	$IceSprite.modulate.a = 1 - current_speed_percent

func slowdown(delta : float):
	current_speed_percent -= delta * slowdown_per_sec
	if current_speed_percent < min_speed_percentage:
		current_speed_percent = min_speed_percentage

func _physics_process(delta: float) -> void:
	var direction = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = direction * speed * current_speed_percent
	move_and_slide()
	

func rotate_to_player():
	if player:
		var direction = (player.global_position - global_position).normalized()
		rotation = direction.angle()

func make_path():
	nav_agent.target_position = player.global_position
	next_path_pos_dir = to_local(nav_agent.get_next_path_position()).normalized()

func _on_trigger_body_entered(body):
	if body is Player:
		if body.current_damage_state == Player.PLAYER_DAMAGE_STATE.Slashing:
			queue_free()
		else:
			body.knockback(global_position)

func _on_timer_timeout():
	make_path()
