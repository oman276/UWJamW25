class_name MainScene

extends Node2D
@onready var player = $Player
@export var wave_move_scale : float = 3
@export var waves : Array[Sprite2D] = []
@onready var timer = $Timer
@onready var new_wave_ = $"CanvasLayer/New Wave!"
@onready var score_list: RichTextLabel = $CanvasLayer/ScoreList
@onready var combo: RichTextLabel = $CanvasLayer/Combo
@onready var added_score: RichTextLabel = $CanvasLayer/AddedScore

@export var chase_enemy : PackedScene
@export var lunge_enemy : PackedScene
@export var shoot_enemy : PackedScene

@export var spawns : Array[Node2D] = []

var initial_wave_positions : Array[Vector2] = []

var wave : int = 1
var enemies_remaining : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	for wave in waves:
		initial_wave_positions.append(wave.position)
	
	wave = 1
	spawn_new_wave(1)

func spawn_new_wave(num : int):
	enemies_remaining = num
	timer.stop()
	timer.wait_time = 3
	timer.start()
	
	new_wave_.modulate.a = 0
	new_wave_.text = " WAVE " + str(num)

	var tween = get_tree().create_tween()
	tween.tween_property(new_wave_, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(1.0)
	tween.tween_property(new_wave_, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_SINE)
	
	for i in range(num):
		var enemy_type = randi_range(1, 10)
		var spawn_loc = randi_range(0, 4)
		var enemy : PackedScene
		if enemy_type <= 7:
			enemy = chase_enemy
		elif enemy_type <= 9:
			enemy = lunge_enemy
		else:
			enemy = shoot_enemy
		var enemy_ins = enemy.instantiate()
		add_child(enemy_ins)
		enemy_ins.global_position = spawns[spawn_loc].global_position
		
		$RespawnTimer.start(1)  # Start a 5-second timer
		await $RespawnTimer.timeout

func enemy_died():
	enemies_remaining -= 1
	if enemies_remaining == 0:
		wave += 1
		utils.wave = wave
		spawn_new_wave(wave)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Pivot.rotation += 1 * delta
	
	for i in range(waves.size()):
		waves[i].position = initial_wave_positions[i] + 0.3 * wave_move_scale * $Pivot/Mover.global_position

func _on_timer_timeout():
	new_wave_.text = ""
