class_name SimpleEnemy

extends CharacterBody2D

@onready var nav_agent = $NavigationAgent2D
@onready var color_rect = $ColorRect
@onready var impact_effect = $ImpactEffect

var is_death_anim : bool = false

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
var base_sprite_positions : Dictionary = {}

@export var rand_scale : float = 1000
var ran_gen : RandomNumberGenerator

@export var rotation_speed: float = 50
#@export var 

func _ready():
	ran_gen = RandomNumberGenerator.new()
	base_color = $Sprites.modulate
	player = get_node_or_null(target)
	if player == null:
		player = get_node("../Player")
		if player == null:
			print("fuck")
	for sprite in base_sprites:
		base_sprite_positions[sprite] = sprite.global_position

func _process(delta):
	if is_death_anim == false:
		current_speed_percent += regen_rate_per_sec * delta
		if current_speed_percent > 1:
			current_speed_percent = 1
		
		$Sprites.modulate = base_color.lerp(frozen_color, 1 - current_speed_percent)
		$IceSprite.modulate.a = 1 - current_speed_percent
	else:
		var rand_x : float = ran_gen.randf_range(-1, 1)
		var rand_y : float = ran_gen.randf_range(-1, 1)
		
		for sprite in base_sprites:
			sprite.global_position = base_sprite_positions[sprite] + Vector2(rand_x, rand_y) * rand_scale

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

func rotate_to_player(delta : float, items : Array[Node2D]):
	if player:
		var direction = (player.global_position - global_position).normalized()
		var target_rotation = direction.angle()
		
		for item in items:
			item.rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)

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
	impact_effect.start_effect()
	is_death_anim = true
	for sprite in base_sprites:
		base_sprite_positions[sprite] = sprite.global_position
	if GameManager.is_live():
		GameManager.current_global_state = GameManager.GLOBAL_GAME_STATE.TempFreeze
		death_freeze_timer.wait_time = 0.1
		death_freeze_timer.start()

func _on_timer_timeout():
	make_path()

func _on_death_freeze_timer_timeout():
	GameManager.current_global_state = GameManager.GLOBAL_GAME_STATE.Default
	get_parent().enemy_died()
	queue_free()
