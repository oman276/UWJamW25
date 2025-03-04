extends Node2D

@export var icarus_spr : TextureRect
@export var main_text : TextureRect
@export var start_btn : TextureRect
@export var instructions_btn : TextureRect
 
var move_distance : float = 200
var move_duration : float = 1.3

func _ready():
	var tween = create_tween()
	var start_pos = icarus_spr.position
	var target_pos = start_pos + Vector2(0, -move_distance)  # Move up

	tween.tween_property(icarus_spr, "position", target_pos, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(icarus_spr, "position", start_pos, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.set_loops()

func _on_start_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		GameManager.load_level(GameManager.LEVELS.Game)

func _on_instructions_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#load instructions... eventually
		pass
