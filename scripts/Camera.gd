extends Camera2D

@export var target: NodePath
@export var smoothing_enabled: bool = true
@export var smoothing_speed: float = 5.0

func _process(delta):
	if target:
		var target_position = get_node(target).global_position
		if smoothing_enabled:
			global_position = global_position.lerp(target_position, smoothing_speed * delta)
		else:
			global_position = target_position
