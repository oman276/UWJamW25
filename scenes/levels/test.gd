extends Node2D


var initial_wave_pos_1
var initial_wave_pos_2
var initial_wave_pos_3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_wave_pos_1 = $Wave1.position
	initial_wave_pos_2 = $Wave2.position
	initial_wave_pos_3 = $Wave3.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Pivot.rotation += 1 * delta
	print($Pivot/Mover.global_position)
	$Wave1.position = initial_wave_pos_1 + 0.3 * $Pivot/Mover.global_position
	$Wave2.position = initial_wave_pos_2 + 0.2 * $Pivot/Mover.global_position
	$Wave3.position = initial_wave_pos_3 + 0.4 * $Pivot/Mover.global_position
