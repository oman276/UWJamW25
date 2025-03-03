extends Camera2D

@export var target: Player
@export var smoothing_enabled: bool = true
@export var smoothing_speed: float = 5.0

@export var bottom_left : Node2D
@export var top_right : Node2D

var base_zoom : Vector2
@export var max_zoom_add : Vector2 = Vector2(5, 5)
var player_max_speed : float = 0
@export var zoom_speed : float = 5

func _ready():
	try_find_player()
	base_zoom = zoom


func _process(delta):
	if target:
		var target_position = target.global_position
		
		target_position.x = clamp(target_position.x, bottom_left.global_position.x, top_right.global_position.x)
		target_position.y = clamp(target_position.y, top_right.global_position.y, bottom_left.global_position.y)	
		
		if smoothing_enabled:
			global_position = global_position.lerp(target_position, smoothing_speed * delta)
		else:
			global_position = target_position
		
		#get velocity of player as a % of max velocity 
		if player_max_speed > 0:
			var current_speed = target.velocity/player_max_speed
			print("current speed perc: " + current_speed)
			var target_zoom = base_zoom + max_zoom_add * current_speed
			zoom.lerp(target_zoom, delta * zoom_speed)
				
	else:
		try_find_player()

func try_find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]
		player_max_speed = target.speed * target.slash_multiplier

