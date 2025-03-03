extends HBoxContainer

@onready var heart = $Heart
@onready var heart_2 = $Heart2
@onready var heart_3 = $Heart3


# Called when the node enters the scene tree for the first time.
func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		player.heart1 = heart
		player.heart2 = heart_2
		player.heart3 = heart_3


