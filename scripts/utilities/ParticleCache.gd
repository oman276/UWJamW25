extends CanvasLayer

var fire_particles = preload("res://scenes/mats/fire.tres")
var ice_particles = preload("res://scenes/mats/ice.tres")

var materials = [fire_particles, ice_particles]

func _ready() -> void:
	for material in materials:
		#var ins = Particles2D.new()
		pass

  