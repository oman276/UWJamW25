extends SimpleEnemy
@onready var shoot_timer = $ShootTimer
@onready var bullet_spawn_host = $BulletSpawnHost
@export var bullet_scene: PackedScene  
@onready var bullet_spawn_point = $BulletSpawnHost/BulletSpawnPoint
@onready var sprites = $Sprites

# SHOOT ENEMY:
# Approach player, stop a solid distance away from them
# When within range, shoot bullet at the target (player)

@export var max_dis_to_player : float = 250.0
var is_shooting : bool = false

@export var friction : float = 300.0
@export var acceleration : float = 200.0
@export var slowdown_friction : float = 150.0
@export var time_between_shots : float = 1.5

func _physics_process(delta):
	if is_shooting:
		#slow vector
		velocity = velocity.move_toward(Vector2.ZERO, slowdown_friction * delta)
		#if player is too far away, exit shooting state
		if global_position.distance_to(player.global_position) > max_dis_to_player:
			is_shooting = false
			shoot_timer.stop()
		pass
	else:
		# lerp in direction of player based on navmesh
		var direction = to_local(nav_agent.get_next_path_position()).normalized()
		velocity = velocity.move_toward(direction * speed * delta, acceleration * delta)
		if global_position.distance_to(player.global_position) < max_dis_to_player:
			is_shooting = true
			shoot_timer.start()
	#move_and_slide()
	_base_enemy_move()
	#rotate_to_player(delta)
	
	#rotate the shooter
	if player:
		var direction = (player.global_position - global_position).normalized()
		bullet_spawn_host.rotation = lerp_angle(rotation, direction.angle(), rotation_speed * delta)
		sprites.rotation = lerp_angle(rotation, direction.angle(), rotation_speed * delta)

func _on_shoot_timer_timeout():
	#fire bullet
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)  # Add to the scene

	bullet.global_transform = bullet_spawn_point.global_transform  
	bullet.velocity = (player.global_position - bullet_spawn_point.global_position).normalized()
