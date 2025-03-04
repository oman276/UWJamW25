extends Node2D

@export var speed: float = 20.0
var velocity: Vector2 = Vector2.ZERO 

func _process(delta):
	if GameManager.current_global_state == GameManager.GLOBAL_GAME_STATE.Default:
		global_translate(velocity * speed * delta) 

func _on_area_2d_body_entered(body):
	if body is WOIPlayer and body.current_damage_state != WOIPlayer.PLAYER_DAMAGE_STATE.Slashing:
			body.knockback(global_position)
	queue_free()
