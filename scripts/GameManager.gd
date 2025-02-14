extends Node2D

enum GLOBAL_GAME_STATE {
	Default,
	Paused,
	TempFreeze,
}

var current_global_state : GLOBAL_GAME_STATE = GLOBAL_GAME_STATE.Default

func is_live() -> bool:
	return current_global_state == GLOBAL_GAME_STATE.Default
