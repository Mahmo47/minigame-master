extends Node

const SAVE_PATH := "user://high_score.cfg"
const LOCAL_PLAYER_NAME := "Player"

var high_score: int = 0
var player_uid: String = ""


func _ready() -> void:
	_load_data()
	if player_uid.is_empty():
		player_uid = Crypto.new().generate_random_bytes(16).hex_encode()
		_save_data()


func submit_score(score: int) -> bool:
	if score <= high_score:
		return false

	high_score = score
	_save_data()
	return true


func get_leaderboard_entries() -> Array[Dictionary]:
	return [
		{
			"uid": player_uid,
			"nickname": LOCAL_PLAYER_NAME,
			"score": high_score,
		}
	]


func get_display_name(entry_uid: String, nickname: String) -> String:
	if entry_uid == player_uid:
		return "YOU"
	return nickname


func _load_data() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return

	high_score = maxi(int(config.get_value("score", "high_score", 0)), 0)
	player_uid = str(config.get_value("player", "uid", ""))


func _save_data() -> void:
	var config := ConfigFile.new()
	config.set_value("score", "high_score", high_score)
	config.set_value("player", "uid", player_uid)
	var error := config.save(SAVE_PATH)
	if error != OK:
		push_error("Failed to save high score: %s" % error_string(error))
