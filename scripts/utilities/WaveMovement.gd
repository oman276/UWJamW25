extends Node2D

@onready var wave_1: Sprite2D = $Wave1
@onready var wave_2: Sprite2D = $Wave2
@onready var wave_3: Sprite2D = $Wave3
@onready var pivot: Node2D = $Pivot
@onready var mover: Node2D = $Pivot/Mover

@export var wave_move_scale: float = 3
@export var rotate_speed : float = 2

var waves : Array[Sprite2D] = []
var initial_wave_positions: Array[Vector2] = []

func _ready() -> void:
	waves.append(wave_1)
	waves.append(wave_2)
	waves.append(wave_3)

	for i in range(3):
		initial_wave_positions.append(waves[i].global_position)

func _process(delta):
	pivot.rotation += delta * rotate_speed
	for i in range(3):
		waves[i].global_position = initial_wave_positions[i] + (0.1 + (0.1 * i)) * wave_move_scale * to_local(mover.global_position)