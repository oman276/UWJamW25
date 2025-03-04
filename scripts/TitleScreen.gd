extends Sprite2D
@onready var label = $"../Label"

func _ready():
	MusicManager.play_music(preload("res://bensound-timeflies.mp3"))  # Change music
	if label:
		label.text = "WAVE: " + str(utils.wave)

