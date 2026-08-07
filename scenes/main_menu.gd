extends Control


func _on_new_game_pressed():
	AudioManager.play_swoosh()
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_leaderboard_pressed():
	AudioManager.play_swoosh()
	pass
