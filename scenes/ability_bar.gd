extends TextureProgressBar

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	value = player.ability_cooldown
