extends Area2D

func _on_body_entered(body):
	if body is Player:
		body.knockback(body.global_position + Vector2(0, 30))
