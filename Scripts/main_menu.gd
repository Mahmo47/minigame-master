extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_btn_settings_pressed() -> void:
	print("settings pressed")

func _on_btn_start_pressed() -> void:
	print("start pressed")
	get_tree().change_scene_to_file("res://Scenes/game selector.tscn")

func _on_btn_exit_pressed() -> void:
	print("exit pressed")
