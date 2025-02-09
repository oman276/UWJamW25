extends SimpleEnemy
@onready var shoot_timer = $ShootTimer

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
	move_and_slide()
	rotate_to_player()

func _on_shoot_timer_timeout():
	#fire bullet
	pass
