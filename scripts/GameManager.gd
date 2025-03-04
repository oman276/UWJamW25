extends Node2D

enum GLOBAL_GAME_STATE {
	Default,
	Paused,
	TempFreeze,
}

enum LEVELS{
	MainMenu,
	Game,
	PostGame
}

var current_global_state : GLOBAL_GAME_STATE = GLOBAL_GAME_STATE.Default
var current_level : LEVELS = LEVELS.MainMenu

func is_live() -> bool:
	return current_global_state == GLOBAL_GAME_STATE.Default

func load_level(level : LEVELS):
	if level == current_level:
		return
	
	
	pass
