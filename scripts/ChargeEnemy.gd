extends SimpleEnemy

@export var accelleration : float = 100.0

func _physics_process(delta: float) -> void:
	#var direction = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = velocity.move_toward(next_path_pos_dir * speed * current_speed_percent * delta, accelleration * delta)
	#move_and_slide()
	_base_enemy_move()
	#rotate_to_player(delta)
