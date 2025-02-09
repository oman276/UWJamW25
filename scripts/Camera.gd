extends Camera2D

@export var target: NodePath
@export var smoothing_enabled: bool = true
@export var smoothing_speed: float = 5.0

@export var bottom_left : Node2D
@export var top_right : Node2D

func _process(delta):
	if target:
		var target_position = get_node(target).global_position
		
		target_position.x = clamp(target_position.x, bottom_left.global_position.x, top_right.global_position.x)
		target_position.y = clamp(target_position.y, top_right.global_position.y, bottom_left.global_position.y)	
		
		if smoothing_enabled:
			global_position = global_position.lerp(target_position, smoothing_speed * delta)
		else:
			global_position = target_position
			
