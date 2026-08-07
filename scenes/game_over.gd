extends CanvasLayer

signal restart
signal back


func _on_restart_pressed() -> void:
	restart.emit()


func _on_back_to_main_pressed() -> void:
	back.emit()
