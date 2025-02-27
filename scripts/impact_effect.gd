extends Node2D
@onready var particles = $Particles

func start_effect():
	particles.emitting = true
