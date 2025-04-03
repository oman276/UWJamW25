class_name MapChunk

extends Node2D

var spawns : Array[Node2D] = []
@export var _spawns : Array[Node2D] = []

func _ready():
  _spawns = spawns