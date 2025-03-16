extends Node2D

# must be assigned an enemy to track
# each frame rotate to face that enemy
# get a 0-100 distance, fade in intensity depending on how close that enemy is/is not

var enemy : Node2D = null
var enemy_existed : bool = false

@onready var sprite = $Sprite2D

@export var rotate_speed : float = 50
@export var min_distance : float = 2000
@export var max_distance : float = 15000


func setup(_enemy : Node2D):
    enemy = _enemy
    enemy_existed = true
    pass

func _process(_delta):
    if(enemy != null):
        look_at(enemy.position)
        var distance = global_position.distance_to(enemy.global_position)
        var percentage = clamp((distance - min_distance) / (max_distance - min_distance), 0, 1)
        sprite.modulate.a = 1 - percentage
    elif(enemy_existed):
        queue_free()

