class_name WOIPlayer

extends CharacterBody2D
@onready var movement_lock = $MovementLock
@onready var color_rect = $ColorRect
@onready var attack_timer = $AttackTimer
@onready var visual_timer = $VisualTimer
@onready var freeze_effect = $FreezeEffect
@onready var fire_effect = $FireVFX
@onready var freeze_vfx = $FreezeEffect/FreezeVFX
@onready var freeze_timer = $FreezeTimer
@onready var invuln_timer = $InvulnTimer
@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var wing_l: Polygon2D = $Polygons/wing_left
@onready var wing_r: Polygon2D = $Polygons/wing_right

var anim_timer := Timer.new()
var dash_toggle = false

var player_scale = 0

var ability_cooldown: float = 0
@export var ability_cooldown_drop_per_sec: float = 5
@export var ability_per_use: float = 30

enum PLAYER_MOVE_STATE {
	Free,
	Slashing,
	Dodging,
	FreezeFrame,
	Knockback,
	DeathFall
}

enum PLAYER_DAMAGE_STATE {
	Vulnerable,
	Slashing,
	FreezeFrame,
	Invulnerable,
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

@export var knockback_multiplier: float = 4.0
@export var knockback_acceleration_multiplier = 4.0

@export var invuln_time: float = 0.7

@export var starting_health: int = 3
var health: int = starting_health

var current_state: PLAYER_MOVE_STATE = PLAYER_MOVE_STATE.Free
var current_damage_state: PLAYER_DAMAGE_STATE = PLAYER_DAMAGE_STATE.Vulnerable

var last_input_dir: Vector2 = Vector2(0, 0)
var last_slash_dir: Vector2 = Vector2(0, 0)
var last_dodge_dir: Vector2 = Vector2(0, 0)

var freeze_effect_active: bool = false

var heart1
var heart2
var heart3

var facing_left = true

@export var freeze_frame_time: float = 0.1

@export var character_polys: Array[Polygon2D]
var tweens: Array[Tween]

var arrow_scn
@onready var enemy_indicator_hub: Node2D = $EnemyIndicatorHub

var combo: int = 0

@onready var slash_attack_active: bool = false

@onready var bonk_particles_str = "res://scenes/vfx/bonk_effect.tscn"
@export var bonk_speed_threshold: float = 100.0

#Audio
@onready var bonk_sound_player := AudioStreamPlayer.new()
const bonk_sound_path: String = "res://audio/wall_bump.mp3"

@onready var attack_sound_player := AudioStreamPlayer.new()
const fire_sound_path: String = "res://audio/fire_attack.mp3"
const damage_sound_path: String = "res://audio/damage_taken.mp3"

@onready var looping_sound_player := AudioStreamPlayer.new()
const ice_sound_path: String = "res://audio/freeze_effect.ogg"

func _ready():
	freeze_vfx.modulate.a = 0
	fire_effect.emitting = false
	
	add_child(anim_timer)
	anim_timer.wait_time = 1.0
	anim_timer.one_shot = true
	player_scale = self.scale.x

	freeze_vfx.emitting = false
	freeze_effect_active = false
	GameManager.current_global_state = GameManager.GLOBAL_GAME_STATE.Default

	arrow_scn = preload("res://scenes/objects/EnemyIndicator.tscn")
	
	bonk_sound_player.max_polyphony = 4
	bonk_sound_player.autoplay = true
	bonk_sound_player.volume_db = -20
	add_child(bonk_sound_player)

	attack_sound_player.max_polyphony = 3
	attack_sound_player.autoplay = true
	attack_sound_player.volume_db = 1
	add_child(attack_sound_player)

	looping_sound_player.max_polyphony = 1
	looping_sound_player.autoplay = true
	looping_sound_player.volume_db = 1
	looping_sound_player.stream = preload(ice_sound_path)
	looping_sound_player.stream.loop = true
	add_child(looping_sound_player)
	looping_sound_player.stop()

func death():
	current_state = PLAYER_MOVE_STATE.DeathFall
	current_damage_state = PLAYER_DAMAGE_STATE.Invulnerable
	collision_layer = 0
	collision_mask = 0
	wing_l.visible = false
	wing_r.visible = false

