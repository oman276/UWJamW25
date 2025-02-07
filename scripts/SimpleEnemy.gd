extends CharacterBody2D

@export var speed := 100.0
@export var target: NodePath

func _physics_process(delta: float) -> void:
	var player = get_node_or_null(target)
	if player == null:
		return  
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()


func _on_trigger_area_entered(area):
	print("player contact")
	pass # Replace with function body.


func _on_trigger_body_entered(body):
	print("player body contact")
	pass # Replace with function body.
