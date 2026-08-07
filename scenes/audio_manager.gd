extends Node

var swoosh_player: AudioStreamPlayer
var music_player: AudioStreamPlayer


func _ready():
	# Swoosh
	swoosh_player = AudioStreamPlayer.new()
	swoosh_player.stream = preload("res://assets/audio/swoosh.ogg")
	add_child(swoosh_player)

	# Background music
	music_player = AudioStreamPlayer.new()
	music_player.stream = preload("res://assets/audio/bg_music.mp3")
	music_player.volume_db = -15
	add_child(music_player)

	music_player.play()


func play_swoosh():
	swoosh_player.play()
