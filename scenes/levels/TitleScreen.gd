extends Sprite2D

func _ready():
	MusicManager.play_music(preload("res://bensound-timeflies.mp3"))  # Change music

func _on_start_button_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.is_pressed():
		get_tree().change_scene_to_file("res://scenes/levels/main_scene.tscn")


func _on_instructions_button_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.is_pressed():
		get_tree().change_scene_to_file("res://scenes/levels/instructions.tscn")
