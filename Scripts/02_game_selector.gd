extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_fruit_catch_pressed() -> void:
	get_tree().change_scene_to_file("res://minigames/fruit-catch/fruitcatch_game.tscn")


func _on_memory_cards_pressed() -> void:
	get_tree().change_scene_to_file("res://minigames/memory/scenes/MemoryGame.tscn")



func _on_snake_pressed() -> void:
	get_tree().change_scene_to_file("res://minigames/snake/snake_game.tscn")



func _on_flappy_bird_pressed() -> void:
	get_tree().change_scene_to_file("res://minigames/flappy-bird/scenes/main.tscn")
