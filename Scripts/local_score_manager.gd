extends Node

signal high_score_changed(game_id: String, high_score: int)

const SAVE_PATH := "user://minigame_scores.cfg"

var high_scores: Dictionary = {}


func _ready() -> void:
	_load_data()


func get_high_score(game_id: String) -> int:
	return maxi(int(high_scores.get(game_id, 0)), 0)


func submit_score(game_id: String, score: int) -> bool:
	var safe_score := maxi(score, 0)
	if safe_score <= get_high_score(game_id):
		return false

	high_scores[game_id] = safe_score
	_save_data()
	high_score_changed.emit(game_id, safe_score)
	return true


func _load_data() -> void:
	high_scores.clear()
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return

	for game_id in config.get_section_keys("high_scores"):
		high_scores[game_id] = maxi(int(config.get_value("high_scores", game_id, 0)), 0)


func _save_data() -> void:
	var config := ConfigFile.new()
	for game_id in high_scores:
		config.set_value("high_scores", str(game_id), int(high_scores[game_id]))

	var error := config.save(SAVE_PATH)
	if error != OK:
		push_error("Failed to save local high scores: %s" % error_string(error))
