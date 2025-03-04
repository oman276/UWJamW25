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

var current_global_state : GLOBAL_GAME_STATE = GLOBAL_GAME_STATE.Default
var current_level_enum : LEVELS = LEVELS.None
var current_level_node : Node2D

func _ready():
	load_level(LEVELS.MainMenu)

func is_live() -> bool:
	return current_global_state == GLOBAL_GAME_STATE.Default

func load_level(level : LEVELS):
	if level == current_level_enum:
		return
	
	if current_level_node:
		remove_child(current_level_node)
		current_level_node.queue_free()
		current_level_node = null  # Ensure reference is cleared

	var scene_str = level_str_dict[level]
	if scene_str != "":
		var scene = load(scene_str)
		current_level_node = scene.instantiate()
		add_child(current_level_node)
