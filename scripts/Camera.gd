extends Camera2D

@export var target: NodePath
@export var smoothing_enabled: bool = true
@export var smoothing_speed: float = 5.0

@export var bottom_left : Node2D
@export var top_right : Node2D

func _process(delta):
	if target:
		var target_position = get_node(target).global_position

		#if target_position.y > 450:
			#target_position.y = 450
		#if target_position.y < 275:
			#target_position.y = 275
			
		print("Target Pos:", target_position)
		print("Bottom Left:", bottom_left.global_position)
		print("Top Right:", top_right.global_position)

		
		target_position.x = clamp(target_position.x, bottom_left.global_position.x, top_right.global_position.x)
		target_position.y = clamp(target_position.y, top_right.global_position.y, top_right.global_position.y)	
		
		if smoothing_enabled:
			global_position = global_position.lerp(target_position, smoothing_speed * delta)
		else:
			global_position = target_position
			
			
			
		# Get the camera half extents based on viewport size and zoom
		#var viewport_size = get_viewport_rect().size
		#var half_extents = (viewport_size * 0.5) * zoom  # Adjust for zoom
		#print(half_extents)
		# Clamp camera position so edges don't exceed bounds
		#global_position.x = clamp(global_position.x, bottom_left.global_position.x, top_right.global_position.x)
		#global_position.y = clamp(global_position.y, bottom_left.global_position.y, top_right.global_position.y)

