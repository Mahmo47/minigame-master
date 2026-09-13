extends Control


func _on_new_game_pressed():
	AudioManager.play_swoosh()
	get_tree().change_scene_to_file("res://minigames/flappy-bird/scenes/bird.tscn")


func _on_leaderboard_pressed():
	AudioManager.play_swoosh()
	get_tree().change_scene_to_file("res://minigames/flappy-bird/scenes/leaderboard.tscn")
