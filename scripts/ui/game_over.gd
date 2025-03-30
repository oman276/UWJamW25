extends Node2D
@onready var label: Label = $Label

func _ready() -> void:
	# Set the label text to show the score and high score
	var score = GameManager.current_score
	var high_score = GameManager.high_score
	label.text = "Your Score: " + str(score).pad_zeros(5) + "\nHigh Score: " + str(high_score).pad_zeros(5)

	GameManager.reset_score()

func _on_start_button_input_event(viewport:Node, event:InputEvent, shape_idx:int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		GameManager.load_level(GameManager.LEVELS.MainMenu)
		pass
