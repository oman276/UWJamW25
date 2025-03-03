class_name FreezeEffect

extends Node2D
@onready var freeze_vfx = $FreezeVFX

var enemies_in_array : Array = []
var effect_active : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if effect_active:
		for enemy in enemies_in_array:
			enemy.slowdown(delta)

func _on_area_2d_body_entered(body):
	if body is SimpleEnemy and not enemies_in_array.has(body):
		enemies_in_array.append(body)

func _on_area_2d_body_exited(body):
	if body is SimpleEnemy and enemies_in_array.has(body):
		enemies_in_array.erase(body)
