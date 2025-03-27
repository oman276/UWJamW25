extends Node2D

@onready var timer = $Timer

func _ready():
  timer.start()

func _on_timer_timeout() -> void:
  GameManager.load_level(GameManager.LEVELS.MainMenu)