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

var spawns : Array[Node2D] = []

var wave : int = 1
var enemies_remaining : int = 0

var score : int = 0

@onready var score_list: RichTextLabel = $CanvasLayer/ScoreList
@onready var combo_text: RichTextLabel = $CanvasLayer/Combo
@onready var added_score_text: RichTextLabel = $CanvasLayer/AddedScore 
@onready var score_timer: Timer = $ScoreUITimer
@onready var enemy_respawn_timer : Timer = $RespawnTimer


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

var current_center : float
var left_x_bound : float 
var right_x_bound : float 
var chunk_order : Array[int]
@onready var transform_val = 15246 * 3

var enemies_list : Array[Node2D]

var tween_combo_text: Tween
var tween_score_text: Tween

func _ready():

	#instantiate the chunks
	chunk_1_instance = chunk_1.instantiate()
	add_child(chunk_1_instance)
	chunk_1_instance.global_position = Vector2(0, 0)
	var spawn_parent_1 = chunk_1_instance.get_node("Spawnpoints")
	for spawn in spawn_parent_1.get_children():
		if spawn == null:
			print("1 null")
		spawns.append(spawn)

	chunk_2_instance = chunk_2.instantiate()
	add_child(chunk_2_instance)
	chunk_2_instance.global_position = Vector2(0, 0) + left_pos_to_add
	var spawn_parent_2 = chunk_2_instance.get_node("Spawnpoints")
	for spawn in spawn_parent_2.get_children():
		if spawn == null:
			print("2 null")
		spawns.append(spawn)

	chunk_3_instance = chunk_3.instantiate()
	add_child(chunk_3_instance)
	chunk_3_instance.global_position = Vector2(0, 0) + right_pos_to_add
	var spawn_parent_3 = chunk_3_instance.get_node("Spawnpoints")
	for spawn in spawn_parent_3.get_children():
		if spawn == null:
			print("3 null")
		spawns.append(spawn)

	current_center = 0
	left_x_bound = -7632 - 10
	right_x_bound = 7623 + 10
	chunk_order = [2, 1, 3]

	wave = 1
	spawn_new_wave(1)

	score_list.text = " Score: " + str(score).pad_zeros(5)
	combo_text.modulate.a = 0
	added_score_text.modulate.a = 0

func spawn_new_wave(num : int):
	enemies_list.clear()

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
		
		enemies_list.append(enemy_ins)

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
	#pop_animation(combo_text)
	#pop_animation(added_score_text)

	GameManager.set_score(score)

func _on_score_ui_timer_timeout() -> void:
	combo_text.modulate.a = 0
	added_score_text.modulate.a = 0
	#tween_text.tween_property(combo_text, "modulate:a", Vector2(1, 1), 0.07)

func _process(delta):
	if player.global_position.x < left_x_bound:
		# Moving right object to the left

		print("left transform!")
		var chunk_to_move_num : int = chunk_order[2]
		chunk_order[2] = chunk_order[1]
		chunk_order[1] = chunk_order[0]
		chunk_order[0] = chunk_to_move_num
		
		var transform_boundaries = current_center + 7632

		current_center -= 15246
		left_x_bound -= 15246
		right_x_bound -= 15246
		
		var chunk_to_move : MapChunk
		match chunk_to_move_num:
			1:
				chunk_to_move = chunk_1_instance
			2:
				chunk_to_move = chunk_2_instance
			3:
				chunk_to_move = chunk_3_instance
			_:
				print("ERROR: Somehow trying to move something other than chunk 1, 2, 3")
		
		chunk_to_move.global_position.x -= transform_val
		for enemy in enemies_list:
			if enemy != null and enemy.global_position.x > transform_boundaries:
				enemy.global_position.x -= transform_val
	
	elif player.global_position.x > right_x_bound:
		# Moving left object to the right

		print("right transform!")
		var chunk_to_move_num : int = chunk_order[0]
		chunk_order[0] = chunk_order[1]
		chunk_order[1] = chunk_order[2]
		chunk_order[2] = chunk_to_move_num

		var transform_boundaries = current_center - 7632
		
		current_center += 15246
		left_x_bound += 15246
		right_x_bound += 15246
		
		var chunk_to_move : MapChunk
		match chunk_to_move_num:
			1:
				chunk_to_move = chunk_1_instance
			2:
				chunk_to_move = chunk_2_instance
			3:
				chunk_to_move = chunk_3_instance
			_:
				print("ERROR: Somehow trying to move something other than chunk 1, 2, 3")
		
		chunk_to_move.global_position.x += transform_val
		for enemy in enemies_list:
			if enemy != null and enemy.global_position.x < transform_boundaries:
				enemy.global_position.x += transform_val


# func pop_animation(target_node: RichTextLabel):
# 	if tween_text:
# 		tween_text.kill()

# 	tween_text = get_tree().create_tween()
# 	tween_text.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# 	tween_text.tween_property(target_node, "scale", Vector2(1.2, 1.2), 0.1)
# 	tween_text.tween_property(target_node, "scale", Vector2(0.95, 0.95), 0.08)
# 	tween_text.tween_property(target_node, "scale", Vector2(1, 1), 0.07)

# func reset_scale(target_node: Node2D):
# 	if tween_text:
# 		tween_text.kill()
# 	target_node.scale = Vector2(1, 1)
