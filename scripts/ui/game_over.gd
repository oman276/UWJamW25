extends Node2D

func _on_start_button_input_event(viewport:Node, event:InputEvent, shape_idx:int):
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        GameManager.load_level(GameManager.LEVELS.MainMenu)
        pass