	velocity = Vector2.ZERO

	freeze_effect.visible = false
	freeze_vfx.emitting = false

	for child in enemy_indicator_hub.get_children():
		if child.is_inside_tree():
			child.queue_free()

	await get_tree().create_timer(4).timeout
	GameManager.load_level(GameManager.LEVELS.PostGame)
	pass
	
func lock_movement_for(seconds: float):
	movement_lock.stop()
	movement_lock.wait_time = seconds
	movement_lock.start()

func slash_attack(dir: Vector2):
	combo = 0

	ability_cooldown += ability_per_use
	if ability_cooldown >= 100:
		death()
		return
	
	anim_timer.start()
	dash_toggle = true
	$AnimationPlayer.play("dash")
	
	velocity = Vector2.ZERO
	current_state = PLAYER_MOVE_STATE.Slashing
	lock_movement_for(0.1)
	last_slash_dir = dir
	
	attack_timer.stop()
	attack_timer.wait_time = invuln_time
	attack_timer.start()
	
	current_damage_state = PLAYER_DAMAGE_STATE.Slashing

	attack_sound_player.stream = preload(fire_sound_path)
	attack_sound_player.play()

func dodge_attack():
	current_state = PLAYER_MOVE_STATE.Dodging
	lock_movement_for(0.2)
	velocity = velocity * dodge_multiplier
	
func knockback(origin_pos: Vector2):
	if current_state != PLAYER_MOVE_STATE.DeathFall:
		current_state = PLAYER_MOVE_STATE.Knockback
	
	color_rect.color = Color.DARK_RED
	visual_timer.stop()
	visual_timer.wait_time = 0.2
	visual_timer.start()
	lock_movement_for(0.2)
	
	velocity = speed * knockback_multiplier * (global_position - origin_pos).normalized()

	attack_sound_player.stream = preload(damage_sound_path)
	attack_sound_player.play()
	
	GameManager.current_global_state = GameManager.GLOBAL_GAME_STATE.TempFreeze
	get_parent().hit_slowdown_begin(0.03)
	invuln_timer.stop()
	invuln_timer.wait_time = 2
	invuln_timer.start()

	for tween in tweens:
		if tween:
			tween.kill()
	tweens.clear()

	for polygon in character_polys:
			var tween = create_tween().set_loops()
			tweens.append(tween)
			tween.tween_property(polygon, "modulate", Color.WHITE, 0.2)
			tween.tween_property(polygon, "modulate", Color(1, 1, 1, 0), 0.2)

	if current_damage_state != PLAYER_DAMAGE_STATE.Invulnerable:
		if not is_inside_tree():
			return
		
		health -= 1
		
		heart1.visible = health >= 3
		heart2.visible = health >= 2
		heart3.visible = health >= 1
		if (health == 0):
			death()
			
	current_damage_state = PLAYER_DAMAGE_STATE.Invulnerable

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
			dodge_attack()
			
		#Freeze Effect Start
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			freeze_effect_active = true
			looping_sound_player.play()
			
