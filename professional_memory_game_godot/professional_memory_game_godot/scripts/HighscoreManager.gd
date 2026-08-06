extends RefCounted

const SAVE_PATH := "user://memory_highscores.cfg"
const DIFFICULTY_NAMES := ["Easy", "Medium", "Hard"]

var records: Dictionary = {}

func _init() -> void:
	load_records()

func load_records() -> void:
	records.clear()
	var config: ConfigFile = ConfigFile.new()
	config.load(SAVE_PATH)
	for difficulty in DIFFICULTY_NAMES:
		records[difficulty] = {
			"score": int(config.get_value(difficulty, "score", 0)),
			"time": float(config.get_value(difficulty, "time", 0.0))
		}

func get_record(difficulty: String) -> Dictionary:
	if not records.has(difficulty):
		return {"score": 0, "time": 0.0}
	return records[difficulty]

func submit_result(difficulty: String, score: int, elapsed_time: float) -> Dictionary:
	var record: Dictionary = get_record(difficulty).duplicate(true)
	var new_high_score: bool = score > int(record["score"])
	var stored_time: float = float(record["time"])
	var new_best_time: bool = stored_time <= 0.0 or elapsed_time < stored_time

	if new_high_score:
		record["score"] = score
	if new_best_time:
		record["time"] = elapsed_time
	records[difficulty] = record
	_save_records()

	return {
		"new_high_score": new_high_score,
		"new_best_time": new_best_time
	}

func reset_all() -> void:
	for difficulty in DIFFICULTY_NAMES:
		records[difficulty] = {"score": 0, "time": 0.0}
	_save_records()

func _save_records() -> void:
	var config: ConfigFile = ConfigFile.new()
	for difficulty in DIFFICULTY_NAMES:
		var record: Dictionary = get_record(difficulty)
		config.set_value(difficulty, "score", int(record["score"]))
		config.set_value(difficulty, "time", float(record["time"]))
	config.save(SAVE_PATH)
