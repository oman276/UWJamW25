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

@export var bonus_ability_regen_per_sec : float = 10

var player : Node2D
@onready var death_freeze_timer = $DeathFreezeTimer

@export var base_sprites : Array[Sprite2D]

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
	player.ability_cooldown -= bonus_ability_regen_per_sec * delta

func _physics_process(delta: float) -> void:
	var direction = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = direction * speed * current_speed_percent
	move_and_slide()

func _base_enemy_move():
	if GameManager.current_global_state == GameManager.GLOBAL_GAME_STATE.Default :
		move_and_slide()

func rotate_to_player():
	if player:
		var direction = (player.global_position - global_position).normalized()
		rotation = direction.angle()

func make_path():
	nav_agent.target_position = player.global_position
	next_path_pos_dir = to_local(nav_agent.get_next_path_position()).normalized()

	if not nav_agent.is_target_reachable():
		print("No valid path found!")
	else:
		print("Path found!")

func _on_trigger_body_entered(body):
	if body is Player:
		if body.current_damage_state == Player.PLAYER_DAMAGE_STATE.Slashing:
			_death()
		else:
			body.knockback(global_position)

func _death():
	if GameManager.is_live():
		GameManager.current_global_state = GameManager.GLOBAL_GAME_STATE.TempFreeze
		death_freeze_timer.wait_time = 0.2
		death_freeze_timer.start()
		
		# Not working right now for some reason :(
		for sprite in base_sprites:
			var tween = create_tween().set_loops()
			tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
			tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.2)

func _on_timer_timeout():
	make_path()

func _on_death_freeze_timer_timeout():
	GameManager.current_global_state = GameManager.GLOBAL_GAME_STATE.Default
	get_parent().enemy_died()
	queue_free()
