extends CanvasLayer

@onready var background = $TextureRect
@onready var text = $TextureRect/Label

func _ready():
    background.modulate.a = 1
    text.modulate.a = 1

func fade_in():
    background.visible = true 
    text.visible = true

    var tween = get_tree().create_tween()
    tween.tween_property(background, "modulate:a", 1.0, 0.5)
    tween.tween_property(text, "modulate:a", 1.0, 0.5) 
     

func fade_out():
    var tween = get_tree().create_tween()
    tween.tween_property(background, "modulate:a", 0.0, 0.5)
    tween.tween_property(text, "modulate:a", 0.0, 0.5)  

    await get_tree().create_timer(0.5).timeout
    
    background.visible = false 
    text.visible = false