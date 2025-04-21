extends Node2D

@export var icarus_spr : TextureRect
@export var main_text : TextureRect
@export var instructions : TextureRect
 
var move_distance : float = 200
var move_duration : float = 1.3

func _ready():
	var tween = create_tween()
	var start_pos = icarus_spr.position
	var target_pos = start_pos + Vector2(0, -move_distance)  # Move up

	tween.tween_property(icarus_spr, "position", target_pos, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(icarus_spr, "position", start_pos, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.set_loops()

	instructions.visible = false
	instructions.modulate.a = 0.0

func _on_start_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		GameManager.load_level(GameManager.LEVELS.Game)

func _on_instructions_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		instructions.modulate.a = 0.0
		instructions.visible = true
		var tween = create_tween()
		tween.tween_property(instructions, "modulate:a", 1.0, 0.276).set_trans(Tween.TRANS_LINEAR)

func _on_instructions_quit_gui_input(event:InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var tween = create_tween()
		tween.tween_property(instructions, "modulate:a", 0.0, 0.276).set_trans(Tween.TRANS_LINEAR)
		
		await tween.finished
		instructions.modulate.a = 0.0
		instructions.visible = false
