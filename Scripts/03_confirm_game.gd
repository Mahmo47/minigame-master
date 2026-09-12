extends Control

func closed_gameinfo():
	get_tree().paused = false

func opened_gameinfo():
	get_tree().paused = true
