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
	PostGame
}

var level_str_dict : Dictionary[LEVELS, String] = {
	LEVELS.None : "",
	LEVELS.MainMenu : "res://scenes/levels/title.tscn",
	LEVELS.Game : "res://scenes/levels/main_scene.tscn",
	LEVELS.PostGame : "res://scenes/levels/game_over.tscn",
}

var loading_canvas : CanvasLayer
var loading_canvas_path : String = "res://scenes/ui/fade_canvas.tscn"

var current_global_state : GLOBAL_GAME_STATE = GLOBAL_GAME_STATE.Default
var current_level_enum : LEVELS = LEVELS.None
var current_level_node : Node2D

func _ready():
	var temp = load(loading_canvas_path)
	loading_canvas = temp.instantiate()
	add_child(loading_canvas)

	load_level(LEVELS.MainMenu)

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

	var scene_str = level_str_dict[level]
	if scene_str != "":
		var scene = load(scene_str)
		current_level_node = scene.instantiate()
		add_child(current_level_node)

	loading_canvas.fade_out()
