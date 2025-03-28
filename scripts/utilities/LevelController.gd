class_name MainScene

extends Node2D
@onready var player = $Player
@export var wave_move_scale : float = 3
@export var waves : Array[Sprite2D] = []
@onready var timer = $Timer
@onready var new_wave_ = $"CanvasLayer/New Wave!"

@export var chase_enemy : PackedScene
@export var lunge_enemy : PackedScene
@export var shoot_enemy : PackedScene

@export var spawns : Array[Node2D] = []

var initial_wave_positions : Array[Vector2] = []

var wave : int = 1
var enemies_remaining : int = 0

var score : int = 0

@onready var score_list: RichTextLabel = $CanvasLayer/ScoreList
@onready var combo_text: RichTextLabel = $CanvasLayer/Combo
@onready var added_score_text: RichTextLabel = $CanvasLayer/AddedScore 
@onready var score_timer: Timer = $ScoreUITimer

# Called when the node enters the scene tree for the first time.
func _ready():
	for wave in waves:
		initial_wave_positions.append(wave.position)
	
	wave = 1
	spawn_new_wave(1)

	score_list.text = " Score: " + str(score).pad_zeros(5)
	combo_text.modulate.a = 0
	added_score_text.modulate.a = 0


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

func add_score(combo : int):
	var added_score = 100 * combo *2
	score += added_score
	print(score)
	score_list.text = " Score: " + str(score).pad_zeros(5)

	score_timer.start()

	combo_text.text = " x[b]" + str(combo) + "[/b]"
	combo_text.modulate.a = 1
	added_score_text.text = " +[b]" + str(added_score) + "[/b]"
	added_score_text.modulate.a = 1

func _on_score_ui_timer_timeout() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(combo_text, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(added_score_text, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
