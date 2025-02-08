extends Camera2D

@export var target: NodePath
@export var smoothing_enabled: bool = true
@export var smoothing_speed: float = 5.0

func _process(delta):
    if target:
        var target_position = get_node(target).global_position
        print(target_position)
        if target_position.y > 450:
            target_position.y = 450
        if target_position.y < 275:
            target_position.y = 275
        if smoothing_enabled:
            global_position = global_position.lerp(target_position, smoothing_speed * delta)
        else:
            global_position = target_position