		#Freeze Effect End
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_released():
			freeze_effect_active = false
			freeze_vfx.emitting = false
			looping_sound_player.stop()
			var tween: Tween = create_tween()
			tween.tween_property(freeze_vfx, "modulate:a", 0, 0.5).from(1)
			pass

func _physics_process(delta: float) -> void:
	if GameManager.current_global_state == GameManager.GLOBAL_GAME_STATE.Default:
		#handle input if free
		var input_vector = Vector2(
				Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
				Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
			).normalized()
		if (current_state == PLAYER_MOVE_STATE.Free):
			if input_vector != Vector2.ZERO:
				velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
			else:
				velocity = velocity.move_toward(Vector2(0, 0), friction * delta)
			last_input_dir = input_vector
		elif (current_state == PLAYER_MOVE_STATE.Slashing):
			velocity = velocity.move_toward(last_slash_dir * speed * slash_multiplier, acceleration * delta * slash_acceleration_multiplier)
		elif (current_state == PLAYER_MOVE_STATE.Dodging || current_state == PLAYER_MOVE_STATE.Knockback):
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta * dodge_acceleration_multiplier)
		elif (current_state == PLAYER_MOVE_STATE.DeathFall):
			velocity = velocity.move_toward(Vector2.DOWN * speed, acceleration * delta * 0.25)
		
		var prev_velocity = velocity
		move_and_slide()
		var angle_to_turn = velocity.angle()
		if velocity.x < 0 and facing_left == true:
			facing_left = false
			self.scale.x = - player_scale
		elif velocity.x > 0 and facing_left == false:
			facing_left = true
			self.scale.x = - player_scale
		if velocity.x == 0 and facing_left != true:
			angle_to_turn = 3.14
		var current_angle = lerp_angle(self.rotation, angle_to_turn, 3 * delta)
		self.rotation = current_angle # Apply to the Node2D rotation
		
		#bounce if we've hit anything
		if get_slide_collision_count() > 0:
			var collision = get_slide_collision(0)
			if collision != null:
				var bounce_vel = prev_velocity.bounce(collision.get_normal()) * speed_kept_on_bounce
				if (bounce_vel.length() < speed):
					velocity = bounce_vel
					velocity = velocity
				else:
					velocity = bounce_vel.normalized() * speed * 1.2

				if velocity.length() > bonk_speed_threshold:
					var bonk_effect = load(bonk_particles_str)
					var bonk_instance = bonk_effect.instantiate()
					get_tree().current_scene.add_child(bonk_instance)
					bonk_instance.global_position = global_position
					bonk_instance.start_effect()

					bonk_sound_player.stream = preload(bonk_sound_path)
					bonk_sound_player.play()
	
	if anim_timer.time_left == 0 && dash_toggle == true:
		$AnimationPlayer.play("flight")
		dash_toggle = false
	
	freeze_effect.effect_active = freeze_effect_active
	
	if freeze_effect_active:
		#rotate the object to face the mouse
		var mouse_pos = get_global_mouse_position()
		var direction = (mouse_pos - global_position).normalized()
		var angle = direction.angle()
		freeze_effect.global_rotation = angle
		if freeze_vfx.emitting == false:
			freeze_vfx.emitting = true
			var tween: Tween = create_tween()
			tween.tween_property(freeze_vfx, "modulate:a", 1, 0.5).from(0)
	fire_effect.rotation_degrees = self.rotation_degrees
	
	ability_cooldown -= ability_cooldown_drop_per_sec * delta
	if ability_cooldown < 0:
		ability_cooldown = 0

	if current_damage_state == PLAYER_DAMAGE_STATE.Slashing:
		fire_effect.emitting = true
	else:
		fire_effect.emitting = false

func _on_movement_lock_timeout():
	if current_state != PLAYER_MOVE_STATE.DeathFall:
		current_state = PLAYER_MOVE_STATE.Free
	else:
		print("locked?")

func _on_attack_timer_timeout():
	current_damage_state = PLAYER_DAMAGE_STATE.Vulnerable
	color_rect.color = Color.WHITE
	fire_effect.emitting = false

func _on_visual_timer_timeout():
	if color_rect.color == Color.DARK_RED:
		color_rect.color = Color.WHITE

func _on_freeze_timer_timeout():
	GameManager.current_global_state = GameManager.GLOBAL_GAME_STATE.Default
	Engine.time_scale = 1.0

func _on_invuln_timer_timeout():
	print("Invuln Timer ended")
	if current_damage_state == PLAYER_DAMAGE_STATE.Invulnerable:
		current_damage_state = PLAYER_DAMAGE_STATE.Vulnerable
	
	for tween in tweens:
		if tween:
			tween.kill()
	tweens.clear()
	
	for polygon in character_polys:
		polygon.modulate = Color(1, 1, 1, 1)

func add_enemy_indicator(enemy: Node2D):
	var indicator = arrow_scn.instantiate()
	enemy_indicator_hub.add_child(indicator)
	indicator.setup(enemy)

func hit_enemy():
	combo += 1
	get_parent().add_score(combo)
