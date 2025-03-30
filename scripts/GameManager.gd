extends Node2D

enum GLOBAL_GAME_STATE {
	Default,
	Paused,
	TempFreeze,
}

enum LEVELS{
	None,
	MainMenu,
	Game,
	PostGame,
  Credits
}

enum THEMES{
	None,
	Title,
	Action,
}

var level_str_dict : Dictionary = {
	LEVELS.None : ["", THEMES.Title],
	LEVELS.Credits : ["res://scenes/levels/credits.tscn", THEMES.Title],
	LEVELS.MainMenu : ["res://scenes/levels/title.tscn", THEMES.Title],
	LEVELS.Game : ["res://scenes/levels/main_scene.tscn", THEMES.Action],
	LEVELS.PostGame : ["res://scenes/levels/game_over.tscn", THEMES.Title],
}

var current_theme : THEMES = THEMES.None
@onready var music_player := AudioStreamPlayer.new()

var loading_canvas : CanvasLayer
var loading_canvas_path : String = "res://scenes/ui/fade_canvas.tscn"

var current_global_state : GLOBAL_GAME_STATE = GLOBAL_GAME_STATE.Default
var current_level_enum : LEVELS = LEVELS.None
var current_level_node : Node2D

# Score variables
var current_score : int = 0
var high_score : int = 0
var new_best : bool = false

func _ready():
	var temp = load(loading_canvas_path)
	loading_canvas = temp.instantiate()
	add_child(loading_canvas)
	add_child(music_player)  

	load_level(LEVELS.Credits)

func is_live() -> bool:
	return current_global_state == GLOBAL_GAME_STATE.Default

func load_level(level : LEVELS):
	if level == current_level_enum:
		return
	
	loading_canvas.fade_in()
	await get_tree().create_timer(0.75).timeout

	if current_level_node:
		remove_child(current_level_node)
		current_level_node.queue_free()
		current_level_node = null 

	var scene_str = level_str_dict[level][0]
	if scene_str != "":
		var scene = load(scene_str)
		current_level_node = scene.instantiate()
		add_child(current_level_node)

	loading_canvas.fade_out()
	play_music(level_str_dict[level][1])

func play_music(track : THEMES):
	if track != current_theme:
		current_theme = track
		music_player.stop()
		match track:
			THEMES.Action:
				music_player.stream = preload("res://assets/music/action_theme.mp3")
			THEMES.Title:
				music_player.stream = preload("res://assets/music/title_theme.mp3")
		music_player.volume_db = -10  
		music_player.autoplay = true 
		music_player.play()

func set_score(score : int):
	current_score = score
	if current_score > high_score:
		high_score = current_score
		new_best = true

func reset_score():
	current_score = 0
	new_best = false

