extends Node

#@onready var music_player := AudioStreamPlayer.new()

func _ready():
	# add_child(music_player)  # Add the player as a child of the autoload
	#music_player.stream = preload("res://bensound-timeflies.mp3")  # Set your music file
	#music_player.volume_db = -10  # Adjust volume if needed
	#music_player.autoplay = true  # Start playing automatically
	#music_player.loop = true  # Make it loop
	pass

func play_music(stream: AudioStream):
	#if music_player.stream != stream:
	#	music_player.stream = stream
		#music_player.play()
	pass

func stop_music():
	#music_player.stop()
	pass
