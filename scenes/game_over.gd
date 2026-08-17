extends CanvasLayer

signal restart
signal back


func set_scores(score: int, high_score: int) -> void:
	$ScorePanel/ScoreValue.text = str(score)
	$ScorePanel/HighScoreValue.text = str(high_score)


func _on_restart_pressed() -> void:
	restart.emit()


func _on_back_to_main_pressed() -> void:
	back.emit()
