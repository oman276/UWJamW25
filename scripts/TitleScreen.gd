extends Sprite2D
@onready var label = $"../Label"

func _ready():
	if label:
		var score = GameManager.current_score
		var high_score = GameManager.high_score
		label.text = "Your Score: " + str(score).pad_decimals(5) + "\nHigh Score: " + str(high_score).pad_decimals(5)

