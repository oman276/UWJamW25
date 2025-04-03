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

var wave : int = 1
var enemies_remaining : int = 0

var score : int = 0

@onready var score_list: RichTextLabel = $CanvasLayer/ScoreList
@onready var combo_text: RichTextLabel = $CanvasLayer/Combo
@onready var added_score_text: RichTextLabel = $CanvasLayer/AddedScore 
@onready var score_timer: Timer = $ScoreUITimer
@onready var enemy_respawn_timer : Timer = $RespawnTimer

# Level Looping
#TODO: Spawnpoints must be selected between all 3 available chunks of zone
#TODO: Change camera boundaries to depend on the size of the available playspace

# background set at (0, 0) compared to the node
# x-position seems to be +-15246 (yeah, I think this works fine?) (bounds of each section is center +- 7623)

var left_pos_to_add : Vector2 = Vector2(-15246, 0)
var right_pos_to_add : Vector2 = Vector2(15246, 0)

var top_y_pos : float = -6000

@export var chunk_1 : PackedScene
@export var chunk_2 : PackedScene
@export var chunk_3 : PackedScene

var chunk_1_instance : MapChunk
var chunk_2_instance : MapChunk
var chunk_3_instance : MapChunk

#May delete later
@onready var chunk_1_path : String = "res://scenes/chunks/map_chunk_1.tscn"
@onready var chunk_2_path : String = "res://scenes/chunks/map_chunk_2.tscn"
@onready var chunk_3_path : String = "res://scenes/chunks/map_chunk_3.tscn"

var bottom_left : Vector2 # min x, max y
var top_right : Vector2 # max x, min y

func _ready():

	#instantiate the chunks
	chunk_1_instance = chunk_1.instantiate()
	add_child(chunk_1_instance)
	chunk_1_instance.global_position = Vector2(0, 0)
	var spawn_parent_1 = chunk_1_instance.get_node("Spawnpoints")
	for spawn in spawn_parent_1.get_children():
		spawns.append(spawn)

	chunk_2_instance = chunk_2.instantiate()
	add_child(chunk_2_instance)
	chunk_2_instance.global_position = Vector2(0, 0) + left_pos_to_add
	var spawn_parent_2 = chunk_2_instance.get_node("Spawnpoints")
	for spawn in spawn_parent_2.get_children():
		spawns.append(spawn)

	chunk_3_instance = chunk_3.instantiate()
	add_child(chunk_3_instance)
	chunk_3_instance.global_position = Vector2(0, 0) + right_pos_to_add
	var spawn_parent_3 = chunk_3_instance.get_node("Spawnpoints")
	for spawn in spawn_parent_3.get_children():
		spawns.append(spawn)

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
		var spawn_loc = randi_range(0, spawns.size() - 1)
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
		
		enemy_respawn_timer.start(1)
		await enemy_respawn_timer.timeout

func enemy_died():
	enemies_remaining -= 1
	if enemies_remaining == 0:
		wave += 1
		utils.wave = wave
		spawn_new_wave(wave)

func _on_timer_timeout():
	new_wave_.text = ""

func add_score(combo : int):
	var added_score = 100 * combo *2
	score += added_score
	score_list.text = " Score: " + str(score).pad_zeros(5)

	score_timer.start()

	combo_text.text = " x[b]" + str(combo) + "[/b]"
	combo_text.modulate.a = 1
	added_score_text.text = " +[b]" + str(added_score) + "[/b]"
	added_score_text.modulate.a = 1

	GameManager.set_score(score)

func _on_score_ui_timer_timeout() -> void:
	combo_text.modulate.a = 0
	added_score_text.modulate.a = 0
