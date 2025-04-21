extends Node2D
@onready var particles = $Particles
@onready var timer = $Timer

func start_effect():
	print("Particles Started")
	particles = $Particles
	timer = $Timer

	particles.emitting = true
	timer.start()

func _on_timer_timeout():
	queue_free()
